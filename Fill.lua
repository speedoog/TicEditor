dofile("Dither.lua")

function FillPix(x,y,c)
	matrixSize = 8
	local threshold = ditherMatrix8x8[x%matrixSize+1][y%matrixSize+1]

	local h=136
	local border=20
	local t = ((y-border)/(h-2*border)) * (matrixSize * matrixSize - 1)

	if t < threshold then
		pix(x, y, c)
	else
		pix(x, y, c+1)
	end
end

function FloodFill(x, y, c)
	if not InScreen(x, y) then return end

	loops = 0

	local o = pix(x, y)
	local q = CreateQueue()
	q:push({x, y})
	while q:isEmpty() == false do
		loops = loops + 1
		if loops / 2 > t then return end

		local v = q:pop()
		x = v[1]
		y = v[2]

		local lx = x

		while Inside(lx - 1, y, o) do
			FillPix(lx - 1, y, c)
			lx = lx - 1
		end

		while Inside(x, y, o) do
			FillPix(x, y, c)
			x = x + 1
		end

		scan(q, lx, x - 1, y + 1, o)
		scan(q, lx, x - 1, y - 1, o)
	end
end

function InScreen(x, y) return x >= 0 and x < 240 and y >= 0 and y < 136 end

function Inside(x, y, o) return pix(x, y) == o and InScreen(x, y) end

function scan(q, lx, rx, y, o)
	local span_added = false
	local x
	for x = lx, rx do
		if Inside(x, y, o) == false then
			span_added = false
		elseif not span_added then
			q:push({x, y})
			span_added = true
		end
	end
end



function CreateFill(x,y,c)
	if c==nil then c=10 end

	local fill = { }

	function fill:str()
		return "fill "..tostring(x).." "..tostring(y).." "..tostring(c)
	end

	function fill:Init()
		if not InScreen(x, y) then return end

		self.x = x
		self.y = y

		self.o = pix(x, y)
		self.q = CreateQueue()
		self.q:push({x, y})
	end

	-- return "continue"
	function fill:Draw(fnPix)
		local q=self.q

		if q:isEmpty() then
			return false
		end

		local o=self.o
		local v = q:pop()
		local x = v[1]
		local y = v[2]
		local lx = x

		while Inside(lx - 1, y, o) do
			fnPix(lx - 1, y, c)
			lx = lx - 1
		end

		while Inside(x, y, o) do
			fnPix(x, y, c)
			x = x + 1
		end

		scan(q, lx, x - 1, y + 1, o)
		scan(q, lx, x - 1, y - 1, o)

		return q:isEmpty()==false
	end

	return fill
end
