function keys:filter(press, key)
	return press and (key == '0' or key == '1' or key == 'space')
end
function click:filter(press)
	return press
end
declare 'deco_cursor' (function(v)
	local w, h = 8, theme.get('win.fnt.size')
	local s = sprite.new(w * 2, h)
	s:fill(theme.get('win.col.bg'))
	s:fill(0, 0, w - 1, h - 1, 'gray')
	return s
end)
global 'inpnr' (0)
global 'randoms' ({})

declare 'beep' (snd.new 'snd/beep.ogg')

function decor.beep(v)
	if beep and not player_moved() then
		if not snd.playing(1) then
			beep:play(1);
		elseif not snd.playing(2) then
			beep:play(2);
		end
	end
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
		if beep then
			beep:play();
		end
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
			fading.set { 'fadeblack', max = FADE_LONG }
			D{'analys'}
			D{'cursor'}
			D{'input'}
			D{'intro'}
			D{'line'}
			walk 'snova'
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

function snow_theme(w)
	theme.set('win.col.fg', 'black')
	theme.set('win.col.link','black')
	theme.set('win.col.alink', 'black')

	theme.set('inv.col.fg', 'black')
	theme.set('inv.col.link','black')
	theme.set('inv.col.alink', 'black')

	if (w or here()).hideinv then
		noinv_theme()
	else
		inv_theme()
	end
end

function noinv_theme()
	theme.set('win.h', 540 - 80)
	theme.set('inv.mode', 'disabled')
	theme.set('win.w', 600)
	theme.set('win.x', 192 + 20)
end

function inv_theme()
	theme.reset('win.h')
	theme.reset('inv.mode')
	theme.reset('win.w')
	theme.reset('win.x')
end

function dark_theme(w)
	theme.reset('win.col.fg')
	theme.reset('win.col.link')
	theme.reset('win.col.alink')

	theme.reset('inv.col.fg')
	theme.reset('inv.col.link')
	theme.reset('inv.col.alink')
	if (w or here()).hideinv then
		noinv_theme()
	else
		inv_theme()
	end
end

function theme_select()
	if D'snow' or here() ^ 'журнал' or D'clouds' or D'journal' then
		snow_theme()
	else
		dark_theme()
	end
end
--dict.add("ребенок", "Мне пять лет. Это все, что я знаю о себе.")

function pp(str)
	p("{#recurse|"..str.."}")
end

declare 'flake' (function(v)
	local sp = v.speed + rnd(2)
	local sp2 = v.speed + rnd(4)
	v.x = v.x + sp;
	v.y = v.y + sp2 / 2;
	if v.x > theme.scr.w() then
		v.x = 0
		v.speed = rnd(5)
	end
	if v.y > theme.scr.h() then
		v.y = 0
		v.speed = rnd(5)
	end
end)

function blur(p, r, g, b)
	local w, h = p:size()
	local cell = function(x, y)
		if x < 0 or x >= w or y < 0 or y >= h then
			return 0
		end
		local r, g, b, a = p:val(x, y)
		return a
	end
	for y = 0, h  do
		for x = 0, w do
			local c1, c2, c3, c4, c5, c6, c7, c8, c9 =
				cell(x - 1, y - 1),
				cell(x, y - 1),
				cell(x + 1, y - 1),
				cell(x - 1, y),
				cell(x, y),
				cell(x + 1, y),
				cell(x - 1, y + 1),
				cell(x, y + 1),
				cell(x + 1, y + 1)
			local c = (c1 + c2 + c3 + c4 + c5 + c6 + c7 + c8 + c9) / 9
			p:val(x, y, r, g, b, math.floor(c))
		end
	end
end

declare 'flake_spr' (function(v)
	local p = pixels.new(7, 7)
	local x, y = 3, 3
	p:val(x, y, 255,255,255,255)
	for i = 1, rnd(5) do
		local w = rnd(3)
		p:fill(x, y, w, w, 255, 255, 255, 255)
		x = x + rnd(2) - 1
		y = y + rnd(2) - 1
	end
	blur(p, 255, 255, 255)
	return p:sprite()
end)

declare 'star_spr' (function(v)
	local p = pixels.new(7, 7)
	local x, y = 3, 3
	p:val(x, y, 255,255,255,255)
	local c = rnd(128) + 127
	for i = 1, rnd(5) do
		local w = rnd(3)
		p:fill(x, y, w, w, 255, 255, 255, 255)
		x = x + rnd(2) - 1
		y = x + rnd(2) - 1
	end
	blur(p, 255, 255, 255)
	return p:sprite()
end)

global 'snow_state' (0)
obj {
	nam = 'снежок';
	hard = false;
	inv = function(s)
		p [[Я покрепче слепил снежок.]];
		s.hard = true
	end;
	shoot = false;
	use = function(s, w)
		if w ^ '#отец' then
			p [[Я бросил снежок.]]
			remove(s)
			if not s.hard then
				p [[Бросок был слабым, комок снега не долетел до цели, рассыпавшись по пути.]]
				p [[Нужно еще сильнее скатать снежок.]]
				s.hard = true
			else
				if s.shoot then
					prefs.snowball_launcher = true
				end
				s.shoot = true
				p [[Попал! Я слышу, как смеется отец. Он идет ко мне.]]
			end
		else
			p [[Я хочу бросить снежком в отца.]]
		end
	end
}
room {
	nam = 'snow';
	title = false;
--	fading = true;
	enter = function()
--		fading.change {'crossfade', max = 20 }
		timer:set(25)
		D {"snow", "img", background = true, "gfx/snow.jpg", z = 2 };
		for i = 1, 50 do
			D {"flake"..tostring(i), 'img', flake_spr, process = flake, x = rnd(theme.scr.w()), y = rnd(theme.scr.h()), speed = rnd(5), z = 1 }
		end
		snow_theme()
		lifeon '#голос'
		p [[Мне нужно выбраться из сугроба!]]
	end;
	onexit = function()
		lifeoff '#голос'
--		D()
--		decor.bgcol = 'white'
		fading.set { 'crossfade', max = 1}
	end;
	decor = function()
		p [[{#снег|Снег. Кругом белый снег.} ]]
		if snow_state < 5 then
			p [[{#ребенок|Я стою}, {#сугроб|провалившись в сугроб}.]];
		else
			p [[{#ребенок|Я стою по колено} {#снег|в снегу.}]];
		end
	end;
	exit = function()
--		dark_theme()
	end;
}: with {
	obj {
		nam = '#снег';
		act = function()
			if snow_state == 5 and not have 'снежок' then
				p [[Я слепил из снега снежок.]]
				take 'снежок'
				return
			end
			p "Снег ослепительно белый. Снежинки роем кружатся у моего лица."
		end;
	};
	obj {
		nam = '#ребенок';
		act = "Мне пять лет. Это все, что я знаю о себе.";
	};
	obj {
		nam = '#сугроб';
		act = function(s)
			if seen '#отец' then
				if snow_state == 1 or snow_state == 2 then
					snd.play 'snd/snow.ogg'
					p [[Я изо всех сил пытаюсь пройти сквозь глубокий снег. Но мне не удается преодолеть его сопротивление.]];
					snow_state = 2
					return
				end
				if snow_state == 3 then
					snow_state = 4
					snd.play ('snd/snow.ogg')
					p [[Я пробиваюсь сквозь снег, молотя руками и ногами. Снег вокруг меня.]];
					return
				end
				if snow_state == 4 then
					p [[Кажется, снег поддается! Он уже не сковывает моих движений. Я выбрался!]]
					snow_state = 5
					return
				end
				snd.play 'snd/snow.ogg'
				pn [[Я снова пытаюсь вылезти из сугроба. Но он глубокий. Мне становится страшно.]]
				p [[-- Папа! -- но отец только смеется и зовет меня к себе.]]
				if actions '#отец' > 0 then
					if snow_state == 0 then snow_state = 1 end
				end
				return
			end
			snd.play 'snd/snow.ogg'
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
			if s.n > 4 then
				if seen '#отец' then
					return
				else
					p [[{#голос|Я слышу, как чей то голос зовет меня.}]]
				end
				return
			end
		end
	};
	obj {
		nam = '#отец';
		dsc = function(s)
			p [[{#ребенок|Я вижу} {#снег|за стеной снега} {#отец|фигуру отца}.]];
		end;
		act = function(s)
			if snow_state == 5 then
				if _'снежок'.shoot then
					snd.play 'snd/snowball.ogg'
					walk 'комок'
					return
				end
				p [[Я злюсь на отца. Зачем он бросил меня в сугроб?]];
				return
			end
			if snow_state == 1 then
				p [[Он смеется и зовет меня к себе. Но я не могу выбраться!]];
			elseif snow_state > 1 then
				if snow_state < 3 then
					p [[За снежной пеленой мне кажется, что отец уходит... ^-- Папа! Помоги!]];
					snow_state = 3
				else
					p [[-- Папа, подожди!]]
				end
			else
				p [[Отец зовет меня к себе. Почему он не поможет мне?]];
			end
		end;
	}:disable();
}
room {
	nam = 'комок';
	title = false;
	{
		time = 0;
	};
	decor = fmt.y("50%")..fmt.c("СНЕЖОК!");
	timer = function(s)
		inv():zap()
		if instead.ticks() - s.time > 500 then
			fading.set {"fadeblack", max = FADE_LONG }
			walk 'пробуждение'
		end
	end;
	enter = function(s)
		s.time = instead.ticks()
		quake.start()
	end;
	exit = function()
		D() -- reset all
		dark_theme();
	end;
}
declare 'shade_spr' (function(v)
	local shade = sprite.new(theme.scr.w(), theme.scr.h())
	shade:fill 'black'
	return shade:alpha(8)
end)

local time = 0
local delay = rnd(2000)
declare 'stars' (function(v)
	if not v.xx then v.xx = v.x end
	if not v.yy then v.yy = v.y end
	local mx, my = instead.mouse_pos()
	local dx = (mx - theme.scr.w() / 2)
	local dy = (my - theme.scr.h() / 2)
	dx = dx * v.dist / (theme.scr.w() / 2)
	dy = dy * v.dist / (theme.scr.w() / 2)
	v.x = v.xx - dx
	v.y = v.yy - dy
end)

const 'STARS' (9)

global 'blink' (false)
declare 'space_bg' (function(v)
	if not v.ffx then v.ffx = v.fx end
	if not v.ffy then v.ffy = v.fy end
	local mx, my = instead.mouse_pos()
	local dx = (mx - theme.scr.w() / 2)
	local dy = (my - theme.scr.h() / 2)
	dx = dx * 8 / (theme.scr.w() / 2)
	dy = dy * 8 / (theme.scr.w() / 2)
	v.fx = v.ffx + dx
	v.fy = v.ffy + dy
	if instead.ticks() - time < delay then
		return
	end
	local s = D('star'..tostring(rnd(STARS)))
	s.alpha = rnd(255)
	blink = not blink
--	D'shade'.hidden = not D'shade'.hidden
	if blink then -- D'shade'.hidden then
		return
	end
	for i = 1, STARS do
		D('star'..tostring(i)).alpha = nil
	end
--	v.fx = v.fx + rnd(2) - 1
--	v.fy = v.fy + rnd(2) - 1
	delay = rnd(200)
	time = instead.ticks()
end)

local function get_offsets(d)
	time = instead.ticks()
	d.fx = rnd(d.realw - theme.scr.w() - 32) + 8
	d.fy = rnd(d.realh - theme.scr.h() - 32) + 8
	d.w = theme.scr.w() + 8
	d.h = theme.scr.h() + 8
	d.ffx = d.fx
	d.ffy = d.fy
end

local function make_stars()
	for i = 1, STARS do
		D {"star"..tostring(i), 'img', star_spr, dist = rnd(8) + 8, process = stars, x = rnd(theme.scr.w()), y = rnd(theme.scr.h()), speed = rnd(5), z = 2 }
	end
end

declare 'fadein_proc' (function(v)
	if v.to > 0 then
		v.to = v.to - 1
		return
	end
	v.alpha = v.alpha + 2
	if v.alpha > 255 then v.alpha = 255 end
end)

function stars_theme()
	D()
	timer:set(60)
	local d = D { 'space', 'img', 'gfx/space.jpg', background = true, process = space_bg, x = 0, y = 0, z = 3 }
	d.realw = d.w
	d.realh = d.h
	get_offsets(d)
	make_stars()
end

room {
	nam = 'пробуждение';
	title = false;
	ini = function(s)
		local d = D 'space'
		if not d then
			return
		end
		get_offsets(d)
		if not d.hidden then
			make_stars()
		end
	end;
	onclick = function(s)
		if not D'wakeup' or not D'wakeup'.finished then
			return
		end
		stars_theme()
		fading.set {"fadeblack", max = FADE_LONG }
		walk 'гибернация'
	end;
	onkey = function(s)
		return s:onclick()
	end;
	timer = function(s)
		if not D'wakeup' then
			local text = [[[b]Алиса:[/b] Пробуждение... Пробуждение... Пробуждение... [pause] [pause] [pause]
Бортовое время 25 февраля 2266 года. 08:00. Вахта 7117.
Все системы функционируют в штатном режиме.
С пробуждением!]];
			D {"wakeup", "txt", text, xc = true, yc = true, x = theme.scr.w()/2, y = theme.scr.h()/2, align = 'center', typewriter = true, z = 1 }
		end
	end;
	enter = function()
		D { 'title', 'img', 'gfx/title.png', xc = true, x = theme.scr.w()/2, y = 16, alpha = 0, process = fadein_proc, to = 100 }
		local text = 'Игра Петра Косых\nНа движке [b]INSTEAD[/b]\nАпрель 2018'
		D { 'about', 'txt', text, xc = true, x = theme.scr.w()/2, color = 'gray', align = 'center', process = fadein_proc, alpha = 0, to = 100 }
		D 'about'.y = theme.scr.h() - D'about'.h
		timer:set(20)
	end;
}
