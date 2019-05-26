local base = require("src.base")
local file = require("src.file")

--[[
local serpent = require("serpent")
local deep_equals = require("lqc.helpers.deep_equals")
local pretty = require("pl.pretty")

--]]

--[[
2019-03-21

property "serpent: equals" fails...

That's simply bizzare. And it gets worse when you look at the printed outputs and find no difference
between the input and output tables. And worse still when you write out the tables yourself and find
no error.

I've been playing around with this for a couple of hours. Frankly, I have no idea what is going on.

property "serpent: equals" {
	generators = { tbl() },
	check = function(t1)
		local t2 = loadstring(serpent.dump(t1))()
		local res = deep_equals(t1, t2)
		if not res and string.len(serpent.dump(t1)) < 80 then
			print("p t1:")
			pretty.dump(t1)
			print("p t2:")
			pretty.dump(t2)
			print("s t1:", serpent.dump(t1))
			print("s t2:", serpent.dump(t2))
		end
		return res
	end
}

property "file.load: recover saved table" {
	generators = { tbl() },
	check = function(t)
		file.save(t)
		return base.equals(file.load(), t)
	end
}
--]]

property "file.save: file exists" {
	generators = { tbl() },
	check = function(t)
		local oldname = file.name
		file.name = os.tmpname()

		file.save(t)
		local res = os.rename(file.name, file.name) and true or false

		os.remove(file.name)
		file.name = oldname
		return res
	end
}

property "file.load: recover simple saved table" {
	generators = { str(), str(), int(), int() },
	check = function(s1, s2, i1, i2)
		local oldname = file.name
		file.name = os.tmpname()

		local in_t = {
			[s1] = {
				[s2] = i2,
				[i2] = s2,
				[s1] = {}
			},
			[i1] = s1
		}
		file.save(in_t)
		local out_t = file.load()

		os.remove(file.name)
		file.name = oldname
		return base.equals(in_t, out_t)
	end
}

property "file.remove_save: remove save" {
	generators = { tbl() },
	check = function(t)
		local oldname = file.name
		file.name = os.tmpname()

		file.save(t)
		file.remove_save()
		local res = os.rename(file.name, file.name) and true or false

		file.name = oldname
		return not res
	end
}
