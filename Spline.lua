function CreateSpline(c)
	if c == nil then c = 10 end

	local item =
	{
		nPix = 0,
		c = c,
		pts = {},
		type = "s",
		t = 0,
		i = 0,
		tend = 0,
		keys = {},
	}

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
		_.i=0
		_.t = 0
		_.keys = {} -- build up CatmullRom keys
		local t = 0
		local x1,y1,x2,y2
		for k,v in pairs(_.pts) do
			x2=v[1]
			y2=v[2]
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
		_.i=_.i+1

		if _.t > _.tend then
			_.t=_.tend
		end

		local v0 = CatmullRom(_.keys,2,tprev)
		local v1 = CatmullRom(_.keys,2,_.t)
		local iPix = 0
		if fnPix ~= nil then
			PlotLine(floor(v0[1]),floor(v0[2]),floor(v1[1]),floor(v1[2]),_.c,fnPix) -- c+2*(_.i&1)
		end

		if _.t < _.tend then
			return 1
		else
			return 0
		end
	end

	return item
end
