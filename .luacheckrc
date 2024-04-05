---@diagnostic disable: lowercase-global

globals = {
        "vector",
        math = {
                fields = {
                        "round",
                        "hypot",
                        "sign",
                        "factorial",
                        "ceil",
                }
        },

        "minetest", "core",

        "dialog_redo"
}

read_globals = {
        "DIR_DELIM",
        "dump", "dump2",
        "VoxelManip", "VoxelArea",
        "PseudoRandom", "PcgRandom",
        "ItemStack",
        "Settings",
        "unpack",
        "loadstring",

        table = {
                fields = {
                        "copy",
                        "indexof",
                        "insert_all",
                        "key_value_swap",
                        "shuffle",
                        "random",
                }
        },

        string = {
                fields = {
                        "split",
                        "trim",
                }
        },
}

ignore = {"631"}
