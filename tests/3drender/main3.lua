local r = require "render"
require "sprite"
require "keys"

function keys:filter(press, key)
	return key == "left" or key == "right" or key == "w" or key == "a" or key == "s" or key == "d" or key == "up" or key == "down" or key == "r" or key == "b"
end

global { hangle = 0, x = 0, y = 0, z = 0 }
declare { look = false }

game.onkey = function(s, press, key)
	if not press then
		return false
	end
	local axis
	local vangle = 0
--	local hangle = 0
	if key == "w" then
		print("L:", look:normalize():unpack())
		x, y, z = (r.vec3(x, y, z) + look:normalize() * 10):unpack()
	elseif key == "a" then
		x = x - 2
	elseif key == "s" then	
		x, y, z = (r.vec3(x, y, z) - look:normalize() * 10):unpack()
	elseif key == "d" then
		x = x + 2
	elseif key == "right" then
		hangle =  hangle - (math.pi / 32)
	elseif key == "left" then
		hangle =  hangle + (math.pi / 32)
	elseif key == "up" then
		vangle = (math.pi / 32)
	elseif key == "down" then
		vangle = - math.pi / 32
	elseif key == "r" then
		local star = r.star({r = 160, temp = rnd(1000, 10000), seed = rnd(10000) })
		local o = r.object():pixels(star, -160, 160, 1)
		scene.objects = {}
		scene:place(o, 0, 0, 200)
	elseif key == "b"then
		local star = r.star({r = 160, temp = 0, seed = rnd(10000) })
		local o = r.object():pixels(star, -160, 160, 1)
		scene.objects = {}
		scene:place(o, 0, 0, 200)
	end
	scene:camera(x, y, z)
--	if not look then look = r.vec3(0, 0, 1) end
	look = scene:climb(look, vangle, hangle)
--	look = scene:roll(look, hangle)
	print("look: ", look:unpack())
	scene:look(look, hangle)
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
	screen = pixels.new(800, 568)
	screen:clear(0, 0, 0, 255)
	scene = r.scene()
	local starv = r.vec3(-300, 0, 200)
	local planetv = r.vec3(30, 0, 30)
	local asteroidv = r.vec3(1, -3, 5)

	local star = r.star({r = 160, temp = 4500 })
	local planet = r.planet({r = 160, light = planetv - starv })
	local asteroid = r.asteroid({r = 160, light = asteroidv - starv, seed = rnd(110000) })

	local o = r.object():pixels(star, -160, 160, 1)
	local p = r.object():pixels(planet, -160, 160, 0.1)
	local a = r.object():pixels(asteroid, -160, 160, 0.01)

	scene:place(o, starv)
	scene:place(p, planetv)
	scene:place(a, asteroidv)
	scene:setfov(160)
	scene:camera(0, 0, 1)
	scene:render(screen)
end

function start()
	look = r.vec3(0, 0, 1)
	scene:look(look)
	screen:clear(0, 0, 0, 255)
	scene:render(screen)
--	os.exit(1)
end

room {
	nam = "main";
	title = false;
}
