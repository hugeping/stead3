local std = stead
std.phrase_prefix = '--'
std.dlg = std.class({
	__dlg_type = true;
	display = function(s)
		local r, nr
		nr = 1
		for i = 1, #s.obj do
			if r then
				r = r .. '^'
			end
			local o = s.obj[i]
			if not o:disabled() and not o:closed() then
				local d = std.call(o, 'dsc')
				if type(d) == 'string' then
					if type(std.phrase_prefix) == 'string' then
						d = std.phrase_prefix .. d
					elseif type(std.phrase_prefix) == 'function' then
						d = std.phrase_prefix(nr) .. d
					end
					d = o:xref(d)
					r = (r or '').. d
					nr = nr + 1
				end
			end
		end
		return r
	end;
}, std.room)
