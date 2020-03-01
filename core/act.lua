--- Central access for monster actions.
--@module core.act

--[[--
Table representing a possible action.

Actions have the following form:
	{
		possible = function(w, src, targ_num),
		utility = function(w, src, targ_num),
		attempt = function(w, src, targ_num)
	}
Where `w` is the `tiny.world`, `src` is the entity doing the action, and `targ_num` is
an integer representing the target. In most cases `targ_num` is a `grid.pos`, but for
certain abilities it may instead be an inventory index.

`possible` must return a truthy value if the action is possible, and a falsy value
otherwise. `utility` must return a value less than or equal to 0 if the action is not
possible. Only `attempt` is allowed to alter the state of the game.

@usage
	-- Check if mudane melee action is possible for entity `e`:
	p = act[enum.power.mundane].melee.possible(world, e, target_position)
	if p then
		-- something
	end

	-- Calculate utility doing the ranged hot action for entity `e`:
	u = act[enum.power.hot].ranged.utility(world, e, target_position)

	-- Attempt the warp flee action for entity `e`:
	act[enum.power.warp].flee.attempt(world, e, target_position)
	-- (Note that when fleeing, `e` will try to get *away* from the `target_position`)
@typedef action
]]

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

--- Initialize `core.act[enum.power.*]`
-- @treturn table the `core.act` module
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

--- Add numeric keys for individual actions of each power.
-- Intended for testing only.
function act.enumerate()
	for k,v in pairs(act) do
		if type(k) == "number" then
			base.extend_arr(v, pairs(base.copy(v)))
		end
	end
end

return act.init()