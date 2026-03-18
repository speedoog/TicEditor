sqrt,abs,sin,cos,tan,pi,min,max,floor=math.sqrt,math.abs,math.sin,math.cos,math.tan,math.pi,math.min,math.max,math.floor
rand,seed=math.random,math.randomseed

function round(a)
	return floor(a+0.5)
end

function remap( x, t1, t2, s1, s2 )
 local f = ( x - t1 ) / ( t2 - t1 )
 return f * ( s2 - s1 ) + s1
end

function clamp(x, l, h)
	if x<l then return l elseif x>h then return h else return x end
end

function lerp(a,b,r)
	return a*(1-r)+b*r
end

function cuberp(a,b,c,d,t)
	local A=d-c-a+b
	local B=a-b-A
	local C=c-a
	local D=b
	local T=t*t
	return A*t*T+B*T+C*t+D
end

function overlap(x,y,x0,x1,y0,y1)
   if x<x0 or x>x1 or y<y0 or y>y1 then return false end
   return true
end

function distance(x0,y0,x1,y1)
	local dx=x0-x1
	local dy=y0-y1
	return sqrt(dx*dx+dy*dy)
end

function rad2deg( r )
	return r/math.pi*180
end

function deg2rad( d )
	return d/180*math.pi
end

function cubicBezier(t, p0, p1, p2, p3)
	return (1 - t)^3*p0 + 3*(1 - t)^2*t*p1 + 3*(1 - t)*t^2*p2 + t^3*p3
end

function cubicBezier2(t,x0,y0,x1,y1,x2,y2,x3,y3)
	return cubicBezier(t,x0,x1,x2,x3),cubicBezier(t,y0,y1,y2,y3)
end

-- ---------------------------------------------------------------------
-- 							Vector2
-- ---------------------------------------------------------------------
function V2Sub(v1,v2) return {v1[1]-v2[1],v1[2]-v2[2]} end
function V2Dot(v1,v2) return v1[1]*v2[1]+v1[2]*v2[2] end
function V2SqLength(v) return v[1]*v[1]+v[2]*v[2] end

-- ---------------------------------------------------------------------
-- 							CatmullRom
-- https://iquilezles.org/articles/minispline/
-- keys format : spline ={0,x0,y0,1,x1,y1,2,x2,y2,3,x3,y3}
-- ---------------------------------------------------------------------

CatmullRomCoefs = {
    { -1, 2,-1, 0},
    {  3,-5, 0, 2},
    { -3, 4, 1, 0},
    {  1,-1, 0, 0} }

function CatmullRom(keys, dim, t)
	-- init result
	local v = {}			-- out
	for i=1,dim do
		v[i] = 0
	end

    local size = dim + 1;
	local num =floor(#keys/size)

    -- find key
    local k = 0
	while k<num and keys[1+k*size]<t do
		k=k+1;
	end

    -- interpolant
    local h
	if k<=0 then
		h=0
	elseif k>=num then
		h=1
	elseif k>0 then
		local t1=keys[1+(k-1)*size]
		local t2=keys[1+k*size]
	 	h=(t-t1)/(t2-t1)
	end

    -- add basis functions
    for i=1,4 do
        local kn = k+i-3;
		if kn<0 then
			kn=0
		elseif kn>(num-1) then
			kn=num-1
		end
		
		local co=CatmullRomCoefs[i]
        local b = 0.5*(((co[1]*h + co[2])*h + co[3])*h + co[4]);
        for j=1,dim do
			v[j] = v[j]+ b*keys[kn*size+j+1]
		end
    end
	return v
end
