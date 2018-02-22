function keys:filter(press, key)
	return press and (key == '0' or key == '1')
end

declare 'deco_cursor' (function(v)
	local w, h = 8, theme.get('win.fnt.size')
	local s = sprite.new(w * 2, h)
	s:fill(theme.get('win.col.bg'))
	s:fill(0, 0, w, h, 'gray')
	return s
end)
global 'inpnr' (0)
global 'randoms' ({})

local beep = snd.new 'snd/beep.ogg'
function decor.beep(v)
	beep:play();
end

local function inp(n)
	local d = D'input'
	table.insert(randoms, instead.ticks() % 2)
	d[3] = d[3] .. n
	d.w = nil
	d.h = nil
	D(d)
	d.x = (theme.scr.w() - d.w ) / 2
	local c = D'cursor'
	c.x = d.x + d.w - 4
	inpnr = inpnr + 1
	local t = D'intro'
	local len = 24
	local w = std.tostr(math.floor(inpnr * t.w / len))
	D { "line", "img", "box:"..w.."x4,red", x = t.x - t.xc, y = c.y + c.h + 8 }
	if inpnr == len then
		D'cursor'.hidden = true
		remove 'zero'
		remove 'one'
		local text = [[Анализирую последовательность... [pause] [pause] [pause]
[b]Плохое качество энтропии![/b] [pause]
В качестве данных беру нулевые биты
от времени нажатия клавиш... [pause] [pause]
]];
		for _, v in ipairs(randoms) do
			text = text .. std.tostr(v)
		end
		D { "analys", "txt", text, xc = true, x = theme.scr.w()/2, y = c.y + c.h + 16, align = 'center', 
		typewriter = true, z = 1 }
	else
		beep:play();
	end
end

menu {
	nam = 'zero';
	disp = '0';
	act = function() inp '0' end;
}

menu {
	nam = 'one';
	disp = '1';
	act = function() inp '1' end;
}
local delay = 0
room {
	nam = 'intro';
	title = false;
	onkey = function(s, a, b)
		if have 'zero' then
			inp(b)
		end
	end;
	timer = function()
		if D'intro' and not D'intro'.finished or
			D'analys' and not D'analys'.finished then
		end
		if D'analys' and D'analys'.finished then
			delay = delay + 1
			if delay < 50 then
			    return false
			end
			fading.set { 'fadeblack', max = 300 }
			D{'analys'}
			D{'cursor'}
			D{'input'}
			D{'intro'}
			D{'line'}
			walk 'main'
			return
		end
		if not D'intro'.started and not D 'cursor' then
			local d = D'intro'
			D {"cursor", "img", deco_cursor, xc = false, frames = 2, w = 8, delay = 300, x = d.x, y = d.y + d.h - d.yc + 1 }
			D {"input", "txt", "", align = 'left', xc = false, x = d.x, y = d.y + d.h - d.yc }
			take 'zero'
			take 'one'
			return
		end
		return false
	end;
	enter = function()
		local x, y, w, h = theme.get 'win.x', theme.get 'win.y', theme.get 'win.w', theme.get 'win.h'
		x, y, w, h = std.tonum(x),  std.tonum(y),  std.tonum(w),  std.tonum(h)
		local text = [[Представьте себе, что вы бросаете монетку. [pause] [pause] [pause]
Ноль - это орел. Один - решка.
Запишите последовательность из нулей и единиц...]]
		timer:set(20)
		D {"intro", "txt", text, xc = true, yc = true, x = theme.scr.w()/2, y = theme.scr.h()/3, align = 'center', typewriter = true, z = 1 }
	end
}
