
function Split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		local num=tonumber(str)
		if num==nil then 
			table.insert(t, str)
		else
			table.insert(t, num)
		end
	end
	return t
end

function FillString(array)
	local s=""
	for k, l in pairs(array) do
		s = s..tostring(l).." "
	end
	return s
end

function Save(file)
	if file==nil then file="temp.txt" end
	local f=fopen(file)
	for k, item in pairs(scene.items) do
		local sline = item:str().."\n"
		fputs(sline, f)
	end
	fclose(f)
end

function IsEmpty(s)
	return s == nil or s == ''
end

function CreateItem(l)
	local p=Split(l)
	local item
	if (p[1]=="line") then item=CreateLine(p[2],p[3],p[4],p[5],p[6]) end
	if (p[1]=="circle") then item=CreateCircle(p[2],p[3],p[4],p[5]) end

	if item~=nil then
		item:Init()
		item.npix=0
		while item:Draw(function(x,y,c) item.npix=item.npix+1 end) do end
	end
	return item
end

function AppendItem(scene, item)
	if item~=nil then
		item:Init()

		item.npix=0
		while item:Draw(function(x,y,c) item.npix=item.npix+1 end) do end

		scene.npix=scene.npix+item.npix
		table.insert(scene.items, item)
	end
end

function Load()
	local scene={}
	scene.npix=0
	scene.items={}
	local TotalPix=0
	local f=fopen("test.txt", "r")
	if f~=0 then
		while(true) do
			local s=fgets(f)
			if IsEmpty(s) then
				break
			else
				local item =CreateItem(s)
				AppendItem(scene, item)
			end
		end
		fclose(f)
	end
--	scene.TotalPix = TotalPix
--	trace("total "..TotalPix)
--	trace(dump(scene))
	return scene
end
