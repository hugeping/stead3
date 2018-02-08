require "sprite"
require "theme"
require "timer"

instead.fading = false

local f = std.obj {
	{
		started = false;
		timer = false;
		step = 0;
	};
	max = 12; -- iterations
	nam = '@fading';
	effect = function(s, src, dst)
		sprite.scr():fill('black')
		local x = (theme.get 'scr.w') * s.step / s.max 
		src:copy(sprite.scr(), x, 0);
		dst:copy(sprite.scr(), x - theme.get 'scr.w', 0);
	end
}

local scr, scr2
local cb = timer.callback

function timer:callback(...)
	if f.started then
		return '@fading'
	end
	return cb(self, ...)
end

function f.start()
	local old = sprite.direct()
	sprite.direct(true)
	sprite.scr():copy(scr)
	sprite.direct(old)
	f.timer = timer:get()
	f.step = 0
	f.started = true
	timer:set(20)
end

instead.render_callback(function()
	if f.started and not sprite.direct() then
		sprite.direct(true)
		sprite.scr():copy(scr2)
		scr:copy(sprite.scr())
	end
end)

std.mod_cmd(function(cmd)
	if cmd[1] ~= '@fading' then
		return
	end

	f.step = f.step + 1

	f:effect(scr, scr2)

	if f.step > f.max then
		f.started = false
		timer:set(f.timer)
		sprite.direct(false)
		return std.nop()
	end
	return
end)

std.mod_start(function()
	scr = sprite.new(theme.get 'scr.w', theme.get 'scr.h')
	scr2 = sprite.new(theme.get 'scr.w', theme.get 'scr.h')
end)

std.mod_step(function(state)
	if not state then
		return
	end
	if player_moved() and std.cmd[1] ~= 'load' then
		f.start()
	end
end)

fading = f

sprite.direct(true)
sprite.direct(false)