-- title:  game title
-- author: game developer
-- desc:   short description
-- script: lua


-- https://pixelartvillage.com/
-- palette 		https://www.pixilart.com/palettes/tic-80-20367
-- bresenham 	https://zingl.github.io/bresenham.html

-- CRT F6
-- Rec F9

btrace=false
xStart=0
yStart=0

abs=math.abs

lines={}
lines2 = { }

poke(0x3FFB,1)	-- hide cursor

dofile("Queue.lua")
dofile("File.lua")
dofile("Line.lua")
dofile("Fill.lua")
dofile("Helpers.lua")

---------------------------------------------------

lines = Load()

for k, l in pairs(lines) do
	local ln = CreateLine(l[1],l[2],l[3],l[4],10)
	table.insert(lines2, ln)
end

iLine=1

t=0


cls()
function TIC()

	local mx,my,ml,mm,mr=mouse()
	
	if ml then
		if btrace==false then
			xStart=mx
			yStart=my
			btrace = true
		end
		PlotLine(xStart,yStart,mx,my,2)
	elseif btrace then
		local ln = {xStart,yStart,mx,my}
		table.insert(lines, ln)
		btrace = false
		Save()
	end
   
	-- for k, l in pairs(lines) do
	-- 	PlotLine(l[1],l[2],l[3],l[4],2)
	-- end

	-- if t>=(#lines) then t=1 trace(t) end
	-- local l2=lines[math.ceil(t)]
	-- if l2~=nil then
	-- 	PlotLine(l2[1],l2[2],l2[3],l2[4],2)	
	-- end

--	if iLine>=#lines2 then iLine=1 end
	local curline = lines2[iLine]
	if curline~=nil then
		local b=curline:Draw()
		if b then iLine=iLine+1 end
	else
		if bFill then 
			cls()
			for k, l in pairs(lines) do
				PlotLine(l[1],l[2],l[3],l[4],10)
			end			
			FloodFill(120,100,8)
		else
			bFill = true
			t=0
		end
	end

	
	-- if mr then
	-- 	t=0
	-- 	FloodFill(mx,my,14)
	-- end
	t=t+1
	
--	Cursor(mx,my)
end


-- <TILES>
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- </TILES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

