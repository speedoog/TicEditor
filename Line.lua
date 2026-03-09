
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

function CreatePolyLine(c)
	if c==nil then c=10 end

	local item =
	{
		nPix=0,
		c=c,
		pts={},
		i=1,
		type="l",
		store=function(self)
			local s={}
			table.insert(s, self.c)
			for k,v in pairs(self.pts) do
				table.insert(s, v[1])
				table.insert(s, v[2])
			end
			return	s
		end,
		InitSeg=function(self, i)
			self.i = i

			if #self.pts<2 then return end

			local p0=self.pts[i]
			local p1=self.pts[i+1]
			self.x  = p0[1]
			self.y  = p0[2]
			self.x1 = p1[1]
			self.y1 = p1[2]
			self.dx = abs(self.x1-self.x)
			self.dy =-abs(self.y1-self.y)
			
			if self.x<self.x1 then self.sx=1 else self.sx=-1 end
			if self.y<self.y1 then self.sy=1 else self.sy=-1 end
			
			self.err= self.dx+self.dy -- error value e_xy
			self.e2 = self.err
		end,
		Init=function(self)
			self:InitSeg(1)
		end,

		Draw=function(self, fnPix)
			if fnPix ~= nil then
				fnPix(self.x, self.y, c)
			end

			while self.x==self.x1 and self.y==self.y1 do	-- completed line ?
				local i=self.i+1
				if i>=#self.pts then
					return 0					-- was last segment
				else
					self:InitSeg(i)				-- next segment
				end
			end

			self.e2 = 2*self.err
			
			if self.e2>=self.dy then -- e_xy+e_x > 0
				self.err=self.err+self.dy
				self.x =self.x+self.sx
			end
			
			if self.e2<=self.dx then -- e_xy+e_y < 0
				self.err=self.err+self.dx
				self.y =self.y+self.sy
			end
			
			return 1
		end
		
	}
	return item
end
