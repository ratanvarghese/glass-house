local base = require("core.base")
local enum = require("core.enum")

local mundane = require("core.act.mundane")
local usetool = require("core.act.usetool")
local warp = require("core.act.warp")
local jump = require("core.act.jump")
local vampiric = require("core.act.vampiric")
local smash = require("core.act.smash")
local rnsummon = require("core.act.rnsummon")
local clone = require("core.act.clone")
local hotcold = require("core.act.hotcold")
local sticky = require("core.act.sticky")
local displace = require("core.act.displace")
local heal = require("core.act.heal")
local slow = require("core.act.slow")
local steal = require("core.act.steal")

local act = {
	MAX_MUNDANE_MOVE = mundane.MAX_MOVE,
	MAX_MUNDANE_MELEE = mundane.MAX_MELEE,
	make_warp_dlist = warp.make_dlist,
	jump_dlist = jump.dlist,
}

function act.init()
	act[enum.power.mundane] = mundane.export
	act[enum.power.tool] = usetool
	act[enum.power.warp] = warp.export
	act[enum.power.jump] = jump.export
	act[enum.power.vampiric] = vampiric
	act[enum.power.smash] = smash
	act[enum.power.summon] = rnsummon
	act[enum.power.clone] = clone
	act[enum.power.hot] = hotcold.hot
	act[enum.power.cold] = hotcold.cold
	act[enum.power.sticky] = sticky
	act[enum.power.displace] = displace
	act[enum.power.heal] = heal
	act[enum.power.slow] = slow
	act[enum.power.steal] = steal
	return act
end

function act.enumerate()
	for k,v in pairs(act) do
		if type(k) == "number" then
			base.extend_arr(v, pairs(base.copy(v)))
		end
	end
end

return act.init()