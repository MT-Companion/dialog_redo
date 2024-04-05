-- dialog_redo/src/elements/choices.lua
-- Branching conversation
--[[
    Copyright (C) 2023  1F616EMO

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

dialog_redo.register_dialog_tree("dialog_redo:example_choices", {
    init = dialog_redo.elements.choices({
        name = "Syetem 1",
        text = "Testing Choices text",
        buttons = function()
            return {
                {
                    text = tostring(os.time()),
                    next = "yaw",
                },
                {
                    text = "Hello World!",
                    next = "hello"
                },
                {
                    text = "Cute 1F616EMO",
                    next = function() return "yep" end
                },
                {
                    text = "Cute 1F616EMO",
                    next = function() return "yep" end
                },
                {
                    text = "Cute 1F616EMO",
                    next = function() return "yep" end
                },
                {
                    text = "Cute 1F616EMO",
                    next = function() return "yep" end
                },
                {
                    text = "Bottom",
                    next = function() return "yep" end
                }
            }
        end,
    }),
    yaw = dialog_redo.elements.func(function(session)
        local name = session.player_name
        local player = minetest.get_player_by_name(name)

        player:set_look_horizontal(0)

        return "leave"
    end),
    hello = dialog_redo.elements.simple({
        name = "Syetem 1",
        text = "Hello, World!",
        next = "leave"
    }),
    yep = dialog_redo.elements.simple({
        name = "Syetem 1",
        text = "nya!",
        next = "leave"
    }),
    leave = dialog_redo.elements.choices({
        name = "Syetem 1",
        text = "Do you want to leave?",
        buttons = {
            {
                text = "No, send me back",
                next = "init", -- Yep, we can do a infinite loop
            },
            {
                text = "Yes",
                next = ""
            }
        }
    })
})

minetest.register_chatcommand("dialog_redo_example_choices", {
    privs = {server = true},
    func = function(name)
        dialog_redo.start_dialog(name, "dialog_redo:example_choices")
        return true
    end
})