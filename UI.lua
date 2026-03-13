local UI = 
{
	show=true,
	color1=2,
	color2=4,
	tooltips={},
	iCurItem=0,
	iCurPt=0,
	mode="editor",
	tool="line",
	player="pause",
	btnx=0,
	btny=0,
	btnSize=10,
	iPixTarget=0,
	btrace = false,

	mx=0,
	my=0,
	ml=false,
	mm=false,
	mr=false,

	dmx = 0,
	dmy = 0,
	dml = false,
	dmm = false,
	dmr = false,
}

scene = {nPix=0}

function UI.DrawTooltips(_)
	vbank(1)
	for k, tip in pairs(_.tooltips) do
	   	print(tip.t,tip.x,tip.y,tip.c,false,1,true)
	end
	_.tooltips = {}
	vbank(0)
end

function UI.Tooltip(_,text)
  	local mx,my=_.mx,_.my
	local offx=3
	local offy=-8

	local w=print(text,gSizeX,gSizeY,0,false,1,true)

	if mx>200 then offx=-w end
	table.insert(_.tooltips, {x=mx+offx,y=my+offy,c=12,t=text})
end

function UI.ButtonLogic(_,x,y,w,h,text)
  	local mx,my,ml,mr=_.mx,_.my,_.dml,_.dmr
   	local hover =overlap(mx,my,x+1,x+w-1,y+1,y+h-1)
	if hover then
		if text then _:Tooltip(text) end
		if ml then _.dml=false end		-- invalidate l/r clicks
		if mr then _.dmr=false end
		return ml,mr
	end
	return false,false
end

function UI.Button(_,x,y,w,h,c,text)
   	rect(x,y,w,h,c)
   	rectb(x,y,w,h,gGrey)
	return _:ButtonLogic(x,y,w,h,text)
end

function UI.ButtonIcon(_,x,y,w,h,cbk,id,text)
   	rect(x,y,w,h,cbk)
   	spr(id,x+w/2-4,y+h/2-4,0)
	return _:ButtonLogic(x,y,w,h,text)
end

function UI.ButtonTool(_,id,text)
	local cbk=gGrey
	if text==_.tool then cbk=2 end
	local b = _:ButtonIcon(_.btnx,_.btny,_.btnSize,_.btnSize,cbk,id,text)
	if b then
		_.tool=text
	end
	_.btny = _.btny+_.btnSize
	return b
end

function UI.ButtonPlayer(_,id,text)
	local cbk=gGrey
	if text==_.player then cbk=2 end
	local b = _:ButtonIcon(_.btnx,_.btny,_.btnSize,_.btnSize,cbk,id,text)
	if b then
		_.player=text
	end
	_.btnx = _.btnx+_.btnSize
	return b
end

function UI.CirclePal(_,x,y,r,c,text)
	circ(x, y, r, c)
	circb(x, y, r, gGrey)
  	local mx,my,ml,mr=_.mx,_.my,_.dml,_.dmr
   	local hover = distance(x,y,mx,my)<=r
	if hover then
		_:Tooltip(text)
		if ml then _.dml=false end		-- invalidate l/r clicks
		if mr then _.dmr=false end
		return ml,mr
	end
	return false,false
end

function UI.DrawPalette(_)
	local ox=0
	local oy=40
	local colors=16
	local bsize	=8
	local columns=2
	local colorspercol = math.floor(colors/columns)
	for c=0,colors-1 do
		local iy = c%colorspercol
		local ix = c//colorspercol
		local ml, mr = _:Button(ox+ix*bsize,oy+iy*bsize,bsize+1,bsize+1,c,tostring(c))
		if ml then _.color1=c end
		if mr then _.color2=c end
	end
	_:CirclePal(ox+bsize*0.5, oy-bsize*0.6, bsize/2, _.color1, "main")
	_:CirclePal(ox+bsize*1.5, oy-bsize*0.6, bsize/2, _.color2, "alt")
end

function UI.DrawTools(_)
	_.btnx = gSizeX-_.btnSize
	_.btny = 10
	local prevTool=_.tool
	_:ButtonTool(256,"line")
	_:ButtonTool(259,"spline")
	_:ButtonTool(257,"circle")
	_:ButtonTool(258,"ellipse")
	_:ButtonTool(260,"fill")
--	_:ButtonTool(267,"speed")
	_:ButtonTool(264,"edit")
	if _:ButtonTool(268,"trash") then
		table.remove(scene.items, _.iCurItem)
		ComputeTotalPix(scene)
		_:SetCurrentItem(_.iCurItem-1)
		_.tool=prevTool							-- restore prev tool
	end
end

function UI.DrawMenu(_)
	local h=7
	rect(0,0,gSizeX,h,gWhite)
	print(string.format("Item %d/%d",_.iCurItem,#scene.items),1,1,gBlack)

	if _.iCurentPt~=0 then 
		local item=scene.items[_.iCurItem]
		if item then
			print(string.format("Pt %d/%d",_.iCurPt,#item.pts),70,1,gBlack)
		end
	end
	_:ButtonLogic(0,0,gSizeX,h)
end

function UI.DrawSequencer(_)
	local c=13
	local min = UI.btnSize
	local max=gSizeX
	local apix=0
	local bpix=0
	local a=min
	local b=0
	local seqSize = UI.btnSize
	for k, item in pairs(scene.items) do
		bpix = apix+item.nPix
		b = remap(bpix,0,scene.nPix,min,max)
		rect(a,gSizeY-seqSize,b,seqSize,c)
		if c==13 then c=gGrey else c=13 end
	 	apix=bpix
	 	a=b
	end

	local mx,my,dml,ml=_.mx,_.my,_.dml,_.ml
	if my>(gSizeY-seqSize) then
		if ml then
			_.iPixTarget =(mx/gSizeX)*scene.nPix
			_.dml=false
		end
	end
end

function UI.SetCurrentItem(_,iItem)
	_.iCurItem = clamp(iItem,0,#scene.items)
	_.iCurPt = 0
	_:SyncPixTarget()
end

function UI.SetCurrentPoint(_,iPt)
	local item=scene.items[_.iCurItem]
	if item then
		_.iCurPt = clamp(iPt,0,#item.pts)
	end
end

function UI.SyncPixTarget(_)
	_.iPixTarget = 0
	for i=1,_.iCurItem do
		_.iPixTarget = _.iPixTarget+scene.items[i].nPix
	end
end

function UI.Draw(_)
	vbank(1)
	cls()
	vbank(0)

	if keyp(gKeyTab) then
		_.show = not _.show
	end

	if _.mode=="editor" then
		if _.show then
			_:DrawEditor()
		end
		_:UpdateItemEditor()
	elseif _.mode=="player" then
		if _.player == "play" then
			_.iPixTarget = _.iPixTarget+2
		end
		if _.show then
			_:DrawPlayer()
		end
	end

	_:DrawTooltips()

	vbank(1)
	DrawCrosshair(_.mx,_.my)
	local item = scene.items[_.iCurItem]
	if item then
		local pt = item.pts[_.iCurPt]
		local edit
		if pt then
			if keyp(gKeyQ,20,1) then pt[1]=pt[1]-1 edit=true end
			if keyp(gKeyD,20,1) then pt[1]=pt[1]+1 edit=true end
			if keyp(gKeyZ,20,1) then pt[2]=pt[2]-1 edit=true end
			if keyp(gKeyS,20,1) then pt[2]=pt[2]+1 edit=true end

			if _.tool=="edit" then
				pt[1] = _.mx
				pt[2] = _.my
			end

			if edit then
				ComputeTotalPix(scene)
				_:SyncPixTarget()
			end

			DrawCrosshair(pt[1],pt[2])
		end
	end
	vbank(0)

end

function UI.DrawEditor(_)
	vbank(1)

	if keyp(gKeyRight,20,1) then
		_:SetCurrentItem(_.iCurItem+1)
	end
	if keyp(gKeyLeft,20,1) then
		_:SetCurrentItem(_.iCurItem-1)
	end

	if keyp(gKeyUp,20,1) then
		_:SetCurrentPoint(_.iCurPt+1)
	end

	if keyp(gKeyDown,20,1) then
		_:SetCurrentPoint(_.iCurPt-1)
	end

	if _:ButtonIcon(0,gSizeY-_.btnSize,_.btnSize,_.btnSize,gBlack,289,"editor") then
		_.mode="player"
	end

	if _:ButtonIcon(0,20,_.btnSize,_.btnSize,gGrey,273,"Save") then
		Save(scene)
	end

	_:DrawPalette()
	_:DrawTools()
	_:DrawMenu()
	_:DrawSequencer()
end

function UI.DrawPlayer(_)
	vbank(1)
	if _:ButtonIcon(0,gSizeY-_.btnSize,_.btnSize,_.btnSize,gBlack,288,"player") then
		_.mode="editor"
	end
	_.btnx = _.btnSize+5
	_.btny = gSizeY-_.btnSize

	if _.player == "pause" then
		if _:ButtonPlayer(304,"play") then
		end
	end

	if _.player == "play" then
		if _:ButtonPlayer(305,"pause") then
		end
	end

	if _:ButtonPlayer(306,"begin") then
		_.iPixTarget = 0
		_.player="pause"
	end
	vbank(0)
end

function UI.UpdateItemEditor(_)
  	local mx,my,dml,dmr,ml=_.mx,_.my,_.dml,_.dmr,_.ml

	local item

	if dml then
		if not _.btrace then									-- 1st click
			if _.tool=="line" then
				item = CreateItem("l")
			elseif _.tool=="spline" then
				item = CreateItem("s")
			end

			if item then									-- item valid, continue init
				item.c = _.color1
				_.btrace = true
				table.insert(item.pts, {mx,my})
				table.insert(item.pts, {mx,my})
				AppendItem(scene,item, _.iCurItem+1)
				ComputeTotalPix(scene)
				_:SetCurrentItem(_.iCurItem+1)
			end
		else												-- New click
			item = scene.items[_.iCurItem]
			local lastpoint=item.pts[#item.pts-1]
			if lastpoint[1]==mx and lastpoint[2]==my then	-- same point = end
				table.remove(item.pts, #item.pts)			-- remove last temp point (duplicate)
				_.btrace=false								-- stop
			else
				item.pts[#item.pts]={mx,my}					-- update point
				table.insert(item.pts, {mx,my})				-- add new one
			end
		end
	end

	if _.btrace then
		if dmr then											-- right click
			item = scene.items[_.iCurItem]
			if #item.pts<=2 then							-- empty item -> Destroy item
				table.remove(scene.items, _.iCurItem)	-- todo may be fix remove in middle of list ?
				ComputeTotalPix(scene)
				_:SetCurrentItem(_.iCurItem-1)
				_.btrace = false
			else											-- remove last point
				table.remove(item.pts, #item.pts)
			end
		else
			item = scene.items[_.iCurItem]				-- currently editing update (classic case)
			item.pts[#item.pts]={mx,my}
			ComputeTotalPix(scene)
			_:SyncPixTarget()
		end
	end

	--[[
	if btrace then
		if _.tool=="line" then
			PlotLine(xStart,yStart,mx,my,_.color1)
		elseif _.tool=="circle" then
			local dx=mx-xStart
			local dy=my-yStart
			local r=floor(sqrt(dx*dx+dy*dy))
			PlotCircle(xStart,yStart,r,_.color1)
		elseif _.tool=="ellipse" then
			local a=abs(mx-xStart)
			local b=abs(my-yStart)
			PlotEllipse(xStart,yStart,a,b,_.color1)
		end
	end

	if btrace and ml==false then
		local item=nil
		if _.tool=="line" then
			item = CreateLine(xStart,yStart,mx,my,_.color1)
		elseif _.tool=="circle" then
			local dx=mx-xStart
			local dy=my-yStart
			local r=floor(sqrt(dx*dx+dy*dy))
			item=CreateCircle(xStart,yStart,r,_.color1)
		elseif _.tool=="ellipse" then
			local a=abs(mx-xStart)
			local b=abs(my-yStart)
			item=CreateEllipse(xStart,yStart,a,b,_.color1)
		elseif _.tool=="fill" then
			item=CreateFill(xStart,yStart,_.color1)
		end

		AppendItem(scene,item)
		ComputeTotalPix(scene)
		_.iPixTarget=scene.nPix
		btrace = false
	end
	]]

end

function UI.DrawItems(_)
	local iPix=0
	local bComplete=false
	local bContinue

	for k, item in pairs(scene.items) do
		bContinue=true
		item:Init()

		while bContinue do
			if iPix >= _.iPixTarget then
				bComplete=true bContinue=false
			else
				local i=item:Draw(function(x,y,c) pix(x,y,c) end)
				bContinue = i>0
				iPix=iPix+i
			end
		end
		if bComplete then break end
	end
end



function UI.Init(_)

	HideCursor()

	scene = Load("test.txt")
	_.iPixTarget = scene.nPix
	_:SetCurrentItem(#scene.items)	-- seek to last

	UI:Draw()
end

function UI.Update(_)

	-- update mouse
	local mx,my,ml,mm,mr=mouse()
	_.dmx = mx - _.mx
	_.dmy = my - _.my
	_.dml = ml and not _.ml
	_.dmm = mm and not _.mm
	_.dmr = mr and not _.mr
	_.mx=mx
	_.my=my
	_.ml=ml
	_.mm=mm
	_.mr=mr

	cls()

	_:DrawItems()

	_:Draw()

end

return UI