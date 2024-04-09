-- dialog_redo/src/elements/simple.lua
-- Simple chat box with a single continue button
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

---@class DialogSimpleOptions: table
---@field avatar? string Image to the avatar of the speaker
---@field name string The display name of the speaker
---@field text string|fun(session: DialogSession): string The text to be diaplayed, or a function returning it
---@field btn_text? string The text to be shown on the button. default: `"Submit"`
---@field next? string The ID of the next dialog. Empty or `nil` to terminate the dialog here.
---@field allow_exit? boolean Whether to allow quitting. default: `false`

---Show a simple dialog box
---@param params DialogSimpleOptions
---@return DialogNode
dialog_redo.elements.simple = function(params)
    local button_text = params.btn_text
    if not button_text then
        if params.next == nil or params.next == "" then
            button_text = S("Quit")
        else
            button_text = S("Continue")
        end
    end
    return {
        show = function(session)
            local text = params.text
            if type(text) == "function" then
                text = text(session)
                if type(text) ~= "string" then
                    session:error("Attempt to display non-string text")
                end
            end
            local formspec = "formspec_version[6]" ..
                "size[12,7.75]" ..
                "position[0.5,0.95]" ..
                "anchor[0.5,1]" ..
                "box[0,0;3,3;#00FF004F]" ..
                "box[3,0;9,3;#00FF002F]" ..
                (params.avatar and ("image[0.5,0.5;2,2;" .. params.avatar .."]") or "") ..
                "label[0.5,2.75;".. F(params.name) .."]" ..
		        "textarea[3.5,0.5;8,2;;;".. F(text) .."]" ..
                "set_focus[dialog_continue]" ..
                "button[0.5,6.5;11,0.7;dialog_continue;" .. F(button_text) .. "]"
            if params.allow_exit then
                formspec = formspec ..
                    "image_button[11.5,0.25;0.25,0.25;dialog_redo_close.png;btn_close;;;false;]"
            end
            return formspec
        end,
        callback = function(_, fields)
            if params.allow_exit then
                if fields.quit == "true" or fields.btn_close then
                    return ""
                end
            end
            return params.next
        end
    }
end