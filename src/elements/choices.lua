-- dialog_redo/src/elements/choices.lua
-- Multiple (up to 4) choices
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

local S = minetest.get_translator("dialog_redo")
local F = minetest.formspec_escape

---@class DialogChoicesButtons: table
---@field text? string Display text of the button. default: `"Option <id>"`
---@field next? string The ID of the next dialog, if this button is pressed. Empty or `nil` to terminate the dialog here.

---@class DialogChoicesOptions: table
---@field avatar? string Image to the avatar of the speaker
---@field name string The display name of the speaker
---@field text string The text to be diaplayed
---@field buttons DialogChoicesOptions[]|fun(session: DialogSession): DialogChoicesOptions[] Table of buttons, of a function returning it.

---Build the formspec of buttons.
---This aligns buttoms to the bottom if `#buttons <= 4`,
---and use a scrollable container if `#buttons > 4`.
---@param buttons DialogChoicesButtons[]
---@return string buttons_formspec
local function build_buttons(buttons)
    local num_options = #buttons
    if num_options <= 4 then
        local y = 3.5 + (4 - num_options)
        local buttons_formspec = ""
        for o = 1, num_options do
            local text = buttons[o].text or S("Option @1", o)
            buttons_formspec = buttons_formspec .. "button[0.5,"..y..";11,0.7;dialog_"..o..";"..F(text).."]"
            y = y + 1
        end
        return buttons_formspec
    end

    -- num_options > 4
    local buttons_formspec = "scrollbaroptions[min=1;max=" .. (num_options - 3) .. ";smallstep=1;largestep=2]" ..
        "scrollbar[11,3.5;0.5,3.7;vertical;scb;0]" ..
        "scroll_container[0.5,3.5;10.5,4;scb;vertical;1]"
    local y = 1

    for o = 1, num_options do
        local text = buttons[o].text or S("Option @1", o)
        buttons_formspec = buttons_formspec .. "button[0,"..y..";10.5,0.7;dialog_"..o..";"..F(text).."]"
        y = y + 1
    end

    buttons_formspec = buttons_formspec .. "scroll_container_end[]"
    return buttons_formspec
end

---Diaply a list of buttons
---@param params DialogChoicesOptions
---@return DialogNode
dialog_redo.elements.choices = function(params)
    return {
        show = function(session)
            session.choices_buttons = params.buttons
            if type(session.choices_buttons) == "function" then
                session.choices_buttons = session.choices_buttons(session)
                if type(session.choices_buttons) ~= "table" then
                    session:error("Invalid list of buttons")
                end
            end

            return "formspec_version[6]" ..
                "size[12,7.75]" ..
                "position[0.5,0.95]" ..
                "anchor[0.5,1]" ..
                "box[0,0;3,3;#00FF004F]" ..
                "box[3,0;9,3;#00FF002F]" ..
                (params.avatar and ("image[0.5,0.5;2,2;" .. params.avatar .."]") or "") ..
                "label[0.5,2.75;".. F(params.name) .."]" ..
		        "textarea[3.5,0.5;8,2;;;".. F(params.text) .."]" ..
                build_buttons(session.choices_buttons)
        end,
        callback = function(session, fields)
            local choices = session.choices_buttons
            local curr_choice
            for o = 1, #choices do
                if fields["dialog_" .. o] then
                    curr_choice = choices[o]
                    break
                end
            end
            if not curr_choice then
                return "self"
            end
            local next = curr_choice.next
            if type(next) == "function" then
                next = next(session)
                if type(next) ~= "string" then
                    session:error("Attempt to go to non-string id")
                end
            end
            return next
        end
    }
end