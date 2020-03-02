--- Save functions for `platform.unixterm`
-- @module platform.unixterm.save

local serpent = require("lib.serpent")

local save = {}

--- Savefile name
save.name = ".save.glass"

local function can_open_file(filename)
	local f = io.open(filename, "r")
	if f == nil then
		return false
	else
		io.close(f)
		return true
	end
end

--- Load game from a file
-- @treturn table game state
function save.load()
	if not can_open_file(save.name) then
		return nil
	end

	local dumpfunc, err = loadfile(save.name)
	assert(dumpfunc, "Error reading savefile "..save.name..":\n"..(err and err or ""))
	setfenv(dumpfunc, {})
	return dumpfunc()
end

--- Save game to a file
-- @tparam table state game state
function save.save(state)
	local f, ferr = io.open(save.name, "w")
	assert(f, ferr)
	f:write(serpent.dump(state))
	f:close()
end

--- Delete savefile
function save.remove()
	os.remove(save.name)
end

return save
