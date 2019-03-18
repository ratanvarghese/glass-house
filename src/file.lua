local serpent = require("serpent")

local base = require("src.base")

local file = {}

function file.load()
	local f, err = io.open(base.savefile, "r")
	if not f then
		return nil
	end

	local s = f:read("*a")
	f:close()
	local dumpfunc, err = loadstring(s)
	assert(dumpfunc, "Error reading savefile "..base.savefile..":\n"..(err and err or ""))
	return dumpfunc()
end

function file.save(lvl)
	local f, ferr = io.open(base.savefile, "w")
	assert(f, ferr)
	f:write(serpent.dump(lvl))
	f:close()
end

function file.remove_save()
	os.remove(base.savefile)
end

return file
