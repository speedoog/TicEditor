
function FloodFill(x, y, c)
	if not InScreen(x, y) then return end

	loops = 0

	local o = pix(x, y)
	local q = CreateQueue()
	q:push({x, y})
	while q:isEmpty() == false do
		loops = loops + 1
		if loops / 2 > t % 200 then return end

		local v = q:pop()
		x = v[1]
		y = v[2]

		local lx = x

		while Inside(lx - 1, y, o) do
			pix(lx - 1, y, c)
			lx = lx - 1
		end

		while Inside(x, y, o) do
			pix(x, y, c)
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

--[[

-- old version, slow

function FloodFill(_x,_y,_c)
 Queue_:clear()
 a=pix(_x,_y)
 
-- local nodes = Queue.new()
-- Queue.enqueue(nodes, {x=_x,y=_y} )
 Queue_:push({_x,_y})
--  trace("x="..tostring(x).." y="..tostring(ly))

  -- Do the floodfill
 while Queue_:isEmpty() == false do
  local v = Queue_:pop()
  local lx = v[1]
  local ly = v[2]

  if pix(lx,ly)==a	then
   pix(lx,ly,_c)
   Queue_:push({lx+1,ly})
--  trace("x="..tostring(lx).." y="..tostring(ly))
--  break
   Queue_:push({lx-1,ly})
   Queue_:push({lx,ly+1})
   Queue_:push({lx,ly-1})
  end
 end

end
]]
