-- title:  vector editor
-- author: rigachupe
-- desc:   tool for creating vector art
-- script: lua
-- saveid: vectoreditor

-- https://tic80.com/play?cart=1426


-- TODO
-- grouping shapes, always one group exists as global group
 -- group dialog
	-- list of groups
	-- add group, delete group
	-- add shape to group
-- bones and animations
-- API for drawing shape forms and animating

--put encoded shape data string here to unpack it
local shapeData=""--"1,2,10,10,100,20,2,3,90,50,60,20,3,4,60,60,70,80,6,0,4,114,74,78,95,110,115,113,89,4,9,181,37,208,56,170,71,5,7,6,149,27,126,19,115,37,124,49,142,52,149,42,7,5,50,54,69,66,8,5,3,184,54"

--flag for loading shapeData into shapes array
local loaded=false
local saved=1

--local position and zoom factor
local x=0
local y=0
local z=1

--selected color
local c=0

--mouse variables
local mousex,mousey,
 mousexold,mouseyold,
 mousedx,mousedy,
 left,middle,right,
 scrollx,scrolly=0
local pressed=false
local shift=false
local showgui=true

--lock cursor movement in one direction only
local LOCK_NONE=0
local LOCK_VERTICAL=1
local LOCK_HORIZONTAL=2
local lockdirection=LOCK_NONE

--if true then show magnifying glass
local magnify=false

--tools : line, circle, tri, rect, polygon, 
-- continuing line, gradient fill, pattern fill
-- paste
local LIN=1
local RCT=2
local CRC=3
local TRI=4
local PLG=5
local CLI=6
local GRD=7
local FIL=8
local PAS=100
local CPY=101

--stored polygon points when editing
local poly={}

--stored copied shape
local copiedShape=nil

--edited point
local pointEdited=nil

--edited shape
local shapeEdited=nil
local shapeEditedIndex=0

--selected shape
--local shapeSelected=nil

--true if redraw is needed
local redraw=true

--shapes created
local shapes={}

--groups created
local groups={}

--settings
local showPoints=true
local snapPoint=false
local tool=LIN
local pattern=0

--gui
guiColors={
 x=0,
	y=128,
	[1]={
	 x=0,
		y=0,
		w=8,
		h=8,
		n="black",
		drw=function()
		 return c==0 and 51 or 35
		end,
		clk=function()
		 setColor(0)
		end,
	},
	[2]={
	 x=8,
		y=0,
		w=8,
		h=8,
		n="purple",
		drw=function()
		 return c==1 and 52 or 36
		end,
		clk=function()
		 setColor(1)
		end,
	},
	[3]={
	 x=16,
		y=0,
		w=8,
		h=8,
		n="red",
		drw=function()
		 return c==2 and 53 or 37
		end,
		clk=function()
		 setColor(2)
		end,
	},
	[4]={
	 x=24,
		y=0,
		w=8,
		h=8,
		n="orange",
		drw=function()
		 return c==3 and 54 or 38
		end,
		clk=function()
		 setColor(3)
		end,
	},
	[5]={--
	 x=32,
		y=0,
		w=8,
		h=8,
		n="yellow",
		drw=function()
		 return c==4 and 55 or 39
		end,
		clk=function()
		 setColor(4)
		end,
	},
	[6]={
	 x=40,
		y=0,
		w=8,
		h=8,
		n="light green",
		drw=function()
		 return c==5 and 56 or 40
		end,
		clk=function()
		 setColor(5)
		end,
	},
	[7]={
	 x=48,
		y=0,
		w=8,
		h=8,
		n="green",
		drw=function()
		 return c==6 and 57 or 41
		end,
		clk=function()
		 setColor(6)
		end,
	},
	[8]={
	 x=56,
		y=0,
		w=8,
		h=8,
		n="dark green",
		drw=function()
		 return c==7 and 58 or 42
		end,
		clk=function()
		 setColor(7)
		end,
	},
	[9]={
	 x=64,
		y=0,
		w=8,
		h=8,
		n="dark blue",
		drw=function()
		 return c==8 and 83 or 67
		end,
		clk=function()
		 setColor(8)
		end,
	},
	[10]={
	 x=72,
		y=0,
		w=8,
		h=8,
		n="blue",
		drw=function()
		 return c==9 and 84 or 68
		end,
		clk=function()
		 setColor(9)
		end,
	},
	[11]={
	 x=80,
		y=0,
		w=8,
		h=8,
		n="light blue",
		drw=function()
		 return c==10 and 85 or 69
		end,
		clk=function()
		 setColor(10)
		end,
	},
	[12]={
	 x=88,
		y=0,
		w=8,
		h=8,
		n="cyan",
		drw=function()
		 return c==11 and 86 or 70
		end,
		clk=function()
		 setColor(11)
		end,
	},
	[13]={
	 x=96,
		y=0,
		w=8,
		h=8,
		n="white",
		drw=function()
		 return c==12 and 87 or 71
		end,
		clk=function()
		 setColor(12)
		end,
	},
	[14]={
	 x=104,
		y=0,
		w=8,
		h=8,
		n="light gray",
		drw=function()
		 return c==13 and 88 or 72
		end,
		clk=function()
		 setColor(13)
		end,
	},
	[15]={
	 x=112,
		y=0,
		w=8,
		h=8,
		n="gray",
		drw=function()
		 return c==14 and 89 or 73
		end,
		clk=function()
		 setColor(14)
		end,
	},
	[16]={
	 x=120,
		y=0,
		w=8,
		h=8,
		n="dark gray",
		drw=function()
		 return c==15 and 90 or 74
		end,
		clk=function()
		 setColor(15)
		end,
	},
}

guiTools={
 x=129,
	y=128,
 [1]={
	 x=0,
		y=0,
		w=8,
		h=8,
		n="line",
		drw=function()
		 return tool==LIN and 19 or 3
		end,
		clk=function()
		 tool=LIN
			poly={}
			selectNothing()
			repaint()
		end,
	},
	[2]={
	 x=8,
	 y=0,
		w=8,
		h=8,
		n="continuing line",
		drw=function()
		 return tool==CLI and 28 or 12
		end,
		clk=function()
		 tool=CLI
			poly={}
			selectNothing()
			repaint()
		end,
	},
	[3]={
	 x=16,
	 y=0,
		w=8,
		h=8,
		n="rectangle",
		drw=function()
		 return tool==RCT and 20 or 4
		end,
		clk=function()
		 tool=RCT
			poly={}
			selectNothing()
			repaint()
		end,
	},
	[4]={
	 x=24,
	 y=0,
		w=8,
		h=8,
		n="circle",
		drw=function()
		 return tool==CRC and 21 or 5
		end,
		clk=function()
		 tool=CRC
			poly={}
			selectNothing()
			repaint()
		end,
	},
	[5]={
	 x=32,
	 y=0,
		w=8,
		h=8,
		n="triangle",
		drw=function()
		 return tool==TRI and 22 or 6
		end,
		clk=function()
		 tool=TRI
			poly={}
			selectNothing()
  	repaint()			
		end,
	},
	[6]={
	 x=40,
	 y=0,
		w=8,
		h=8,
		n="polygon",
		drw=function()
		 return tool==PLG and 23 or 7
		end,
		clk=function()
		 tool=PLG
			poly={}
			selectNothing()
			repaint()
		end,
	},
	[7]={
	 x=48,
	 y=0,
		w=8,
		h=8,
		n="gradient fill",
		drw=function()
		 return tool==GRD and 30 or 29
		end,
		clk=function()
		 tool=GRD
			poly={}
			selectNothing()
			repaint()
		end,
	},
	[8]={
	 x=56,
	 y=0,
		w=8,
		h=8,
		n="pattern fill",
		drw=function()
		 return tool==FIL and 31 or 15
		end,
		clk=function()
		 tool=FIL
			poly={}
			selectNothing()
			repaint()
		end,
	},
	[9]={
	 x=64,
	 y=0,
		w=8,
		h=8,
		n="move point",
		k=64, --shift
		drw=function()
		 --return snapPoint and 25 or 9
			return shift and 25 or 9
		end,
		clk=function()
			shift=not shift
			guiTools[9].n=shift and "move shape" or "move point"
		end,
	},
	[10]={
	 x=72,
	 y=0,
		w=8,
		h=8,
		n="save",
		drw=function()
		 return 10
		end,
		clk=function()
		 trace("Saving shapes to console... ("..saved..")")
			saved=saved+1
			saveShapes()
		end,
	},
	[11]={
	 x=80,
	 y=0,
		w=8,
		h=8,
		n="undo",
		k=51, --backspace
		drw=function()
		 return 13
		end,
		clk=function()
		 if #shapes>0 then
			 shapes[#shapes]=nil
				repaint()
			end
		end,
	},
	[12]={
	 x=88,
	 y=0,
		w=8,
		h=8,
		n="delete",
		k=52, --delete
		drw=function()
		 return 14
		end,
		clk=function()
		 if shapeEditedIndex>0 then
				table.remove(shapes,shapeEditedIndex)
			 pointEdited=nil
				shapeEdited=nil
				shapeEditedIndex=0
				selectLastShape()
 			repaint()
			else
			 table.remove(shapes,#shapes)
				pointEdited=nil
				shapeEdited=nil
				shapeEditedIndex=0
				selectLastShape()
 			repaint()
			end
		end,
	},
	[13]={
	 x=96,
	 y=0,
		w=8,
		h=8,
		n="copy",
		k=3,
		drw=function()
		 return 43 --tool==CPY and 44 or 43
		end,
		clk=function()
		 tool=CPY
	  if shapeEditedIndex>0 then
			 copiedShape=deepcopy(shapeEdited)
				tool=PAS
		 end
 	end,
	},
	[14]={
	 x=104,
	 y=0,
		w=8,
		h=8,
		n="paste",
		k=16,
		drw=function()
		 return tool==PAS and 27 or 11
		end,
		clk=function()
		 tool=PAS
		end,
	},
}

guiPattern={
 x=129,
	y=119,
 [1]={
	 x=0,
	 y=0,
		w=8,
		h=8,
		drw=function()
		 return pattern==0 and 272 or 256
		end,
		clk=function()
		 setPattern(0)
		end,
	},
	[2]={
	 x=8,
	 y=0,
		w=8,
		h=8,
		drw=function()
		 return pattern==1 and 273 or 257
		end,
		clk=function()
		 setPattern(1)
		end,
	},
	[3]={
	 x=16,
	 y=0,
		w=8,
		h=8,
		drw=function()
		 return pattern==2 and 274 or 258
		end,
		clk=function()
		 setPattern(2)
		end,
	},
	[4]={
	 x=24,
	 y=0,
		w=8,
		h=8,
		drw=function()
		 return pattern==3 and 275 or 259
		end,
		clk=function()
		 setPattern(3)
		end,
	},
	[5]={
	 x=32,
	 y=0,
		w=8,
		h=8,
		drw=function()
		 return pattern==4 and 276 or 260
		end,
		clk=function()
		 setPattern(4)
		end,
	},
	[6]={
	 x=40,
	 y=0,
		w=8,
		h=8,
		drw=function()
		 return pattern==5 and 277 or 261
		end,
		clk=function()
		 setPattern(5)
		end,
	},
	[7]={
	 x=48,
	 y=0,
		w=8,
		h=8,
		drw=function()
		 return pattern==6 and 278 or 262
		end,
		clk=function()
		 setPattern(6)
		end,
	},
	[8]={
	 x=56,
	 y=0,
		w=8,
		h=8,
		drw=function()
		 return pattern==7 and 279 or 263
		end,
		clk=function()
		 setPattern(7)
		end,
	},
	[9]={
	 x=64,
	 y=0,
		w=8,
		h=8,
		drw=function()
		 return pattern==8 and 280 or 264
		end,
		clk=function()
		 setPattern(8)
		end,
	},
	[10]={
	 x=72,
	 y=0,
		w=8,
		h=8,
		drw=function()
		 return pattern==9 and 281 or 265
		end,
		clk=function()
		 setPattern(9)
		end,
	},
	[11]={
	 x=80,
	 y=0,
		w=8,
		h=8,
		drw=function()
		 return pattern==10 and 282 or 266
		end,
		clk=function()
		 setPattern(10)
		end,
	},
}

function TIC()
 --load shapeData only once
	if loaded==false then
	 loaded=true
		loadShapes()
	end

 --mouse and keyboard
 getInput()
	
	--paint drawing
	if redraw==true then
	 --but only when redrawing is needed to not use cpu
	 redraw=false
 	cls(13)
		--drawGrid()
 	drawShapes()
		saveScreen()
	else
	 --this draws stored screen for less cpu consumption
	 showScreen()
	end
	
	--draw what is edited and rest of gui
	drawMagnify()
	drawMouseAxis()
	drawEditedShape()
	drawPalette()
	
	--show how many points are stored in drawing
	--outline("shapes:"..#shapes,5,5,0)
	--outline("redrawing:"..(redraw and "yes" or "no"),5,15,0)

	--cursor
	if key(63)==false then
 	spr(17,(mousex+x)*z,(mousey+y)*z,0)
	end
	poke(0x03FFB,0)
end

--get mouse and keyboard change
function getInput()
 --mouse get the point
 mousex,mousey,left,middle,right,scrollx,scrolly=mouse()
	if mousex>250 then mousex=0 end
	if mousex>239 then mousex=239 end
	if mousey>250 then mousey=0 end
	if mousey>135 then mousey=135 end
	if mousexold==nil or mouseyold==nil then
	 mousexold=mousex
		mouseyold=mousey
	end
	mousedx=mousex-mousexold
 mousedy=mousey-mouseyold
	mousexold=mousex
	mouseyold=mousey
	
	--snap mouse to liner planes when holding ctrl
	if key(63) then
	 local i=#poly
		if i>0 then
		 --if distance2(mousex,poly[i].x)>distance2(mousey,poly[i].y) then
			if lockdirection==LOCK_VERTICAL then
			 mousey=poly[i].y
			elseif lockdirection==LOCK_HORIZONTAL then
	   mousex=poly[i].x
	  end		
		end
 end
		
	--[[
	--keys move screen to sides
	if btn(0) then y=y-1 repaint() end
	if btn(1) then y=y+1 repaint() end
	if btn(2) then x=x-1 repaint() end
	if btn(3) then x=x+1 repaint() end
	--]]
	--H
	if keyp(8) then
	 if lockdirection~=LOCK_HORIZONTAL then
		 lockdirection=LOCK_HORIZONTAL
		else
		 lockdirection=LOCK_NONE
		end
	end
	--V
	if keyp(22) then
	 if lockdirection~=LOCK_VERTICAL then
		 lockdirection=LOCK_VERTICAL
		else
		 lockdirection=LOCK_NONE
		end
	end
	--M
	if keyp(13) then
	 magnify= not magnify
	end
	
	--move hierarchy shapes
	if shapeEdited and shapeEditedIndex>0 then
	 local i=shapeEditedIndex
		local k=#shapes
		local s
		if keyp(54) then --pgup
		 if i<k then
			 s=shapes[i+1]
				shapes[i+1]=shapes[i]
				shapes[i]=s
				shapeEditedIndex=i+1
				repaint()
			end
		end
		if keyp(55) then --pgdown
		 if i>1 then
			 s=shapes[i-1]
				shapes[i-1]=shapes[i]
				shapes[i]=s
				shapeEditedIndex=i-1
				repaint()
			end
		end
		if keyp(56) then --home
		 table.remove(shapes,i)
			table.insert(shapes,shapeEdited)
			shapeEditedIndex=k
			repaint()
		end
		if keyp(57) then --end
		 table.remove(shapes,i)
			table.insert(shapes,1,shapeEdited)
			shapeEditedIndex=1
			repaint()
		end
	end
	
	--tab show/hide gui
	if keyp(49) then
	 showgui=not showgui
	end
	
	--alt switches points visiblity
	if keyp(65) then
	 showPoints=not showPoints
		repaint()
	end
	
	--mouse zoom
	if scrolly<0 then
	 --z=z-0.1
		if z<0.1 then
		 z=0.1
		end
	end
	if scrolly>0 then
	 --z=z+0.1
		if z>4 then
		 z=4
		end
	end
	--mouse clicked
	if left==false and right==false and pressed==true then
	 pressed=false
	end
	
	--left click selects gui or creates points
	if left and pressed==false then
	 pressed=true
	 local b1=clickGui(guiTools)
  local	b2=clickGui(guiColors)
		local b3=false
		if tool==FIL then
		 b3=clickGui(guiPattern)
		end
		if b1==false and b2==false and b3==false then
 		createPoint()
		end
	end
	
	--right click moves points with cursor
	if right then
	 if pressed==false then
 	 pressed=true
			if shift then
			 editShape()
			else
	 	 editPoint()
			end
		else
		 if shift then
			 moveShape()
			else
		  movePoint()
			end
		end
	end
	
	--check key strokes
	keyGui(guiTools)
end

--paint center of mouse
function drawMouseAxis()
	if key(63) then
	 local y=mousey*z
		local x=mousex*z
		local co=getOppositeColor(c)
	 line(0,y,240,y,co)
		line(x,0,x,136,co)
	end
end

--paint grid
function drawGrid()
 local step=8
 for j=0,135,step do
  for i=0,239,step do
		 pix(i,j,15)
		end
	end
end

--draw all stored shapes
function drawShapes()
 for i=1,#shapes do
	 local s=shapes[i]
		drawShape(s)
	end
end

--draw vector art shape
function drawShape(s)
 local c=s.c
	local co=getOppositeColor(c)
	local p=s.p
 if s.t==LIN then
	 local sx=x+p[1].x
	 local	sy=y+p[1].y
		local mx=x+p[2].x
		local my=y+p[2].y
	 line(sx*z,sy*z,mx*z,my*z,c)
	elseif s.t==CLI then
  local sx=x+p[1].x
	 local	sy=y+p[1].y
		for i=2,#p do
		 local mx=x+p[i].x
			local my=y+p[i].y
		 line(sx*z,sy*z,mx*z,my*z,c)
			sx=mx
			sy=my
		end
	elseif s.t==RCT then
	 local sx=x+p[1].x
	 local	sy=y+p[1].y
		local mx=x+p[2].x
		local my=y+p[2].y
		sx,mx=getLesserFirst(sx,mx)
		sy,my=getLesserFirst(sy,my)
	 rect(sx*z,sy*z,(mx-sx)*z,(my-sy)*z,c)
		--if shapeSelected==s then
		-- rectb(sx*z,sy*z,(mx-sx)*z,(my-sy)*z,co)
		--end
	elseif s.t==CRC then
	 local sx=x+p[1].x
	 local	sy=y+p[1].y
		local mx=x+p[2].x
		local my=y+p[2].y
		local dx=sx-mx
		local dy=sy-my
		local r=math.sqrt(dx*dx+dy*dy)
	 circ(sx*z,sy*z,r*z,c)
		--if shapeSelected==s then
		-- circb(sx*z,sy*z,r*z,co)
		--end
	elseif s.t==TRI then
		local sx=x+p[1].x
	 local	sy=y+p[1].y
		local mx=x+p[2].x
		local my=y+p[2].y
		local ex=x+p[3].x
		local ey=y+p[3].y
	 tri(sx*z,sy*z,mx*z,my*z,ex*z,ey*z,c)
		--if shapeSelected==s then
		-- line(sx*z,sy*z,mx*z,my*z,co)
		--	line(sx*z,sy*z,ex*z,ey*z,co)
		--	line(ex*z,ey*z,mx*z,my*z,co)
		--end
	elseif s.t==PLG then
		local sx=x+p[1].x
	 local	sy=y+p[1].y
		local mx=x+p[2].x
		local my=y+p[2].y
		local ex,ey
		for i=3,#p do
		 local p = p[i]
		 ex=x+p.x
			ey=y+p.y
		 tri(sx*z,sy*z,mx*z,my*z,ex*z,ey*z,c)
			mx=ex
			my=ey
		end
	 --[[if shapeSelected==s then
		 mx=sx
			my=sy
		 for i=2,#p do
		  local p = p[i]
		  ex=x+p.x
			 ey=y+p.y
		  line(mx*z,my*z,ex*z,ey*z,co)
			 mx=ex
			 my=ey
		 end
			line(sx*z,sy*z,ex*z,ey*z,co)
		end]]--
	elseif s.t==GRD then
	 local sx=x+p[1].x
	 local	sy=y+p[1].y
		local mx=x+p[2].x
		local my=y+p[2].y
		gradfill(sx*z,sy*z,mx*z,my*z,c)
	elseif s.t==FIL then
	 local sx=x+p[1].x
	 local	sy=y+p[1].y
	 floodfill(sx*z,sy*z,c,s.f)
	end
	
	--paint points
	if showPoints then
	 local all=shapeEdited==s
		for i=1,#s.p do
		 local p=s.p[i]
   spr((all or p==pointEdited) and 18 or 2,(p.x-3+x)*z,(p.y-3+y)*z,0)
		end	
	end
end

--draw vector art shapes
function drawEditedShape()
 if tool==LIN then
	 if #poly==1 then
		 local sx=poly[1].x
		 local	sy=poly[1].y
			local mx=mousex
			local my=mousey
			--[[if key(63) then
			 if distance2(sx,mx)>distance2(sy,my) then
				 my=sy
				else
				 mx=sx
				end
			end]]--
		 line(sx*z,sy*z,mx*z,my*z,c)
		end
	elseif tool==CLI then
	 if #poly>=1 then
	  local sx=poly[1].x
		 local	sy=poly[1].y
			for i=2,#poly do
			 local mx=poly[i].x
				local my=poly[i].y
			 line(sx*z,sy*z,mx*z,my*z,c)
				sx=mx
				sy=my
			end
			local mx=mousex
			local my=mousey
--[[			if key(63) then
			 if distance2(sx,mx)>distance2(sy,my) then
				 my=sy
				else
				 mx=sx
				end
			end
]]--			
		 line(sx*z,sy*z,mx*z,my*z,c)
	 end
	elseif tool==RCT then
	 if #poly==1 then
		 local sx=poly[1].x
		 local	sy=poly[1].y
			local mx=mousex
			local my=mousey
			sx,mx=getLesserFirst(sx,mx)
			sy,my=getLesserFirst(sy,my)
		 rect(sx*z,sy*z,(mx-sx)*z,(my-sy)*z,c)
		end
	elseif tool==CRC then
	 if #poly==1 then
		 local sx=poly[1].x
		 local	sy=poly[1].y
			local mx=mousex
			local my=mousey
			local dx=sx-mx
			local dy=sy-my
			local r=sqrt(dx*dx+dy*dy)
		 circ(sx*z,sy*z,r*z,c)
		end
	elseif tool==TRI then
	 if #poly==2 then
			local sx=poly[1].x
		 local	sy=poly[1].y
			local mx=poly[2].x
			local my=poly[2].y
			local ex=mousex
			local ey=mousey
		 tri(sx*z+x,sy*z+y,mx*z+x,my*z+y,ex*z+x,ey*z+y,c)
		end
	elseif tool==PLG then
	 if #poly>=2 then
			local sx=poly[1].x
		 local	sy=poly[1].y
			local mx=poly[2].x
			local my=poly[2].y
			local ex,ey,ec
			for i=3,#poly do
			 local p=poly[i]
			 ex=p.x
				ey=p.y
				ec=p.c
			 tri(sx*z+x,sy*z+y,mx*z+x,my*z+y,ex*z+x,ey*z+y,c)
				mx=ex
				my=ey
			end
		end
	elseif tool==GRD then
	 if #poly==2 then
		 local sx=poly[1].x
		 local	sy=poly[1].y
			local mx=mousex
			local my=mousey
		 line(sx*z,sy*z,mx*z,my*z,c)
		end
	elseif tool==FIL then
		local mx=mousex
		local my=mousey
		spr(16,mx*z,my*z,0)
	end
	
	--paint points
	if showPoints then
		for i=1,#poly do
		 local p = poly[i]
			spr(18,(p.x-3+x)*z,(p.y-3+y)*z,0)
		end	
		--if pointEdited==nil then
 	--	spr(17,(mousex+x)*z,(mousey+y)*z,0)
		--end
	end
end

--draw palette and selected color
function drawPalette()
	drawGui(guiTools)
	drawGui(guiColors)
	if tool==FIL then
 	drawGui(guiPattern)
	end
	tooltipGui(guiTools)
	tooltipGui(guiColors)
end

--draw magnifying glass
function drawMagnify()
 if magnify==false then return end
 local bx=0
	local by=0
	if mousex<=26 then
	 bx=240-9*3+1
	end
 local ax=bx
	local ay=by
	local as=8
	for j=mousey-1,mousey+1 do
	 for i=mousex-1,mousex+1 do
		 local col=pix(i,j)
			rect(ax,ay,as,as,col)
			rectb(ax,ay,as,as,0)
			ax=ax+as+1
		end
		ay=ay+as+1
		ax=bx
	end	
	--print("mx="..mousex.." my="..mousey,50,5,0)
end

--check gui key stroke
function keyGui(g)
 if showgui==false then return end
	for i=1,#g do
	 local e=g[i]
		local k=e.k
		if k and keyp(k) then
		 e.clk()
		end
	end
end

--draw defined gui table
function drawGui(g)
 if showgui==false then return end
 local x=g.x
	local y=g.y
	for i=1,#g do
	 local e=g[i]
		local s=e.drw()
		spr(s,x+e.x,y+e.y)
	end
end

--tooltip defined gui table
function tooltipGui(g)
 if showgui==false then return end
 local x=g.x
	local y=g.y
	for i=1,#g do
	 local e=g[i]
  if isMouseIn(x+e.x,y+e.y,e.w,e.h) then
		 outline(e.n,x+e.x,y+e.y-8)
			return
		end
	end
end

--print outlined text
function outline(t,x,y)
 local w=print(t,0,-10)
	if x+w>=240 then
	 x=240-w-1
	end
	print(t,x-1,y-1,0)
	print(t,x+1,y+1,0)
	print(t,x-1,y+1,0)
	print(t,x+1,y-1,0)
	print(t,x-1,y,0)
	print(t,x+1,y,0)
	print(t,x,y-1,0)
	print(t,x,y+1,0)
 print(t,x,y,12)
end

--click defined gui table
function clickGui(g)
 if showgui==false then return false end
 local x=g.x
	local y=g.y
	for i=1,#g do
	 local e=g[i]
  if isMouseIn(x+e.x,y+e.y,e.w,e.h) then
 	 e.clk()
			return true
		end
	end
	return false
end

--get opposite color
function getOppositeColor(c)
 if c==0 or c==1 or c==8 or c==15 then return 12 end
	return 0
end

--create a new point when clicked on the editing plane
function createPoint()
	if mousey<136 and left then
	 local p
		local mx=mousex*z-x
		local my=mousey*z-y
		--check if not at the same spot as previous point
		if #poly>0 then
 		p=poly[#poly]
			if p.x==mx and p.y==my then
			 --either end some of the complex shapes
			 if tool==CLI then
				 local s={}
					s.c=c
					s.t=CLI
					s.p=poly
					shapes[#shapes+1]=s
					poly={}
					selectLastShape()
					repaint()
				elseif tool==PLG then
				 local s={}
					s.c=c
					s.t=PLG
					s.p=poly
					shapes[#shapes+1]=s
					poly={}
					selectLastShape()
					repaint()
				end
				--or return because we do not want to have multiple points
				--on the same position
			 return
			end
		end
		
		if tool==PAS then
		 if copiedShape then
 		 local s=deepcopy(copiedShape)
				local dx=s.p[1].x-mx
				local dy=s.p[1].y-my
				for i=1,#s.p do
				 p=s.p[i]
					p.x=p.x-dx
					p.y=p.y-dy
				end
				shapes[#shapes+1]=s
				poly={}
				selectLastShape()
				repaint()
				return
			end
		end
		
		--create new point
		p={}
		p.x = mx
		p.y = my
		poly[#poly+1] = p
		
		--and add shape if finished to the stack
		if tool==LIN then
		 if #poly==2 then
			 local s={}
				s.c=c
				s.t=LIN
				s.p=poly
				--[[
				if key(63) then
				 if distance2(s.p[1].x,mx)>distance2(s.p[1].y,my) then
					 s.p[2].y=s.p[1].y
					else
					 s.p[2].x=s.p[1].x
					end
				end
				]]--
				shapes[#shapes+1]=s
				poly={}
				selectLastShape()
				repaint()
			end
		--[[
		elseif tool==CLI then
		 if #poly>1 then
			 local i=#poly
				local j=i-1
			 if key(63) then
					if distance2(poly[j].x,mx)>distance2(poly[j].y,my) then
						poly[i].y=poly[j].y
					else
						poly[i].x=poly[j].x
					end
				end
			end
		]]--
		elseif tool==RCT then
		 if #poly==2 then
			 local s={}
				s.c=c
				s.t=RCT
				s.p=poly
				shapes[#shapes+1]=s
				poly={}
				selectLastShape()
				repaint()
			end
		elseif tool==CRC then
		 if #poly==2 then
			 local s={}
				s.c=c
				s.t=CRC
				s.p=poly
				shapes[#shapes+1]=s
				poly={}
				selectLastShape()
				repaint()
			end
		elseif tool==TRI then
		 if #poly==3 then
			 local s={}
				s.c=c
				s.t=TRI
				s.p=poly
				shapes[#shapes+1]=s
				poly={}
				selectLastShape()
				repaint()
			end
		elseif tool==GRD then
		 if #poly==2 then
			 local s={}
				s.c=c
				s.t=GRD
				s.p=poly
				shapes[#shapes+1]=s
				poly={}
				selectLastShape()
				repaint()
			end
		elseif tool==FIL then
		 if #poly==1 then
			 local s={}
				s.c=c
				s.f=pattern
				s.t=FIL
				s.p=poly
				shapes[#shapes+1]=s
				poly={}
				selectLastShape()
				repaint()
			end
		end
	end
end

--select last added shape
function selectLastShape()
 shapeEditedIndex=#shapes
	if shapeEditedIndex==0 then
	 shapeEdited=nil
		pointEdited=nil
		return
	end
 shapeEdited=shapes[shapeEditedIndex]
 pointEdited=shapeEdited.p[1]
end

--select nothing
function selectNothing()
 pointEdited=nil
	shapeEdited=nil
	shapeEditedIndex=0
end

--point editation selection
function editPoint()
 pointEdited=nil
	shapeEdited=nil
	shapeEditedIndex=0
	local d=999999
 for i=#shapes,1,-1 do
	 local s=shapes[i]
	 for j=1,#s.p do
		 local p=s.p[j]
			local dx=mousex-p.x
			local dy=mousey-p.y
			local dp=math.sqrt(dx*dx+dy*dy)
			if d>dp then 
			 d=dp
				if d<5 then
 				pointEdited=p
					shapeEdited=s
					shapeEditedIndex=i
				end
			end
		end
	end
	repaint()
end

--shape editation selection
function editShape()
 shapeEdited=nil
	pointEdited=nil
	shapeEditedIndex=0
	for i=#shapes,1,-1 do
	 local s=shapes[i]
		if s.t==LIN then
		 if mouseInLine(s.p[1],s.p[2]) then
			 shapeEdited=s
				shapeEditedIndex=i
				break
			end
		elseif s.t==CLI then
		 for j=2,#s.p do
			 if mouseInLine(s.p[j-1],s.p[j]) then
			  shapeEdited=s
				 shapeEditedIndex=i
					break
		 	end
			end
		elseif s.t==CRC then
		 if mouseInCircle(s.p[1],s.p[2]) then
			 shapeEdited=s
				shapeEditedIndex=i
				break
			end
		elseif s.t==RCT then
		 if mouseInRect(s.p[1],s.p[2]) then
			 shapeEdited=s
				shapeEditedIndex=i
				return
			end
		elseif s.t==TRI then
		 if mouseInTriangle(s.p[1],s.p[2],s.p[3]) then
			 shapeEdited=s
				shapeEditedIndex=i
				break
			end
		elseif s.t==PLG then
		 local p1=s.p[1]
			local p2=s.p[2]
			local p3
		 for j=3,#s.p do
			 p3=s.p[j]
			 if mouseInTriangle(p1,p2,p3) then
				 shapeEdited=s
					shapeEditedIndex=i
					break
				end
				p2=p3
			end
		elseif s.t==FIL then
		 if mouseInPoint(s.p[1]) then
			 shapeEdited=s
				shapeEditedIndex=i
				break
			end
		elseif s.t==GRD then
		 if mouseInPoint(s.p[1]) or mouseInPoint(s.p[2]) then
			 shapeEdited=s
				shapeEditedIndex=i
				break
			end
		end
	end
	repaint()
end

--set color
function setColor(nc)
 c=nc
	if shapeEdited then
	 shapeEdited.c=nc
		repaint()
	end
end

--set pattern
function setPattern(np)
 pattern=np
	if shapeEdited and shapeEdited.t==FIL then
	 shapeEdited.f=np
		repaint()
	end
end

--[[
--select shape by mouse over
function selectShape()
 shapeSelected=nil
 for i=1,#shapes do
	 local s=shapes[i]
		if s.t==CRC then
		 if mouseInCircle(s.p[1],s.p[2]) then
			 shapeSelected=s
				repaint()
				return
			end
		elseif s.t==RCT then
		 if mouseInRect(s.p[1],s.p[2]) then
			 shapeSelected=s
				repaint()
				return
			end
		elseif s.t==TRI then
		 if mouseInTriangle(s.p[1],s.p[2],s.p[3]) then
			 shapeSelected=s
				repaint()
			 return
			end
		elseif s.t==PLG then
		 local p1=s.p[1]
			local p2=s.p[2]
		 for i=3,#s.p do
		  local p3=s.p[i]
				if mouseInTriangle(s.p[1],s.p[2],s.p[3]) then
			  shapeSelected=s
				 repaint()
			  return
			 end
				p2=p3
		 end
		end
	end
end
]]--

--save shapes into string
function saveShapes()
 local f="local shapeData=\""
	local s,p
	for i=1,#shapes do
	 s=shapes[i]
		if i>1 then
		 f=f..","
		end
	 f=f..s.t..","..s.c
		if s.t==FIL then
		 f=f..","..s.f
		end
		if s.t==CLI or s.t==PLG then
		 f=f..","..#s.p
		end
		for j=1,#s.p do
		 p=s.p[j]
			f=f..","..p.x..","..p.y
		end
	end
	f=f.."\""
	trace(f)
end

--load shapes from string
function loadShapes()
 if shapeData=="" then
	 return
	end
	
	local a={}
	for v in shapeData:gmatch("([^,]+)") do
	 table.insert(a,v)
	end
	
	local i=1
	local points=0
	while i<#a do
	 local s={}
		s.p={}
		s.t=tonumber(a[i])
		i=i+1
		s.c=tonumber(a[i])
	 i=i+1
		if s.t==FIL then
		 s.f=tonumber(a[i])
			i=i+1
		end
		
		--trace("shape:"..s.t..","..s.c)
		
		if s.t==CLI or s.t==PLG then
		 points=tonumber(a[i])
			i=i+1
		elseif s.t==FIL then
		 points=1
		elseif s.t==TRI then
		 points=3
		else
		 points=2
		end
		
		--trace("points="..points)
		for j=1,points do
			local p={}
			p.x=tonumber(a[i])
			i=i+1
			p.y=tonumber(a[i])
			i=i+1
			--trace("x:"..p.x.." y:"..p.y)
			table.insert(s.p,p)
		end
		table.insert(shapes,s)
	end
end

--move point where mouse is
function movePoint()
 if pointEdited==nil then return end
	pointEdited.x=mousex
	pointEdited.y=mousey
	repaint()
end

--move whole shape by mouse difference
function moveShape()
 if shapeEdited==nil then return end
	for j=1,#shapeEdited.p do
	 local p=shapeEdited.p[j]
		p.x=p.x+mousedx
		p.y=p.y+mousedy
	end
	repaint()
end

--just force redrawing
function repaint()
 redraw=true
end

--return true if mouse is in rectangle
function isMouseIn(x,y,w,h)
 return mousex>=x and mousex<=x+w and 
   	    mousey>=y and mousey<=y+h
end

--return the lesser value first
function getLesserFirst(a,b)
	if a>b then
	 return b,a
	end
	return a,b
end

--some math functions
sqrt = math.sqrt
abs  = math.abs
flr  = math.floor

--get -1 if value is less than 0 else 1
function sgn(a)
	return a<0 and -1 or 1
end

--get midle value from 3 values
function mid(a,b,c)
 local median = math.max(math.min(a,b), math.min(math.max(a,b),c));
	return median
end

-- get spritesheet pixel
function sget(x,y)
 local addr=0x4000+(x//8+y//8*16)*32 
 return peek4(addr*2+x%8+y%8*8) 
end

-- set spritesheet pixel
function sset(x,y,c)
 local addr=0x4000+(x//8+y//8*16)*32 
 poke4(addr*2+x%8+y%8*8,c) 
end

--fast pattern flood
function floodfill(x,y,nc,pat)
 pat=pat or 0
 local oc=pix(x,y)
 if (oc==nc) then return end
 local queue={}
 local add=mid(pat,0,1)
   
 function fill2(x,y)
	 if x<0 or y<0 or x>239 or y>135 then
		 return
		end
  if pix(x,y)==oc then
   queue[#queue+add]=x*256+y
   pix(x,y,nc)
   if(x>0) then fill2(x-1,y) end
   if(x<239) then fill2(x+1,y) end
   if(y>0) then fill2(x,y-1) end
   if(y<135) then fill2(x,y+1) end
  end
 end
	
 fill2(x,y)
   
 if pat>0 then
  local poff=8*pat + 256*8
  local q,a,b
  for i=1,#queue do
   q=queue[i]
   a=flr(q/256)
   b=q-a*256
   if(sget(poff+a%8,b%8)==0) then pix(a,b,oc) end
  end
 end
end

--gradient fill
bayer={
{0.0625,0.5625,0.1875,0.6875},
{0.8125,0.3125,0.9375,0.4375},
{0.25  ,0.75  ,0.125 ,0.625},
{1.0   ,0.5   ,0.875 ,0.375}}

gradfill_maxdist=100

function gradfill(x0,y0,x1,y1,nc)
 local oc=pix(x0,y0)
 if(oc==nc) then return end
 local queue={}
 
 --gradient line
 local xdist,ydist=x1-x0,y1-y0
 local dist=sqrt(xdist*xdist+ydist*ydist)
 --normal
 local xnorm,ynorm=-ydist,xdist
 local nptx0,npty0=x0+xnorm,y0+ynorm
 local normc=nptx0*y0-npty0*x0
 
 local sgndir=sgn((x1*ynorm-y1*xnorm+normc)/dist)
 local d,sgnd,mod
 
 function gfill(x,y)
	 if x<0 or y<0 or x>239 or y>135 then
		 return
		end
  d=(x*ynorm-y*xnorm+normc)/dist
  sgnd=sgn(d)
  if(sgnd==sgndir and abs(d)>dist) then return end
  if pix(x,y)==oc then
   pix(x,y,nc)
   if(x>0) then gfill(x-1,y) end
   if(x<239) then gfill(x+1,y) end
   if(y>0) then gfill(x,y-1) end
   if(y<135) then gfill(x,y+1) end
   if(sgnd==sgndir) then queue[#queue+1]=x*256+y end
  end
 end
  
	gfill(x0,y0)

 --apply bayer dither
 local q,a,b
 for i=1,#queue do
  q=queue[i]
  a=flr(q/256)
  b=q-a*256
  d=abs((a*ynorm-b*xnorm+normc)/dist)
  if(d/dist>bayer[a%4+1][b%4+1]) then pix(a,b,oc) end
 end
end

--store screen into map memory
function saveScreen()
 local j=32768
 for i=0,16320 do
	 poke(j+i,peek(i))
	end
end

--show stored screen
function showScreen()
 local j=32768
	for i=0,16320 do
	 poke(i,peek(j+i))
	end
end

--copy table with subtables
function deepcopy(orig)
 local orig_type = type(orig)
 local copy
 if orig_type == 'table' then
  copy = {}
  for orig_key, orig_value in next, orig, nil do
      copy[deepcopy(orig_key)] = deepcopy(orig_value)
  end
  setmetatable(copy, deepcopy(getmetatable(orig)))
 else -- number, string, boolean, etc
  copy = orig
 end
 return copy
end

-->> mouse collision with shapes<<--

function mouseInCircle(p1,p2)
	local radius=distance(p1.x,p1.y,p2.x,p2.y)
	return collidePointCircle(mousex,mousey,p1.x,p1.y,radius)
end

function mouseInRect(p1,p2)
	return collidePointRect(mousex,mousey,p1.x,p1.y,p2.x,p2.y)
end

function mouseInTriangle(p1,p2,p3)
 return collidePointTriangle(mousex,mousey,p1.x,p1.y,p2.x,p2.y,p3.x,p3.y)
end

function mouseInLine(p1,p2)
 return collideLinePoint(p1.x,p1.y,p2.x,p2.y,mousex,mousey)
end

function mouseInPoint(p1)
 return collidePointPoint(mousex,mousey,p1.x,p1.y)
end

-->>collision methods provided by TylerBurden<<--

--calculate length between two values
function distance2(a,b)
 return abs(a-b)
end

--calculate distance between two points
function distance(x1,y1,x2,y2)
	local distX=x1-x2
	local distY=y1-y2
	return sqrt((distX*distX)+(distY*distY))
end

--px1,py1=point 1
--px2,py2=point 2
function collidePointPoint(px1,py1,px2,py2)
	--if px1==px2 and py1==py2 then
	if distance(px1,py1,px2,py2)<4 then
		return true
	else
		return false
	end
end

--px,py=point
--x1,y1,x2,y2,x3,y3=triangle points
function collidePointTriangle(px,py,x1,y1,x2,y2,x3,y3)
	local areaO=math.abs((x2-x1)*(y3-y1)-(x3-x1)*(y2-y1))
	local area1=math.abs((x1-px)*(y2-py)-(x2-px)*(y1-py))
	local area2=math.abs((x2-px)*(y3-py)-(x3-px)*(y2-py))
	local area3=math.abs((x3-px)*(y1-py)-(x1-px)*(y3-py))
	if area1+area2+area3==areaO then
		return true
	else
		return false
	end
end

--lx1,ly1,lx2,ly2=line points
--px,py=point
function collideLinePoint(lx1,ly1,lx2,ly2,px,py)
	local len=distance(lx1,ly1,lx2,ly2)
	local d1=distance(px,py,lx1,ly1)
	local d2=distance(px,py,lx2,ly2)
	local buffer=.1
	if d1+d2>=len-buffer and d1+d2<=len+buffer then
		return true
	else
		return false
	end
end

--px,py=point
--cx,cy,cr=circle position and radius
function collidePointCircle(px,py,cx,cy,cr)
	if distance(px,py,cx,cy)<=cr then
		return true
	else
		return false
	end
end

--px,py=point
--rx,ry,rw,rh=rectangle position and size
function collidePointRect(px,py,rx1,ry1,rx2,ry2)
 local x1,x2=getLesserFirst(rx1,rx2)
	local y1,y2=getLesserFirst(ry1,ry2)
	if px>=x1 and	px<=x2 and py>y1 and py<=y2 then
		return true
	else
		return false
	end
end

--px,py=point
--rx,ry,rw,rh=rectangle position and size
function collidePointRect2(px,py,rx,ry,rw,rh)
	if px>=rx and	px<=rx+rw and py>=ry and py<=ry+rh then
		return true
	else
		return false
	end
end