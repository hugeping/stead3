room {
	nam = 'intro';
	title = false;
	timer = function()
		if not D("intro").started then
		end
	end;
	enter = function()
		local x, y, w, h = theme.get 'win.x', theme.get 'win.y', theme.get 'win.w', theme.get 'win.h'
		x, y, w, h = std.tonum(x),  std.tonum(y),  std.tonum(w),  std.tonum(h)
		local text = [[Введите числа от 0 до 9...]]
		timer:set(20)
		D {"intro", "txt", text, xc = true, yc = true, x = w / 2, y = h / 2, align = 'left', typewriter = true, z = 1 }
	end
}
