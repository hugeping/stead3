require "sprite"
local maf = require "maf"
local PI = math.pi
local std = stead

local render = {
}
render.__index = render

local scene = {
}
scene.__index = scene

local object = {
}
object.__index = object

local zvec = maf.vec3(0, 0, 1)
local xvec = maf.vec3(1, 0, 0)
local yvec = maf.vec3(0, 1, 0)

local function clamp( x, min, max )
	if x < min then return min end
	if x > max then return max end
	return x
end

local function KtoRGB(kelvin)
	local temp = kelvin / 100

	local red, green, blue

	if temp <= 66 then 
		red = 255
		green = temp
		green = 99.4708025861 * math.log(green) - 161.1195681661
		if temp <= 19 then
			blue = 0
		else
			blue = temp - 10
			blue = 138.5177312231 * math.log(blue) - 305.0447927307
		end
	else
		red = temp - 60
		red = 329.698727446 * math.pow(red, -0.1332047592)
		green = temp - 60
		green = 288.1221695283 * math.pow(green, -0.0755148492 )
		blue = 255
	end
	return clamp(red, 0, 255), clamp(green, 0, 255), clamp(blue,  0, 255)
end

local SEED = 1

function render.noise(x)
	if not x then
		x = SEED
	end
	x = x * 1103515245 + 11;
	SEED = math.ceil(x / 65536) % 32767
	return SEED;
end

function render.rnd(n)
	return math.floor(render.noise() % n) + 1
end

function render.rndf(n)
	return (render.rnd(32767) - 16384) / 16384
end

-- t.r - radius, t.temp -- temperature, t.seed -- seed
function render.star(t)
	local seed = t.seed or 1
	render.noise(seed)
	local nseed = render.rndf() * 16387
	local blackhole = t.temp == 0

	if blackhole then t.temp = render.rnd(30000) end

	local pxl = pixels.new(t.r * 2, t.r * 2)
	local xc = t.r 
	local yc = t.r 
	local r = t.r
	local tt = t.temp
	local d = t.r / 4

	if blackhole then d = t.r / 4 end

	if blackhole then
		for i = 0, d - 1 do
			local x = (d - i) / d
			pxl:fill_circle(xc, yc, r - i, KtoRGB(tt - (d - i) * 100))
		end
		pxl:fill_circle(xc, yc, r - d, 0, 0, 0, 255)
		d = t.r / 4
	else
		for i = 0, d - 1 do
			local x = (d - i) / d
			pxl:fill_circle(xc, yc, r - i, KtoRGB(tt - (x) * 5000))
		end
		pxl:fill_circle(xc, yc, r - d, KtoRGB(tt))
		d = d / 1.4
	end

	local r2 = r ^ 2
	local rd2 = (r - d) ^ 2 

	for y = 0, t.r * 2 do -- flames
		local dy2 = (y - yc) ^ 2
		local ny = y / (2 * r) * 20
		for x = 0, t.r * 2 do
			local dx2 = (x - xc) ^2
			if dx2 + dy2 < r2 and dx2 + dy2 > rd2 then
				local gr = (dx2 + dy2) ^ 0.5
				gr = 1 - (gr - (r - d)) / d
				local nx = x / (2 * r) * 20
				local n = instead.noise2(nx + nseed, ny + nseed)
				local rr, gg, bb = pxl:val(x, y)
				pxl:val(x, y, rr, gg, bb, (n * 127 + 127) * gr)
			end
		end
	end

if not blackhole then
	local sfactor = 17 + render.rndf() * 3
	d = t.r / 4
	r2 = (r - d) ^ 2
	r = t.r - d -- 2 * d
	for y = d, t.r * 2 - d do -- surface
		local dy2 = (y - yc) ^ 2
		for x = d, t.r * 2 - d do
			local ny = (y - d) / (2 * r) * sfactor
			local dx2 = (x - xc) ^2
			if dx2 + dy2 < r2 then
				local z = (r2 - dx2 - dy2) ^ 0.5
				local nx = (x - d) / (2 * r) * sfactor
				local nz = (z / (2 * r)) * sfactor
				local n = instead.noise3(nx + nseed, ny + nseed, nz + nseed)
				if n < - 0.1 then
					local rr, gg, bb = KtoRGB(tt + n * 5000)
					local col = { rr, gg, bb, 255 }
					pxl:val(x, y, std.unpack(col))
				end
			end
		end
	end
else -- blackhole
	pxl:circleAA(xc, yc, r - d, KtoRGB(t.temp))
end
	return pxl
end

local function TtoRGB()
	return 200, 200, 200
end

local color_from_height

local mars = {
	[-1.0] = { 0, 0, 0 };
	[-0.5] = { 96, 0, 0 };
	[-0.8] = { 128, 0, 0 };
	[0.5] = { 210, 10, 10 };
	[0.7] = { 220, 50, 50 };
	[1.0] = { 255, 100, 100 };
}


local earth = {
	[-1.0] = { 0, 0, 128 };
	[-0.25] = { 0, 0, 255 };
	[0] = {0, 128, 255};
	[0.0625] = { 240, 240, 64};
	[0.1250] = { 32, 160, 0 };
	[0.3750] = { 116, 88, 62 }; -- 224, 224, 0 };
	[0.07500] = { 128, 128, 128 };
	[1.0] = {255, 255, 255};
}

local asteroid = {
	[-1.0] = { 0, 0, 0 };
	[1.0] = {255, 255, 255};
}

local function grad(g, n)
	local keys
	if not g.sorted then
		keys = {}
		for k, v in pairs(g) do
			table.insert(keys, k)
		end
		table.sort(keys)
		g.sorted = keys
	else
		keys = g.sorted
	end
	local start = -1.0
	local sr, sg, sb = 0, 0, 0

	if g[-1.0] then
		sr, sg, sb = g[-1.0][1], g[-1.0][2], g[-1.0][3]
	end
	local abs = math.abs
	for v, k in ipairs(keys) do
		if n <= k then
			local e = abs(n - start) / abs(k - start)
			local s = 1 - e
			
			return clamp(s * sr + e * g[k][1], 0, 255),
				clamp(s * sg + e * g[k][2], 0, 255),
				clamp(s * sb + e * g[k][3], 0, 2555)
		end
		start = k
		sr, sg, sb = g[k][1], g[k][2], g[k][3]
	end
end

local function atmosphere(n)
	local r, g, b = 255, 0, 0
--	local r, g, b = 200, 200, 255
	return r, g, b, clamp(n * 150, 0, 255)
--	return r, g, b, (1 - n) * 90
end
local grads = {
	earth = earth;
	mars = mars;
	asteroid = asteroid;
}
local function shape(n, t)
--	n = clamp(n, -1, 1)
	return grad(grads[t], n)
---	return grad(earth, n)
--	return grad(mars, n)
--	return grad(asteroid, n)
end

local function do_ring(pxl, ring, rr, ref, sina, cosa, cosb, inv)
	local yy
	local xc, yc = rr - 1, rr - 1
	ref = ref -- * ref
	print("ref = ", ref)
	for y = 0, rr - 1 do
		yy = y * cosb
		local ysina = yy * sina
		local ycosa = yy * cosa
		local xcosa, xsina, nx, ny, aa, bb, cc, dd
		for x = 0, rr - 1 do
			aa, bb, cc, dd = ring:val(xc - x, yc - y)
			if (aa ~= 0 or bb ~= 0 or cc ~= 0) then
				xcosa = x * cosa; xsina = x * sina
				nx = xcosa - ysina; ny = ycosa + xsina
				aa = clamp(aa * ref, 0, 255)
				bb = clamp(bb * ref, 0, 255)
				cc = clamp(cc * ref, 0, 255)
				dd = 100
				if inv then
					pxl:pixel(xc + nx, yc + ny, aa, bb, cc, dd)
				else
					pxl:pixel(xc - nx, yc - ny, aa, bb, cc, dd)
				end
				nx = nx - 2 * xcosa; ny = ny - 2 * xsina
				if inv and x > 0 then
					pxl:pixel(xc + nx, yc + ny, aa, bb, cc, dd)
				elseif x > 0 then
					pxl:pixel(xc - nx, yc - ny, aa, bb, cc, dd)
				end
			end
		end
	end
end

local saturn_rings = {
	[-1.0] = { 0, 0, 0 },
	[-0.9] = { 20, 20, 20 },
	[-0.8] = { 40, 40, 40 },
	[-0.7] = { 128, 128, 128 },
	[-0.5] = { 190, 190, 190 },
	[-0.4] = { 128, 128, 128 },
	[0.2] = { 210, 220, 210 },
	[0.5] = { 100, 100, 100 },
	[0.7] = { 210, 210, 190 },
	[0.8] = { 230, 210, 190 },
	[1.0] = { 230, 220, 190 },
}

local function render_rings(pxl, t, angle, beta)
	local r, rr, d
	local nseed = render.rndf() * 16387
	local point = maf.vec3()
	local sun = t.sun
	r = t.r
	rr = 2 * t.r
	d = rr - rr / 1.7
	local ring = pixels.new(rr, rr)
	ring:clear(0, 0, 0, 0)
	local c
	for i = 1, d do
		c = instead.noise1(i / d * 6 + nseed)
		c = 2 *(1 - i / d) - 1 + c
		local r, g, b = grad(saturn_rings, clamp(c, -1, 1))
		ring:fill_circle(rr, rr, rr - i, r, g, b, 255)
	end
	ring:fill_circle(rr, rr, rr - d, 0, 0, 0, 255)

	local cosb = math.cos(PI / 2 + math.abs(beta))
	local cosa = math.cos(-angle)
	local sina = math.sin(-angle)
	local pxl2 = pixels.new(2 * rr, 2 * rr)
	local inv = beta < 0
	local rot = maf.rotation()
	rot:angleAxis(angle, zvec)
	local rot2 = maf.rotation()
	rot2:angleAxis(beta, rot * xvec)
	point = rot * rot2 * yvec
	local ref = sun:angle(point)
	ref = clamp(ref / PI, 0, 1) 

	do_ring(pxl2, ring, rr, ref, sina, cosa, cosb, inv);

	pxl:blend(pxl2, (rr - r), (rr - r)) -- planet

	do_ring(pxl2, ring, rr, ref, sina, cosa, cosb, not inv);

	pxl = pxl2
	return pxl
end

function render.planet(t)
	local seed = t.seed or 1
	render.noise(seed)
	local nseed = render.rndf() * 16387

	local r = t.r
	local pxl = pixels.new(r * 2, r * 2)
	local xc = t.r
	local yc = t.r
	local tt = t.temp
	local d = t.r / 4

	local d = r / 6 -- atmosphere
	local r2 = (r - d) ^ 2
	r = t.r - d
	local sfactor = 8
	local rfactor = 3 -- reflect

	local sun = t.light or maf.vec3(0.5, 0.5, 1)

	local point = maf.vec3()
	std.busy(true)
	local dd = t.r * 2 - d
	local nx, ny, nz, n, rc, gc, bc, rr, xx, yy
	for y = d, dd do -- surface
		local dy2 = (y - yc) ^ 2
		yy = yc - y
		for x = d, dd do
			local dx2 = (x - xc) ^2
			xx = x - xc
			if dx2 + dy2 <= r2 then
				local zz = (r2 - dx2 - dy2) ^ 0.5
				point.x, point.y, point.z = xx, yy, -zz
				rr = sun:angle(point)
				rr = clamp(rr / PI, 0, 1) 
				rr = rr ^ 2 * rfactor
				nx = (r + xx) / (2 * r) * sfactor
				nz = (zz / (2 * r)) * sfactor
				ny = (r + yy) / (2 * r) * sfactor
				n = instead.noise3(nx + nseed, ny + nseed, nz + nseed) +
					instead.noise3(nx * 2 + nseed, ny * 2 + nseed, nz * 2 + nseed) / 2 + 
					instead.noise3(nx * 4 + nseed, ny * 4 + nseed, nz * 4 + nseed) / 4
				rc, gc, bc = shape(clamp(n, -1, 1), 'mars')
				pxl:val(x, y, clamp(rc * rr, 0, 255), clamp(gc * rr, 0, 255), clamp(bc * rr, 0, 255), 255)
			end
		end
		std.busy(true)
	end
	local r2 = t.r ^ 2
	local rd2 = (t.r - d) ^ 2 

	for y = 0, t.r * 2 do -- atmosphere
		local dy2 = (y - yc) ^ 2
		for x = 0, t.r * 2 do
			local dx2 = (x - xc) ^2
			if dx2 + dy2 < r2 and dx2 + dy2 > rd2 then
				local gr = (dx2 + dy2) ^ 0.5
				gr = 1 - (gr - (t.r - d)) / d
				local z = (r2 - dx2 - dy2) ^ 0.5
				point.x, point.y, point.z = x - t.r, y - t.r, - z
				local rr = sun:angle(point)
				rr = clamp(rr / PI, 0, 1) 
				rr = rr ^ 2 * rfactor
				pxl:val(x, y, atmosphere(rr * gr) ) --255, 0, 0, clamp(rr * gr * 150, 0, 255))
			end
		end
		std.busy(true)
	end
-- rings
	t.sun = sun

	pxl = render_rings(pxl, t, PI / 32, -PI / 8)

	std.busy(false)

	return pxl
end

function render.asteroid(t)
	local seed = t.seed or 1
	render.noise(seed)
	local nseed = render.rndf() * 16387
	local r = t.r
	local pxl = pixels.new(r * 2, r * 2)
	local xc = t.r
	local yc = t.r

	local sfactor = 2
	local rfactor = 1 -- reflect
	local vfactor = r / 2
	local sun = t.light or maf.vec3(0.5, 0.5, 1)
	local point = maf.vec3()
	local point2 = maf.vec3()
	std.busy(true)
	local dd = t.r * 2
	local nx, ny, nz, n, rc, gc, bc, rr, xx, yy
	local r2 = r ^ 2
	for y = 1, dd do -- surface
		local dy2 = (y - yc) ^ 2
		yy = yc - y
		local ox = false
		local oy = false
		for x = 1, dd do
			local dx2 = (x - xc) ^2
			xx = x - xc
			if dx2 + dy2 <= r2 then
				local zz = (r2 - dx2 - dy2) ^ 0.5
				point2.x, point2.y, point2.z = xx, yy, -zz
				point2:normalize()
				point.x, point.y, point.z = xx, yy, -zz

				nx = (r + xx) / (2 * r) * sfactor
				ny = (r + yy) / (2 * r) * sfactor
				nz = (zz / (2 * r)) * sfactor

				n = instead.noise3(nx + nseed, ny + nseed, nz + nseed) --+
--					instead.noise3(nx * 2 + nseed, ny * 2 + nseed, nz * 2 + nseed) / 2 +
--					instead.noise3(nx * 4 + nseed, ny * 4 + nseed, nz * 4 + nseed) / 4

				point2:scale((1 + n) / 2 * vfactor)
				point:sub(point2);

				rr = sun:angle(point)
				rr = clamp(rr / PI, 0, 1) 
				rr = rr * rr * rfactor

				nx = (r + point.x) / (2 * r) * sfactor * 4
				ny = (r + point.y) / (2 * r) * sfactor * 4
				nz = (point.z / (2 * r)) * sfactor * 4

				local nn = instead.noise3(nx + nseed, ny + nseed, nz + nseed) +
					instead.noise3(nx * 2 + nseed, ny * 2 + nseed, nz * 2 + nseed) / 2 +
					instead.noise3(nx * 4 + nseed, ny * 4 + nseed, nz * 4 + nseed) / 4

				nn = clamp(nn, -1, 1)

				nx, ny, nz = point.x, point.y, point.z
				rc, gc, bc = shape(nn, 'asteroid')
				local c = clamp(rc * rr, 0, 255)
				pxl:fill_circle(xc + nx, yc - ny, 6, c, c, c, 255)
			end
		end
		std.busy(true)
	end
	std.busy(false)
	return pxl
end

function render.object()
	local o = {
		shapes = {}
	}
	setmetatable(o, object)
	return o
end

function object:circle(x, y, r, col)
	table.insert(self.shapes, { t = 'circle', x = x, y = y, r = r, col = col }) 
	return self
end

function object:pixels(pixels, x, y, scale)
	table.insert(self.shapes, { t = 'pixels', pixels = pixels, x = x, y = y, scale = scale or 1 }) 
	return self
end

function object:render(screen, fov, x, y, z)
	local pos = x
	if type(x) == 'number' then
		pos = maf.vec3(x, y, z)
	end
	local w, h = screen:size()
	local xc = math.floor(w / 2)
	local yc = math.floor(h / 2)
	for k, o in ipairs(self.shapes) do
		if o.t == 'circle' then
			local nx = fov * (pos.x + o.x) / pos.z
			local ny = fov * (pos.y + o.y) / pos.z
			local nr = fov * (o.r) / pos.z
			screen:circle(xc + nx, yc - ny, nr, std.unpack(o.col))
		elseif o.t == 'pixels' then
			local scale = o.scale * fov / pos.z -- (pos.x ^ 2 + pos.y ^ 2 + pos.z ^ 2)  ^ 0.5
			local nx = fov * (pos.x + o.x * o.scale) / pos.z
			local ny = fov * (pos.y + o.y * o.scale) / pos.z
			if scale > 0 and scale < 16 then
				local pp2 = o.pixels:scale(scale, scale, true)
				pp2:blend(screen, xc + nx, yc - ny)
			end
		end
	end
end

function render.vec3(x, y, z)
	return maf.vec3(x, y, z)
end

function render.scene()
	local o = {
		objects = {}
	}
	setmetatable(o, scene)
	o:look(0, 0, 1)
	o:camera(0, 0, 0)
	o:setfov(PI / 4)
	return o
end

function scene:light(x, y, z)
	if type(x) == 'number' then
		self.light = maf.vec3(x, y, z)
	else
		self.light = x
	end
end

function scene:setfov(fov)
	self.fov = fov
end

function scene:climb(look, angle, roll)
	print("in:", look:unpack())
	local q = maf.rotation()
	local q2 = maf.rotation()
	local q3 = maf.rotation()

	q:between(zvec, maf.vec3(look.x, 0, look.z))
	q3:angleAxis(roll, look)
	local axis = q3 * (q * xvec)
	q2:angleAxis(angle, axis)
	print("axis: ", axis:unpack())
	print("look: ", (q2 * look):unpack())
	return q2 * look
end

function scene:roll(look, angle)
	local q = maf.rotation()
	q:between(zvec, look)
--	self.quat:inv(q)
	local v = q * yvec
	local q2 = maf.rotation()
	q2:angleAxis(angle, zvec)
	q2:mul(q)
	return q2 * zvec
end

function scene:look(vec, y, z, angle)
	print(y)
	if type(vec) == 'number' then
		vec = maf.vec3(x, y, z)
		angle = angle or 0
	else
		angle = y or 0
	end
	local q = maf.rotation()
	q:between(vec, zvec)
	local q2 = maf.rotation()
--	qq:between(zvec, vec)
	local q3 = maf.rotation()
	local qq = maf.rotation()
	q:between(maf.vec3(vec.x, 0, vec.z), zvec) -- alpha
	qq:between(zvec, maf.vec3(vec.x, 0, vec.z)) 
	print("alpha: ", q:getAngleAxis())
	print("vec: ", vec:unpack())
	print("zvec: ", (q * zvec):unpack())
	q2:between(vec, qq * zvec) -- beta
	print("beta: ", q2:getAngleAxis())
	q3:angleAxis(-angle, vec)
	self.quat = q * q2 * q3
end

function scene:camera(x, y, z)
	local coord = x
	if type(x) == 'number' then
		coord = maf.vec3(x, y, z)
	end
	self.position = coord
end

function scene:render(screen)
	local current_scene = {}
	for k, o in ipairs(self.objects) do
		local ncoord = (o.pos - self.position):rotate(self.quat)
		table.insert(current_scene, { o = o.o, pos = ncoord })
	end
	table.sort(current_scene, function(a, b)
		return a.pos.z > b.pos.z
	end)
	for k, o in ipairs(current_scene) do
		if o.pos.z > 0 then
			o.o:render(screen, self.fov, o.pos)
--			print(o.pos.x, o.pos.y, o.pos.z)
		end
	end
end

function scene:place(object, x, y, z)
	local coord = x
	if type(x) == 'number' then
		coord = maf.vec3(x, y, z)
	end
	table.insert(self.objects, { o = object, pos = coord })
end

return render
