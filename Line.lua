
function PixPatch(x,y,c)
	pix(x,y, c+1)
	pix(x-1,y+1, c)
	pix(x+1,y-1, c)
	pix(x-1,y+1, c)
	pix(x+1,y+1, c)
end

function PlotLine(x0,y0,x1,y1,c)
	local dx = abs(x1-x0)
	local dy =-abs(y1-y0)

	local sx,sy
	if x0<x1 then sx=1 else sx=-1 end
	if y0<y1 then sy=1 else sy=-1 end

	local err=dx+dy -- error value e_xy
	local e2 = err
	local b=true
	while(b) do
		pix(x0,y0, c)
		e2 = 2*err
		if e2>=dy then -- e_xy+e_x > 0
			if x0==x1 then b=false end
			err=err+dy
			x0 =x0+sx
		end
		
		if e2<=dx then -- e_xy+e_y < 0
			if y0==y1 then b=false end
			err=err+dx
			y0 =y0+sy
		end

	end
end

function CreateLineMem(ptr)
	local p,item
	ptr,p=Pop(ptr,5)
	item=CreateLine(p[1],p[2],p[3],p[4],p[5])
	return ptr,item
end

function CreateLine(x0,y0,x1,y1,c)
	if c==nil then c=10 end

	local line = { }

	function line:str()
		return "line "..tostring(x0).." "..tostring(y0).." "..tostring(x1).." "..tostring(y1).." "..tostring(c)
	end

	function line:Init()
		self.x = x0
		self.y = y0
		self.dx = abs(x1-x0)
		self.dy =-abs(y1-y0)

		if x0<x1 then line.sx=1 else line.sx=-1 end
		if y0<y1 then line.sy=1 else line.sy=-1 end

		self.err= self.dx+self.dy -- error value e_xy
		self.e2 = self.err
	end

	-- return "continue"
	function line:Draw(fnPix)
		fnPix(self.x,self.y, c)

		if self.x==x1 and self.y==y1 then return false end

		self.e2 = 2*self.err

		if self.e2>=self.dy then -- e_xy+e_x > 0
			self.err=self.err+self.dy
			self.x =self.x+self.sx
		end
		
		if self.e2<=self.dx then -- e_xy+e_y < 0
			self.err=self.err+self.dx
			self.y =self.y+self.sy
		end

		return true
	end

	return line
end
