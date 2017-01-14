local std = stead
std.dlg = std.class({
	__dlg_type = true;
	look = function(s)
		local r
		for i = 1, #s.obj do
			if r then
				r = r .. '^'
			end
			local o = s.obj[i]
			if not o:disabled() and not o:closed() then
				local d = iface:xref(std.call(s[i], 'dsc'), o)
				if type(d) == 'string' then
					r = (r or '').. d
				end
			end
		end
		return r
	end;
}, std.room)
