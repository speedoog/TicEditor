local UI = { show=true, color1=2, color2=4, tooltips={}, mode="editor", tool="line", player="pause", _x=0, _y=0,_sz=10 }

gSeqSize=UI._sz
gPixTarget =0
scene = {npix=0}


function UI:DrawTooltips()
	vbank(1)
	for k, tip in pairs(self.tooltips) do
	   	print(tip.t,tip.x,tip.y,tip.c,false,1,true)
	end
	self.tooltips = {}
	vbank(0)
end

function UI:tooltip(text)
  	local mx,my=self.mx,self.my
	local offx=3
	local offy=-8

	w=print(text,gSizeX,gSizeY,0,false,1,true)

	if mx>200 then offx=-w end
	table.insert(self.tooltips, {x=mx+offx,y=my+offy,c=12,t=text})
end

function UI:ButtonLogic(x,y,w,h,text)
  	local mx,my,ml,mr=self.mx,self.my,self.dml,self.dmr
   	local hover =overlap(mx,my,x+1,x+w-1,y+1,y+h-1)
	if hover then
		if text then self:tooltip(text) end
		if ml then self.dml=false end		-- invalidate l/r clicks
		if mr then self.dmr=false end
		return ml,mr
	end
	return false,false
end

function UI:Button(x,y,w,h,c,text)
   	rect(x,y,w,h,c)
   	rectb(x,y,w,h,gGrey)
	return self:ButtonLogic(x,y,w,h,text)
end

function UI:ButtonIcon(x,y,w,h,cbk,id,text)
   	rect(x,y,w,h,cbk)
   	spr(id,x+w/2-4,y+h/2-4,0)
	return self:ButtonLogic(x,y,w,h,text)
end

function UI:ButtonTool(id,text)
	local cbk=gGrey
	if text==self.tool then cbk=2 end
	local b = self:ButtonIcon(self._x,self._y,self._sz,self._sz,cbk,id,text)
	if b then
		self.tool=text
	end
	self._y=self._y+self._sz
	return b
end

function UI:ButtonPlayer(id,text)
	local cbk=gGrey
	if text==self.player then cbk=2 end
	local b = self:ButtonIcon(self._x,self._y,self._sz,self._sz,cbk,id,text)
	if b then
		self.player=text
	end
	self._x=self._x+self._sz
	return b
end

function UI:CirclePal(x,y,r,c,text)
	circ(x, y, r, c)
	circb(x, y, r, gGrey)
  	local mx,my,ml,mr=self.mx,self.my,self.dml,self.dmr
   	local hover = distance(x,y,mx,my)<=r
	if hover then
		self:tooltip(text)
		if ml then self.dml=false end		-- invalidate l/r clicks
		if mr then self.dmr=false end
		return ml,mr
	end
	return false,false
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
	self:CirclePal(ox+bsize*0.5, oy-bsize*0.6, bsize/2, self.color1, "main")
	self:CirclePal(ox+bsize*1.5, oy-bsize*0.6, bsize/2, self.color2, "alt")
end

function UI:DrawTools()
	self._x=gSizeX-self._sz
	self._y=10
	self:ButtonTool(256,"line")
	self:ButtonTool(257,"circle")
	self:ButtonTool(258,"ellipse")
	self:ButtonTool(259,"fill")
	self:ButtonTool(260,"speed")
	if self:ButtonTool(261,"trash") then
		table.remove(scene.items, #scene.items)
		ComputeTotalPix(scene)
	end
end

function UI:DrawMenu()
	local h=7
	rect(0,0,gSizeX,h,gWhite)
	print("Editor",1,1,gBlack)
	self:ButtonLogic(0,0,gSizeX,h)
end

function UI:DrawSequencer()
	local c=13
	local min=UI._sz
	local max=gSizeX
	apix=0
	bpix=0
	a=min
	b=0
	for k, item in pairs(scene.items) do
		bpix = apix+item.npix
		b = remap(bpix,0,scene.npix,min,max)
		rect(a,gSizeY-gSeqSize,b,gSeqSize,c)
		if c==13 then c=gGrey else c=13 end
	 	apix=bpix
	 	a=b
	end

	local mx,my,dml,ml=self.mx,self.my,self.dml,self.ml
	if my>(gSizeY-gSeqSize) then
		if ml then
			gPixTarget =(mx/gSizeX)*scene.npix
			self.dml=false
		end
	end

end

function UI:Draw()
	vbank(1)
	cls()
	vbank(0)

	if keyp(49) then
		self.show = not self.show
	end

	if self.show then
		if self.mode=="editor" then
			self:DrawEditor()
		elseif self.mode=="player" then
			self:DrawPlayer()
		end
	end

	self:DrawTooltips()

end

function UI:DrawEditor()
	vbank(1)
	if self:ButtonIcon(0,gSizeY-self._sz,self._sz,self._sz,gBlack,289,"editor") then
		self.mode="player"
	end

	self:DrawPalette()
	self:DrawTools()
	self:DrawMenu()
	self:DrawSequencer()
	vbank(0)

	self:UpdateItemEditor()
end

function UI:DrawPlayer()
	vbank(1)
	if self:ButtonIcon(0,gSizeY-self._sz,self._sz,self._sz,gBlack,288,"player") then
		self.mode="editor"
	end
	self._x=self._sz+5
	self._y=gSizeY-self._sz

	if self.player=="play" then
		gPixTarget=gPixTarget+1
	end

	if self:ButtonPlayer(304,"play") then
		
	end
	if self:ButtonPlayer(305,"pause") then
		
	end
	if self:ButtonPlayer(306,"begin") then
		gPixTarget=0
		self.player="pause"
	end
	vbank(0)
end

function UI:UpdateItemEditor()
  	local mx,my,dml,ml=self.mx,self.my,self.dml,self.ml

	if dml and btrace==false then
		xStart=mx
		yStart=my
		btrace = true
	end

	if btrace then
		if self.tool=="line" then
			PlotLine(xStart,yStart,mx,my,self.color1)
		elseif self.tool=="circle" then
			local dx=mx-xStart
			local dy=my-yStart
			local r=floor(sqrt(dx*dx+dy*dy))
			PlotCircle(xStart,yStart,r,self.color1)
		elseif self.tool=="ellipse" then
			local a=abs(mx-xStart)
			local b=abs(my-yStart)
			PlotEllipse(xStart,yStart,a,b,self.color1)
		end
	end

	if btrace and ml==false then
		local item=nil
		if self.tool=="line" then
			item = CreateLine(xStart,yStart,mx,my,self.color1)
		elseif self.tool=="circle" then
			local dx=mx-xStart
			local dy=my-yStart
			local r=floor(sqrt(dx*dx+dy*dy))
			item=CreateCircle(xStart,yStart,r,self.color1)
		elseif self.tool=="ellipse" then
			local a=abs(mx-xStart)
			local b=abs(my-yStart)
			item=CreateEllipse(xStart,yStart,a,b,self.color1)
		elseif self.tool=="fill" then
			item=CreateFill(xStart,yStart,self.color1)
		end

		AppendItem(scene,item)
		ComputeTotalPix(scene)
		gPixTarget=scene.npix
		btrace = false
	end
end

function UI:DrawItems()
	local iPix=0
	local bComplete=false
	local bContinue

	for k, item in pairs(scene.items) do
		bContinue=true
		item:Init()
		while bContinue do
			iPix=iPix+1
			bContinue = item:Draw(function(x,y,c) pix(x,y,c) end)
			if iPix>=gPixTarget then bComplete=true bContinue=false end
		end
		if bComplete then break end
	end
end

MEM_Map=0x08000 

FS={}

function FS_Load(FS)
	ptr=MEM_Map
	local count=peek(ptr)
	ptr=ptr+1
	for ifile=0,count-1 do
		local f={}
		name=""
		while peek(ptr)~=0 do
			c=peek(ptr)
			ptr=ptr+1
			name=name..string.char(c)
		end
		ptr=ptr+1
		szlo=peek(ptr) ptr=ptr+1
		szhi=peek(ptr) ptr=ptr+1
		szfull=szhi*256+szlo
		f.name = name
		f.size = szfull 
		table.insert(FS, f)
	end

	baseAddress = ptr
	for k, f in pairs(FS) do
		f.add=baseAddress
		baseAddress=baseAddress+f.size
		c=peek(f.add)
	end
end

function Pop(address, count)
	local params={}
	for i=0,count-1 do
		table.insert(params, peek(address+i))
	end
	return address+count,params
end

function FS_FindFile(fn)
	for k, f in pairs(FS) do
		if f.name==fn then
			return f
		end
	end
	return nil
end

function FS_LoadScene(file)
	local scene={}
	scene.npix=0
	scene.items={}

	local f=FS_FindFile(file)
	if f==nil then return scene end

	ptr=f.add
	while true do
		b=peek(ptr) ptr=ptr+1
		if b==0 then break end
		
		item=nil
		cmd=string.char(b)
		if cmd=='l' then
			ptr,item = CreateLineMem(ptr)
		elseif cmd=='e' then
			ptr,item = CreateEllipseMem(ptr)
		elseif cmd=='c' then
			ptr,item = CreateCircleMem(ptr)
		elseif cmd=='f' then
			ptr,item = CreateFillMem(ptr)
		end

		if item~=nil then
			AppendItem(scene, item)
		end
	end

	ComputeTotalPix(scene)
	return scene
end


function UI:Init()

	FS_Load(FS)

    xStart = 0
    yStart = 0
    btrace = false
	-- init mouse
	local mx,my,ml,mm,mr=mouse()
	self.mx=mx
	self.my=my
	self.ml=ml
	self.mm=mm
	self.mr=mr

 --   scene = Load("test.txt")
	scene = FS_LoadScene("test.txt")

--	Save(scene, "abc.txt")

	UI:Draw()
end



function plotCubicBezier(x0,y0,x1,y1,x2,y2,x3,y3)
--	DrawCrosshair(x0,y0)
--	DrawCrosshair(x1,y1)
--	DrawCrosshair(x2,y2)
--	DrawCrosshair(x3,y3)
	xa, ya = cubicBezier2(0,x0,y0,x1,y1,x2,y2,x3,y3)
	c=0
	for t = 0,1,0.05 do
		xb=xa
		yb=ya
		xa, ya = cubicBezier2(t,x0,y0,x1,y1,x2,y2,x3,y3)
		line(xa,ya,xb,yb,c%8+1)
		c=c+1
	end
end

function plotbidule(t)
	x0=70+t*sin(t*1.23)
	y0=70+t*cos(t*1.07)
	x1=100+60*sin(t*1.74)
	y1=70+60*cos(t*1.03)
	x2=100+60*sin(t*1.14)
	y2=70+60*cos(t*1.63)
	x3=120+60*sin(t*1.44)
	y3=70+60*cos(t*1.33)
	plotCubicBezier(x0,y0, x1,y1, x2,y2, x3,y3)
end

function UI:Update()

	-- update mouse
	local mx,my,ml,mm,mr=mouse()
	self.dmx = mx - self.mx
	self.dmy = my - self.my
	self.dml = ml and not self.ml
	self.dmm = mm and not self.mm
	self.dmr = mr and not self.mr
	self.mx=mx
	self.my=my
	self.ml=ml
	self.mm=mm
	self.mr=mr

	cls()

	self:Draw()

	self:DrawItems()

	plotCubicBezier(50,50, 30,20, 50,10, 200,100)


end

return UI