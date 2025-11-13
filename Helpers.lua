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

function overlap(x,y,x0,x1,y0,y1)
   if x<x0 or x>x1 or y<y0 or y>y1 then return false end
   return true
end

function Button(x,y,w,h,c)
   rect(x,y,w,h,c)
   rectb(x,y,w,h,15)
  	local mx,my,ml,mm,mr=mouse()
   if (ml or mr) and overlap(mx,my,x,x+w,y,y+h) then
      return ml,mr
   end
   return false,false
end
