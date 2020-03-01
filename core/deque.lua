--- Double-ended queue (deque)
-- @module core.deque
local deque = {}

--- Table representing a deque
-- @typedef deque.deque

--- Create a deque.
-- @treturn deque.deque
function deque.new()
	return {front = 0, back = 0, len = 0}
end

local function pop_check(q)
	assert(deque.len(q) > 0, "Attempt to pop empty deque")
end

local function sync_check(q)
	assert(q.back <= q.front, "Deque back ahead of front")
end

--- Pop item from back of deque `q`.
-- @tparam deque.deque q
-- @return popped item
function deque.pop_back(q)
	pop_check(q)
	local res = q[q.back]
	q[q.back] = nil
	q.len = q.len - 1
	if q.len > 0 then
		q.back = q.back + 1
	end
	sync_check(q)
	return res
end

--- Pop item from front of deque `q`.
-- @tparam deque.deque q
-- @return popped item
function deque.pop_front(q)
	pop_check(q)
	local res = q[q.front]
	q[q.front] = nil
	q.len = q.len - 1
	if q.len > 0 then
		q.front = q.front - 1
	end
	sync_check(q)
	return res
end

--- Push item to back of deque `q`.
-- @tparam deque.deque q
-- @param v item to push
function deque.push_back(q, v)
	sync_check(q)
	if q.len > 0 then
		q.back = q.back - 1
	end
	sync_check(q)
	q.len = q.len + 1
	q[q.back] = v
end

--- Push item to front of deque `q`.
-- @tparam deque.deque q
-- @param v item to push
function deque.push_front(q, v)
	sync_check(q)
	if q.len > 0 then
		q.front = q.front + 1
	end
	sync_check(q)
	q.len = q.len + 1
	q[q.front] = v
end


--- Get item at the back of deque `q` without removing it.
-- @tparam deque.deque q
-- @return the item at the back of `q`
function deque.peek_back(q)
	return q[q.back], deque.len(q) > 0
end

--- Get item at the front of deque `q` without removing it.
-- @tparam deque.deque q
-- @return the item at the front of `q`
function deque.peek_front(q)
	return q[q.front], deque.len(q) > 0
end

--- Get number of items in deque `q`.
-- @tparam deque.deque q
-- @treturn int
function deque.len(q)
	return q.len
end

local function forwards_iter(q, _var)
	if _var >= q.len then
		return nil
	else
		return _var + 1, q[q.back + _var]
	end
end

--- Iterate over deque `q` in `for` loop, back to front.
-- See [Programming in Lua](https://www.lua.org/pil/7.2.html).
-- @tparam deque.deque q
-- @usage for _,v in deque.forwards(q) do
--     -- something
-- end
function deque.forwards(q)
	return forwards_iter, q, 0
end

local function backwards_iter(q, _var)
	if _var >= q.len then
		return nil
	else
		return _var + 1, q[q.front - _var]
	end
end

--- Iterate over deque `q` in `for` loop, front to back.
-- See [Programming in Lua](https://www.lua.org/pil/7.2.html).
-- @tparam deque.deque q
-- @usage for _,v in deque.backwards(q) do
--     -- something
-- end
function deque.backwards(q)
	return backwards_iter, q, 0
end

--- Push items from iterator to back of deque `q`.
-- See [Programming in Lua](https://www.lua.org/pil/7.2.html).
-- @tparam deque.deque q
-- @tparam func f iterator, such as `pairs` or `base.rn_distinct`
-- @param ... arguments to f
-- @usage deque.extend_back(q, ipairs, {"Hello", "World"}) -- "World" will be in the back
function deque.extend_back(q, f, ...)
	for _,v in f(...) do
		deque.push_back(q, v)
	end
end

--- Push items from iterator to front of deque `q`.
-- See [Programming in Lua](https://www.lua.org/pil/7.2.html).
-- @tparam deque.deque q
-- @tparam func f iterator, such as `pairs` or `base.rn_distinct`
-- @param ... arguments to f
-- @usage deque.extend_back(q, ipairs, {"Hello", "World"}) -- "World" will be in the front
function deque.extend_front(q, f, ...)
	for _,v in f(...) do
		deque.push_front(q, v)
	end
end

return deque
