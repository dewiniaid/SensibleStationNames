require "scoring"

local backer_set = nil

function on_init()
    global.players_debugging = {}
    global.count_debugging = 0  -- Can't rely on #
end

function on_load()
    if global.count_debugging then
        start_debugging()
    end
end

script.on_init(on_init)
script.on_load(on_load)


function start_debugging()
    script.on_event(defines.events.on_player_changed_position, on_player_changed_position)
    script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
        if event.setting == 'SensibleStationNames_allow-debug' then
            return validate_debuggers()
        end
    end)
end

function stop_debugging()
    script.on_event(defines.events.on_player_changed_position, nil)
    script.on_event(defines.events.on_runtime_mod_setting_changed, nil)
end

function validate_debuggers()
    for player_index, debugging in pairs(global.players_debugging) do
        if debugging and not player_can_debug(player_index) then
            toggle_debug(player_index, false)
        end
    end
end

function player_can_debug(player_index)
    local setting = settings.global['SensibleStationNames_allow-debug'].value
    if setting == 'nobody' then
        return false
    elseif setting == 'everybody' then
        return true
    else
        local player = game.players[player_index]
        return (player and player.permission_group and player.permission_group.allows_action(defines.server_command))
    end
end

function toggle_debug(player_index, new_value)
    local debugging = (global.players_debugging[player_index] or false)
    local value = new_value
    if value == nil then
        value = not debugging
    end
    if value == debugging then
        -- noop
        return
    end
    if value and not player_can_debug(player_index) then
        -- not allowed
        return
    end

    -- If we're still here: value is true if we're transitioning from debug off to debug on, or false if opposite.
    if value then
        global.count_debugging = global.count_debugging + 1
        if global.count_debugging == 1 then
            start_debugging()
        end
    else
        global.count_debugging = global.count_debugging - 1
        if global.count_debugging == 0 then
            stop_debugging()
        end
    end

    global.players_debugging[player_index] = value
    local top = game.players[player_index].gui.top
    local ctl = top.SensibleStationNameDisplay

    if not value then
        if ctl then
            ctl.destroy()  -- og smash!
        end
        return
    end

    if not ctl then
        top.add {
            type = "label",
            name = "SensibleStationNameDisplay",
            style = "bold_label",
            caption = "FIXME: Actually show something useful."
        }
        update_debug(player_index)
        return
    end
end


script.on_event("SensibleStationNames_toggle-debug", function(event)
    toggle_debug(event.player_index)
end)


function is_valid_entity(entity)
    return entity.valid and entity.type == 'train-stop' and entity.supports_backer_name()
end

function is_default_name(entity)
    if not entity.supports_backer_name() then
        return false
    end
    if not backer_set then  -- Lazy initialize
        backer_set = {}
        for _, v in pairs(game.backer_names) do
            backer_set[v] = true
        end
    end
    return backer_set[entity.backer_name] or false
end

function on_created_entity(event)
    local entity = event.created_entity
    if not is_valid_entity(entity) then
        return
    end
    if not is_default_name(entity) then
        return
    end
    assign_moniker(entity)
end


script.on_event(defines.events.on_built_entity, on_created_entity)
script.on_event(defines.events.on_robot_built_entity, on_created_entity)

function assign_moniker(entity)
    local template, score = name_for_area(entity.force, entity.surface, entity.position)
    if template then
        entity.backer_name = string.format(template, entity.backer_name)
    end
end


function position_to_chunk(position)
    return {math.floor(position.x / 32), math.floor(position.y / 32)}
end

function chunk_to_area(chunk)
    local x = chunk[1]*32
    local y = chunk[2]*32
    return {{x, y}, {x+31, y+31} }
end

function expanding_chunks(origin, max_radius)
    -- Yields ({x, y}, radius) pairs searching outward from the origin chunk.  The first yielded result will always be
    -- origin.
    local x, y = unpack(origin)
    local first = true
    local seq = 0

    local radius = 0
    local dx = 0
    local dy = 0

    local position = {x, y}  -- Avoid flooding the gc with a table for every result.
    local area = {{x*32, y*32}, {(x*32)+31, (y*32)+31}}  -- FIXME: What about fractional positions on chunk edges?

    local function iterator()
        if first then
            first = false
            return origin, area, 0
        end
        -- Step forward
        -- WTB coroutines so this could just be a few simple for loops.
        if dx >= radius then
            if dy >= radius then
                if max_radius and radius >= max_radius then
                    return nil
                end
                -- Expand radius
                radius = radius + 1
                -- Reset to upper-left corner.
                dx = -radius
                dy = -radius
            else
                -- Reset to left of next row.
                dy = dy + 1
                dx = -radius
            end
        elseif dy == -radius or dy == radius then
            -- In first or last row, so simple increment dx.
            dx = dx + 1
        else
            dx = radius -- In a middle row, so the last iteration had to be the left.  Do the right.
        end
        position[1] = x+dx
        position[2] = y+dy
        area[1][1] = position[1] * 32
        area[1][2] = position[2] * 32
        area[2][1] = position[1] * 32 + 31
        area[2][2] = position[2] * 32 + 31
        return position, area, radius
    end
    return iterator
end



function update_debug(player_index)
    local player = game.players[player_index]
    local top = player.gui.top
    local ctl = top.SensibleStationNameDisplay
    if not ctl then
        return
    end

    local template, score = name_for_area(player.force, player.surface, player.position)

    ctl.caption = string.format(
        "%s  (score: %.4f; origin=(%d, %d); chunk=(%d, %d))",
        string.format(template, "<name>"), score,
        player.position.x, player.position.y,
        unpack(position_to_chunk(player.position))
    )
end

function name_for_area(force, surface, origin)
    local best_score, best_name
    local scores = {}

    local function distance_modifier(entity)
        local dx = entity.position.x - origin.x
        local dy = entity.position.y - origin.y
        return 1/(dx*dx+dy*dy)
    end


    local modifier, prototype, new_score
    local function scan_chunk(chunk, area)
        if not (surface.is_chunk_generated(chunk) and force.is_chunk_charted(surface, chunk)) then
            return
        end
        for categories, entities in pairs({
            [RESOURCE_CATEGORIES] = surface.find_entities_filtered{area=area, type="resource"},
            [ENTITY_CATEGORIES] = surface.find_entities_filtered{area=area, force=force }
        }) do
            for _, entity in pairs(entities) do
                prototype = entity.prototype    -- Avoid repeated lookups
                if prototype.type == "entity-ghost" then
                    prototype = entity.ghost_prototype
                end
                modifier = nil
                for id, category in pairs(categories) do
                    if category.match(prototype, entity) then
                        modifier = modifier or distance_modifier(entity)
                        new_score = (
                            (scores[id] or 0)
                            + ((category.score and category.score(modifier)) or modifier)*(category.weight or 1)
                        )
                        scores[id] = new_score
                        if not best_score or new_score > best_score then
                            best_score = new_score
                            best_name = category.name
                        end
                    end
                end
            end
        end
    end

    local last_radius = nil

    -- Iterate over chunks looking for something interesting
    for chunk, area, radius in expanding_chunks(position_to_chunk(origin), settings.global['SensibleStationNames_search-radius'].value) do
        if last_radius and last_radius ~= radius and best_score then
            return best_name, best_score
        end
        last_radius = radius
        if surface.is_chunk_generated(chunk) and force.is_chunk_charted(surface, chunk) then
            scan_chunk(chunk, area)
        end
    end

    if not best_score then
        return "%s", 0
    end
    return best_name, best_score
end

function on_player_changed_position(event)
    if global.players_debugging[event.player_index] then
        update_debug(event.player_index)
    end
end



