function CreateItemBase(t,c)
	return {nPix = 0,type = t,c = c,pts = {}}
end

function CreateItem(cmd)
	if gItemFactory == nil then
		gItemFactory = {
			["l"] = CreatePolyLine,
			["s"] = CreateSpline,
			["f"] = CreateFill,
			-- ["e"] = true,
			-- ["c"] = true,
		}
	end
	local item
	local fnCreate = gItemFactory[cmd]
	if fnCreate then
		item = CreateItemBase(cmd)
		fnCreate(item)
	end
	return item
end

function PlotLine(x0,y0,x1,y1,c,fn)
	if fn == nil then fn = pix end

	local dx = abs(x1-x0)
	local dy = -abs(y1-y0)

	local sx,sy
	if x0 < x1 then sx = 1 else sx = -1 end
	if y0 < y1 then sy = 1 else sy = -1 end

	local err = dx+dy -- error value e_xy
	local e2 = err
	local b = true
	local iPix = 0
	while (b) do
		iPix = iPix+1
		fn(x0,y0,c)
		e2 = 2*err
		if e2 >= dy then -- e_xy+e_x > 0
			if x0 == x1 then b = false end
			err = err+dy
			x0 = x0+sx
		end
		if e2 <= dx then -- e_xy+e_y < 0
			if y0 == y1 then b = false end
			err = err+dx
			y0 = y0+sy
		end
	end
	return iPix
end

function CreatePolyLine(item)
	item.i = 1

	function item.Load(_,p)
		_.c = p[1]
		local ptcount = (#p-1)>>1
		for i = 1,ptcount do
			_.pts[i] = {p[i*2],p[1+i*2]}
		end
	end

	function item.Save(_)
		local s = {}
		table.insert(s,_.c)
		for k,v in pairs(_.pts) do
			table.insert(s,v[1])
			table.insert(s,v[2])
		end
		return s
	end

	function item.InitSeg(_,i)
		_.i = i

		if #_.pts < 2 then return end

		local p0 = _.pts[i]
		local p1 = _.pts[i+1]
		_.x = p0[1]
		_.y = p0[2]
		_.x1 = p1[1]
		_.y1 = p1[2]
		_.dx = abs(_.x1-_.x)
		_.dy = -abs(_.y1-_.y)

		if _.x < _.x1 then _.sx = 1 else _.sx = -1 end
		if _.y < _.y1 then _.sy = 1 else _.sy = -1 end

		_.err = _.dx+_.dy -- error value e_xy
		_.e2 = _.err
	end

	function item.Init(_)
		_:InitSeg(1)
	end

	function item.Draw(_,fnPix)
		if fnPix ~= nil then
			fnPix(_.x,_.y,_.c)
		end

		while _.x == _.x1 and _.y == _.y1 do -- completed line ?
			local i = _.i+1
			if i >= #_.pts then
				return 0     -- was last segment
			else
				_:InitSeg(i) -- next segment
			end
		end

		_.e2 = 2*_.err

		if _.e2 >= _.dy then -- e_xy+e_x > 0
			_.err = _.err+_.dy
			_.x = _.x+_.sx
		end

		if _.e2 <= _.dx then -- e_xy+e_y < 0
			_.err = _.err+_.dx
			_.y = _.y+_.sy
		end

		return 1
	end

	return item
end

function CreateSpline(item)
	item.t = 0
	item.i = 0
	item.tend = 0
	item.keys = {}

	function item.Load(_,p)
		_.c = p[1]
		local ptcount = (#p-1)>>1
		for i = 1,ptcount do
			_.pts[i] = {p[i*2],p[1+i*2]}
		end
	end

	function item.Save(_)
		local s = {}
		table.insert(s,_.c)
		for k,v in pairs(_.pts) do
			table.insert(s,v[1])
			table.insert(s,v[2])
		end
		return s
	end

	function item.Init(_)
		_.i = 0
		_.t = 0
		_.keys = {} -- build up CatmullRom keys
		local t = 0
		local x1,y1,x2,y2
		for k,v in pairs(_.pts) do
			x2 = v[1]
			y2 = v[2]
			if x1 ~= nil then
				t = t+distance(x1,y1,x2,y2)
			end
			table.insert(_.keys,t)
			table.insert(_.keys,x2)
			table.insert(_.keys,y2)
			x1 = x2
			y1 = y2
		end
		_.tend = t
	end

	function item.Draw(_,fnPix)
		local dt = 3
		local tprev = _.t
		_.t = _.t+dt
		_.i = _.i+1

		if _.t > _.tend then
			_.t = _.tend
		end

		local v0 = CatmullRom(_.keys,2,tprev)
		local v1 = CatmullRom(_.keys,2,_.t)
		local iPix = 0
		if fnPix ~= nil then
			PlotLine(round(v0[1]),round(v0[2]),round(v1[1]),round(v1[2]),_.c,fnPix) -- c+2*(_.i&1)
		end

		if _.t < _.tend then
			return 1
		else
			return 0
		end
	end

	return item
end

function CreateQueue()
	local queue = {_queue = {},_pointer = 0,_has = {}}
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

function InScreen(x,y)
	return x >= 0 and x < gSizeX and y >= 0 and y < gSizeY
end

function Inside(x,y,o)
	return pix(x,y) == o and InScreen(x,y)
end

function HorizontalScan(q,lx,rx,y,o)
	local span_added = false
	local x
	for x = lx,rx do
		if Inside(x,y,o) == false then
			span_added = false
		elseif not span_added then
			q:push({x,y})
			span_added = true
		end
	end
end

function CreateFill(item)
	item.maxpt=1
	function item.Load(_,p)
		_.c = p[1]
		local ptcount = (#p-1)>>1
		for i = 1,ptcount do
			_.pts[i] = {p[i*2],p[1+i*2]}
		end
	end

	function item.Save(_)
		local s = {}
		table.insert(s,_.c)
		for k,v in pairs(_.pts) do
			table.insert(s,v[1])
			table.insert(s,v[2])
		end
		return s
	end

	function item.Init(_)
		local x=_.pts[1][1]
		local y=_.pts[1][2]

		if not InScreen(x,y) then return end

		_.x = x
		_.y = y

		_.o = pix(x,y)
		_.q = CreateQueue()
		_.q:push({x,y})
	end

	function item.Draw(_,fnPix)
		local q = _.q

		if q:isEmpty() then
			return 0
		end

		local o = _.o
		local v = q:pop()
		local x = v[1]
		local y = v[2]
		local lx = x

		while Inside(lx-1,y,o) do
			if fnPix ~= nil then
				fnPix(lx-1,y,_.c)
			end
			lx = lx-1
		end

		while Inside(x,y,o) do
			if fnPix ~= nil then
				fnPix(x,y,_.c)
			end
			x = x+1
		end

		HorizontalScan(q,lx,x-1,y+1,o)
		HorizontalScan(q,lx,x-1,y-1,o)

		if q:isEmpty() then
			return 0
		else
			return 1
		end
	end

	return item
end
