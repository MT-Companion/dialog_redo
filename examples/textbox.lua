-- dialog_redo/src/elements/textbox.lua
-- Testing textboxes.
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

dialog_redo.register_dialog_tree("dialog_redo:example_textbox", {
    init = dialog_redo.elements.textbox({
        name = "Text Field Administrator",
        text = "Please enter your name",
        next = "hi",
        process_text = function(session, text)
            if text == nil then
                return "Text must not be empty"
            elseif text == "error" then
                if minetest.check_player_privs(session.player_name, "server") then
                    session:error("Fed up.")
                end
                return "Invalid privs"
            elseif #text < 2 then
                return "Length of name must be longer than 2"
            end
            session.name = text -- You can store whatever you want in session
        end
    }),
    hi = dialog_redo.elements.simple({
        name = "Syetem 3",
        text = function(session)
            return "Hello, " .. session.name
        end,
        next = ""
    }),
})

minetest.register_chatcommand("dialog_redo_example_textbox", {
    privs = {server = true},
    func = function(name)
        dialog_redo.start_dialog(name, "dialog_redo:example_textbox")
        return true
    end
})