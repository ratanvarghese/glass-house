local serpent = require("serpent")

local base = require("base")

local file = {}

function file.load()
	local f, ferr = io.open(base.savefile, "r")
	if not f then
		return nil
	end

	local s = f:read("*a")
	f:close()
	local dumpfunc, err = loadstring(s)
	if not dumpfunc then
		error("Error reading savefile " .. base.savefile .. ": " .. err)
	end

	return dumpfunc()
end

function file.save(lvl)
	local f, ferr = io.open(base.savefile, "w")
	if not f then
		error(ferr)
	end
	f:write(serpent.dump(lvl))
	f:close()
end

return file
