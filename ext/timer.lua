-- raw iface to timer

local std = stead
local type = std.type

local instead = std.ref '@instead'

instead.timer = instead_timer

local timer = std.obj {
	nam = '@timer';
	ini = function(s)
		if s.timer then
			s:set(s.timer)
		end
	end;
	get = function(s)
		return std.tonum(s.timer) or 0;
	end;
	stop = function(s)
		return s:set(0)
	end;
	set = function(s, v)
		if type(v) ~= 'number' then
			std.err("Wrong argument to timer:set(): "..std.tostr(v), 2)
		end
		s.timer = v
		instead.timer(s.timer)
		return true
	end;
	callback = function(s)
		return '@timer'
	end
}

std.timer = function() -- sdl part call this one
	if std.type(timer.callback) == 'function' then
		return timer:callback();
	end
	return
end

std.mod_done(function(s)
	timer:stop()
end)

std.mod_cmd(function(cmd)
	if cmd[1] ~= '@timer' then
		return
	end
	local r,v
	if std.here().timer then
		r, v = std.call(stead.here(), 'timer');
	elseif std.game.timer then
		r, v = stead.call(std.game, 'timer');
	end
	if r ~= nil or v ~= nil then
		return r, v
	end
	return nil, false
end)
