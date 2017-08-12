--$Name:fingers3$
--$Version:1.0$

require "finger"
require "timer"
local fingers = {}

function finger:filter(press, fid, x, y) -- all finger events
	return true
end

timer:set(20)

game.onfinger = function(s, press, fid, x, y)
	if press then
		pn (x, "x", y, rnd(10))
		table.insert(fingers, { id = fid, x = x, y = y });
	else
		fingers = {}
	end
	return true
end

game.timer = function()
	if not check_fingers() then
		return false
	end
end

function check_fingers()
	local fng = finger:list()
	local k, v
	if #fingers == 0 then
		return
	end
	local V
	for k,v in ipairs(fingers) do
		pn ("id: ", v.id, " x:", v.x, " y:", v.y);
	end
	pn ("----")
	for k,v in ipairs(fng) do
		local dx = v.x - fingers[1].x
		local dy = v.y - fingers[1].y
		pn ("id: ", v.id, " x:", v.x, " y:", v.y, " dx:", dx, " dy:", dy);
	end
	return true
end
