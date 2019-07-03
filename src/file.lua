local serpent = require("lib.serpent")

local file = {}

file.name = ".save.glass"

local function can_open_file(filename)
	local f = io.open(filename, "r")
	if f == nil then
		return false
	else
		io.close(f)
		return true
	end
end

function file.load()
	if not can_open_file(file.name) then
		return nil
	end

	local dumpfunc, err = loadfile(file.name)
	assert(dumpfunc, "Error reading savefile "..file.name..":\n"..(err and err or ""))
	setfenv(dumpfunc, {})
	return dumpfunc()
end

function file.save(lvl)
	local f, ferr = io.open(file.name, "w")
	assert(f, ferr)
	f:write(serpent.dump(lvl))
	f:close()
end

function file.remove_save()
	os.remove(file.name)
end

return file
