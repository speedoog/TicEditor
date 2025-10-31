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


lines2 = { }

--poke(0x3FFB,1)	-- hide cursor

function include(file)
	trace(file.." load")
	dofile(file)
	trace(file.." loaded !")
end

include("Maths.lua")
include("Queue.lua")
include("File.lua")
include("Line.lua")
include("Fill.lua")
include("Helpers.lua")


---------------------------------------------------

lines2 = Load()

--iLine=1

t=0

gSizeX	=240
gSizeY	=136
gWhite	=12
gSeqSize=12

function DrawPalette()
	local ox=0
	local oy=20
	local colors=16
	local bsize	=12
	local columns=2
	local colorspercol = math.floor(colors/columns)
	for i=0,colors-1 do
		local iy = i%colorspercol
		local ix = i//colorspercol
		rect(ox+ix*bsize,oy+iy*bsize,bsize+1,bsize+1,i)
		rectb(ox+ix*bsize,oy+iy*bsize,bsize+1,bsize+1,15)
	end
end

function DrawMenu()
	rect(0,0,gSizeX,7,12)
	print("Editor",1,1,15)
end

function DrawSequencer()
	local c=13
	ax=0
	for k, ln in pairs(lines2.items) do
--		trace(dump(ln))
		sx=(ln.npix/lines2.npix)*gSizeX
		rect(ax,gSizeY-gSeqSize,ax+sx,gSeqSize,c)
		if c==13 then c=15 else c=13 end
	 	ax=ax+sx
	end
end

function DrawUI()
	vbank(1)
	cls()
	DrawPalette()
	DrawMenu()
	DrawSequencer()
	vbank(0)
end

DrawUI()

gPixTarget =0

function TIC()
	cls()

	local mx,my,ml,mm,mr=mouse()
	
	if ml then
		if my>(gSizeY-gSeqSize) then
			gPixTarget =(mx/gSizeX)*lines2.npix
		else
			if btrace==false then
				xStart=mx
				yStart=my
				btrace = true
			else
				PlotLine(xStart,yStart,mx,my,2)
			end
		-- elseif btrace then
		-- 	local ln = {xStart,yStart,mx,my}
		-- 	table.insert(lines, ln)
		-- 	btrace = false
		-- 	Save()
		end
	elseif btrace then
		btrace = false
	end

	local iPix=0
	local bComplete=false
	local bContinue
--	trace("-------------")
	for k, ln in pairs(lines2.items) do
		bContinue=true
		ln:Init()
		while bContinue do
			bContinue = ln:Draw(function(x,y,c) pix(x,y,c) iPix=iPix+1 end)
			if iPix>=gPixTarget then bComplete=true bContinue=false end
		end
		if bComplete then break end
	end

--	trace(iPix)
   
	-- for k, l in pairs(lines) do
	-- 	PlotLine(l[1],l[2],l[3],l[4],2)
	-- end

	-- if t>=(#lines) then t=1 trace(t) end
	-- local l2=lines[math.ceil(t)]
	-- if l2~=nil then
	-- 	PlotLine(l2[1],l2[2],l2[3],l2[4],2)	
	-- end

--	if iLine>=#lines2 then iLine=1 end

	-- local curline = lines2[iLine]
	-- if curline~=nil then
	-- 	local b
	-- 	for i=0,1 do
	-- 		b=curline:Draw(pix)
	-- 		if b then iLine=iLine+1 break end
	-- 	end
	-- -- else
	-- -- 	if bFill then 
	-- -- 		cls()
	-- -- 		for k, l in pairs(lines) do
	-- -- 			PlotLine(l[1],l[2],l[3],l[4],10)
	-- -- 		end			
	-- -- 		FloodFill(120,100,8)
	-- -- 	else
	-- -- 		bFill = true
	-- -- 		t=0
	-- -- 	end
	-- end

--	ditherrect(0,t%300-150,30,136,136,2,3)
	
	-- if mr then
	-- 	t=0
	-- 	FloodFill(mx,my,14)
	-- end
	t=t+2
	
--	Cursor(mx,my)
end


-- <TILES>
-- 000:0123456700000000000000000000000000000000000000000000000000000000
-- 001:eccccccccc888888caaaaaaaca888888cacccccccacc0ccccacc0ccccacc0ccc
-- 002:ccccceee8888cceeaaaa0cee888a0ceeccca0ccc0cca0c0c0cca0c0c0cca0c0c
-- 003:eccccccccc888888caaaaaaaca888888cacccccccacccccccacc0ccccacc0ccc
-- 004:ccccceee8888cceeaaaa0cee888a0ceeccca0cccccca0c0c0cca0c0c0cca0c0c
-- 017:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 018:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- 019:cacccccccaaaaaaacaaacaaacaaaaccccaaaaaaac8888888cc000cccecccccec
-- 020:ccca00ccaaaa0ccecaaa0ceeaaaa0ceeaaaa0cee8888ccee000cceeecccceeee
-- </TILES>

-- <SPRITES>
-- 000:89abcdef00000000000000000000000000000000000000000000000000000000
-- </SPRITES>

-- <MAP>
-- 001:102000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:112100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

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

