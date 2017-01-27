local std = stead
local type = std.type
std.rawset(_G, 'std', stead)
p = std.p
pr = std.pr
pn = std.pn
pf = std.pf
obj = std.obj
stat = std.stat
room = std.room
dlg = std.dlg
me = std.me
here = std.here
from = std.from
walk = std.walk
walkin = std.walkin
walkout = std.walkout

function object(w)
	local o
	if std.is_tag(w) then
		o = std.here():lookup(w)
		if not o then
			std.err("Wrong tag: "..w, 3)
		end
		return o
	end
	o = std.ref(w)
	if not o then
		std.err("Wrong object: "..std.tostr(w), 3)
	end
	return o
end

function for_all(fn, ...)
	if type(fn) ~= 'function' then
		std.err("Wrong argument to for_all: "..std.tostr(fn), 2)
	end
	local a = {...}
	for i = 1, #a do
		fn(a[i])
	end
end

function closed(w)
	return object(w):closed()
end

function disabled(w)
	return object(w):enabled()
end

function enable(w)
	return object(w):enable()
end

function pop(w)
	local r = here():pop(w)
	if type(r) == 'string' then
		std.p(r)
	end
	return r
end

function push(w)
	local r = here():push(w)
	if type(r) == 'string' then
		std.p(r)
	end
	return r
end

std.mod_init(function()
	declare {
		game = std.ref 'game',
		pl = std.ref 'pl',
	}
end)
