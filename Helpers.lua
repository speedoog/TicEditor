gSizeX	=240
gSizeY	=136
gWhite	=12

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function HideCursor()
    poke(0x3FFB,1)
end

function DrawCrosshair(mx, my)
	local max = 2
	local min = 1
	local color = 15
	PlotLine(mx-max, my, mx-min, my, color)
	PlotLine(mx+min, my, mx+max, my, color)
	PlotLine(mx, my-max, mx, my-min, color)
	PlotLine(mx, my+min, mx, my+max, color)
end


function CirclePal(x,y,r,c)
	circ(x, y, r, c)
	circb(x, y, r, 15)
end

