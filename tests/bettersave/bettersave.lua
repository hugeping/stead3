local function rename_auto()
	for k = 1, #std.objects do
		local o = std.objects[k]
		local oo = {}
		local w = o and o:where()
		if w then
			table.insert(oo, 1, o)
		end

		while w and type(w.nam) == 'number' and w.nam > 0 do -- auto allocated
			table.insert(oo, 1, w)
			w = w:where()
		end

		for kk, vv in ipairs(oo) do
			local w = vv:where()
			if not w then
				break
			end
			local pfx = 'o'
			local o, i = w.obj:lookup(vv)
			if not o then
				pfx = 'w'
				o, i = w.way:lookup(vv)
				if not o then
					break
				end
			end
			-- print(std.tostr(w.nam)..'.'..pfx..std.tostr(i))
			vv:__renam(std.tostr(w.nam)..'.'..pfx..std.tostr(i))
		end
	end
end

std.mod_init(function() -- declarations
	game.ini = std.hook(game.ini, function(f, self, load, ...)
		local r, v = f(self, load, ...)
		if not load then
			rename_auto()
		end
		return r, v
	end)
end, 100)
