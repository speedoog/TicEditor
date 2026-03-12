require "Maths"

function PlotEllipse(xm, ym, a, b, c)
	local x = -a
	local y = 0           				-- II. quadrant from bottom left to top right
	local a2=floor(a*a)
	local b2=floor(b*b)

	local e2 = b2
	local err = x*(2*e2+x)+e2;			-- error of 1.step

	repeat
		pix(xm-x, ym+y, c);
		pix(xm+x, ym+y, c);
		pix(xm+x, ym-y, c);
		pix(xm-x, ym-y, c);

		e2 = 2*err;
		if (e2 >= (x*2+1)*b2) then		-- e_xy+e_x > 0
			x=x+1
			err = err+(x*2+1)*b2
		end

		if (e2 <= (y*2+1)*a2) then		-- e_xy+e_y < 0
			y=y+1
			err = err+(y*2+1)*a2
		end
	until x>0

	while (y<b) do						-- too early stop of flat ellipses a=1, -> finish tip of ellipse 
		pix(xm, ym+y,c)
		pix(xm, ym-y,c)
		y=y+1
	end
end

function CreateEllipseMem(ptr)
	local p,item
	ptr,p=Pop(ptr,5)
	item=CreateEllipse(p[1],p[2],p[3],p[4],p[5])
	return ptr,item
end


function CreateEllipse(xm, ym, a, b, c)
	if c == nil then c = 10 end

	local ellipse = {}

	function ellipse:str()
		return "ellipse "..tostring(xm).." "..tostring(ym).." "..tostring(a).." "..tostring(b).." "..tostring(c)
	end

	function ellipse.Init(_)
		_.x = -a
		_.y = 0           				-- II. quadrant from bottom left to top right
		_.a2=floor(a*a)
		_.b2=floor(b*b)
		_.e2 = _.b2
		_.err = _.x*(2*_.e2+_.x)+_.e2;			-- error of 1.step
	end

	function ellipse.Draw(_,fnPix)
		if _.x<=0 then
			if fnPix~=nil then
				fnPix(xm-_.x, ym+_.y, c);
				fnPix(xm+_.x, ym+_.y, c);
				fnPix(xm+_.x, ym-_.y, c);
				fnPix(xm-_.x, ym-_.y, c);
			end

			_.e2 = 2*_.err;
			if (_.e2 >= (_.x*2+1)*_.b2) then		-- e_xy+e_x > 0
				_.x=_.x+1
				_.err = _.err+(_.x*2+1)*_.b2
			end

			if (_.e2 <= (_.y*2+1)*_.a2) then		-- e_xy+e_y < 0
				_.y=_.y+1
				_.err = _.err+(_.y*2+1)*_.a2
			end

			return 4
		elseif _.y<b then
			if fnPix~=nil then
				fnPix(xm, ym+_.y,c)
				fnPix(xm, ym-_.y,c)
			end
			_.y=_.y+1
		end

		if _.y>b then
			return 2
		end

		return 0
	end

	return ellipse
end
