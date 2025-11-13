local UI = { show=true, color1=2, color2=4, tooltips={}, tool="line", _x=0, _y=0,_sz=8 }
gSeqSize=12
gPixTarget =0

function UI:DrawTooltips()
	for k, tip in pairs(self.tooltips) do
	   	print(tip.t,tip.x,tip.y,tip.c,false,1,true)
	end
	self.tooltips = {}
end

function UI:tooltip(text)
  	local mx,my=mouse()
	local offx=3
	local offy=-8

	w=print(text,gSizeX,gSizeY,0,false,1,true)

	if mx>200 then offx=-w end
	table.insert(self.tooltips, {x=mx+offx,y=my+offy,c=12,t=text})
end

function UI:Button(x,y,w,h,c,text)
   	rect(x,y,w,h,c)
   	rectb(x,y,w,h,15)
	local mx,my,ml,mm,mr=mouse()
   	local hover =overlap(mx,my,x+1,x+w-1,y+1,y+h-1)
	if hover then
		self:tooltip(text)
		return ml,mr 
	end
	return false,false
end

function UI:ButtonIcon(x,y,w,h,cbk,id,text)
   	rect(x,y,w,h,cbk)
   	spr(id,x+w/2-4,y+h/2-4,0)
  	local mx,my,ml,mm,mr=mouse()
   	local hover =overlap(mx,my,x+1,x+w-1,y+1,y+h-1)
	if hover then
		self:tooltip(text)
		return ml,mr 
	end
	return false,false
end

function UI:ButtonTool(id,text)
	local cbk=15
	if text==self.tool then cbk=2 end
	if self:ButtonIcon(self._x,self._y,self._sz,self._sz,cbk,id,text) then
		self.tool=text
	end
	self._y=self._y+self._sz
end

function UI:DrawPalette()
	local ox=0
	local oy=40
	local colors=16
	local bsize	=8
	local columns=2
	local colorspercol = math.floor(colors/columns)
	for c=0,colors-1 do
		local iy = c%colorspercol
		local ix = c//colorspercol
		local ml, mr = self:Button(ox+ix*bsize,oy+iy*bsize,bsize+1,bsize+1,c,tostring(c))
		if ml then self.color1=c end
		if mr then self.color2=c end
	end
	CirclePal(ox+bsize*0.5, oy-bsize*0.6, bsize/2, self.color1)
	CirclePal(ox+bsize*1.5, oy-bsize*0.6, bsize/2, self.color2)	
end

function UI:DrawTools()
	self._sz=12
	self._x=gSizeX-self._sz
	self._y=40
	self:ButtonTool(256,"line")
	self:ButtonTool(257,"circle")
	self:ButtonTool(258,"fill")
	self:ButtonTool(259,"wait")
	self:ButtonTool(260,"trash")
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
		self:DrawTools()
		self:DrawMenu()
		self:DrawSequencer()
	end
	self:DrawTooltips()

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
				if self.tool=="line" then
					PlotLine(xStart,yStart,mx,my,self.color1)
				elseif self.tool=="circle" then
					local dx=mx-xStart
					local dy=my-yStart
					local r=floor(sqrt(dx*dx+dy*dy))
					PlotCircle(xStart,yStart,r,self.color1)
				end
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