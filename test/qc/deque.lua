local base = require("core.base")
local deque = require("core.deque")

property "deque.len: start out empty" {
	generators = {},
	check = function()
		local dq = deque.new()
		return deque.len(dq) == 0
	end
}

property "deque.extend_back, deque.len: correct length" {
	generators = { tbl() },
	check = function(t)
		local dq = deque.new()
		deque.extend_back(dq, ipairs, t)
		return deque.len(dq) == #t
	end
}

property "deque.peek_front: 2nd value false if empty" {
	generators = {},
	check = function()
		local dq = deque.new()
		local _, hasv = deque.peek_front(dq)
		return not hasv
	end
}

property "deque.extend_back, deque.peek_front: correct value" {
	generators = { tbl() },
	check = function(t)
		local dq = deque.new()
		deque.extend_back(dq, ipairs, t)
		local v, hasv = deque.peek_front(dq)
		return (v == t[1] and hasv) or t[1] == nil
	end,
	when_fail = function(t)
		local dq = deque.new()
		deque.extend_back(dq, ipairs, t)
		local v, hasv = deque.peek_front(dq)
		print("\n")
		print("t[1]:", t[1])
		print("v:", v)
		print("hasv:", hasv)
		print("len:", deque.len(dq))
		print("#t:", #t)
	end
}

property "deque.extend_back, deque.peek_front, deque.len: correct length" {
	generators = { tbl() },
	check = function(t)
		local dq = deque.new()
		deque.extend_back(dq, ipairs, t)
		deque.peek_front(dq)
		return deque.len(dq) == #t 
	end
}

property "deque.peek_back: 2nd value false if empty" {
	generators = {},
	check = function()
		local dq = deque.new()
		local _, hasv = deque.peek_back(dq)
		return not hasv
	end
}

property "deque.extend_back, deque.peek_back: correct value" {
	generators = { tbl() },
	check = function(t)
		local dq = deque.new()
		deque.extend_back(dq, ipairs, t)
		local v, hasv = deque.peek_back(dq)
		return (v == t[#t] and hasv) or t[1] == nil
	end
}

property "deque.extend_back, deque.peek_back, deque.len: correct length" {
	generators = { tbl() },
	check = function(t)
		local dq = deque.new()
		deque.extend_back(dq, ipairs, t)
		deque.peek_back(dq)
		return deque.len(dq) == #t
	end
}

property "deque.extend_back, deque.pop_front: correct value" {
	generators = { tbl(), int() },
	check = function(t, popn)
		local popn = base.clip(popn, 0, #t)
		local dq = deque.new()
		deque.extend_back(dq, ipairs, t)
		local res
		for i=1,popn do
			res = deque.pop_front(dq)
		end
		return res == t[popn]
	end
}

property "deque.extend_back, deque.pop_back, deque.len: correct length" {
	generators = { tbl(), int() },
	check = function(t, popn)
		local popn = base.clip(popn, 0, #t)
		local dq = deque.new()
		deque.extend_back(dq, ipairs, t)
		for i=1,popn do
			deque.pop_back(dq)
		end
		return deque.len(dq) == (#t - popn)
	end
}

property "deque.pop_back: error if empty" {
	generators = {},
	check = function()
		local dq = deque.new()
		return not pcall(function() deque.pop_back(dq) end)
	end
}

property "deque.extend_back, deque.push_back: equivalent operations" {
	generators = { tbl() },
	check = function(t)
		local dq1, dq2 = deque.new(), deque.new()
		deque.extend_back(dq1, ipairs, t)
		for _,v in ipairs(t) do
			deque.push_back(dq2, v)
		end
		return base.equals(dq1, dq2)
	end
}

property "deque.extend_back, deque.backwards, deque.len: expected values from backwards" {
	generators = { tbl() },
	check = function(t)
		local dq = deque.new()
		deque.extend_back(dq, ipairs, t)
		local i = 0
		for _,v in deque.backwards(dq) do
			i = i + 1
			if v ~= t[i] then
				return false
			end
		end
		if i ~= deque.len(dq) then
			print(i, deque.len(dq))
		end
		return i == deque.len(dq)
	end
}

property "deque.extend_front, deque.len: correct length" {
	generators = { tbl() },
	check = function(t)
		local dq = deque.new()
		deque.extend_front(dq, ipairs, t)
		return deque.len(dq) == #t
	end
}

property "deque.extend_front, deque.peek_front: correct value" {
	generators = { tbl() },
	check = function(t)
		local dq = deque.new()
		deque.extend_front(dq, ipairs, t)
		local v, hasv = deque.peek_front(dq)
		return (v == t[#t] and hasv) or t[1] == nil
	end
}

property "deque.extend_front, deque.peek_front, deque.len: correct length" {
	generators = { tbl() },
	check = function(t)
		local dq = deque.new()
		deque.extend_front(dq, ipairs, t)
		deque.peek_front(dq)
		return deque.len(dq) == #t 
	end
}

property "deque.extend_front, deque.peek_back: correct value" {
	generators = { tbl() },
	check = function(t)
		local dq = deque.new()
		deque.extend_front(dq, ipairs, t)
		local v, hasv = deque.peek_back(dq)
		return (v == t[1] and hasv) or t[1] == nil
	end
}

property "deque.extend_front, deque.peek_back, deque.len: correct length" {
	generators = { tbl() },
	check = function(t)
		local dq = deque.new()
		deque.extend_front(dq, ipairs, t)
		deque.peek_back(dq)
		return deque.len(dq) == #t 
	end
}

property "deque.extend_front, deque.pop_back: correct value" {
	generators = { tbl(), int() },
	check = function(t, popn)
		local popn = base.clip(popn, 0, #t)
		local dq = deque.new()
		deque.extend_front(dq, ipairs, t)
		local res
		for i=1,popn do
			res = deque.pop_back(dq)
		end
		return res == t[popn]
	end
}

property "deque.extend_front, deque.pop_front, deque.len: correct length" {
	generators = { tbl(), int() },
	check = function(t, popn)
		local popn = base.clip(popn, 0, #t)
		local dq = deque.new()
		deque.extend_front(dq, ipairs, t)
		for i=1,popn do
			deque.pop_front(dq)
		end
		return deque.len(dq) == (#t - popn)
	end
}

property "deque.pop_front: error if empty" {
	generators = {},
	check = function()
		local dq = deque.new()
		return not pcall(function() deque.pop_front(dq) end)
	end
}

property "deque.extend_front, deque.push_front: equivalent operations" {
	generators = { tbl() },
	check = function(t)
		local dq1, dq2 = deque.new(), deque.new()
		deque.extend_front(dq1, ipairs, t)
		for _,v in ipairs(t) do
			deque.push_front(dq2, v)
		end
		return base.equals(dq1, dq2)
	end
}

property "deque.extend_front, deque.forwards, deque.len: expected values from forwards" {
	generators = { tbl() },
	check = function(t)
		local dq = deque.new()
		deque.extend_front(dq, ipairs, t)
		local i = 0
		for _,v in deque.forwards(dq) do
			i = i + 1
			if v ~= t[i] then
				return false
			end
		end
		return i == deque.len(dq)
	end
}
