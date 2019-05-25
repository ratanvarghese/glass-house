local serpent = require("serpent")

local file = {}

file.name = ".save.glass"

function file.load()
	local f, err = io.open(file.name, "r")
	if not f then
		return nil
	end

	local s = f:read("*a")
	f:close()
	local dumpfunc, err = loadstring(s)
	assert(dumpfunc, "Error reading savefile "..file.name..":\n"..(err and err or ""))
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
