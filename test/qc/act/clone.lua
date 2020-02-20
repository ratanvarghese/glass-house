local base = require("core.base")
local enum = require("core.enum")
local act = require("core.act")

property "act[enum.power.clone].ranged: possible and utility same as rnsummon" {
	generators = {},
	numtests = 1,
	check = function()
		local f1 = act[enum.power.clone].ranged.possible
		local f2 = act[enum.power.summon].ranged.possible
		local f3 = act[enum.power.clone].ranged.utility
		local f4 = act[enum.power.summon].ranged.utility
		return f1 == f2 and f3 == f4
	end
}

property "act[enum.power.clone].ranged.attempt: call rnsummon with right arguments" {
	generators = { tbl(), tbl(), int(), int(), any() },
	check = function(w, src, targ_pos, kind, ret)
		src.kind = kind

		local oldsummon = act[enum.power.summon].ranged.attempt
		local attempt_args = {}
		act[enum.power.summon].ranged.attempt = function(...)
			table.insert(attempt_args, {...})
			return ret
		end
		local res = act[enum.power.clone].ranged.attempt(w, src, targ_pos)
		act[enum.power.summon].ranged.attempt = oldsummon
		return res == ret and base.equals(attempt_args, {{w, src, targ_pos, kind}})
	end
}