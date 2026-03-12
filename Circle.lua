function PlotCircle(x, y, r, c)
	local px = 0
	local py = r
	local m = 5 - 4 * r

	while (px <= py) do
		pix((px + x), (py + y), c)
		pix((py + x), (px + y), c)
		pix((-px + x), (py + y), c)
		pix((-py + x), (px + y), c)
		pix((px + x), (-py + y), c)
		pix((py + x), (-px + y), c)
		pix((-px + x), (-py + y), c)
		pix((-py + x), (-px + y), c)

		if m > 0 then
			py = py - 1
			m = m - 8 * py
		end

		px = px + 1
		m = m + 8 * px + 4
	end
end

function CreateCircleMem(ptr)
	local p,item
	ptr,p=Pop(ptr,4)
	item=CreateCircle(p[1],p[2],p[3],p[4])
	return ptr,item
end


function CreateCircle(x, y, r, c)
	if c == nil then c = 10 end

	local circle = {}

	function circle:str()
		return "circle "..tostring(x).." "..tostring(y).." "..tostring(r).." "..tostring(c)
	end

	function circle.Init(_)
		_.x = x
		_.y = y
		_.px = 0
		_.py = r
		_.m = 5 - 4 * r
	end

	function circle.Draw(_,fnPix)
		if (_.px <= _.py) then
			if fnPix~=nil then
				fnPix((_.px + x), (_.py + y), c)
				fnPix((_.py + x), (_.px + y), c)
				fnPix((-_.px + x), (_.py + y), c)
				fnPix((-_.py + x), (_.px + y), c)
				fnPix((_.px + x), (-_.py + y), c)
				fnPix((_.py + x), (-_.px + y), c)
				fnPix((-_.px + x), (-_.py + y), c)
				fnPix((-_.py + x), (-_.px + y), c)
			end

			if _.m > 0 then
				_.py = _.py - 1
				_.m = _.m - 8 * _.py
			end

			_.px = _.px + 1
			_.m = _.m + 8 * _.px + 4

			return 8
		end

		return 0
	end

	return circle
end
