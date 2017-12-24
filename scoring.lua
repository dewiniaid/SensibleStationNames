RESOURCE_CATEGORIES = {
    mines = {
        name = "%s Mines",
        match = function(prototype) return prototype.resource_category == 'basic-solid' and prototype.name ~= 'stone' end,
        weight = 0.01,
    },
    quarry = {
        name = "%s Quarry",
        match = function(prototype) return prototype.name == 'stone' end,
        weight = 0.01,
    },
    wells = {
        name = "%s Wells",
        match = function(prototype) return prototype.resource_category == 'basic-fluid' end,
        weight = 0.1,
    },
}

ENTITY_CATEGORIES = {
    factory = {
        name = "%s Factory",
        match = function(prototype) return prototype.type == 'assembling-machine' and prototype.crafting_categories['crafting'] end,
    },
    refinery = {
        name = "%s Refinery",
        match = function(prototype) return prototype.type == 'assembling-machine' and prototype.crafting_categories['oil-processing'] end,
    },
    plant = {
        name = "%s Chemical Plant",
        match = function(prototype) return prototype.type == 'assembling-machine' and prototype.crafting_categories['chemistry'] end,
    },
    centrifuge = {
        name = "%s Nuclear Processing",
        match = function(prototype) return prototype.type == 'assembling-machine' and prototype.crafting_categories['centrifuging'] end,
    },
    smeltery = {
        name = "%s Foundry",
        match = function(prototype) return prototype.type == 'furnace' and prototype.crafting_categories['smelting'] end,
    },
    power = {
        name = "%s Power Plant",
        match = function(prototype) return prototype.type == 'generator' or prototype.type == 'reactor' end,
    },
}
