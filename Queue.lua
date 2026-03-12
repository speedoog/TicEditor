
function CreateQueue()
	local queue = {_queue={}, _pointer = 0, _has = {}}
	queue.__index = queue

	function queue:new()
		return setmetatable({},queue)
	end

	function queue.push(_,item)
		if _._has[item] then return end
		_._pointer = _._pointer+1
		_._queue[_._pointer] = item
		_._has[item] = true
		return _
	end

	function queue.pop(_)
		local item = _._queue[1]
		_._pointer = _._pointer-1
		table.remove(_._queue,1)
		_._has[item] = nil
		return item
	end

	function queue.isEmpty(_)
		return (_._pointer == 0)
	end

	function queue.clear(_)
		_._queue = {}
		_._has = {}
		_._pointer = 0
		return _
	end

	return queue
end
