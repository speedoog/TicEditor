
function CreateSpline(c)
	if c==nil then c=10 end

	local item =
	{
		nPix=0,
		c=c,
		pts={},
		type="s",
		t=0,
		tend=0,
		keys={},
		store=function(self)
			local s={}
			table.insert(s, self.c)
			for k,v in pairs(self.pts) do
				table.insert(s, v[1])
				table.insert(s, v[2])
			end
			return	s
		end,
		Init=function(self)
			self.t=0
			self.keys={}						-- build up CatmullRom keys
			local t=0
			local x,y
			for k,v in pairs(self.pts) do
				if x~=nil then
					t=t+distance(x,y,v[1],v[2])/100
				end
				table.insert(self.keys,t)
				table.insert(self.keys,v[1])
				table.insert(self.keys,v[2])
				x=v[1]
				y=v[2]
			end
			self.tend=t
		end,
		
		Draw=function(self, fnPix)
			local dt = 0.05
			local tprev=self.t
			self.t=self.t+dt
			
			if self.t<=self.tend then
				local v0 = CatmullRom(self.keys, 2, tprev)
				local v1 = CatmullRom(self.keys, 2, self.t)
				local iPix=0
				if fnPix~=nil then
					PlotLine(floor(v0[1]),floor(v0[2]),floor(v1[1]),floor(v1[2]), self.c, fnPix)
				end
				return 1
			else
				return 0
			end
		end
	}
	return item
end
