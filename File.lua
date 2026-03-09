
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
	if p[1]=="l" then
		local len=p[2]
		item=CreatePolyLine(p[3])
		local ptcount=(len-1)>>1
		for i=1,ptcount do
			item.pts[i]={p[2+i*2], p[3+i*2]}
		end
	elseif p[1]=="circle" then
		item=CreateCircle(p[2],p[3],p[4],p[5])
	elseif p[1]=="fill" then
		item=CreateFill(p[2],p[3],p[4])
	elseif p[1]=="ellipse" then
		item=CreateEllipse(p[2],p[3],p[4],p[5],p[6])
	end

	return item
end

function AppendItem(scene, item, iPos)
	if item~=nil then
		table.insert(scene.items, iPos, item)
	end
end

function ComputeTotalPix(scene)
	scene.nPix = 0
	for k, item in pairs(scene.items) do
		item:Init()
		item.nPix = 0
		local iPix = 1
		while iPix > 0 do
			iPix = item:Draw()
			item.nPix = item.nPix + iPix
		end
		scene.nPix = scene.nPix + item.nPix
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

	local scene={
		filename=fileName,
		nPix=0,
		items={},
	}

	local f=io.open(fileName, "r")
	if f~=nil then

		while(true) do
			local s=f:read()
			if s==nil then break end
			local item =CreateItem(s)
			AppendItem(scene, item, #scene.items+1)
		end
		io.close(f)
	end
	ComputeTotalPix(scene)
	return scene
end

function Save(scene, fileName)
	if fileName==nil then
		fileName=scene.filename
	end
	local f=io.open(fileName, "w")
	if f~=nil then
		for k, item in pairs(scene.items) do
			local s=item:store()
			f:write(item.type)
			f:write(" ")
			f:write(#s)
			for k,v in pairs(s) do
				f:write(" ")
				f:write(v)
			end
			f:write("\n")
		end
	end
   f:close()
end
