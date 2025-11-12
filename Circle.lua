function PlotCircle(x, y, r, c)
	px = 0
	py = r
	m = 5 - 4 * r

	while (px <= py) do
		pix((px + x), (py + y), c)
		pix((py + x), (px + y), c)
		pix((-px + x), (py + y), c)
		pix((-py + x), (px + y), c)
		pix((px + x), (-py + y), c)
		pix((py + x), (-px + y), c)
		pix((-px + x), (-py + y), c)
		pix((-py + x), (-px + y), c)

		if m > 0 then
			py = py - 1
			m = m - 8 * py
		end

		px = px + 1
		m = m + 8 * px + 4
	end
end

function CreateCircle(x, y, r, c)
	if c == nil then
		c = 10
	end

	local circle = {}

	function circle:Init()
		s = self
		s.x = x
		s.y = y
		s.px = 0
		s.py = r
		s.m = 5 - 4 * r
	end

	function circle:Draw(fnPix)
		s = self
		if (s.px <= s.py) then
			fnPix((s.px + x), (s.py + y), c)
			fnPix((s.py + x), (s.px + y), c)
			fnPix((-s.px + x), (s.py + y), c)
			fnPix((-s.py + x), (s.px + y), c)
			fnPix((s.px + x), (-s.py + y), c)
			fnPix((s.py + x), (-s.px + y), c)
			fnPix((-s.px + x), (-s.py + y), c)
			fnPix((-s.py + x), (-s.px + y), c)

			if s.m > 0 then
				s.py = s.py - 1
				s.m = s.m - 8 * s.py
			end

			s.px = s.px + 1
			s.m = s.m + 8 * s.px + 4

			return true
		end

		return false
	end

	return circle
end
