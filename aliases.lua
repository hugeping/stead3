local std = stead
std.rawset(_G, 'std', stead)
p = std.p
pr = std.pr
pn = std.pn
pf = std.pf
obj = std.obj
room = std.room
dlg = std.dlg
me = std.me
here = std.here
from = std.from
walk = std.walk
walkin = std.walkin
walkout = std.walkout

std.mod_init(function()
	declare {
		game = std.ref 'game',
		pl = std.ref 'pl',
	}
end)
