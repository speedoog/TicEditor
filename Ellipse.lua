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

function CreateEllipse(xm, ym, a, b, c)
	if c == nil then c = 10 end

	local ellipse = {}

	function ellipse:str()
		return "ellipse "..tostring(xm).." "..tostring(ym).." "..tostring(a).." "..tostring(b).." "..tostring(c)
	end

	function ellipse:Init()
		s = self
		s.x = -a
		s.y = 0           				-- II. quadrant from bottom left to top right
		s.a2=floor(a*a)
		s.b2=floor(b*b)
		s.e2 = s.b2
		s.err = s.x*(2*s.e2+s.x)+s.e2;			-- error of 1.step
	end

	function ellipse:Draw(fnPix)
		s = self
		if s.x<=0 then
			fnPix(xm-s.x, ym+s.y, c);
			fnPix(xm+s.x, ym+s.y, c);
			fnPix(xm+s.x, ym-s.y, c);
			fnPix(xm-s.x, ym-s.y, c);

			s.e2 = 2*s.err;
			if (s.e2 >= (s.x*2+1)*s.b2) then		-- e_xy+e_x > 0
				s.x=s.x+1
				s.err = s.err+(s.x*2+1)*s.b2
			end

			if (s.e2 <= (s.y*2+1)*s.a2) then		-- e_xy+e_y < 0
				s.y=s.y+1
				s.err = s.err+(s.y*2+1)*s.a2
			end

			return true
		elseif s.y<b then
			fnPix(xm, ym+s.y,c)
			fnPix(xm, ym-s.y,c)
			S.y=s.y+1
		end

		if s.y>b then
			return true
		end

		return false
	end

	return ellipse
end
