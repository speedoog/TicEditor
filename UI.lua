local UI = { show=true, color1=2, color2=4 }

function UI:HideCursor()
    poke(0x3FFB,1)
end

function UI:DrawCrosshair(mx, my)
	local max = 2
	local min = 1
	local color = 15
	PlotLine(mx-max, my, mx-min, my, color)
	PlotLine(mx+min, my, mx+max, my, color)
	PlotLine(mx, my-max, mx, my-min, color)
	PlotLine(mx, my+min, mx, my+max, color)
end

gSeqSize=12
gPixTarget =0

function CirclePal(x,y,r,c)
	circ(x, y, r, c)
	circb(x, y, r, 15)
end


function UI:DrawPalette()
	local ox=0
	local oy=40
	local colors=16
	local bsize	=8
	local columns=2
	local colorspercol = math.floor(colors/columns)
	for i=0,colors-1 do
		local iy = i%colorspercol
		local ix = i//colorspercol
		local ml, mr = Button(ox+ix*bsize,oy+iy*bsize,bsize+1,bsize+1,i)
		if ml then self.color1=i end
		if mr then self.color2=i end
	end
	CirclePal(ox+bsize*0.5, oy-bsize*0.6, bsize/2, self.color1)
	CirclePal(ox+bsize*1.5, oy-bsize*0.6, bsize/2, self.color2)	
end

function UI:DrawMenu()
	rect(0,0,gSizeX,7,12)
	print("Editor",1,1,15)
end

function UI:DrawSequencer()
	local c=13
	ax=0
	for k, ln in pairs(scene.items) do
--		trace(dump(ln))
		sx=(ln.npix/scene.npix)*gSizeX
		rect(ax,gSizeY-gSeqSize,ax+sx,gSeqSize,c)
		if c==13 then c=15 else c=13 end
	 	ax=ax+sx
	end
end

function UI:Draw()
	vbank(1)
	cls()

	if keyp(49) then
		self.show = not self.show
	end

	if self.show then		
		self:DrawPalette()
		self:DrawMenu()
		self:DrawSequencer()
	end

	vbank(0)
end

function UI:UpdateEditLine()
	local mx,my,ml,mm,mr=mouse()

	if ml then
		if my>(gSizeY-gSeqSize) then
			gPixTarget =(mx/gSizeX)*scene.npix
		else
			if btrace==false then
				xStart=mx
				yStart=my
				btrace = true
			else
				PlotLine(xStart,yStart,mx,my,2)
			end
		end
	elseif btrace then
		btrace = false
	end
end

function UI:DrawShapes()
	local iPix=0
	local bComplete=false
	local bContinue

	for k, ln in pairs(scene.items) do
		bContinue=true
		ln:Init()
		while bContinue do
			bContinue = ln:Draw(function(x,y,c) pix(x,y,c) iPix=iPix+1 end)
			if iPix>=gPixTarget then bComplete=true bContinue=false end
		end
		if bComplete then break end
	end
end

function UI:Init()
    xStart = 0
    yStart = 0
    btrace = false

    scene = Load()
    Save()
    UI:Draw()
end

function UI:Update()
	cls()

	self:Draw()

    self:UpdateEditLine()
    self:DrawShapes()

end

return UI