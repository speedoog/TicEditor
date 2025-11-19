
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

function IsEmpty(s)
	return s == nil or s == ''
end

function CreateItem(l)
	local p=Split(l)
	local item
	if p[1]=="line" then
		item=CreateLine(p[2],p[3],p[4],p[5],p[6])
	elseif p[1]=="circle" then
		item=CreateCircle(p[2],p[3],p[4],p[5])
	elseif p[1]=="fill" then
		item=CreateFill(p[2],p[3],p[4])
	end

	return item
end

function AppendItem(scene, item)
	if item~=nil then
		table.insert(scene.items, item)
	end
end

function ComputeTotalPix(scene)
	scene.npix=0

	cls()
	local bContinue
	for k, item in pairs(scene.items) do
		item:Init()
		item.npix=0
		bContinue=true
		while bContinue do
			item.npix=item.npix+1
			bContinue = item:Draw(function(x,y,c) pix(x,y,c) end)
		end
		scene.npix=scene.npix+item.npix
	end
end

function scandir()
	local filelist={}
    local file = io.popen("dir *.txt /b")
    for filename in file:lines() do
		table.insert(filelist, filename)
    end
    file:close()
    return filelist
end

function Load(fileName)

--	p=scandir()

	local scene={}
	scene.npix=0
	scene.items={}

	local f=io.open(fileName, "r")
	if f~=nil then

		while(true) do
			local s=f:read()
			if s==nil then break end
			local item =CreateItem(s)
			AppendItem(scene, item)
		end
		io.close(f)
	end
	ComputeTotalPix(scene)
	return scene
end

function Save(scene, fileName)
	if fileName==nil then fileName="temp.txt" end
	local f=io.open(fileName, "w")
	if f~=nil then
		for k, item in pairs(scene.items) do
			local sline = item:str().."\n"
			f:write(sline)
		end
	end
   f:close()
end
