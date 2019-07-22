local base = require("core.base")
local save = require("platform.unixterm.save")

property "save.load: recover saved table" {
	generators = { tbl() },
	check = function(t)
		local oldname = save.name
		save.name = os.tmpname()

		save.save(t)
		local loaded = save.load()
		os.remove(save.name)
		save.name = oldname
		return base.equals(loaded, t)
	end
}

property "save.save: file exists" {
	generators = { tbl() },
	check = function(t)
		local oldname = save.name
		save.name = os.tmpname()

		save.save(t)
		local res = os.rename(save.name, save.name) and true or false

		os.remove(save.name)
		save.name = oldname
		return res
	end
}

property "save.load: falsy if file doesn't exist" {
	generators = {},
	check = function()
		local oldname = save.name
		save.name = os.tmpname()
		local state = save.load()
		save.name = oldname
		return not state
	end
}

property "save.load: error if file calls function" {
	generators = {},
	check = function()
		local oldname = save.name
		save.name = os.tmpname()
		local f = io.open(save.name, "w")
		f:write("print('Hi')")
		f:close()
		local ok = pcall(save.load)
		save.name = oldname
		return not ok
	end
}

property "save.remove: remove save" {
	generators = { tbl() },
	check = function(t)
		local oldname = save.name
		save.name = os.tmpname()

		save.save(t)
		save.remove()
		local res = os.rename(save.name, save.name) and true or false

		save.name = oldname
		return not res
	end
}

