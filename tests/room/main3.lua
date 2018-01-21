require "keys"
require "timer"
local r = require "room"

local map = {
    { 0, 0, 0, 0, 0 },
    { 0, 1, 1, 1, 1 },
    { 0, 0, 0, 0, 1 },
    { 0, 1, 1, 1, 1 },
    { 0, 0, 0, 0, 0 },
}
function start(load)
    r = r:new(256, 256, 2)
    for y = 1, 5 do
	for x = 1, 5 do
	    local b = map[y][x] == 1
	    r.map:set(x - 1, y - 1, { block = b })
	end
    end
    r.map:get(3, 2).item = {}
    r.player.x = 0
    r.player.y = 2.5
    r.player.dir = 0
    timer:set(50)
    r:render()
end

function game:timer()
    if keys:state('left') then
	r.player:rotate(-0.05)
	r:render()
    elseif keys:state('right') then
	r.player:rotate(0.05)
	r:render()
    elseif keys:state('w') then
	r.player:walk(0.1, r.map)
	r:render()
    elseif keys:state('s') then
	r.player:walk(-0.1, r.map)
	r:render()
    elseif keys:state('a') then
	r.player:rotate(- math.pi/2)
	r.player:walk(0.1, r.map)
	r.player:rotate(math.pi/2)
	r:render()
    elseif keys:state('d') then
	r.player:rotate(math.pi/2)
	r.player:walk(0.1, r.map)
	r.player:rotate(-math.pi/2)
	r:render()
    end
    r:draw()
end
