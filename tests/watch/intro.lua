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
	beep:play(1);
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
			walk 'snow'
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

function snow_theme()
	if D 'snow' then
		theme.set('win.col.fg', 'black')
		theme.set('win.col.link','black')
		theme.set('win.col.alink', 'black')
	end
end

function dark_theme()
	theme.reset('win.col.fg')
	theme.reset('win.col.link')
	theme.reset('win.col.alink')
end

dict.add("снег", "Снег ослепительно белый. Снежинки роем кружатся у моего лица.")
dict.add("ребенок", "Мне пять лет. Это все, что я знаю о себе.")

function pp(str)
	p("{#recurse|"..str.."}")
end

declare 'flake' (function(v)
	v.x = v.x + rnd(v.speed)
	v.y = v.y + rnd(v.speed) / 2
	if v.x > theme.scr.w() then v.x = 0 end
	if v.y > theme.scr.h() then v.y = 0 end
end)
declare 'flake_spr' (function(v)
	return sprite.new 'box:2x2,white' -- todo
end)
room {
	nam = 'snow';
	title = false;
--	fading = true;
	enter = function()
		timer:set(25)
		D {"snow", "img", background = true, "gfx/snow.jpg", z = 2 };
		for i = 1, 50 do
			D {"flake"..tostring(i), 'img', flake_spr, process = flake, x = rnd(theme.scr.w()), y = rnd(theme.scr.h()), speed = rnd(8) + 8, z = 1 }
		end
		snow_theme()
		lifeon '#голос'
	end;
	decor = [[{$dict снег|Снег. Кругом белый снег.} {$dict ребенок|Я стою}, {#сугроб|провалившись в сугроб}.]];
	exit = function()
		dark_theme()
	end;
}: with {
	obj {
		nam = '#сугроб';
		act = function(s)
			if seen '#отец' then
				pn [[Я снова пытаюсь вылезти из сугроба. Но он глубокий. Мне становится страшно.]]
				p [[-- Папа! -- но отец только смеется и зовет меня к себе.]]
				return
			end
			p [[Я пытаюсь вылезти из сугроба, но только глубже проваливаюсь в податливый снег.]]
		end;
	};
	obj {
		nam = '#голос';
		n = 1;
		act = function(s)
			p [[Это голос отца! За стеной снега я вижу его фигуру.]]
			enable '#отец';
		end;
		life = function(s)
			s.n = s.n + 1
			if s.n > 3 then
				if seen '#отец' then
					return
				else
					p [[{#голос|Я слышу как чей то голос зовет меня.}]]
				end
				return
			end
		end
	};
	obj {
		nam = '#отец';
		dsc = [[{$dict ребенок|Я вижу} {$dict снег|за стеной снега} {#отец|фигуру отца}.]];
		act = function(s)
			p [[Отец зовет меня к себе. Почему он не поможет мне?]];
		end;
	}:disable();
}
