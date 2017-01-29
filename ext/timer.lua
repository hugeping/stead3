-- raw iface to timer

local std = stead
local type = std.type

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
