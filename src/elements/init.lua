-- dialog_redo/src/elements/init.lua
-- Default elements
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

---@type { [string]: fun(params: table): DialogNode }
dialog_redo.elements = {}

local scripts = {
    "simple",
    "textbox",
    "choices",
    "func",
}
local BASE = minetest.get_modpath("dialog_redo") .. DIR_DELIM .. "src" .. DIR_DELIM .. "elements" .. DIR_DELIM

for _, name in ipairs(scripts) do
    dofile(BASE .. name .. ".lua")
end