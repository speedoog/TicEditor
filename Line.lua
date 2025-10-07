
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

function CreateLine(x0,y0,x1,y1,c)
	local line = { }
	line.x = x0
	line.y = y0
	line.dx = abs(x1-x0)
	line.dy =-abs(y1-y0)

--	local sx,sy
	if x0<x1 then line.sx=1 else line.sx=-1 end
	if y0<y1 then line.sy=1 else line.sy=-1 end

	line.err=line.dx+line.dy -- error value e_xy
	line.e2 = line.err

	function line:Draw()
		local stop=false
		pix(self.x,self.y, c)
		if self.x==x1 and self.y==y1 then stop=true end

		self.e2 = 2*self.err

		if self.e2>=self.dy then -- e_xy+e_x > 0
			self.err=self.err+self.dy
			self.x =self.x+self.sx
		end
		
		if self.e2<=self.dx then -- e_xy+e_y < 0
			self.err=self.err+self.dx
			self.y =self.y+self.sy
		end

		return stop
	end

	return line
end
