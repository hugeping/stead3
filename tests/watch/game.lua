function me_act()
	p [[Меня зовут Андрей Летов. Я бортинженер звездолета "Пилигрим".]]
end
me_use = me_act
dict.add('я', me_act, me_use)
dict.add('криоотсек', [[Модуль гибернации представляет из себя кольцо, которое состоит из четырех отсеков. Искусственная гравитация обеспечивается вращением модуля.
На время разгона и торможения "Пилигрима" полом служат боковые поверхности кольца. Сейчас же звездолет идет на крейсерской скорости.]])
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
	local x, y =  mt.x - mt.w / 2 - 15, mt.y
	if here().title == 'Модуль гибернации' then
		y = y - 24
	end
	D { 'mark-top', 'img', mark_spr, yc = true, x = x, y = y }
	local mf = D 'map-front'
	x, y = mf.x, mf.y
	if here().subtitle == 'Отсек 1' then
		y = y + mf.h / 2 - 8
	elseif here().subtitle == 'Отсек 2' then
		x = x + mf.w / 2 - 10
	elseif here().subtitle == 'Отсек 3' then
		y = y - mf.h / 2 + 10
	elseif here().subtitle == 'Отсек 4' then
		x = x - mf.w / 2 + 10
	end
	D { 'mark-front', 'img', mark2_spr, yc = true, xc = true, x = x, y = y }
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
		path { '#встать', 'Встать', 'Отсек 1' }:disable();
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
-- Летят на: Глизе 667 Cc: https://ru.wikipedia.org/wiki/%D0%A1%D0%BF%D0%B8%D1%81%D0%BE%D0%BA_%D0%B1%D0%BB%D0%B8%D0%B6%D0%B0%D0%B9%D1%88%D0%B8%D1%85_%D1%8D%D0%BA%D0%B7%D0%BE%D0%BF%D0%BB%D0%B0%D0%BD%D0%B5%D1%82_%D0%B7%D0%B5%D0%BC%D0%BD%D0%BE%D0%B3%D0%BE_%D1%82%D0%B8%D0%BF%D0%B0
-- Летят на термоядерном двигателе 0.3c
-- Реакция дейтерий + гелий-3 https://ru.wikipedia.org/wiki/%D0%A2%D0%B5%D1%80%D0%BC%D0%BE%D1%8F%D0%B4%D0%B5%D1%80%D0%BD%D1%8B%D0%B9_%D1%80%D0%B0%D0%BA%D0%B5%D1%82%D0%BD%D1%8B%D0%B9_%D0%B4%D0%B2%D0%B8%D0%B3%D0%B0%D1%82%D0%B5%D0%BB%D1%8C
-- с использованием малых количеств антиматерии
-- причина колонизации: обнаружение пригодной планеты зондами,
-- нестабильность солнца
-- Проект поддерживается "
-- Летят в составе конвоя по колонизации. Каждые 10 лет с земли запускается корабль,
-- 1-й корабль был "Пионер 2217" (группа высадки, 20 человек)
-- "Пилигрим" - 2й корабль (о нем и история) (механизмы, эмбрионы животных, 20 человек)
-- За ними должен лететь 3-й уже с людьми (20 человек + 150 человек): "Ковчег".
-- 75 лет по земным часам
-- 70 по часам корабля
-- экипаж 20 человек - специалисты, по суюъективному времени - 3.5 года
-- Вахты по 48 часоа, потом 40 дней сон.
-- время событий: 39 год полета по часам корабля: 7117 вахта (всего 12775 вахт, на одного человека приходится 640 вахт)

-- причина -- нестабильность солнца, начало исследований межзвездного пространства

-- два отсека с гравитацией. В них 3 пола \_/ -- так как разгон и торможение идут с 1g
-- отсек 2 (гибернации):
-- сектор 1: 7 капсул (и гг),
-- сектор 2: 7 капсул
-- сектор 3: 6 капсул, душ
-- сектор 4: эмбрионы животных
-- отсек 1 (жилой)
-- сектор 1: кубрик (можно спать, читать итд)
-- сектор 2: столовая
-- сектор 3: инженерный отсек
-- сектор 4: туалет, аптечка
-- 0 отсек -- труба, из которой выходим
-- капитанский мостик (нет гравитации)
-- шлюз, где есть шатл, скафандры.
-- трюмы.
-- 3 силовой отсек (двигатель)

local function pager(s, txt)
	if not s.__page then s.__page = 0 end
	s.__page = s.__page + 1
	if s.__page > #txt then s.__page = 1 end
	p(txt[s.__page])
end

obj {
	nam = 'капсулы';
	act = function(s)
		if here().subtitle == 'Отсек 1' then
			pn [[В этом отсеке установлено 7 гибернетических капсул.]]
		elseif here().subtitle == 'Отсек 2' then
			pn [[В этом отсеке установлено 7 гибернетических капсул.]]
		elseif here().subtitle == 'Отсек 3' then
			pn [[В этом отсеке установлено 6 гибернетических капсул.]]
		end
		local txt = {
			[[Капсулы устроены таким образом, чтобы при разгоне и торможении "Пилигрима" могли менять свое положение.]],
			[[ В капсулах экипаж проводит основное время полета, за исключением часов вахты.
			Человек не может непрерывно находиться в состоянии гибернации больше двух месяцев.]],
			[[Во время гибернации каждый из членов экипажа видит сон. Сон, длящийся 40 дней корабельного времени.
Но для каждого из нас он длится одну "ночь" между вахтами.]],
		[[Сны нам показывает Алиса -- наш бортовой ИИ. В ее банках памяти находятся мысле-записи наших воспоминаний.]] }
		pager(s, txt)
	end;
};
obj {
	nam = 'одежда';
	inv = function(s)
		p [[В комплект одежды входит серый комбинезон и магнитные ботинки. Без них крайне затруднительно
перемещаться в отсеках с нулевой гравитацией.]]
		p [[Сейчас мне нет смысла одеваться, сначала нужно принять душ. Он находится в 3-м отсеке.]]
	end;
}

local function taken(w)
	return actions(w, 'take') > 0
end

obj {
	nam = 'панели';
	act = function(s)
		if here().subtitle == 'Отсек 1' then
			if not taken 'одежда' then
				pn [[В панелях расположены шкафчики с вещами экипажа. Я забрал свой комплект одежды.]]
				take 'одежда'
			else
				p [[Больше ничего интересного в шкафчиках я не обнаружил.]]
			end
		else
			if seen '#контейнеры' then
				return [[Оборудование и медикаменты.]]
			end
			p [[Я не стал копаться в вещах спящего экипажа.]]
		end
	end;
};

room {
	nam = 'Отсек 0';
	title = "Модуль гибернации";
	subtitle = 'Отсек 0';
	way = { path {'В отсек 1', 'Отсек 1'}, path{'2', 'Отсек 2'},path {'3', 'Отсек 3'}, path {'4', 'Отсек 4'} };
	onenter = function(s, w)
		if not shower then
			p [[Сначала нужно принять душ.]]
			return false
		end
		if w ^ 'Отсек 1' or w ^ 'Отсек 2' or w ^ 'Отсек 3' or w ^ 'Отсек 4' then
			p [[Я поднялся по лестнице в нулевой отсек.]]
		end
	end;
	onexit = function(s, w)
		if w ^ 'Отсек 1' or w ^ 'Отсек 2' or w ^ 'Отсек 3' or w ^ 'Отсек 4' then
			p [[Я спустился по лестнице в отсек.]]
		end
	end;
}
local CW = fmt.img 'gfx/cw.png'
local CCW = fmt.img 'gfx/ccw.png'
local UP = fmt.img 'gfx/up.png'
local DOWN = fmt.img 'gfx/down.png'

room {
	nam = 'Отсек 1';
	title = 'Модуль гибернации';
	subtitle = 'Отсек 1';
	decor = [[{$d криоотсек|По всей площади отсека} {капсулы|установлены капсулы.} {#капсула|Одна из капсул открыта}. {$d стена|Вдоль стен} {панели|расположены панели.}]];
	way = { path {CW, 'Отсек 4'}, path{UP, 'Отсек 0'},path {CCW, 'Отсек 2'} };
	onexit = function(s)
		if not taken 'одежда' then
			p [[Мне нужно забрать свою одежду.]]
			return false
		end
	end;
} : with
{
	obj {
		nam = '#капсула';
		act = function(s)
			p [[Это моя капсула.]];
			p [[Вахта длится 48 часов. Еще не время уходить в гибернацию.^Каждый член экипажа
несет свою вахту 48 часов. Затем находится в состоянии гибернации около 40 дней. Таким образом, субъективное
время полета составляет всего три с половиной года. На Земле за это время пройдет 75 лет...]]
		end;
	};
	'капсулы', 'панели',
}

room {
	nam = 'Отсек 2';
	title = 'Модуль гибернации';
	subtitle = 'Отсек 2';
	decor = [[{$d криоотсек|По всей площади отсека} {капсулы|установлены капсулы.} {$d стена|Вдоль стен} {панели|расположены панели.}]];
	way = { path {CW, 'Отсек 1'}, path{UP, 'Отсек 0'}, path {CCW, 'Отсек 3'} };
} : with
{
	'капсулы', 'панели',
}

global 'shower' (false)
room {
	nam = 'Отсек 3';
	title = 'Модуль гибернации';
	subtitle = 'Отсек 3';
	decor = [[{$d криоотсек|По всей площади отсека} {капсулы|установлены капсулы.} {$d стена|Вдоль стен} {панели|расположены панели.} {$d криоотсек|В этом отсеке} {#душ|находится душевая.}]];
	way = { path {CW, 'Отсек 2'}, path{UP, 'Отсек 0'}, path {CCW, 'Отсек 4'} };
} : with
{
	obj {
		nam = '#душ';
		act = function(s)
			if not shower then
				shower = true
				pn [[Не без удовольствия я принял прохладный душ и переоделся.]]
				remove 'одежда'
				pn [[Теперь можно приступить к осмотру.]]
			else
				p [[Хорошо, что душевая находится в модуле с искусственной гравитацией.]]
			end
		end;
	},
	'капсулы', 'панели',
}

room {
	nam = 'Отсек 4';
	title = 'Модуль гибернации';
	subtitle = 'Отсек 4';
	decor = [[{$d криоотсек|В этом отсеке} {#контейнеры|находятся крио-контейнеры.} {$d стена|Вдоль стен} {панели|расположены панели.}]];
	way = { path {CW, 'Отсек 3'}, path{UP, 'Отсек 0'}, path {CCW, 'Отсек 1'} };
} : with
{
	obj {
		nam = '#контейнеры';
		act = function(s)
			p [[12 ослепительно белых квадратных контейнеров с эмбрионами домашних животных.]]
			pn [["Пилигрм" -- второй звездолет в конвое, который был отправлен на Глизе 667 Cc. Мы везем
оборудование и эмбрионы животных.]];
			pn [[Надеюсь, в контейнерах есть эмбрионы кошек.]];
		end;
	},
	'панели',
}