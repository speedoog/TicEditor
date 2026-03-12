
gSizeX = 240
gSizeY = 136
gSizeX2 = gSizeX/2
gSizeY2 = gSizeY/2

gBlack	=0
gWhite	=12
gGrey 	=15

gAddPalette = 0x3FC0
gAddBorderCol = 0x3FF8
gAddScreenOffX = 0x3FF9
gAddScreenOffY = 0x3FFA
gAddMap = 0x8000

-- keys (https://skyelynwaddell.github.io/tic80-manual-cheatsheet/)
gKeySpace= 48
gKeyTab	= 49
gKeyUp   = 58
gKeyDown = 59
gKeyLeft = 60
gKeyRight= 61
gKeyCtrl = 63

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
   poke(0x3FFB,0)
end

function DrawCrosshair(mx, my)
	local max = 2
	local min = 1
	local color = gGrey
	PlotLine(mx-max, my, mx-min, my, color)
	PlotLine(mx+min, my, mx+max, my, color)
	PlotLine(mx, my-max, mx, my-min, color)
	PlotLine(mx, my+min, mx, my+max, color)
end


