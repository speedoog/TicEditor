abs,sin,cos,tan,pi,min,max,floor=math.abs,math.sin,math.cos,math.tan,math.pi,math.min,math.max,math.floor
rand,seed=math.random,math.randomseed

function remap( x, t1, t2, s1, s2 )
 local f = ( x - t1 ) / ( t2 - t1 )
 return f * ( s2 - s1 ) + s1
end

function clamp(x, l, h)
	if x<l then return l elseif x>h then return h else return x end
end
