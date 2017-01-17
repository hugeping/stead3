local std = stead
std.rawset(_G, 'std', stead)
p = std.p;
pr = std.pr;
pn = std.pn;
obj = std.obj;
room = std.room;
dlg = std.dlg;
me = std.me;
here = std.here;
walk = function(...);
	return std.me():walk(...)
end;
walkin = function(...)
	return std.me():walkin(...)
end;
walkout = function(...)
	return std.me():walkout(...)
end;

std.mod_init(function()
	declare {
		game = std.ref 'game',
		pl = std.ref 'pl',
	}
end)
