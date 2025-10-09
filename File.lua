
function Split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		table.insert(t, tonumber(str))
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
  
function Save()
	local f=fopen("test.txt")
	for k, l in pairs(lines) do
		local sline = FillString(l).."\n"
--		line(l[1],l[2],l[3],l[4],2)
		fputs(sline, f)
	end
	fclose(f)
end

local function IsEmpty(s)
	return s == nil or s == ''
end

function Load()
	local lines={}
	local f=fopen("test.txt", "r")
	if f==0 then return lines end

	bContinue=true
	while(bContinue) do
		local s=fgets(f)
--		trace(s)
		if IsEmpty(s) then
			bContinue=false
		else
			l=Split(s)
			table.insert(lines, l)
		end
	end
	fclose(f)
	return lines
end
