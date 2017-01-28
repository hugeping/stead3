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
new = std.new
delete = std.delete
nameof = std.nameof
dispof = std.dispof
titleof = std.titleof

function from(ww)
	local wh
	ww = ww or std.here()
	wh = std.ref(ww)
	if not std.is_obj(wh, 'room') then
		std.err("Wrong argument to from: "..std.tostr(wh), 2)
	end
	return wh:from()
end;

function walk(w, ...)
	local r, v = std.me():walk(w, ...)
	if type(r) == 'string' then
		std.p(r)
	end
	return r, v
end

function walkin(w, ...)
	local r, v = std.me():walkin(w, ...)
	if type(r) == 'string' then
		std.p(r)
	end
	return r, v
end

function walkout(w, ...)
	if not std.is_obj(w, 'room') then
		std.err("Wrong argument to walkout: "..std.tostr(w), 2)
	end
	local r, v = std.me():walkout(w, ...)
	if type(r) == 'string' then
		std.p(r)
	end
	return r, v
end

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

function seen(w, ww)
	local wh
	ww = ww or std.here()
	wh = std.ref(ww)
	if not std.is_obj(wh) then
		std.err("Wrong 2-nd argument to seen: "..std.tostr(ww), 2)
	end
	return wh:seen(w)
end

function lookup(w, ww)
	local wh
	ww = ww or std.here()
	wh = std.ref(ww)
	if not std.is_obj(wh) and not std.is_obj(wh, 'list') then
		std.err("Wrong 2-nd argument to lookup: "..std.tostr(ww), 2)
	end
	return wh:lookup(w)
end

function ways(ww)
	local wh
	ww = ww or std.here()
	wh = std.ref(ww)
	if not std.is_obj(wh, 'room') then
		std.err("Wrong 2-nd argument to ways: "..std.tostr(ww), 2)
	end
	return wh.way
end

function objs(ww)
	local wh
	ww = ww or std.here()
	wh = std.ref(ww)
	if not std.is_obj(wh) then
		std.err("Wrong 2-nd argument to objs: "..std.tostr(ww), 2)
	end
	return wh.obj
end

function search(w, ...)
	return std.me():search(w, ...)
end

function have(w, ...)
	return std.me():have(w, ...)
end

function inroom(w, ...)
	return object(w):room(w, ...)
end

function where(w, ...)
	return object(w):where(w, ...)
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
	local wh = std.here()
	if not std.is_obj(wh, 'dlg') then
		std.err("Call pop() in non-dialog object: "..std.tostr(wh), 2)
	end
	local r, v = wh:pop(w)
	if type(r) == 'string' then
		std.p(r)
	end
	return r, v
end

function push(w)
	local wh = std.here()
	if not std.is_obj(wh, 'dlg') then
		std.err("Call push() in non-dialog object: "..std.tostr(wh), 2)
	end
	local r, v = ww:push(w)
	if type(r) == 'string' then
		std.p(r)
	end
	return r, v
end

function empty(w)
	if not w then
		return std.here():empty()
	end
	return object(w):empty(w)
end

std.mod_init(function()
	declare {
		game = std.ref 'game',
		pl = std.ref 'pl',
	}
end)
