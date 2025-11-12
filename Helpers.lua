gSizeX	=240
gSizeY	=136
gWhite	=12

function Cursor(mx, my)
	local max = 2
	local min = 1
	local color = 15
	PlotLine(mx-max, my, mx-min, my, color)
	PlotLine(mx+min, my, mx+max, my, color)
	PlotLine(mx, my-max, mx, my-min, color)
	PlotLine(mx, my+min, mx, my+max, color)
end

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
