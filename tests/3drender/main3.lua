local r = require "render"
require "sprite"
require "keys"

function keys:filter(press, key)
	return key == "left" or key == "right" or key == "w" or key == "a" or key == "s" or key == "d" or key == "up" or key == "down"
end

global { hangle = 0, vangle = 0, x = 0, y = 0, z = 0 }
declare { look = false }

game.onkey = function(s, press, key)
	if not press then
		return false
	end
	local axis
	if key == "w" then
		x, y, z = (r.vec3(x, y, z) + look * 2):unpack()
	elseif key == "a" then
		x = x - 2
	elseif key == "s" then	
		x, y, z = (r.vec3(x, y, z) - look * 2):unpack()
	elseif key == "d" then
		x = x + 2
	elseif key == "right" then
		hangle = hangle - (math.pi / 32)
	elseif key == "left" then
		hangle = hangle + (math.pi / 32)
	elseif key == "up" then
		vangle = vangle - (math.pi / 32)
	elseif key == "down" then
		vangle = vangle + (math.pi / 32)
	end
	scene:camera(x, y, z)
	look = scene:rotate(hangle, vangle)
	print(look:unpack())
--	print("VIEW: ", hangle, vangle)
	screen:clear(0, 0, 0, 255)
	scene:render(screen)
	return true
end

function gfx()
	return screen:sprite()
end

game.pic = gfx

declare {
	screen = false;
	scene = false;
}

function init()
	screen = pixels.new(640, 480)
	screen:clear(0, 0, 0, 255)
	scene = r.scene()
	local o = r.object():circle(0, 0, 200, { 255, 255, 255, 255 })
	local circle = pixels.new(200, 200)
	circle:circle(100, 100, 98, 255, 255, 255, 255);
	local o = r.object():pixels(circle, -100, 100, 1)
	scene:place(o, 0, 0, 200)
--	scene:place(o, 0, 0, 5)
	scene:setfov(160)
	scene:camera(0, 0, 1)
	scene:render(screen)
end

function start()
	look = scene:rotate(hangle, vangle)
end
