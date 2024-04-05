-- dialog_redo/src/elements/simple.lua
-- The most simple example.
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

dialog_redo.register_dialog_tree("dialog_redo:example_simple", {
    init = dialog_redo.elements.simple({
        name = "Syetem 1",
        text = "Testing Btn text",
        btn_text = "Btn text 1",
        next = "step2"
    }),
    step2 = dialog_redo.elements.simple({
        name = "Syetem 2",
        text = "Testing no Btn text",
        next = "step3"
    }),
    step3 = dialog_redo.elements.simple({
        name = "Syetem 3",
        text = "Testing quit",
        next = ""
    }),
})

minetest.register_chatcommand("dialog_redo_example_simple", {
    privs = {server = true},
    func = function(name)
        dialog_redo.start_dialog(name, "dialog_redo:example_simple")
        return true
    end
})