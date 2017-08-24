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
	local sfactor = 13 + render.rndf() * 3
	d = t.r / 4
	r2 = (r - d) ^ 2
	r = t.r - 2 * d
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
	[-1.0] = { 64, 20, 20 };
	[-0.5] = { 100, 32, 32 };
	[-0.8] = { 128, 0, 0 };
	[0.5] = { 200, 50, 50 };
	[0.7] = { 200, 10, 10 };
	[1.0] = { 255, 255, 255 };
}

local function grad(g, n)
	local keys = {}
	for k, v in pairs(g) do
		table.insert(keys, k)
	end
	table.sort(keys)
	local start = 0
	local sr, sg, sb = 0, 0, 0
	for v, k in ipairs(keys) do
		if n <= k then
			local e = (n - start) / k
			local s = 1 - e
			return s * sr + e * g[k][1], 
				s * sg + e * g[k][2], 
				s * sb + e * g[k][3]
		end
		start = k
		sr, sg, sb = g[k][1], g[k][2], g[k][3]
	end
end
local function atmosphere(n)
	local r, g, b = 0, 0, 255
	return r, g, b, (1 - n) * 90
end

local function shape(n)
	return grad(mars, n)
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
--	pxl:fill_circle(xc, yc, r, TtoRGB(t.t))



	local d = r / 6 -- atmosphere
	local r2 = (r - d) ^ 2
	r = t.r - 2 * d
	local sfactor = 8
	local rfactor = 3 -- reflect

	local sun = t.light or maf.vec3(0.5, 0.5, 1)
--	for i = 0, d - 1 do
--		local x = (d - i) / d
--		pxl:fill_circle(xc - 1, yc - 1, t.r - i, atmosphere(x))
--	end


	for y = d, t.r * 2 - d do -- surface
		local dy2 = (y - yc) ^ 2
		for x = d, t.r * 2 - d do
			local ny = (y - d) / (2 * r) * sfactor
			local dx2 = (x - xc) ^2
			if dx2 + dy2 <= r2 then
				local z = (r2 - dx2 - dy2) ^ 0.5
				local rc, gc, bc = pxl:val(x, y)
				local point = maf.vec3(x - t.r, y - t.r, -z)
				local rr = sun:angle(point)
				rr = clamp(rr / PI, 0, 1) 
				rr = rr ^ 2 * rfactor
				local nx = (x - d) / (2 * r) * sfactor
				local nz = (z / (2 * r)) * sfactor
				local n = instead.noise3(nx + nseed, ny + nseed, nz + nseed) +
					instead.noise3(nx * 2 + nseed, ny *2 + nseed, nz * 2 + nseed) / 2 +
					instead.noise3(nx * 4 + nseed, ny *4 + nseed, nz * 4 + nseed) / 4
				rc, gc, bc = shape(n, t.t)
				pxl:val(x, y, clamp(rc * rr, 0, 255), clamp(gc * rr, 0, 255), clamp(bc * rr, 0, 255), 255)
			end
		end
	end

	local r2 = t.r ^ 2
	local rd2 = (t.r - d) ^ 2 

	for y = 0, t.r * 2 do -- flames
		local dy2 = (y - yc) ^ 2
		for x = 0, t.r * 2 do
			local dx2 = (x - xc) ^2
			if dx2 + dy2 < r2 and dx2 + dy2 > rd2 then
				local gr = (dx2 + dy2) ^ 0.5
				gr = 1 - (gr - (t.r - d)) / d
				local z = (r2 - dx2 - dy2) ^ 0.5
				local point = maf.vec3(x - t.r, y - t.r, -z)
				local rr = sun:angle(point)
				rr = clamp(rr / PI, 0, 1) 
				rr = rr ^ 2 * rfactor
				pxl:val(x, y, 255, 0, 0, clamp(rr * gr * 150, 0, 255))
			end
		end
	end

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
local zvec = maf.vec3(0, 0, 1)
local xvec = maf.vec3(1, 0, 0)
local yvec = maf.vec3(0, 1, 0)

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
