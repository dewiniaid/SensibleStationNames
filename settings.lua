data:extend{
    {
        type = "int-setting",
        name = "SensibleStationNames_search-radius",
        setting_type = "runtime-global",
        order = 100,
        default_value = 3,
        minimum_value = 1,
        maximum_value = 15,
    },
    {
        type = "string-setting",
        name = "SensibleStationNames_allow-debug",
        setting_type = "runtime-global",
        order = 100,
        default_value = 'console',
        allowed_values = {'nobody', 'console', 'everybody'},
    }
}
