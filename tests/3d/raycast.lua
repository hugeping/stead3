-- Copyright 2016 Yat Hin Wong
local raycast = {}

local camera = {}
local rsin, rcos -- ray sine and cosine

local function tableConcat(t1, t2)
	for i=1, #t2 do
		t1[#t1 + 1] = t2[i]
	end
	return t1
end

local floor = math.floor
local ceil = math.ceil
--[[
local function cache(f)
    local c={}
    return function (x)
        local y=c[x]
        if y==nil then
            y=f(x)
            c[x]=y
        end
        return y
    end
end
]]--

local sin = math.sin
local cos = math.cos
local tan = math.tan
local atan2 = math.atan2

-- finds the next grid intersection
local function step(rise, run, x, y, inverted)
	if run == 0 then
		return {length2 = math.huge}
	end
	
	local dx = run > 0 and floor(x+1)-x or ceil(x-1)-x
	local dy = dx * (rise/run)
	return {x = inverted and y + dy or x + dx,
	        y = inverted and x + dx or y + dy,
			length2 = dx * dx + dy * dy}
end

-- checks wall presence and sets eventual height and distance from Player
local function inspect(step, shiftX, shiftY, distance, offset)
	local dx = rcos < 0 and shiftX or 0
	local dy = rsin < 0 and shiftY or 0
	step.height = map.get(step.x - dx, step.y - dy)
	step.distance = distance + step.length2 ^ 0.5
	if shiftX > 0 then
		step.shading = rcos < 0 and 2 or 0
	else
		step.shading = rsin < 0 and 2 or 1
	end
	step.offset = offset - floor(offset)
	return step
end

-- casts a ray and checks if it encounters a wall
local function cast(origin)
	local stepX = step(rsin, rcos, origin.x, origin.y, false)
	local stepY = step(rcos, rsin, origin.y, origin.x, true)
	local nextStep = stepX.length2 < stepY.length2 and
		inspect(stepX, 1, 0, origin.distance, stepX.y) or
		inspect(stepY, 0, 1, origin.distance, stepY.x)
	
	if nextStep.distance > camera.range then
		return {origin}
	else
		return tableConcat({origin}, cast(nextStep))
	end
end

-- draws a rectangle for each raycast
local function drawColumn(column, ray, angle)
	local left = math.floor(column * camera.spacing)
	local width = math.ceil(camera.spacing)
	for i,step in ipairs(ray) do
		if step.height > 0 then
			local z = step.distance * cos(angle)
			local height = camera.height * step.height / z
			local top = camera.height / 2 * (1 + 1 / z) - height
			local factor = math.max(150 - (math.max(step.distance + step.shading, 0)*255/15),0)
			if PIXELS then
				screen:clear(left, top, width, height, factor, factor, factor)
			else
				local col = string.format("#%02x%02x%02x", factor, factor, factor)
				sprite.scr():fill(left, top, width, height, col)
			end
			return
		end
	end
end

function raycast.init(w, h, res, fl, range)
	camera.width = w
	camera.height = h
	camera.resolution = res
	camera.spacing = camera.width / camera.resolution
	camera.focalLength = fl
	camera.range = range
end

function raycast.draw()
	collectgarbage 'stop'
	for column = 0, camera.resolution-1 do
		local x = column / camera.resolution - 0.5
		local angle = atan2(x, camera.focalLength)
		rsin = sin(Player.direction + angle)
		rcos = cos(Player.direction + angle)
		local ray = cast({x = Player.x, y = Player.y, height = 0, distance = 0})
		drawColumn(column, ray, angle)
	end
	collectgarbage()
end

return raycast
