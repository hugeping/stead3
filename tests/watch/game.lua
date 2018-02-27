function me_act()
	p [[Меня зовут Андрей Летов. Я бортинженер звездолета "Пилигрим".]]
end
me_use = me_act
dict.add('я', me_act, me_use)
dict.add('криоотсек', [[Криоотсек занимает всю нижнюю палубу звездолета.]])
dict.add('стена', [[Стена защищает нас от безмолвного космоса.]])

function game:onact(w)
	local r, v = std.call(here(), 'onact', w)
	if v == false then
		return r, v
	end
end
declare 'mark_spr' (function()
	local w, h = 12, 12
	local p = pixels.new(w, h)
	p:polyAA({0, 0, w - 1, h / 2 - 1, 0, h - 1}, color2rgb 'red')
	return p:sprite()
end)
declare 'mark2_spr' (function()
	local w, h = 12, 12
	local p = pixels.new(w, h)
	p:polyAA({0, 0, w / 2 - 2, h / 2 - 1, 0, h - 1}, color2rgb 'red')
	p:polyAA({w / 2, h / 2 - 1, w - 1, 0, w - 1, h - 1}, color2rgb 'red')
	return p:sprite()
end)

function markers()
	local mt = D 'map-top'
	if not mt then D { 'mark-top'}; D {'mark-front'}; return; end
	D { 'mark-top', 'img', mark_spr, yc = true, x = mt.x - mt.w / 2 - 15, y = mt.y }
	local mf = D 'map-front'
	D { 'mark-front', 'img', mark2_spr, yc = true, xc = true, x = mf.x, y = mf.y }
end

function game:afterwalk()
	markers()
end

room {
	nam = 'гибернация';
	title = 'В капсуле';
	enter = function(s)
		p [[Долгий шипящий звук разгерметизации. Я медленно прихожу в себя...]];
		snd.play 'snd/steam.ogg'
	end;
	exit = function()
		local wx, wy = std.tonum(theme.get('win.x')), std.tonum(theme.get('win.y'))
		local ww = std.tonum(theme.get('win.w'))
		D { 'map-top', 'img', 'gfx/piligrim1.png', xc = true, yc = true, x = wx / 2, y = theme.scr.h() / 2 }
		local x = (wx + ww + theme.scr.w()) / 2
		D { 'map-front', 'img', 'gfx/piligrim2.png', xc = true, yc = true, x = x, y = theme.scr.h() / 2 }
		p [[Не без труда я выбрался из камеры. Теперь необходимо одеться.]];
	end;
	decor = [[{#холод|Холодно.} {$d я|Я лежу} {#капсула|в криокапсуле.} {#пар|Вокруг меня клубится белый пар.}]];
	way = {
		path { '#встать', 'Встать', 'Отсек гибернации' }:disable();
	};
}: with
{
	obj {
		nam = '#холод';
		act = [[Как странно, словно зимний холод из моего сна.]];
	};
	obj {
		nam = '#капсула';
		act = function()
			p [[Белая крышка капсулы открыта. Нужно приступать к вахте.]];
			enable '#встать'
		end;
	};
	obj {
		nam = '#пар';
		act = [[Клубы холодного пара напоминают вьюгу из моего сна.]];
	}
}

room {
	nam = 'Отсек гибернации';
	title = 'Отсек гибернации';
	subtitle = 'Сектор 1';
	decor = [[{$d криоотсек|По всей площади отсека} {#капсулы|установлены капсулы.} {$d стена|Вдоль стены} {#шкафы|расположены шкафы.}]];
} : with
{
	obj {
		nam = '#капсулы';
	};
	obj {
		nam = '#шкафы';
	};
}
