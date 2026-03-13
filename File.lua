

function CreateItemBase(t,c)
	return {nPix = 0,type = t,c=c, pts = {}}
end

function CreateItem(cmd)
	if gItemFactory==nil then
		gItemFactory = {
			["l"] = CreatePolyLine,
			-- ["e"] = true,
			-- ["c"] = true,
			-- ["f"] = true,
			["s"] = CreateSpline,
		}
	end
	local item
	local fnCreate = gItemFactory[cmd]
	if fnCreate then
		item = CreateItemBase(cmd)
		fnCreate(item)
	end
	return item
end

function LoadItem(l,Factory)
	local p=Split(l)
	local cmd = p[1]

	local item = CreateItem(cmd)

	if item then
		table.remove(p,1)	-- cmd
		table.remove(p,1)	-- size
		item:Load(p)
	end

	return item
end

function AppendItem(scene, item, iPos)
	if item~=nil then
		if iPos==nil then
			iPos=#scene.items+1
		end
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

function ScanDir(filter)
	if filter == nil then filter = "*" end
	local filelist={}
	local file = io.popen("dir "..filter.." /b")
	if file then
		for filename in file:lines() do
			table.insert(filelist, filename)
		end
		file:close()
	end
    return filelist
end


function Load(fileName)

--	local filelist = ScanDir("*.txt")
	trace("Loading "..fileName)

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
			local item = LoadItem(s,Factory)
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
	if f then
		for k, item in pairs(scene.items) do
			local s=item:Save()
			f:write(item.type)
			f:write(" ")
			f:write(#s)
			for k,v in pairs(s) do
				f:write(" ")
				f:write(v)
			end
			f:write("\n")
		end
		f:close()
	end
end
