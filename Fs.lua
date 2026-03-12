FS = {}

function FS_Load(FS)
    ptr = gAddMap
    local count = peek(ptr)
    ptr = ptr+1
    for ifile = 0,count-1 do
        local f = {}
        name = ""
        while peek(ptr) ~= 0 do
            c = peek(ptr)
            ptr = ptr+1
            name = name..string.char(c)
        end
        ptr = ptr+1
        szlo = peek(ptr)
        ptr = ptr+1
        szhi = peek(ptr)
        ptr = ptr+1
        szfull = szhi*256+szlo
        f.name = name
        f.size = szfull
        table.insert(FS,f)
    end

    baseAddress = ptr
    for k,f in pairs(FS) do
        f.add = baseAddress
        baseAddress = baseAddress+f.size
        c = peek(f.add)
    end
end

function Pop(address,count)
    local params = {}
    for i = 0,count-1 do
        table.insert(params,peek(address+i))
    end
    return address+count,params
end

function FS_FindFile(fn)
    for k,f in pairs(FS) do
        if f.name == fn then
            return f
        end
    end
    return nil
end

function FS_LoadScene(file)
    local scene = {}
    scene.nPix = 0
    scene.items = {}

    local f = FS_FindFile(file)
    if f == nil then return scene end

    ptr = f.add
    while true do
        b = peek(ptr)
        ptr = ptr+1
        if b == 0 then break end

        item = nil
        cmd = string.char(b)
        if cmd == 'l' then
            ptr,item = CreateLineMem(ptr)
        elseif cmd == 'e' then
            ptr,item = CreateEllipseMem(ptr)
        elseif cmd == 'c' then
            ptr,item = CreateCircleMem(ptr)
        elseif cmd == 'f' then
            ptr,item = CreateFillMem(ptr)
        end

        if item ~= nil then
            AppendItem(scene,item)
        end
    end

    ComputeTotalPix(scene)
    return scene
end
