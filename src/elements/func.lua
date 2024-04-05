-- dialog_redo/src/elements/func.lua
-- Execute the given function without other actions
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

---Execute the given function without other actions
---@param func fun(session: DialogSession): string Return the next ID
---@return DialogNode
dialog_redo.elements.func = function(func)
    return {
        callback = function(session) return func(session) end
    }
end
