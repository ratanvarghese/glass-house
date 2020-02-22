local base = require("core.base")
local enum = require("core.enum")

local act_mundane = require("core.act.mundane")
local act_usetool = require("core.act.usetool")
local act_warp = require("core.act.warp")
local act_jump = require("core.act.jump")
local act_vampiric = require("core.act.vampiric")
local act_smash = require("core.act.smash")
local act_rnsummon = require("core.act.rnsummon")
local act_clone = require("core.act.clone")
local act_hotcold = require("core.act.hotcold")
local act_sticky = require("core.act.sticky")
local act_displace = require("core.act.displace")

local act = {
	MAX_MUNDANE_MOVE = act_mundane.MAX_MOVE,
	MAX_MUNDANE_MELEE = act_mundane.MAX_MELEE,
	make_warp_dlist = act_warp.make_dlist,
	jump_dlist = act_jump.dlist,
}

function act.init()
	act[enum.power.mundane] = {
		wander = act_mundane.wander,
		pursue = act_mundane.pursue,
		flee = act_mundane.flee,
		melee = act_mundane.melee
	}
	act[enum.power.tool] = {
		pickup = act_usetool.pickup,
		drop = act_usetool.drop,
		equip = act_usetool.equip
	}
	act[enum.power.warp] = {
		wander = act_warp.wander,
		pursue = act_warp.pursue,
		flee = act_warp.flee,
		ranged = act_warp.ranged
	}
	act[enum.power.jump] = {
		wander = act_jump.wander,
		pursue = act_jump.pursue,
		flee = act_jump.flee,
		ranged = act_jump.ranged
	}
	act[enum.power.vampiric] = {
		melee = act_vampiric.melee
	}
	act[enum.power.smash] = {
		pursue = act_smash.pursue,
		wander = act_smash.wander
	}
	act[enum.power.summon] = {
		ranged = act_rnsummon.ranged
	}
	act[enum.power.clone] = {
		ranged = act_clone.ranged
	}
	act[enum.power.hot] = {
		ranged = act_hotcold.hot.ranged
	}
	act[enum.power.cold] = {
		ranged = act_hotcold.cold.ranged
	}
	act[enum.power.sticky] = {
		melee = act_sticky.melee
	}
	act[enum.power.displace] = {
		melee = act_displace.melee
	}

	for k,v in pairs(act) do
		if type(k) == "number" then
			base.extend_arr(v, pairs(base.copy(v)))
		end
	end
	return act
end

return act.init()