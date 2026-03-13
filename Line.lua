
function PlotLine(x0,y0,x1,y1,c,fn)
	if fn==nil then fn=pix end

	local dx = abs(x1-x0)
	local dy =-abs(y1-y0)

	local sx,sy
	if x0<x1 then sx=1 else sx=-1 end
	if y0<y1 then sy=1 else sy=-1 end

	local err=dx+dy -- error value e_xy
	local e2 = err
	local b=true
	local iPix=0
	while(b) do
		iPix=iPix+1
		fn(x0,y0, c)
		e2 = 2*err
		if e2>=dy then -- e_xy+e_x > 0
			if x0==x1 then b=false end
			err=err+dy
			x0 =x0+sx
		end
		if e2<=dx then -- e_xy+e_y < 0
			if y0==y1 then b=false end
			err=err+dx
			y0 =y0+sy
		end
	end
	return iPix
end

function CreatePolyLine(item)
	item.i=1

	function item.Load(_,p)
		_.c=p[1]
		local ptcount = (#p-1)>>1
		for i = 1,ptcount do
			_.pts[i] = {p[i*2],p[1+i*2]}
		end
	end

	function item.Save(_)
		local s={}
		table.insert(s, _.c)
		for k,v in pairs(_.pts) do
			table.insert(s, v[1])
			table.insert(s, v[2])
		end
		return	s
	end

	function item.InitSeg(_, i)
		_.i = i

		if #_.pts<2 then return end

		local p0=_.pts[i]
		local p1=_.pts[i+1]
		_.x  = p0[1]
		_.y  = p0[2]
		_.x1 = p1[1]
		_.y1 = p1[2]
		_.dx = abs(_.x1-_.x)
		_.dy =-abs(_.y1-_.y)

		if _.x<_.x1 then _.sx=1 else _.sx=-1 end
		if _.y<_.y1 then _.sy=1 else _.sy=-1 end

		_.err= _.dx+_.dy -- error value e_xy
		_.e2 = _.err
	end

	function item.Init(_)
		_:InitSeg(1)
	end

	function item.Draw(_,fnPix)
		if fnPix ~= nil then
			fnPix(_.x, _.y, _.c)
		end

		while _.x==_.x1 and _.y==_.y1 do	-- completed line ?
			local i=_.i+1
			if i>=#_.pts then
				return 0					-- was last segment
			else
				_:InitSeg(i)				-- next segment
			end
		end

		_.e2 = 2*_.err

		if _.e2>=_.dy then -- e_xy+e_x > 0
			_.err=_.err+_.dy
			_.x =_.x+_.sx
		end

		if _.e2<=_.dx then -- e_xy+e_y < 0
			_.err=_.err+_.dx
			_.y =_.y+_.sy
		end

		return 1
	end

	return item
end


--[[

function CreateLine(x0,y0,x1,y1,c)
	if c==nil then c=10 end

	local line = { }

	function line:str()
		return "line "..tostring(x0).." "..tostring(y0).." "..tostring(x1).." "..tostring(y1).." "..tostring(c)
	end

	function line.Init(_)
		_.x = x0
		_.y = y0
		_.dx = abs(x1-x0)
		_.dy =-abs(y1-y0)

		if x0<x1 then line.sx=1 else line.sx=-1 end
		if y0<y1 then line.sy=1 else line.sy=-1 end

		_.err= _.dx+_.dy -- error value e_xy
		_.e2 = _.err
	end

	-- return "continue"
	function line.Draw(_,fnPix)
		if fnPix ~= nil then
			fnPix(_.x,_.y, c)
		end

		if _.x==x1 and _.y==y1 then return 0 end

		_.e2 = 2*_.err

		if _.e2>=_.dy then -- e_xy+e_x > 0
			_.err=_.err+_.dy
			_.x =_.x+_.sx
		end
		
		if _.e2<=_.dx then -- e_xy+e_y < 0
			_.err=_.err+_.dx
			_.y =_.y+_.sy
		end

		return 1
	end

	return line
end

]]--