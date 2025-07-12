-- dialog_redo/src/sessions.lua
-- Handle sessions
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

---@type { string: DialogSession }
dialog_redo.sessions = {}

---Set a session as the player's session
---@param player_name string
---@param new_session DialogSession
function dialog_redo.set_session(player_name, new_session)
    -- Invalidate the previous session
    if dialog_redo.sessions[player_name] then
        dialog_redo.sessions[player_name].is_valid = false
    end
    -- Replace the session
    new_session.is_valid = true
    dialog_redo.sessions[player_name] = new_session
end

---Delete a session by player name
---@param player_name string
function dialog_redo.delete_session_by_player_name(player_name)
    -- Invalidate the session
    if dialog_redo.sessions[player_name] then
        dialog_redo.sessions[player_name].is_valid = false
    end
    dialog_redo.sessions[player_name] = nil
end

---Delete a session
---@param session DialogSession
function dialog_redo.delete_session(session)
    session.is_valid = false
    for k, t in ipairs(dialog_redo.sessions) do
        if t == session then
            dialog_redo.sessions[k] = nil
            break
        end
    end
end

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    dialog_redo.delete_session_by_player_name(name)
end)

---@class DialogSession: table
---@field dialog_tree DialogTree
---@field current_id string
---@field player_name string
---@field form_name string
local session_indextable = {
    ---Show a formspec with the internal session ID
    ---@param formspec string The formspec to be shown
    show_formspec = function(self, formspec)
        if not self.is_valid then return false end
        minetest.show_formspec(self.player_name, self.form_name, formspec)
        return true
    end,
    ---Properly terminate this formspec and do garbage collection
    proper_terminate = function(self)
        if not self.is_valid then return false end
        minetest.close_formspec(self.player_name, self.form_name)
        dialog_redo.delete_session(self)
    end,
    ---Properly terminate the session, and then raise an error
    ---@param msg string The error message to be raised
    ---@see DialogSession.proper_terminate
    ---@see error
    error = function(self, msg) -- For raising error inside dialog
        if not self.is_valid then return false end
        self:proper_terminate()
        error(msg, 2)
    end
}

---Create a new session for the player
---@param player_name string The name of the player
---@param custom_session table Custom session fields
---@return DialogSession
function dialog_redo.create_new_session(player_name, custom_session)
    local new_session = setmetatable({}, { __index = session_indextable })
    if custom_session then
        for k, v in pairs(custom_session) do
            if not session_indextable[k] then
                new_session[k] = v
            end
        end
    end
    new_session.player_name = player_name
    new_session.form_name = "dialog_redo:session_" .. player_name .. "_" .. tostring(os.time())

    dialog_redo.set_session(player_name, new_session)
    return new_session
end
