declare 'deco_cursor' (function(v)
	local w, h = 8, theme.get('win.fnt.size')
	local s = sprite.new(w * 2, h)
	s:fill 'black'
	s:fill(0, 0, w, h, 'grey')
	return s
end)

room {
	nam = 'intro';
	title = false;
	timer = function()
		if not D'intro'.started and not D 'cursor' then
			local d = D'intro'
			D {"cursor", "img", deco_cursor, frames = 2, delay = 300, x = d.x, y = d.y + d.h }
		end
	end;
	enter = function()
		local x, y, w, h = theme.get 'win.x', theme.get 'win.y', theme.get 'win.w', theme.get 'win.h'
		x, y, w, h = std.tonum(x),  std.tonum(y),  std.tonum(w),  std.tonum(h)
		local text = [[Введите числа от 0 до 9...]]
		timer:set(20)
		D {"intro", "txt", text, xc = true, yc = true, x = theme.scr.w()/2, y = theme.scr.h() / 3, align = 'left', typewriter = true, z = 1 }
	end
}
