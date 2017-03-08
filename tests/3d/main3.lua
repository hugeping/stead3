-- Copyright 2016 Yat Hin Wong
require "sprite"
require "timer"
require "keys"

declare {
	PIXELS = true;
	Player = {};
	map = {};
	raycast = require "raycast";
	maze = require "maze";
	imgWidth = 0;
	imgHeight = 0;
	screen = false;
}
local stime = 0
function init()
if PIXELS then
	imgWidth = 640;
	imgHeight = 480;
	screen = pixels.new(640, 480)
else
	imgWidth = 640;
	imgHeight = 480;
end
	instead.mouse_show(false)
	instead.mouse_pos(imgWidth/2, imgHeight/2)

	raycast.init(imgWidth, imgHeight, 160, 0.8, 14)--14)

	Player.x = -1
	Player.y = -1
	Player.direction = math.pi/4

	map.create(30)
	--map.print()
	
	stime = instead.ticks()
end
function start()
	timer:set(20)
end
function game:timer()
	local dt = instead.ticks() - stime
	stime = instead.ticks()
	dt = dt / 1000
	local dx, dy = 0, 0

	-- go forward or backward
	local forward = 0
	if keys:state("w") then
		forward = 3
	elseif keys:state("s") then
		forward = -3
	end
	
	if math.abs(forward) > 0 then
		dx = math.cos(Player.direction) * forward * dt
		dy = math.sin(Player.direction) * forward * dt
	end
	
	-- strafe left or right
	local strafe = 0
	if keys:state("a") then
		strafe = -2
	elseif keys:state("d") then
		strafe = 2
	end
	
	if math.abs(strafe) > 0 then
		dx = dx + math.cos(Player.direction + math.pi/2) * strafe * dt
		dy = dy + math.sin(Player.direction + math.pi/2) * strafe * dt
	end
	
	-- checks if movement is allowed by the map
	if map.get(Player.x + dx, Player.y) <= 0 then
		Player.x = Player.x + dx
	end
	if map.get(Player.x, Player.y + dy) <= 0 then
		Player.y = Player.y + dy
	end
	
	-- turn left or right with mouse
	local mx, my = instead.mouse_pos()
	local turn = (mx - imgWidth/2)*0.05
	instead.mouse_pos(imgWidth/2, imgHeight/2)

	if math.abs(turn) > 0 then
		Player.direction = (Player.direction + turn*dt + 2*math.pi)%(2*math.pi)
	else
		if keys:state 'right' then
			Player.direction = (Player.direction + 1*dt + 2*math.pi)%(2*math.pi)
		elseif keys:state 'left' then
			Player.direction = (Player.direction + -1*dt + 2*math.pi)%(2*math.pi)
		end
	end
	draw()
	return false
end

function draw()
if PIXELS then
	screen:clear(0, 0, 0, 255)
	raycast.draw()
	screen:copy_spr(sprite.scr())
else
	sprite.scr():fill('black')
	raycast.draw()
end
end

-- creates a new map and initializes variables for minimap rendering
function map.create(size)
	map.grid = maze.create(size)
	map.size = 2*size+1
	map.grid[2][1] = 0
	map.grid[map.size-1][map.size] = 0
	
	map.padding = 50
	map.blockSize = (imgHeight-map.padding)/map.size
	map.offsetX = (imgWidth - map.blockSize*map.size)/2
	map.offsetY = map.padding/2
end

function map.get(x, y)
	local x = math.floor(x)
	local y = math.floor(y)
	if x < 1 or x > map.size or y < 1 or y > map.size then
		return -1
	end
	return map.grid[x][y]
end
