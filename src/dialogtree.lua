-- dialog_redo/src/dialogtree.lua
-- Register and handle dialogtrees
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

--[[
    Format of a dialog node:
    {
        show = function(session) end,
        -- returns a formspec string
        callback = function(session, fields) end,
        -- returns:
        --- "self": go back to itself
        --- id (string): go to that dialog
        --- nil or empty string: terminate the dialog
        --- other: error
    }
]]

---@alias DialogTree { [string]: DialogNode }

---@class DialogNode: table
---@field show? fun(session: DialogSession): string If `nil`, `callback` will be called immediately with empty `fields`
---@field callback fun(session: DialogSession, fields: { string: any }): string?

---@type { [string]: DialogTree }
---@see dialog_redo.register_dialog_tree
dialog_redo.registered_dialog_trees = {}

---Register a named dialog tree
---@param name string
---@param def DialogTree
function dialog_redo.register_dialog_tree(name, def)
    dialog_redo.registered_dialog_trees[name] = def
end

---Handle showing a DialogNode
---@param session DialogSession
---@param node DialogNode
function dialog_redo.show_node(session, node)
    if not node.show then
        dialog_redo.handle_callback(session, {})
        return
    end

    local rtn_formspec = node.show(session)
    if type(rtn_formspec) ~= "string" then
        session:proper_terminate()
        error("Attempt to display non-string formspec")
    end
    session:show_formspec(rtn_formspec)
end

---Start a dialog for the player
---@param player_name string
---@param dialog string|DialogTree If `DialogTree`, show that dialog; otherwise, find the given registered dialog.
---@param custom_session table Custom session fields
function dialog_redo.start_dialog(player_name, dialog, custom_session)
    if type(dialog) == "string" then
        local dialog_name = dialog
        dialog = dialog_redo.registered_dialog_trees[dialog]
        if dialog == nil then
            error("Attempt to use invalid dialog " .. dialog_name)
        end
    end
    if dialog["init"] == nil then
        error("Invalid dialog tree " .. dialog .. "without `init` node")
    end
    local session = dialog_redo.create_new_session(player_name, custom_session)
    session.dialog_tree = dialog
    session.current_id = "init"

    dialog_redo.show_node(session, dialog["init"])
end

---Handle callback of a currently ongoing sessions
---@param session DialogSession
---@param fields { [string]: any }
function dialog_redo.handle_callback(session, fields)
    local dialog = session.dialog_tree
    local current_id = session.current_id
    local callback_rtn = dialog[current_id].callback(session, fields)
    if callback_rtn == nil or callback_rtn == "" then
        -- Quit the dialog
        -- elements wanting to respect fields.quit
        -- must check themselves
        session:proper_terminate()
    elseif type(callback_rtn) == "string" then
        if callback_rtn == "self" then
            callback_rtn = current_id
        end
        if not dialog[callback_rtn] then
            session:proper_terminate()
            error("Attempt to display invalid dialog " .. callback_rtn)
        end

        session.current_id = callback_rtn
        dialog_redo.show_node(session, dialog[callback_rtn])
    elseif callback_rtn ~= "keep" then
        session:proper_terminate()
        error("Invalid responce type " .. type(callback_rtn) .. " from dialog callback")
    end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local player_name = player:get_player_name()
    if not dialog_redo.sessions[player_name] then return end
    if not dialog_redo.sessions[player_name].is_valid then return end
    if dialog_redo.sessions[player_name].form_name ~= formname then return end

    minetest.log("action", "[dialog_redo] Received " .. formname)

    local session = dialog_redo.sessions[player_name]
    dialog_redo.handle_callback(session, fields)
end)