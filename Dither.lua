
ditherMatrix2x2 = {
	{0, 2},
	{3, 1},
	}

ditherMatrix4x4 = {
	{0, 8, 2, 10},
	{12, 4, 14, 6},
	{3, 11, 1, 9},
	{15, 7, 13, 5},
	}

ditherMatrix8x8 = {
	{0, 32, 8, 40, 2, 34, 10, 42},
	{48, 16, 56, 24, 50, 18, 58, 26},
	{12, 44, 4, 36, 14, 46, 6, 38},
	{60, 28, 52, 20, 62, 30, 54, 22},
	{3, 35, 11, 43, 1, 33, 9, 41},
	{51, 19, 59, 27, 49, 17, 57, 25},
	{15, 47, 7, 39, 13, 45, 5, 37},
	{63, 31, 55, 23, 61, 29, 53, 21},
}

BayerMatrix16 =
{{0, 128, 32, 160, 8, 136, 40, 168, 2, 130, 34, 162, 10, 138, 42, 170},
{192, 64, 224, 96, 200, 72, 232, 104, 194, 66, 226, 98, 202, 74, 234, 106},
{48, 176, 16, 144, 56, 184, 24, 152, 50, 178, 18, 146, 58, 186, 26, 154},
{240, 112, 208, 80, 248, 120, 216, 88, 242, 114, 210, 82, 250, 122, 218, 90},
{12, 140, 44, 172, 4, 132, 36, 164, 14, 142, 46, 174, 6, 134, 38, 166},
{204, 76, 236, 108, 196, 68, 228, 100, 206, 78, 238, 110, 198, 70, 230, 102},
{60, 188, 28, 156, 52, 180, 20, 148, 62, 190, 30, 158, 54, 182, 22, 150},
{252, 124, 220, 92, 244, 116, 212, 84, 254, 126, 222, 94, 246, 118, 214, 86}, 
{3, 131, 35, 163, 11, 139, 43, 171, 1, 129, 33, 161, 9, 137, 41, 169},
{195, 67, 227, 99, 203, 75, 235, 107, 193, 65, 225, 97, 201, 73, 233, 105},
{51, 179, 19, 147, 59, 187, 27, 155, 49, 177, 17, 145, 57, 185, 25, 153},
{243, 115, 211, 83, 251, 123, 219, 91, 241, 113, 209, 81, 249, 121, 217, 89},
{15, 143, 47, 175, 7, 135, 39, 167, 13, 141, 45, 173, 5, 133, 37, 165},
{207, 79, 239, 111, 199, 71, 231, 103, 205, 77, 237, 109, 197, 69, 229, 101},
{63, 191, 31, 159, 55, 183, 23, 151, 61, 189, 29, 157, 53, 181, 21, 149},
{255, 127, 223, 95, 247, 119, 215, 87, 253, 125, 221, 93, 245, 117, 213, 85}}

function ditherrect(x,y,w,h,fadeThickness,c1,c2)
	local horizontal = false
	local matrixSize = 8

	local matrix
	if matrixSize == 2 then
		matrix = ditherMatrix2x2
	elseif matrixSize == 4 then
		matrix = ditherMatrix4x4
	else
		matrixSize = 8
		matrix = ditherMatrix8x8
	end

	dimension = #matrix

	local centerOffset, startX, startY, endX, endY
	if horizontal then
		centerOffset = w / 2 - fadeThickness / 2
		rect(x, y, centerOffset, h, c1)
		startX = x + centerOffset
		endX = x + fadeThickness + centerOffset
		startY = y
		endY = y + h
	else
		centerOffset = h / 2 - fadeThickness / 2
		rect(x, y, w, centerOffset, c1)
		startX = x
		endX = x + w
		startY = y + centerOffset
		endY = y + fadeThickness + centerOffset
	end

	local x1,x2, y1, y2
	for x1=startX,endX-1 do
		for y1=startY,endY-1 do
			if horizontal then
				x2 = x1 - x - centerOffset
				y2 = y1 - y
			else
				x2 = x1 - x
				y2 = y1 - y - centerOffset
			end
			local threshold = matrix[x2 % dimension+1][y2 % dimension+1]

			local t
			if horizontal then
				t = (x2 / fadeThickness) * (matrixSize * matrixSize - 1)
			else
				t = (y2 / fadeThickness) * (matrixSize * matrixSize - 1)
			end
			
			local color
			if t < threshold then
				color=c1
			else
				color=c2
			end

			pix(x1, y1, color)
		end
	end

	if horizontal then
		rect(endX, y, centerOffset, h, c2)
	else
		rect(x, endY, w, centerOffset, c2)
	end
end
