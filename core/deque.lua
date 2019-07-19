local deque = {}

function deque.new()
	return {front = 0, back = 0, len = 0}
end

local function pop_check(q)
	assert(deque.len(q) > 0, "Attempt to pop empty deque")
end

local function sync_check(q)
	assert(q.back <= q.front, "Deque back ahead of front")
end

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

function deque.push_back(q, v)
	sync_check(q)
	if q.len > 0 then
		q.back = q.back - 1
	end
	sync_check(q)
	q.len = q.len + 1
	q[q.back] = v
end

function deque.push_front(q, v)
	sync_check(q)
	if q.len > 0 then
		q.front = q.front + 1
	end
	sync_check(q)
	q.len = q.len + 1
	q[q.front] = v
end

function deque.peek_back(q)
	return q[q.back], deque.len(q) > 0
end

function deque.peek_front(q)
	return q[q.front], deque.len(q) > 0
end

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

function deque.backwards(q)
	return backwards_iter, q, 0
end

function deque.extend_back(q, f, ...)
	for _,v in f(...) do
		deque.push_back(q, v)
	end
end

function deque.extend_front(q, f, ...)
	for _,v in f(...) do
		deque.push_front(q, v)
	end
end

return deque
