local std = stead
std.dlg = std.class({
	__dlg_type = true;
	display = function(s)
		local r
		local d = stead.space_delim
		std.space_delim = '^'
		r = s.obj:display()
		std.space_delim = d
		return r
	end;
}, std.room)
