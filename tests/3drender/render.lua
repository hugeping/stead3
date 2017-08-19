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


function render.star(t)
	local pxl = pixels.new(t.r * 2, t.r * 2)
	local xc = t.r 
	local yc = t.r 
	local r = t.r
	local tt = t.temp
	local d = t.r / 4

	for i = 0, d - 1 do
		pxl:fill_circle(xc, yc, r - i, KtoRGB(tt - (d - i) * 100))
	end
	pxl:fill_circle(xc, yc, r - d, KtoRGB(tt))
	d = d / 1.5
	for y = 0, t.r * 2 do
		for x = 0, t.r * 2 do
			if (x - xc) ^ 2 + (y - yc) ^ 2 < (r) ^ 2 and 
				(x - xc) ^ 2 + (y - yc) ^ 2 > (r - d) ^ 2 then
				local gr = ((x - xc) ^ 2 + (y - yc) ^ 2) ^ 0.5
				gr = 1 - (gr - (r - d)) / d 
				local n = instead.noise3(x / 20, y / 20, z / 20)
				local rr, gg, bb = pxl:val(x, y)
				pxl:val(x, y, rr, gg, bb, (n * 127 + 127) * gr)
			end
		end
	end

	d = t.r / 4

	for y = 0, t.r * 2 do
		for x = 0, t.r * 2 do
			if (r - x - d) ^ 2 + (r - y - d) ^ 2 < (r - d) ^ 2 then
				local z = (r ^ 2 - (r - x) ^ 2) ^ 0.5
				local n = instead.noise3(x / 20, y / 20, z / 20)
				if n < -0.1 then
					local rr, gg, bb = KtoRGB(tt + n * 5000)
					local col = { rr, gg, bb, 255 }
					pxl:pixel(x + d, y + d, std.unpack(col))
				end
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
			local nx = fov * (pos.x + o.x) / pos.z
			local ny = fov * (pos.y + o.y) / pos.z
			local scale = o.scale * fov / pos.z
			local pp2 = o.pixels:scale(scale, scale, true)
			pp2:blend(screen, xc + nx, yc - ny)
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
	o:rotate(0, 0)
	o:camera(0, 0, 0)
	o:setfov(PI / 4)
	return o
end

function scene:setfov(fov)
	self.fov = fov
end

function scene:look(angle, x, y, z)
	local q = maf.rotation()
	q:between(maf.vec3(0, 0, 1), x, y, z)
	self.quat = q
end

function scene:rotate(hangle, vangle)
	local qh = maf.rotation()
	qh:angleAxis(hangle, 0, 1, 0)
	local qv = maf.rotation()
	qv:angleAxis(vangle, 1, 0, 0)
	local qq = maf.rotation()
	qv:mul(qh, qq)
	self.quat = qq
	local v = qq * maf.vec3(0, 0, 1)
	v.y = - v.y
	v.x = - v.x
	return v
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
			print(o.pos.x, o.pos.y, o.pos.z)
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
