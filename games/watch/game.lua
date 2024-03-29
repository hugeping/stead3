require "noinv"
require "nolife"
require "prefs"

loadmod "keyboard"

prefs.snowball_launcher = false
prefs.chess_master = false
prefs.romance = false
prefs.rnd_master = false
prefs.strong = false

local render = require "render"

function me_act()
	p [[Меня зовут Сергей Летов. Я бортинженер звездолета "Пилигрим".]]
end
me_use = me_act

dec = function(nam, desc)
	return obj {nam = nam, act = desc }
end

dict.add('я', me_act, me_use)
dict.add('криоотсек', [[Модуль гибернации представляет из себя кольцо, которое состоит из четырех отсеков. Искусственная гравитация обеспечивается вращением модуля.
На время разгона и торможения "Пилигрима" полом служат боковые поверхности кольца. Сейчас же звездолет идет на крейсерской скорости.]])
dict.add('стена', [[За стенками звездолета -- молчаливый космос.]])

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

function gravity()
	if here().subtitle == 'Отсек 0' or
		here().subtitle == 'Ангар' or
		here().subtitle == 'Шлюзовой отсек' or
		here().subtitle == 'Аварийный шлюз' or
		here().subtitle == 'Центр управления' or
		here().subtitle == 'Воронье гнездо' then
		return false
	end
	return true
end

function markers()
	if here():type 'dlg' then
		return
	end
	local mt = D 'map-top'
	if not mt then
		return
	end
	if not mt then D { 'mark-top'}; D {'mark-front'}; return; end
	local x, y =  mt.x - mt.w / 2 - 15, mt.y
	if here().title == 'Модуль гибернации' then
		y = y - 24
	elseif here().title == 'Жилой модуль' then
		y = y - 51
	elseif here().title == 'Шлюз' then
		y = y + 6
		x = x + 32
	elseif here().title == 'Мостик' then
		x = x + 54
		y = y - 84
		if here().subtitle == 'Воронье гнездо' then
			y = y - 12
		end
	end
	if visited 'провал' then
		D { 'mark-front', 'img', mark_spr, yc = true, x = x, y = y }
	else
		D { 'mark-top', 'img', mark_spr, yc = true, x = x, y = y }
	end
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
	if visited 'провал' then
		D { 'mark-top', 'img', mark2_spr, yc = true, xc = true, x = x, y = y }
	else
		D { 'mark-front', 'img', mark2_spr, yc = true, xc = true, x = x, y = y }
	end
end
local last_mus = 0
function game:afterwalk()
	if not sleeped and visited 'Отсек 1' then
		if snd.music_playing() then
			last_mus = instead.ticks()
		elseif instead.ticks() - last_mus > 60 * 1000 then
			snd.music ('mus/isthatyou.ogg', 1)
		end
	end
	markers()
end

function map_theme()
	local wx, wy = std.tonum(theme.get('win.x')), std.tonum(theme.get('win.y'))
	local ww = std.tonum(theme.get('win.w'))
	if visited 'провал' then
		D { 'map-front', 'img', 'gfx/piligrim2.png', xc = true, yc = true, x = wx / 2, y = theme.scr.h() / 2 }
		local x = (wx + ww + theme.scr.w()) / 2
		D { 'map-top', 'img', 'gfx/piligrim1.png', xc = true, yc = true, x = x + 20 , y = theme.scr.h() / 2 }
	else
		D { 'map-top', 'img', 'gfx/piligrim1.png', xc = true, yc = true, x = wx / 2, y = theme.scr.h() / 2 }
		local x = (wx + ww + theme.scr.w()) / 2
		D { 'map-front', 'img', 'gfx/piligrim2.png', xc = true, yc = true, x = x, y = theme.scr.h() / 2 }
	end
end

room {
	nam = 'гибернация';
	title = 'В капсуле';
	enter = function(s)
		p [[Долгий шипящий звук разгерметизации. Я медленно прихожу в себя...]];
		snd.play 'snd/steam.ogg'
	end;
	exit = function()
		map_theme()
		p [[Не без труда я выбрался из камеры. Теперь необходимо одеться.]];
		snd.music ('mus/isthatyou.ogg', 1)
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
			p [[Белая крышка капсулы открыта.]]
			if actions("#dict-я") == 0 then
				p [[Надо собраться с мыслями... Кто я?]];
				return
			end
			p [[Нужно приступать к вахте.]];
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
-- Летят в составе конвоя по колонизации. Каждые 10 лет с земли запускается корабль,
-- 1-й корабль был "Пионер 2217" (группа высадки, 20 человек)
-- "Пилигрим" - 2й корабль (о нем и история) (механизмы, эмбрионы животных, 20 человек)
-- За ними должен лететь 3-й уже с людьми (20 человек + 150 человек): "Ковчег".
-- 75 лет по земным часам
-- 70 по часам корабля
-- экипаж 20 человек - специалисты, по субъективному времени - 3.5 года
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
-- сектор 2: кухня
-- сектор 3: инженерный отсек
-- сектор 4: туалет, аптечка
-- 0 отсек -- труба, из которой выходим
-- капитанский мостик (нет гравитации)
-- шлюз, где есть шатл, скафандры.
-- трюмы.
-- 3 силовой отсек (двигатель)

local function pager(s, txt)
	local done = false
	if not s.__page then s.__page = 0 end
	s.__page = s.__page + 1
	if s.__page > #txt then s.__page = 1; done = true; end
	p(txt[s.__page])
	return s.__page == #txt, done
end

local function pager_prev(s, txt)
	if not s.__page then s.__page = 1; p(txt[s.__page]); return true end
	s.__page = s.__page - 1
	if s.__page == 0 then
		s.__page = 1
	end
	p(txt[s.__page])
	return s.__page == 1
end

global {
	cap1 = false;
	cap2 = false;
	cap3 = false;
}

obj {
	nam = 'капсулы';
	act = function(s)
		if sleeped then
			return [[Мог бы я спасти их? Мог бы я спасти Елену? Эта мысль мучает меня снова и снова.]]
		end
		if here().subtitle == 'Отсек 1' then
			pn [[В этом отсеке установлено 7 гибернационных капсул.]]
			cap1 = true
		elseif here().subtitle == 'Отсек 2' then
			pn [[В этом отсеке установлено 7 гибернационных капсул.]]
			cap2 = true
			if disabled('елена') then
				p [[Я помню, что в одной из капсул находится Елена.]]
				enable 'елена'
				return
			end
		elseif here().subtitle == 'Отсек 3' then
			pn [[В этом отсеке установлено 6 гибернационных капсул.]]
			cap3 = true
		end
		local txt = {
			[[Капсулы устроены таким образом, чтобы при разгоне и торможении "Пилигрима" они могли менять свое положение.]],
			[[В капсулах экипаж проводит основное время полета, за исключением часов вахты.
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
	use = function(s)
		s:inv()
	end
}

local function taken(w)
	return actions(w, 'take') > 0
end

obj {
	nam = 'панели';
	act = function(s)
		if here().title == 'Модуль гибернации' then
			if sleeped then
				return [[У меня нет никакого желания исследовать личные вещи экипажа.]]
			end
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
		elseif here().title == 'Жилой модуль' then
			p [[Ничего интересного.]]
		end
	end;
};

dict.add('отсек0', [[
Нулевые отсеки связывают жилой модуль и модуль гибернации с остальными отсеками звездолета.
Внутренний диаметр нулевого отсека примерно соответствует человеческому росту, так что тут довольно тесно.
]], false)

dict.add('гравитация', [[
Только в жилом модуле и модуле гибернации за счет вращения поддерживается гравитация. В остальных отсеках
гравитации нет.]], false)

dict.add('ботинки', [[
Нужна определенная привычка, чтобы чувствовать себя в них естественно.
Ботинки очень крепко магнитятся к стенам корабля и перед тем, как оторвать подошву от поверхности, нужно
особым образом повернуть ногу... У меня уже почти получается делать это рефлекторно.]], false)

room {
	nam = 'Отсек 0';
	title = "Модуль гибернации";
	subtitle = 'Отсек 0';
	decor = [[{$d отсек0|Здесь} {$d гравитация|нет искусственной гравитации.} {$d ботинки|Звук от магнитных ботинок глухо отражается} {$d стена|от изогнутых стен.}
 {$d отсек0|Из этого отсека} {#лифт|с помощью лифта} {#шлюз|можно попасть в шлюз.}]];
	way = {  path {'В отсек 1', 'Отсек 1'}, path{'2', 'Отсек 2'},path {'3', 'Отсек 3'}, path {'4', 'Отсек 4'}, path {'В жилой модуль', 'Жилой Отсек 0'}, path { 'В шлюз', 'Шлюз'} };
	onenter = function(s, w)
		if not shower then
			p [[Сначала нужно принять душ.]]
			return false
		end
		if w ^ 'Отсек 1' or w ^ 'Отсек 2' or w ^ 'Отсек 3' or w ^ 'Отсек 4' then
			p [[Я поднялся по лестнице в нулевой отсек.]]
		end
	end;
	enter = function(s, f)
		if f ^ 'Шлюз' then
			action ([[Я вошел в шлюзовой лифт. Двери с шипением закрылись. Лифт перенес меня в 0-отсек.]], true)
			return
		end
	end;
	onexit = function(s, w)
		if w ^ 'Отсек 1' or w ^ 'Отсек 2' or w ^ 'Отсек 3' or w ^ 'Отсек 4' then
			p [[Я спустился по лестнице в отсек.]]
		end
	end;
}: with {
	dec('#лифт',[[Звездолет состоит из двух частей. Носовая часть может находиться во вращении, создавая гравитацию в кольцевых модулях.
Хвостовая часть не вращается. В ней находятся двигатель и шлюзовой модуль. Попасть в шлюзовой модуль можно через шлюзовую шахту с помощью лифта.]]);
	dec('#шлюз', [[В шлюзовом модуле расположен ангар.]]);
}

local CW = fmt.img 'gfx/cw.png'
local CCW = fmt.img 'gfx/ccw.png'
local UP = fmt.img 'gfx/up.png'
local DOWN = fmt.img 'gfx/down.png'

obj {
	nam = 'монета';
	know = false;
	num = 0;
	inv = function(s)
		if skaf then
			p [[Сначала лучше снять скафандр.]]
			return
		end
		if not gravity() then
			p [[Я раскрутил монетку в невесомости и поймал ее.]]
		else
			p [[Я подбросил монетку.]]
		end
		if sleeped then
			p [[Решка.]]
			s.num = s.num + 1
			if s.num > 15 then
				p [[Ничего не понимаю.]]
			elseif s.num > 10 then
				p [[С точки зрения теории вероятностей, любая последовательность выпаданий монеты имеет такую же вероятность, как
и любая другая. Но как же это странно...]]
				prefs.rnd_master = true
			elseif s.num > 5 then
				p [[Снова решка. Как это возможно?]]
			end
			return
		end
		if rnd(2) == 1 then
			p [[Орел.]]
		else
			p [[Решка.]]
		end
	end;
	use = function(s, w)
		if not sleeped and w ^ 'елена' then
			p [[Я подумал, что возвращать подарок Елене в этой же вахте не стоит.]]
			return
		end
		p [[Каким образом здесь может помочь древняя монета?]];
	end;
}
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
			if emails == 0 and not taken('монета') then
				pn [[Я нагнулся и обнаружил под своей капсулой маленький круглый кусочек металла.]]
				p [[Похоже, это монетка -- древняя мелкая денежная единица.]]
				p [[Интересно, откуда она у Елены?]]
				take 'монета'
				return
			end
			p [[Это моя капсула.]];
			if sleeped then
				return [[Вход в криосон возможен и без Алисы. Правда, в таком случае проснуться уже не удастся.
Вероятно, мне придется сделать это. По крайней мере, когда кончатся запасы воздуха и еды.]]
			end
			if watch_status() then
				if not sleeped then
					p [[Пока не вышли 48 часов вахты, я могу подремать на кушетке в жилом модуле.]]
					return
				else
					p [[Что происходит?]]
					return
				end
			end
			p [[Вахта длится 48 часов. Еще не время уходить в гибернацию.^Каждый член экипажа
несет свою вахту 48 часов. Затем находится в состоянии гибернации около 40 дней. Таким образом, субъективное
время полета составляет всего 3,5 года. На Земле за это время пройдет 75 лет...]]
		end;
	};
	'капсулы', 'панели',
}

dict.add('елена', function(s)
	if sleeped then
		 p [[Мне больно думать о том, что теперь никогда не произойдет.]]
		 return
	 end
	 p [[Елена Светлова -- биолог "Пилигрима". Экипаж "Пилигрима" смешанный, многие члены экипажа составляют пару.
Мы не успели пожениться на Земле, но если... когда мы долетим до цели, мы сделаем это.]]
end)

global { elena_death = false };

room {
	nam = 'Отсек 2';
	title = 'Модуль гибернации';
	subtitle = 'Отсек 2';
	decor = [[{$d криоотсек|По всей площади отсека} {капсулы|установлены капсулы.} {$d стена|Вдоль стен} {панели|расположены панели.}]];
	way = { path {CW, 'Отсек 1'}, path{UP, 'Отсек 0'}, path {CCW, 'Отсек 3'} };
} : with
{
	'капсулы', 'панели',
	obj {
		nam = 'елена';
		dsc = function(s)
			if sleeped then
				p [[{В одной из капсул находится Елена}.]];
			else
				p [[{В одной из капсул находится} {$d елена|Елена}.]];
			end
		end;
		act = function(s)
			if sleeped then
				if not cap2d then
					p [[Я бросился к капсуле Елены. Показатели жизнедеятельности нулевые....]]
					elena_death = true
				end
				p [[Не может быть. Этого не может быть...]]
				return
			end
			p [[Я подошел к капсуле и некоторое время смотрел на родные черты лица сквозь небольшое окошко.]];
		end;
	}:disable();
}

dlg.ph_onact = function(s, w)
	if w.noshow then
		return
	end
	if here().noshow then
		return
	end
	local r, v = std.call(w, 'dsc')
	if type(r) == 'string' then
		return '-- '..r
	end
	return r, v
end;

function  watch_status()
	if not cap1 or not cap2 or not cap3 then
		return false
	end
	if not send1 or not send2 or not send3 then
		return false
	end
	if not visited 'reading' then
		return false
	end
	if not cont_chk then
		return false
	end
	if not visited('Жилой Отсек 1') then
		return false
	end
	if not visited('Жилой Отсек 2') then
		return false
	end
	if not visited('Жилой Отсек 3') then
		return false
	end
	if not visited('Жилой Отсек 4') then
		return false
	end
	if not visited('Шлюз') then
		return false
	end
	if not visited('шлюзотсек') then
		return false
	end
	if not visited('Мостик') then
		return false
	end
	if not visited 'Воронье гнездо' then
		return false
	end
	return true
end

dlg {
	nam = 'alice1';
	title = [[Алиса]];
	noinv = true;
	noshow = true;
	phr = {
		{ always = true, "Узнать статус вахты.",
		  function()
			  if watch_status() then
				  p [[-- Отличная служба, бортинженер! Теперь, остаток вахты вы можете отдохнуть в жилом модуле.]]
				  return
			  end
			  p "Капсулы:"
			  if cap1 and cap2 and cap3 then
				  pn "проверены."
			  else
				  local n = 1
				  if cap1 then n = n + 6 end
				  if cap2 then n = n + 7 end
				  if cap3 then n = n + 6 end
				  pn ("осмотрено ", n, " из 20")
			  end
			  p "Крио-контейнеры:"
			  if cont_chk then
				  pn "проверены."
			  else
				  pn "не проверены."
			  end
			  p "Жилые отсеки."
			  local f = true
			  if not visited('Жилой Отсек 1') then
				  p "Отсек 1: не проверен."
				  f = false
			  end
			  if not visited('Жилой Отсек 2') then
				  p "Отсек 2: не проверен."
				  f = false
			  end
			  if not visited('Жилой Отсек 3') then
				  p "Отсек 3: не проверен."
				  f = false
			  end
			  if not visited('Жилой Отсек 4') then
				  p "Отсек 4: не проверен."
				  f = false
			  end
			  if f then
				  pn "проверены."
			  else
				  pn()
			  end
			  if visited('Шлюз') then
				  if not visited('шлюзотсек') then
					  pn ("Ангар: не проверен шлюз.")
				  else
					  pn ("Ангар: проверен.")
				  end
			  else
				  pn ("Ангар: не проверен.")
			  end
			  if visited('Мостик') then
				  if not visited 'Воронье гнездо' then
					  pn ("Мостик: не проверен.")
				  else
					  pn ("Мостик: проверен.")
				  end
			  else
				  pn ("Мостик: не проверен.")
			  end
			  p ("Видеосообщения:")
			  if not visited 'reading' then
				  p "не просмотрены, "
			  else
				  p "просмотрены, "
			  end
			  if not send1 or not send2 or not send3 then
				  p ("ответы не отправлены.")
			  else
				  p ("ответы отправлены.")
			  end
		  end
		},
		{ always = true, "Запросить статус", [[-- Все системы функционируют в штатном режиме.]] },
		{ always = true, "Закончить разговор", function() walkback() end },
	}
}: with {
}

obj {
	nam = 'браслет';
	inv = function(s)
		if sleeped then
			p [[Алиса не отвечает.]]
			return
		end
		p [[Этот браслет следит за пульсом, а также позволяет Алисе слышать меня из любого уголка звездолета. Алиса -- наш бортовой компьютер. У него, вернее у нее, очень приятный голос.]];
		walkin 'alice1'
	end;
}

obj {
	nam = 'браслет программиста';
	inv = function(s)
		p [[Теперь я могу подключиться к отладочному порту.]]
	end;
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
				p [[На запястье я надел свой браслет, который лежал в нагрудном кармане комбинезона.]]
				remove 'одежда'
				take 'браслет'
				pn [[Теперь можно поесть. Кухня находится в жилом модуле.]]
			else
				if sleeped then
					p [[Надо экономить воду. Хотя, зачем?]]
					return
				end
				p [[Хорошо, что душевая находится в модуле с искусственной гравитацией.]]
			end
		end;
	},
	'капсулы', 'панели',
}

global 'cont_chk' (false)

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
			cont_chk = true
			p [[12 ослепительно белых квадратных контейнеров с эмбрионами домашних животных.]]
			pn [["Пилигрим" -- второй звездолет в конвое, который был отправлен на Глизе 667 Cc. Мы везем
оборудование и эмбрионы животных.]];
			if sleeped then
				p [[Возможно, эмбрионы в порядке.]]
				return
			end
			pn [[Надеюсь, в контейнерах есть эмбрионы кошек.]];
		end;
	},
	'панели',
}

room {
	nam = 'Жилой Отсек 0';
	title = "Жилой модуль";
	subtitle = 'Отсек 0';
	decor = [[{$d отсек0|Здесь} {$d гравитация|нет искусственной гравитации.} {$d ботинки|Звук от магнитных ботинок глухо отражается} {$d стена|от изогнутых стен.}]];
	way = {  path {'В отсек 1', 'Жилой Отсек 1'}, path{'2', 'Жилой Отсек 2'},path {'3', 'Жилой Отсек 3'}, path {'4', 'Жилой Отсек 4'},
		path { 'На мостик', 'Мостик'}, path { 'В модуль гибернации', 'Отсек 0'}  };
	onenter = function(s, w)
		if w ^ 'Жилой Отсек 1' or w ^ 'Жилой Отсек 2' or w ^ 'Жилой Отсек 3' or w ^ 'Жилой Отсек 4' then
			p [[Я поднялся по лестнице в нулевой отсек.]]
		end
	end;
	onexit = function(s, w)
		if w ^ 'Жилой Отсек 1' or w ^ 'Жилой Отсек 2' or w ^ 'Жилой Отсек 3' or w ^ 'Жилой Отсек 4' then
			p [[Я спустился по лестнице в отсек.]]
		end
	end;
}

dict.add('жилойотсек', [[Жилой модуль -- это второй модуль "Пилигрима", в котором поддерживается искусственная гравитация.
Четыре отсека позволяют с относительным комфортом провести свободные часы вахты. И не сойти с ума от одиночества.
Так же как и в модуле гибернации, на стадии разгона и торможения боковые стены отсеков становятся полом.]])

global 'breakfast' (false)
dict.add('кубрик', [[Кубрик -- отсек жилого модуля, предназначенный для отдыха экипажа. Свободное пространство
на звездолете -- это роскошь, но кубрик дает возможность проводить вахты с относительным комфортом. А успех миссии напрямую
зависит от психологического здоровья экипажа.]]);

obj {
	nam = 'шахматы';
	dsc = [[{#стол|На столе} {$d я|я} {вижу шахматную доску.}]];
	act = function(s)
		if chess_puzzle_solved then
			if sleeped then
				p [[Никогда не любил шахматы.]]
				return
			end
			p [[Я никогда не любил шахматы. Все-таки хорошо, что я не подвел команду белых.]]
		else
			if sleeped then
				p [[Завершить партию?]]
			else
				p [[Весь экипаж разделен на две команды: белые и черные. Каждый из нас во время вахты делает один ход.
Это еще один способ избежать одиночества. Я играю за белых.]];
			end
			enable 'партия'
		end
	end;
	obj = {
		obj {
			nam = 'партия';
			dsc = [[{Сейчас мой ход.}]];
			act = function(s)
				walkin 'игра-шахматы'
			end;
		}:disable();
	}
}:disable();

global 'sleeped' (false)

room {
	nam = 'Жилой Отсек 1';
	title = 'Жилой модуль';
	subtitle = 'Отсек 1';
	decor = [[{$d жилойотсек|Этот отсек} {$d кубрик|служит кубриком.} {$d кубрик|Здесь} {#кровати|установлены удобные кушетки.}
{$d кубрик|Прямо посредине отсека} {#стол|находится продолговатый стол,} {#кресла|вокруг} {#стол|которого} {#кресла|стоят четыре кресла.}]];
	way = { path {CW, 'Жилой Отсек 4'}, path{UP, 'Жилой Отсек 0'},path {CCW, 'Жилой Отсек 2'} };
}: with {
	obj {
		nam = '#кровати';
		act = function(s)
			if maneur and ship_heading ~= 0 then
				fading.set {"fadeblack", max = FADE_LONG }
				walk 'переход'
				return
			end
			pn [[Кушетки индивидуально подстраиваются под анатомические особенности человека. На них можно удобно поспать несколько часов.
Обычным сном, не входя в анабиоз. А можно просто полежать, погрузившись в свои мысли.]];
			if disabled '#журнал' then
				p [[На одной из кушеток я заметил журнал экипажа.]]
				enable '#журнал'
				return
			end
			if not watch_status() then
				p [[Пока я не закончил вахту, не стоит валяться на кушетке.]]
				return
			end
			if not sleeped then
				sleeped = true
				std.pclr()
				snd.stop_music()
				walkin 'Двор-enter'
				return
			end
			p [[Но мне не хочется мыслей. Я гоню их прочь.]]
		end;
	};
	obj {
		nam = '#стол';
		act = function(s)
			p [[Стол может быть легко убран и тогда отсек превращается в спорт-зал.]]
			p [[Сейчас же на столе стоит шахматная доска.]]
			enable 'шахматы'
		end;
		obj = { 'шахматы' };
	};
	obj {
		nam = '#кресла';
		act = function(s)
			if sleeped then
				p [[Что я должен думать, глядя на эти кресла?]]
				return
			end
			p [[Кубрик рассчитан на одновременное нахождение в нем до четырех членов экипажа.
Правда, пока мы движемся на крейсерской скорости, вахту несет только один член экипажа. В данный момент -- это я.]]
		end;
	};
	obj {
		nam = '#журнал';
		dsc = [[{#кровати|На кушетке} {лежит журнал.}]];
		act = function(s)
			p [[Журнал из обычной бумаги -- еще один способ поддерживать связь. Связь между людьми из разных вахт.]]
			if not sleeped then
				p [[Здесь есть что угодно: стихи, мысли, анекдоты, наброски. Все, что составляет обычное человеческое общение, которого так не хватает.]]
			else
				p [[А теперь, это связь между людьми разделенными смертью.]]
			end
			enable '#записи';
--			walkin 'журнал'
		end;
		obj = {
			obj {
				nam = '#записи';
				dsc = [[{$d я|Я} {могу прочитать новые записи.}]];
				act = function(s)
					walkin 'журнал'
				end
			}:disable();
		}
	}:disable();
}

global 'need_email' (false)

room {
	nam = 'Жилой Отсек 2';
	title = 'Жилой модуль';
	subtitle = 'Отсек 2';
	eat = false;
	decor = [[{$d жилойотсек|Основное пространство отсека} {#кухня|занимает кухня.} {#кафе|В другом конце} {#кресла|установлены кресла},
{#столик|столик} и {#панель|инфо-панель.}]];
	way = { path {CW, 'Жилой Отсек 1'}, path{UP, 'Жилой Отсек 0'},path {CCW, 'Жилой Отсек 3'} };
	onexit = function(s)
		if have 'поднос' then
			p [[Поднос со своим завтраком я оставил на кухне.]]
			place ('поднос', '#кухня')
			return
		end
		if seen 'поднос' and where('поднос') ^ '#столик' then
			if _'поднос'.eaten then
				p [[Сначала нужно отнести грязный поднос.]]
			else
				p [[Хорошо бы сначала поесть. А то кофе остынет.]]
			end
			return false
		end
	end;
	enter = function(s)
		if not breakfast and not sleeped then
			pn [[Как только я зашел в отсек, раздался мягкий голос Алисы -- нашего бортового компьютера.]]
			pn [[-- С добрым утром и приятной вахты! Я приготовила кофе и яичницу!]]
			pn [[-- Спасибо, Алиса!]]
		end
	end;
}: with {
	obj {
		nam = '#кафе';
		act = [[Эта часть отсека служит своеобразным "кафе". Правда, мне в этом кафе так же одиноко, как и в любом другом отсеке...]];
	};
	obj {
		nam = '#кухня';
		act = function(s)
			p [[Кухня синтезирует пищу, которую мы едим. Чтобы не испортить аппетит, я стараюсь не думать о том, как это происходит.]];
			p [[Пища появляется из панели выдачи на специальном подносе. Использованные подносы отправляются в принимающую панель.]]
		end;
	}: with {
		obj {
			nam = 'поднос';
			eaten = false;
			dsc = function(s)
				if where(s) ^ '#кухня' then
					p [[{#кухня|Возле панели выдачи стоит} {поднос с моим завтраком.}]];
				else
					if s.eaten then
						p [[{#столик|На столике стоит} {поднос.}]];
					else
						p [[{#столик|На столике стоит} {поднос с моим завтраком.}]];
					end
				end
			end;
			use = function(s, w)
				if w ^ '#столик' then
					p [[Я поставил поднос на столик.]]
					place (s, w)
				elseif w ^ '#кухня' then
					p [[Я поставил поднос обратно.]]
					place (s, w)
				else
					p [[Лучше просто съесть свой завтрак.]]
				end
			end;
			act = function(s)
				if s.eaten then
					p [[Я поднялся из-за стола и отнес поднос к принимающей панели. Поднос исчез в недрах кухни.]]
					remove(s)
					return
				end
				s.eaten = true
				breakfast = true
				walkin 'reading'
			end;
			tak = function(s)
				if where(s) ^ '#кухня' then
					p [[Я забрал поднос с кофе и яичницей. Интересно, из чего сделаны яйца?]];
					return
				end
				return false
			end;
			inv = [[Кофе совсем как настоящий! По крайней мере, такой же горячий.]];
		};
	};
	obj {
		nam = '#кресла';
		act = function(s)
			if have 'поднос' then
				p [[Я могу разлить кофе. Сначала надо поставить поднос на столик.]]
				return
			end
			p [[Два компактных пластиковых кресла. Это весь комфорт, на который приходится рассчитывать.]]
		end;
	};
	obj {
		nam = '#панель';
		act = function(s)
			p [[Сейчас панель выключена.]]
		end;
	};
	obj {
		nam = '#столик';
		act = function(s)
			p [[Круглый столик из пластика.]];
		end;
	};
}

room {
	nam = 'Жилой Отсек 3';
	title = 'Жилой модуль';
	subtitle = 'Отсек 3';
	decor = [[{$d я|Я} {#инжотсек|нахожусь в инженерном отсеке.} {$d стена|Вдоль стен} {#места|установлены рабочие места.}]];
	way = { path {CW, 'Жилой Отсек 2'}, path{UP, 'Жилой Отсек 0'},path {CCW, 'Жилой Отсек 4'} };
}: with {
	dec ('#инжотсек', [[В этом отсеке жилого модуля находятся рабочие места экипажа.]]);
	dec ('#места', function(s) p [[Рабочие места экипажа и оборудование. Я также вижу консоль.]]; enable '#консоль'; end);
	obj {
		nam = '#консоль';
		dsc = [[{#инжотсек|Здесь} {есть консоль.}]];
		act = function(s)
			walkin 'консоль'
		end;
	}:disable();
}

room {
	nam = 'Жилой Отсек 4';
	title = 'Жилой модуль';
	subtitle = 'Отсек 4';
	decor = [[{#санотсек|Это медицинский отсек. Здесь} {#туалет|установлен туалет.}]];
	way = { path {CW, 'Жилой Отсек 3'}, path{UP, 'Жилой Отсек 0'},path {CCW, 'Жилой Отсек 1'} };
}: with {
	dec ('#санотсек', [[Несмотря на свое название, отсек скорее играет роль биологической лаборатории. Кроме того, здесь есть туалет.]]);
	obj {
		nam = '#туалет';
		time = 0;
		act = function(s)
			if game:time() - s.time > 10 then
				p [[Я воспользовался туалетом. Какое все-таки счастье, что в жилом модуле есть гравитация!]];
				s.time = game:time()
			else
				p [[Нет необходимости пользоваться туалетом так часто.]]
			end
		end;
	};
}

room {
	nam = 'reading';
	title = [[Жилой модуль]];
	subtitle = [[Отсек 2]];
	decor = function()
		p [[{$d я|Я} {#удовольствие|не без удовольствия} {#еда|принялся за еду.}]]
		p [[{#напротив|Прямо напротив} {$d я|меня} {#панель|находится инфопанель.}]];
	end;
	enter = function()
		pn [[-- Личная корреспонденция с Земли за 10 апреля 2254 года. -- раздался успокаивающий голос Алисы.]]
		p [[12 лет сигнал с Земли добирался сюда. Но для меня время замкнулось. Время отправки сообщения с Земли стало "здесь и сейчас" на "Пилигриме". Иначе просто можно сойти с ума.]]
	end;
}: with
{
	dec ('#напротив', [[Инфопанель специально установлена напротив столика.]]);
	dec ('#удовольствие', [[После выхода из гибернации никто не жалуется на отсутствие аппетита.]]);
	dec ('#еда', [[Кофе меня взбодрит.]]);
	obj {
		nam = '#панель';
		act = function(s)
			local txt = {
				[[Экран загорелся голубым светом. Через пару секунд на нем появилось изображение женского лица.]],
				[[-- Сынок, здравствуй! Не беспокойся! У нас все хорошо. Главное, как ты там, один?... ]],
				[[-- Да, я помню, что твой ответ придет только... Ах, ты просил делать вид, что расстояния между нами не существует. Да ведь так все и есть!]],
				[[-- Я чувствую и знаю, что мы рядом, что ты сейчас слышишь меня. Что мы связаны не этой связью, а другой...-- я опустил голову и посмотрел на поднос. Когда я снова поднял взгляд, мама уже утерла слезы.]],
				[[-- Я получаю твои сообщения из центра звездных перелетов раз в два месяца, и очень им рада! Но не беспокойся о нас, у тебя же там совсем нет времени!]],
				[[-- Я знаю, что не увижу тебя здесь. У тебя не было выбора. Ведь ты такой умный и должен был лететь ради... Ради нашего будущего. Так что не вини себя. А что будет здесь, на Земле, никто точно не знает. Так что я рада, очень рада, что ты улетел.]],
				[[-- Ох, я опять все испортила! В общем, просто подумай о нас, а мы с папой будем всегда с тобой, что бы ни случилось!]],
				[[-- Время передачи кончается, а я опять потратила его зря. Сынок, до связи! Я буду ждать!]],
				[[Экран снова загорелся голубым светом. Я думал о том, что мама получит (уже получила 12 лет назад) сообщение, которое я записал... Я даже не помнил точно. И мне не хотелось
уточнять это у Алисы, которая деликатно молчала. Время полностью разладилось, разорвалось в клочья. Оно осталось только в нашей вере и любви. Зачем я здесь?]],
				[[-- Передача из центра звездных полетов от 11 апреля 2254 года -- спокойный голос Алисы вывел меня из задумчивости.^-- Да, спасибо, Алиса.]],
				[[-- Центр "Пилигриму". Передача 7297. -- на экране появилось лицо лысеющего сотрудника центра.]];
				[[-- Получена передача номер 683 от "Ковчега". Полет проходит в штатном режиме.]];
				[[-- Получена передача номер 3670 от "Пионера-2217". Полет проходит... в штатном режиме.]];
				[[-- Таким образом, по нашим наблюдениям, выполнение программы идет по плану.]];
				[[-- Солнечная активность... нестабильная. За последние 7 дней уровень излучения возрастал дважды.]];
				[[Служащий помолчал немного. Потом посмотрел мне прямо в глаза.^-- Удачи вам, ребята.]];
				[[И снова синий экран.^-- Передача от "Пионера-2217" от 20 февраля 2256 года.^-- Да, давай.]];
				[[-- "Пионер-2217" всем, кто слышит. Передача 6257. -- на экране худощавое лицо на фоне такого знакомого жилого отсека.]];
				[[-- Полет проходит в штатном режиме. Надеемся, что и у "Ковчега" все хорошо.]];
				[[-- Ребята немного устали, но мы справляемся. Привет "Пилигриму" и "Ковчегу". Верю, что мы вас скоро услышим. Конец связи!]];
				[[Передача закончилась. Я ковырял вилкой остатки завтрака. Нужно сходить в инженерный отсек и записать ответы. Ответы... Время
на "Пионере", время на Земле, время на "Пилигриме" и на "Ковчеге"? Какое из них настоящее? Ведь все-таки оно должно где-то быть. Настоящее.]];
				[[]];
			}
			if pager(s, txt) then
				need_email = true;
				walkback()
			end
		end;
	}
}

local chess_puzzle = {
	'k.......',
	'.R......',
	'nK......',
	'........',
	'........',
	'........',
	'........',
	'........',
}

local function chess_cell(x, y)
	if x < 1 or x > 8 or y < 1 or y > 8 then
		return
	end
	local r = chess_puzzle[y]
	if not r then return end
	local c = r:sub(x, x)
	if c == '.' then return end
	return c
end

local function clear_board()
	for y = 1, 8 do
		for x = 1, 8 do
			D { 'fig-'..std.tostr(x)..std.tostr(y) }
		end
	end
	D {'selection'}
end

local CS = 48

local function make_board(b)
	local f = {
		['q'] = 0,
		['k'] = 1,
		['r'] = 2,
		['n'] = 3,
		['b'] = 4,
		['p'] = 5,
	}
	local d = D 'chessboard'
	local boardx, boardy = d.x, d.y
	clear_board()
	for y = 1, 8 do
		local r = b[y]
		if not r then
			return
		end
		for x = 1, 8 do
			local c = r:sub(x, x)
			if c and c ~= '.' then
				local n = f[c:lower()]
				local xx, yy = (x - 1) * CS + boardx, (y - 1) * CS + boardy
				local white = not f[c]
				D { 'fig-'..std.tostr(x)..std.tostr(y), 'img', chess_spr, z = 1, x = xx, y = yy, xx = x, yy = y, white = white, fig = n }
			end
		end
	end
end

declare 'board_spr' (function()
	local w, h = CS, CS
	local spr = sprite.new(w * 8 + 24, h * 8 + 24)
	local fnt = sprite.fnt(theme.get 'win.fnt.name', 12)
	for y = 1, 8 do
		for x = 1, 8 do
			local xx, yy = x - 1, y - 1
			local color = '#fff7f2'
			if (xx + yy) % 2 == 1 then
				color = '#b38973'
			end
			spr:fill(xx * w, yy * h, w, h, color)
		end
	end
	local t = {"a", "b", "c", "d", "e", "f", "g", "h"}
	for y = 1, 8 do
		local a = fnt:text(std.tostr(9 - y), 'white', 1)
		a:copy(spr, 8 * w + 4, (y - 1)* h + (CS - 12) / 2)
		a = fnt:text(t[y], 'white', 1)
		a:copy(spr, (y - 1)* w + (CS - 12) / 2, 8 * h + 4)
	end
	return spr
end)

declare 'chess_spr' (function(v)
	local spr = sprite.new 'gfx/chess.png'
	local fx, fy = 0, 0
	if v.white then fy = CS end
	fx = v.fig * CS
	local f = sprite.new(CS, CS)
	spr:copy(fx, fy, CS, CS, f, 0, 0)
	return f
end)

declare 'selector_spr' (function(v)
	local p = pixels.new(CS, CS)
	p:poly({0, 0, CS - 1, 0, CS - 1, CS - 1, 0, CS - 1}, 32, 32, 32, 255)
	p:poly({1, 1, CS - 2, 1, CS - 2, CS - 2, 1, CS - 2}, 255, 255, 255, 255)
	p:poly({2, 2, CS - 3, 2, CS - 3, CS - 3, 2, CS - 3}, 32, 32, 32, 255)
	return p:sprite()
end)

local board_w = CS * 8
local board_h = CS * 8
global 'chess_selected' (false)
global 'chess_puzzle_solved' (false)

local function chess_onclick(s, name, press, x, y)
	local d = D 'chessboard'
	if not press then
		return
	end
	local boardx, boardy = d.x, d.y
	x = math.floor(x / CS) + 1
	y = math.floor(y / CS) + 1
	local c = chess_cell(x, y)
	if not chess_selected then
		if not c or c:find("[a-z]") then
			return false
		end
	end
	if seen '#назад' then
		return false
	end
	if not chess_selected or (c and c:find("[A-Z]")) then
		chess_selected = string.format('fig-%d%d', x, y)
		D {'selection', 'img', selector_spr, x = boardx + (x - 1) * CS, y = boardy + (y - 1) * CS, z = 0 }
	else -- make move
		local eat = false
		if c then -- eat?
			eat = c
		end
		local d = D(chess_selected)
		local c = chess_cell(d.xx, d.yy)
		local dx, dy = math.abs(x - d.xx), math.abs(y - d.yy)
		if c == 'R' and (dx ~= 0 and dy ~= 0) then
			return false
		end
		if c == 'K' and (not ((dx == 1 or dx == 0) and (dy == 1 or dy ==0)) or (x == 1 and y == 2)) then
			return false
		end
		if chess_selected == 'fig-22' and x == 4 then
			chess_puzzle_solved = true
		end
		chess_selected = false
		D {'selection' }
		d.x = (x - 1) * CS + boardx
		d.y = (y - 1) * CS + boardy
		if eat then
			D{string.format('fig-%d%d', x, y)}
		end
		enable '#назад'
	end
end

room {
	nam = 'игра-шахматы';
	title = 'Жилой модуль';
	subtitle = 'Отсек 1';
	hidetitle = true;
	hideinv = true;
	ondecor = chess_onclick;
	hint = false;
	enter = function()
		D {'chessboard', 'img', board_spr, x = (theme.scr.w() - board_w) / 2, y = tonumber(theme.get 'win.y'), z = 1, click = true }
		make_board(chess_puzzle)
		disable '#назад'
		noinv_theme()
	end;
	exit = function(s, t)
		inv_theme()
		D { 'chessboard'}
		clear_board()
		if sleeped then
			p [[Верный ход или нет... В этом уже нет никакого смысла...]]
			return
		end
		if not chess_puzzle_solved then
			if not s.hint then
				pn [[-- Позволю себе заметить, белые делают мат в два хода -- послышался голос Алисы.^
-- Хм, а я думал, что тебе запрещено давать подсказки...^
-- Ох. Прошу прощения, не выдержала.]]
				s.hint = true
			else
				pn [[Гм, я как буд-то слышу грустный вздох Алисы. Интересно, она так же подсказывает и команде черных? Алиса сказала, что белые делают мат в два хода.]]
			end
			p [[Похоже, есть смысл попробовать найти верный ход.]];
		else
			p [[-- Хочу заметить, вы сделали прекрасный ход! -- раздался голос Алисы.]]
			prefs.chess_master = true
			disable ('партия')
		end
	end;
	way = {
		path {
			'#назад',
			'Назад',
			from,
		}:disable();
	}
}

room {
	nam = 'journal-prev';
}
room {
	nam = 'журнал';
	title = 'Жилой модуль';
	hidetitle = true;
	hideinv = true;
	fading = true;
	subtitle = 'Отсек 1';
	enter = function(s)
		D {'journal', 'img', 'gfx/journal.png', x = (theme.scr.w() - 680) / 2, y = (theme.scr.h() - 540) / 2 }
		snow_theme(s)
		s.__page = 0
		disable '#листатьназад'
	end;
	onexit = function(s, t)
		if s == t then
			if pager(s, s.txt) then
				walkback()
				return
			end
			if s.__page > 1 then
				enable '#листатьназад'
			end
			return false
		elseif t ^ 'journal-prev' then
			if pager_prev(s, s.txt) then
				disable '#листатьназад'
			end
			return false
		end
	end;
	exit = function(s, t)
		D {'journal' }
		dark_theme(t)
	end;
	dsc = [[{$fmt b|{$fmt c|Журнал экипажа звездолета "ПИЛИГРИМ"}}^
{$fmt y|50%}{$fmt em|{$fmt c|"Открылась бездна, звезд полна}^
{$fmt c|Звездам числа нет, бездне дна..."}}]];
	{txt = {
[[Сегодня, пока я валялся в кубрике и пялился на звезды, мне пришла в голову странная мысль.^
Сколько бы тысяч световых лет не было между нами, я влияю на каждую звезду, которую вижу!^
Ведь если принять во внимание квантовые
взаимодействия, то я (мой глаз и сознание) действуют на звездный свет таким образом, что фотон проявляет
себя! Пока свет не попал ко мне в глаз, мозг, сознание... он существует только в состоянии
суперпозиции. А существует ли он тогда вообще? Не могу успокоиться, эта мысль меня вдохновляет! Считайте меня
конченным солипсистом, но в этом что-то есть!^

{$fmt r|Н.С., 12 декабря 2266}]];
[[Николай, мне кажется, тебе стоит поменьше думать. Ты так долго смотрел в космос, что космос
стал смотреть в тебя. Я понимаю, к чему ты клонишь, но, друг, просто расслабься! У Алисы
есть все серии "Колумба", рекомендую.^
{$fmt r|Павел}^^
Космос настраивает на философию. Что есть, то есть. Но я все время думаю о Земле. Не могу поверить,
что никогда не увижу тех, кто остался. Что с ними сейчас? Что ждет нас на Глизе? И это при том, что Алиса крутит мне сны о детстве. А как у вас?^{$fmt r|А. Белоусов}]];
[[Саша, Алиса выбирает сны с учетом твоего подсознания. Доверься ей. Она пытается сохранить твою психику целостной, невзирая на то, что мы тут все испытываем.^{$fmt r|Татьяна Соколова}^^
Тоже поиграю в философию. Мы -- это лишь наша память. Реальности на нас наплевать.^{$fmt r|Линда}^
Экипаж! Наша миссия исключительно важна. И вы все это знаете. На Глизе у нас будет масса дел перед тем, как прибудет "Ковчег". А
парням с "Пионера" еще тяжелее. Мне кажется, эта мысль поможет нам всем думать не о собственных переживаниях, а о нашем долге.^{$fmt r|Капитан судна, Михаил Громов}]];
[[Кэп, на журнал ваши полномочия не распространяются. Вы сами знаете, что его существование обосновано целью поддержки психологического комфорта экипажа. Хи-хи.^{$fmt r|Аноним}^^
Аноним, зря скрываешься. Твоя вахта известна капитану.^{$fmt r|Старпом}^^
Отставить подписываться чужими именами!^{$fmt r|Сергей Синицын, старпом "Пилигрима", 30 декабря 2266}]];
[[И все-таки, как там будет? В новом мире трех солнц. Наш полет так не похож на возвращение домой...^
Линда, с твоим наивным материализмом сложно спорить. Но что есть реальность, как не предмет веры? Заметь, трудная проблема
сознания так и не решена. Несмотря на то, что Алиса кажется живой, жива ли она на самом деле? Есть ли у нее свобода воли?^{$fmt r|Товио Андерс}]];
[[Ребята, смотрите, что я нашла. Вам не кажется, что это про нас?^
{$fmt r|Оксана}^
{$fmt c|Как океан объемлет шар земной,^
Земная жизнь кругом объята снами...^
Настанет ночь — и звучными волнами^
Стихия бьет о берег свой.^
***^
Небесный свод, горящий славой звездной,^
Таинственно глядит из глубины, —^
И мы плывем, пылающею бездной^
Со всех сторон окружены.}]];
[[Оксана, какая ты романтичная. Я надеюсь, что по прибытии мы сможем узнать друг друга поближе!^{$fmt r|Твой Борис}]];
[[Борис, ты можешь выразить свои чувства в личной переписке. Оксана, спасибо за стихи. Моя очередь.^{$fmt r|Мамору Кудо}^
{$fmt c|Звезды в небесах.^
О, какие крупные!^
О, как высоко!}]];
[[Несколько новых набросков. Надеюсь, вам понравится.^{$fmt r|Василий Зорин, 18 февраля 2266}]];
[[{$fmt img|gfx/piligrim.png}]];
[[{$fmt c|{$fmt img|gfx/shluz.png}}]];
[[{$fmt c|{$fmt img|gfx/capsules.png}}]];
[[]];
	}};
	way = {
		path {
			'#закрыть',
			'Закрыть',
			from,
		};
		path {
			'#листатьназад',
			'<< Назад',
			'journal-prev',
		};
		path {
			'#листать',
			'Вперед >>',
			'журнал',
		};
	}
}
local roster = {
	{ "капитан", "Михаил Громов"}, --
	{ "старпом", "Сергей Синицын"},
	{ "главный инженер", "Борис Виноградов" },--
	{ "судовой врач", "Татьяна Соколова" },--
	{ "астроном", "Оксана Теплова" }, --
	{ "механик", "Константин Фролов" },
	{ "связист", "Василий Зорин"},--
	{ "рулевой", "Мамору Кудо"}, --
	{ "бортинженер", "Сергей Летов" },
	{ "биолог", "Елена Светлова" },
	{ "штурман", "Павел Семилетов"}, --
	{ "кок", "Ольга Потапова" },
	{ "оператор", "Вера Орлова" },--
	{ "программист", "Петр Есенин" },
	{ "медсестра", "Кейт Стингрей"},
	{ "боцман", "Товио Андерс"}, --
	{ "астронавт", "Линда Фишер"},--
	{ "астронавт", "Наталия Снежинская"},
	{ "астронавт", "Александр Белоусов"},--
	{ "астронавт", "Николай Семенов" },--
}
global 'emails' (1)
keyboard.subtitle = ""
keyboard.hidetitle = false
keyboard.hideinv = true

room {
	nam = 'inbox';
	title = 'Жилой модуль';
	hideinv = true;
	hidetitle = true;
	subtitle = 'Отсек 3';
	answ = false;
	decor = function(s)
		if s.answ then
			pn("{$fmt b|Кому: Елена Светлова} {$fmt tab,100%}{$fmt b|{$fmt nb|26 Февраля 2266 года}}")
			pn("{$fmt l|{$fmt img|box:600x1,gray}}")
			pn (s.answ)
			pn("{$fmt em|{$fmt r|Сергей Летов}}")
			pn("{$fmt l|{$fmt img|box:600x1,gray}}")
		end
		pn("{$fmt b|От кого: Елена Светлова} {$fmt tab,100%}{$fmt b|{$fmt nb|25 Февраля 2266 года}}")
		pn("{$fmt l|{$fmt img|box:600x1,gray}}")
		p [[Сережа, я так рада, что ты у меня есть! Когда я брожу в одиночестве по отсекам корабля, останавливаюсь возле твоей капсулы, вижу звезды в иллюминаторах,
смотрю записи с Земли... Мне начинает казаться, что я исчезающе мала, что меня уже нет. Но твои письма возвращают меня к жизни.^
Теплые слова. Наши сны о детстве. Любовь к тем, кто остался в прошлом и те, для кого мы сами -- прошлое... Я всегда смущалась писать о Боге, но здесь все мои мысли снова и снова
о Нем. Бездна, такая страшная и такая прекрасная. Интересно, что чувствуют другие?^
Сережа, я сегодня сделала маленькую глупость -- под твою капсулу я положила безделушку... Когда я увижу, что ты ее забрал, мне будет
не так больно видеть тебя лежащим в капсуле.^
{$fmt em|Твоя Лена.}^]]
	end;
	onenter = function()
		emails = 0;
		_'@keyboard'.title = 'Сообщение';
		_'@keyboard'.subtitle = 'Кому: Елена Светлова'
		_'@keyboard'.args = {}
		_'@keyboard'.alt_xlat = true
	end;
	onkbd = function(s, w)
		s.answ = w
		w = w:gsub("[ \t\n]+", "")
		if w:len() > 32 and
			(w:find("люб") or w:find("Люб") or w:find("лена") or w:find("Лен") or
			 w:find("орош") or w:find("космо") or w:find("селен") or w:find("слов")) then
				prefs.romance = true
		end
	end;
	onexit = function(s, t)
		if t ^ '@keyboard' then
			return
		end
		D('menu').hidden = false
		D('auth').hidden = false
		(D'auth')[3] = [[Идентификация... [pause] успешно
Добро пожаловать, Сергей.]]
		D(D'auth')
		walkback()
		beep:play(1);
		return false
	end;
	way = {
		path {
			'#закрыть',
			'Закрыть',
			from,
		};
		path {
			'#ответить',
			'Ответить',
			'@keyboard',
		};
	};
}
declare 'rec_spr' (
function(v)
	local p = pixels.new(40 * 2, 40)
	p:circleAA(20, 20, 15, 255, 0, 0)
	p:fill_circle(20, 20, 15, 255, 0, 0)
	return p:sprite()
end)
global {
	send1 = false;
	send2 = false;
	send3 = false;
}
room {
	nam = 'video';
	title = 'Жилой модуль';
	hideinv = true;
	hidetitle = true;
	subtitle = 'Отсек 3';
	time = 5;
	len = 0;
	timer = function(s)
		if s.time > 0 then
			s.time = s.time - 0.05
			if s.time > 0 then
				local d = D 'recording'
				d[3] = [[Запись начнется через ]]..std.tostr(math.round(s.time)).." сек."
				D(d)
				return
			else
				s.time = 0
				s.len = 0
				enable '#закончить'
				disable '#закрыть'
				local d = D 'console'
				D {'rec', 'img', rec_spr, frames = 2, h = 40, w = 40, delay = 100, x = d.x + d.w - 64, y = d.y + 32 }
			end
		end
		if s.time == 0 then
			s.time = -1
			local d = D 'recording'
			d.xc = true
			d.w = false
			d[3] = [[ИДЕТ ЗАПИСЬ...]]
			D(d)
			beep:play(1);
			return
		end
		s.len = s.len + 0.05
	end;
	ondecor = function(s, _, press, _, _, _, e)
		local d = D 'recording'
		if not press then
			return false
		end
		if e == 'delete' then
			d.h, d.w = false, false
			d[3] = [[Удаляю запись... [pause] готово.]]
			d.xc = true
			d.typewriter = true
			D(d)
		elseif e == 'send1' or e == 'send2' or e == 'send3' then
			d.h, d.w = false, false
			d.xc = true
			d[3] = [[Отправляю запись... [pause] готово.]]
			d.typewriter = true
			D(d)
			if e == 'send1' then
				send1 = true
			elseif e == 'send2' then
				send2 = true
			elseif e == 'send3' then
				send3 = true
			end
		else
			return false
		end
		return false
	end;
	onenter = function(s)
		local d = D 'console'
		s.time = 3
		local m = [[Запись начнется через ]]..std.tostr(s.time).." сек."
		D {'recording', 'txt', m, x = theme.scr.w() / 2, y = theme.scr.h() / 2, xc = true, yc = true}
	end;
	onexit = function(s, t)
		if t == s then
			beep:play(1);
			local d = D 'recording'
			d.xc = true
			d.yc = true
			d[3] = [[Записано ]].. std.tostr(math.round(s.len))..[[ сек.
{send1|[ Земля ]} {send2|[ Пионер 2217]} {send3|[ Ковчег ]} {delete|[ Удалить ]} ]]
			d.h, d.w = false, false
			D(d)
			D{'rec'}
			disable("#закончить")
			enable("#закрыть")
			beep:play(1);
			return false
		end
		D('menu').hidden = false
		D('auth').hidden = false
		D{'recording'}
		D{'rec'}
		walkback()
		beep:play(1);
		return false
	end;
	way = {
		path {
			'#закрыть',
			'Закрыть',
			from,
		};
		path {
			'#закончить',
			'Закончить',
			'video',
		}:disable();
	};
}

room {
	nam = 'консоль';
	title = 'Жилой модуль';
	hideinv = true;
	hidetitle = true;
	subtitle = 'Отсек 3';
	onenter = function(s)
		if not _'поднос'.eaten then
			p [[Сначала, я бы хотел позавтракать...]]
			return false
		end
	end;
	enter = function(s, f)
		local d = D {'console', 'img', 'gfx/console.png', x = (theme.scr.w() - 680) / 2, y = (theme.scr.h() - 540) / 2  }
		local m = [[Идентификация... [pause] успешно
Добро пожаловать, Сергей.]]
		if emails > 0 then
			m = m .. [[ У вас ]]..tostring(emails)..' новое сообщение.'
		end

		local a = D {'auth', 'txt', m, x = d.x + 32, y = d.y + 32, typewriter = true }
		noinv_theme()
	end;
	ondecor = function(s, _, press, _, _, _, n)
		if not press then return false end
		if n == 'm_inbox' then
			D('menu').hidden = true
			D('auth').hidden = true
			beep:play(1);
			walkin 'inbox'
			return
		elseif n == 'm_video' then
			D('menu').hidden = true
			D('auth').hidden = true
			beep:play(1);
			walkin 'video'
			return
		end
		return false
	end;
	m_menu = [[{m_inbox|>Почта}
{m_video|>Записать видео-сообщение}]];
	timer = function(s)
		local d = D 'auth'
		if d and d.finished and not D 'menu' then
			D { 'menu', 'txt', s.m_menu, x = d.x, y = d.y + d.h }
		end
	end;
	onexit = function(s, t)
		if s == t then
			pager(s, s.txt)
			return false
		end
	end;
	exit = function(s, t)
		D {'console' }
		D { 'auth' }
		D { 'menu' }
		inv_theme()
	end;
	way = {
		path {
			'#закрыть',
			'Закрыть',
			from,
		};
	};
}

dict.add('шлюз', [[Шлюзовой модуль состоит из ангара для посадочной шлюпки и небольшого шлюза для выхода в открытый космос.
Пол модуля расположен перпендикулярно оси корабля. Перемещение здесь возможно только с помощью магнитных ботинок. Чтобы попасть в 0-отсек, нужно воспользоваться шлюзовым лифтом.]] )

room {
	nam = 'Шлюз';
	title = 'Шлюз';
	subtitle = 'Ангар';
	decor = [[{$d шлюз|В шлюзовом модуле} {$d гравитация|нет искусственной гравитации.} {#место|Большую часть пространства} {#шлюпка|занимает посадочная шлюпка.}
{#лифт|В центре модуля находится лифт.}]];
	enter = function(s, f)
		if f ^ 'Отсек 0' or f ^ 'Отсек 0 Пионер' then
			action ([[Я вошел в шлюзовой лифт. Двери с шипением закрылись. Медленно лифт перенес меня в ангар.]], true)
			return
		end
	end;
	onexit = function(s, t)
		if t ^ 'Отсек 0' and visited 'chap3' then
			if not onpioner then
				p [[Я принял решение высадиться на "Пионер". Мне нужно в шлюзовой отсек.]]
				return false
			end
			if skaf then
				p [[Сначала лучше снять скафандр.]]
				return false
			end
			if onpioner then
				walk 'Отсек 0 Пионер'
				return
			end
		end
	end;
	way = { path{UP, 'Отсек 0'}, path{ "В шлюзовой отсек", "шлюзотсек" } };
}: with {
	dec("#место", "Диаметр модуля составляет примерно половину диаметра жилых модулей. Этого пространства достаточно для того, чтобы вместить в себя посадочную шлюпку.");
	obj {
		nam = '#шлюпка';
		act = function(s)
			if onpioner then
				p [[Я надеюсь, что она еще понадобится.]]
				return
			end
			if sleeped then
				p [[Теперь она бесполезна.]]
				return
			end
			p [[Она понадобится нам на Глизе.]];
		end;
	};
	dec('#лифт', "Лифт через шлюзовую шахту позволяет попасть в 0-отсек и к двигателям.");
}

global {
	skaf = false;
}

room {
	nam = 'шлюзотсек';
	title = 'Шлюз';
	subtitle = 'Шлюзовой отсек';
	decor = [[{#шлюз|Шлюзовой отсек занимает небольшую} {$d шлюз|часть модуля.} {$d стена|Вдоль одной из стен} {#кресла|закреплены ракетные кресла.}
{#шлюз|Здесь} {#скафандры|есть скафандры.}]];
	way = { path{ "В ангар", "Шлюз" } };
	life = function(s)
		if player_moved() and not from() ^ 'openspace' then
			snd.play('snd/engine.ogg', 4)
		end
	end;
	enter = function(s, f)
		if f ^ 'openspace' then
			snd.play('snd/engine.ogg', 4)
			lifeoff(s)
			map_theme()
			action ([[Я вернулся через открытый шлюз на "Пилигрим". Дал команду на закрытие шлюза и отстегнулся от кресла.]], true)
			fading.set {"fadeblack", max = FADE_LONG }
			return
		end
	end;
}: with {
	dec('#шлюз', [[Шлюзовой отсек предназначен для индивидуального выхода в открытый космос с целью ремонтных работ.]]);
	obj {
		nam = '#кресла';
		act = function(s)
			if skaf and not onpioner then
				D {'map-top'}
				D {'map-front'}
				D {'mark-front'}
				D {'mark-top'}
				lifeon(here())
				walkin 'openspace'
				action ([[Я пристегнулся к креслу, выполнил регламентные проверки и активировал открытие шлюза.
Некоторое время я наблюдал как передо мной распахивается открытый космос...]], true)
				fading.set {"fadeblack", max = FADE_LONG }
				snd.stop_music()
				return
			end
			p [[В таком кресле можно относительно комфортно перемещаться в открытом космосе на небольшие расстояния.]];
		end;
	};
	obj {
		ini = function(s)
			if skaf then
				snd.play('snd/breath.ogg', 3, 0)
			end
		end;
		nam = '#скафандры';
		act = function(s)
			if visited 'chap3' then
				skaf = not skaf
				if skaf then
					p [[Не без труда я забрался в скафандр.]]
					snd.play('snd/breath.ogg', 3, 0)
					D {'mask', 'img', 'gfx/mask.png', z = 0.1 }
					fading.set {"fadeblack", now = true }
				else
					p [[Я снял скафандр.]]
					D {'mask'}
					fading.set {"fadeblack", now = true }
					snd.stop(3)
				end
			else
				p [[Скафандры для выхода в открытый космос.]]
			end
		end;
	}
}

dict.add('мостик', [[Мостик -- центр управления звездолетом. Он разделен на два отсека: капитанский мостик и наблюдательный пункт (воронье гнездо). Отсеки связаны лестницей.]])
dict.add('пилигрим', [["Пилигрим" -- второй звездолет миссии к Глизе 667. "Пилигрим" был отправлен через 10 лет после старта "Пионера-2217". Оба звездолета имеют одинаковую конструкцию
и должны подготовить плацдарм для прибытия "Ковчега". Третий звездолет "Ковчег" построен и запущен через 10 лет после старта "Пилигрима".
Он обладает огромной вместительностью и более совершенной системой гибернации, которая не требует прерывания сна.]])

function game:onwalk()
	if D'black' then
		return false
	end
end

room {
	nam = 'Мостик';
	title = 'Мостик';
	subtitle = 'Центр управления';
	timer = function()
		if D'black' then
			if D'black'.alpha == 255 then
				D{'сирена'}
				D{'black'}
				lifeoff 'сирена'
				walk 'chap2'
				fading.set {"fadeblack", max = FADE_LONG }
				return
			end
		end
		return false
	end;
	exit = function(s, t)
		if t ^ 'Жилой Отсек 0' and pioner then
			walk 'chap3'
			fading.set {"fadeblack", max = FADE_LONG }
			return
		end
	end;
	decor = [[{$d мостик|Капитанский мостик занимает} {#нос|носовую часть} {$d пилигрим|звездолета}. {$d мостик|Здесь} {$d гравитация|нет искусственной гравитации.}
{$d стена|Вдоль стенки отсека} {#консоли|расположены консоли.}]];
	way = { path{"В воронье гнездо", 'Воронье гнездо'}, path{DOWN, 'Жилой Отсек 0'}  };
}: with {
	dec("#нос",  [[На самом носу звездолета расположено воронье гнездо. Древний морской жаргонный термин, который раньше означал наблюдательный пункт на мачте корабля,
теперь относится к небольшому отсеку на носу, выполняющему ту же функцию.]]);
	obj {
		nam = '#консоли';
		act = function(s)
			if radar then
				walkin 'Радар'
				return
			end
			p 'Нет необходимости вмешиваться в работу автоматики.';
		end;
	}
}

local rot = 0

declare 'stars_rot' (function(v)
	v.x = math.cos(v.rad + rot) * v.r + theme.scr.w() / 2
	v.y = math.sin(v.rad + rot) * v.r + theme.scr.h() / 2
end)

global { rstars = {} };

global { hud_selected = false, num_selected = 0 }
local hud_cursor = pixels.new(32, 32)
hud_cursor:poly({1, 1, 30, 1, 30, 30, 1, 30, 1, 1}, 255, 255, 255, 128);
hud_cursor = hud_cursor:sprite()

global {
	ship_r = 12,
	ship_distance = 0.121241
}

declare 'rnd_star_spr' (
function(v)
	if num_selected == 0 then
		local w = ship_r
		local p = pixels.new(w * 32, w)
		local alpha = 0
		for i = 1, 32 do
			p:circleAA((i - 1) * w + w/2, w/2, w/2 - 2, color2rgb('white'))
			p:circleAA((i - 1) * w + w/2, w/2, w/2 - w/10, color2rgb('white'))
			local r = w / 2 - 3
			local a = alpha
			for k = 1, 4 do
				local x, y = r * math.cos(a), r * math.sin(a)
				local xx = (i - 1) * w + w/2
				local yy = w / 2
				p:lineAA(xx, yy, xx + x, yy + y, color2rgb('white'))
				a = a + math.pi / 2
			end
			p:fill_circle((i - 1) * w + w/2, w/2, w/5, color2rgb('#f0f0f0'))
			alpha = alpha + math.pi / 64
		end
		blur(p, 240, 255, 255)
		return p:sprite()
	end
	rnd_seed(num_selected)
	local star = render.star({r = rnd(5)+3, temp = rnd(6000)})
	return star:sprite()
end)

room {
	nam = 'tele';
	star = false;
	title = 'Мостик';
	subtitle = 'Воронье гнездо';
	hideinv = true;
	hidetitle = true;
	enter = function(s)
		if num_selected == 0 then
			D { 'star', 'img', rnd_star_spr, xc = true, yc = true, x = 512, y = 288, z = 2, frames = 32, w = ship_r, h = ship_r, delay = 200 }
		else
			D { 'star', 'img', rnd_star_spr, xc = true, yc = true, x = 512, y = 288, z = 2 }
		end
	end;
	way = { path {"Назад", from } };
}

declare 'aship_spr' (function(v, select)
	if ship_heading == 0 then
		local p = pixels.new(5, 5)
		p:fill_circle(2, 2, 2, color2rgb 'cyan')
		blur(p, 200, 255, 255)
		return p:sprite()
	end
	local p = pixels.new(2, 2)
	p:pixel(0, 0, color2rgb('gray'))
	p:pixel(1, 0, color2rgb('blue'))
	p:pixel(1, 1, color2rgb('cyan'))
	p:pixel(0, 1, color2rgb('green'))
	return p:sprite()
end)

local hud_text = false
local hud_font = sprite.fnt(theme.get'win.fnt.name', 12)
local NEW_STARS = 18
local SNAMES = {
	"Glisse 667",
	"G Sco",
	"Sargas",
	"Dschubba",
	"Nunki",
	"d Oph",
	"3 Sgr",
	"Sargas",
	"Kaus Media",
	"HIP 87220",
	"τ Sco",
	"ψ Sgr",
	"β Oph",
	"θ Lup",
	"Stead3",
	"c Oph",
	"Antares",
	"HIP 83336",
}

declare 'star_render' (
function(v)
	v.sprite:draw(sprite.scr(), v.x - v.xc, v.y - v.yc)
	if hud_selected == v[1] then
		hud_cursor:draw(sprite.scr(), v.x - v.xc - 15 + v.w / 2 , v.y - v.yc - 15 + v.h / 2)
		if not hud_text then
			hud_text = hud_font:text(v.num and SNAMES[v.num] or "???", 'cyan')
		end
		local w, h = hud_text:size()
		hud_text:draw(sprite.scr(), v.x - w/2 + v.w / 2, v.y + 15 + v.h);
	end
end)

local function make_new_stars()
	for i = 1, STARS do
		local s = D("star"..tostring(i))
		s.hidden = true
		D{"hud", "img", hud_spr, xc = true, yc = true, x = theme.scr.w()/2, y = theme.scr.h() /2, z = 1}
	end
	local rot = 2 * rnd() * math.pi- math.pi

	for i = STARS + 1, STARS + NEW_STARS do
		local s
		if rstars[i] then
			s = std.clone(rstars[i])
			s.rad = s.rad + rot
		else
			s = {"star"..tostring(i), 'img', star_spr, dist = rnd(8) + 8, process = stars_rot, x = rnd(theme.scr.w()), y = rnd(theme.scr.h()), speed = rnd(5), z = 2, click = 16, render = star_render, num = i - STARS }
			local dx, dy = s.x - theme.scr.w()/2, s.y - theme.scr.h()/2
			local r = (dx ^ 2 + dy ^ 2) ^ 0.5
			if s.num == 1 then
				r = 1
			end
			s.r = r
			local alpha = 2 * rnd() * math.pi  - math.pi
			s.rad = alpha
			rstars[i] = std.clone(s)
		end
		s = D(s)
	end
	if sleeped and not onpioner then
		local d = D {"ship", "img", aship_spr, xc = true, yc = true, rad = 2 * rnd() * math.pi - math.pi, r = rnd(50) + 50, z = 1.5, x = 0, y = 0, process = stars_rot, click = 16, render = star_render }
		if ship_heading == 0 then
			d.r = rnd(16)
			d = D ('star'..tostring(STARS+1))
			d.r = 32
		end
	end
end

local function hide_new_stars(all)
	if sleeped then
		D{"ship"}
	end
	if not all then
		for i = 1, STARS do
			local s = D("star"..tostring(i))
			s.hidden = false
		end
	end
	D{"hud"}
	for i = STARS + 1, STARS + NEW_STARS do
		D {"star"..tostring(i) }
	end
end

declare 'hud_spr' (function()
	local w, h = 361, 361
	local p = pixels.new(w, h)
	local col = 'gray'
	local r = w / 2
	p:circleAA(w / 2, h / 2, w / 2, color2rgb(col))
	p:lineAA(0, h / 2, 32, h / 2, color2rgb(col))
	p:lineAA(w - 32, h / 2, w, h / 2, color2rgb(col))
	p:lineAA(w / 2, 0, w / 2, 32, color2rgb(col))
	p:lineAA(w / 2, h - 32, w / 2, h, color2rgb(col))
	p:lineAA(w / 2, h / 2 - 16, w / 2, h / 2 + 16, color2rgb(col))
	p:lineAA(w / 2 - 16, h / 2, w / 2 + 16, h / 2, color2rgb(col))
	for aa = 0, math.pi / 4, math.pi / 8 do
		local a = aa + math.pi / 8
		for i = 1, 4 do
			local x = (r - 2)* math.cos(a)
			local y = (r - 2)* math.sin(a)
			local x2 = (r - 8)* math.cos(a)
			local y2 = (r - 8)* math.sin(a)
			p:lineAA(x + w / 2, y + h / 2, x2 + w / 2, y2 + h / 2, color2rgb(col))
			a = a + math.pi / 2
		end
	end
	return p:sprite()
end)
global {
	radar = false;
}
room {
	nam = 'Воронье гнездо';
	title = 'Мостик';
	decor = [[{$d я|Я} {#отсек|нахожусь в наблюдательном отсеке.}]];
	subtitle = 'Воронье гнездо';
	hideinv = true;
	hidetitle = true;
	ondecor = function(s, name, press)
		if not press then
			return
		end
		hud_selected = name
		hud_text = false
	end;
	timer = function(s)
		rot = rot - 0.005
		return false
	end;
	enter = function(s, f)
		if f ^ 'tele' then
			D {'tele'}
			D {'tele-space'}
			D {'star'}
			make_new_stars()
			return
		end
--		p [[Я поднялся в воронье гнездо по лестнице.]]
		local d = D 'space'
		hud_selected = false
		d.hidden = true
		fading.set {"fadeblack", max = FADE_LONG / 2, now = true }
		make_new_stars()
		noinv_theme()
	end;
	exit = function(s, t)
		if t ^ 'tele' then
			hide_new_stars(true)
			D { 'tele-space', 'img', 'gfx/milkyway.jpg', x = 200, y = 0, z = 3, fx = rnd(500), fy = rnd(50), background = true };
			D { 'tele', 'img', 'gfx/tele.png', x = 0, y = 0, z = 1 };
			return
		end
		local d = D 'space'
		d.hidden = false
		fading.set {"fadeblack", max = FADE_LONG / 2, now = true }
		hide_new_stars()
		inv_theme()
		if onpioner then
			if t ^ 'Мостик' then
				walkin 'Мостик Пионер'
			end
			return
		end
		if pioner then
			p [[Таких кораблей на момент нашего отбытия было построено всего два. И один из них -- "Пилигрим". Итак, этот корабль -- "Пионер-2217", но как он здесь оказался?]]
		end
	end;
	way = { path{DOWN, 'Мостик'}  };
}: with {
	dec('#отсек', [[Носовая часть звездолета имеет огромные иллюминаторы, что позволяет вести наблюдение визуально, а не с помощью радиотелескопа.
Обычно иллюминаторы закрыты щитами, которые можно открывать для выполнения наблюдений.]]);
}: with {
	obj {
		nam = '#пульт';
		dsc = [[{#отсек|Здесь} {есть пульт управления.}]];
		act = function()
			if not sleeped then
				p [[Сейчас нет необходимости выполнять визуальные наблюдения.]];
				return
			end
			if not hud_selected then
				p [[Сначала нужно выбрать объект наблюдения.]]
				return
			end
			if hud_selected then
				num_selected = D(hud_selected).num or 0
				if num_selected == 0 then
					if not radar or not visited 'Радар' then
						p [[Странный объект. Нужно сходить на мостик и проверить, регистрируется ли он...]];
						radar = true
					elseif ship_r >= 20 then
						pn [[Я могу различить вращающиеся модули! Звездолет с Земли?]]
						p [[Это похоже... Не может быть, что бы это был "Пионер"! Ведь он стартовал с Земли за 10 лет до нашего старта.]]
						pioner = true
					elseif ship_r >= 16 then
						p [[Я могу различить вращающиеся модули! Звездолет с Земли?]]
					elseif ship_r >= 12 then
						p [[Кажется, это звездолет. Я не знаю, что и думать....]]
					end
				end
				walk 'tele'
			end
		end;
	};
}
global {
	ship_heading = math.pi / 8;
	pioner = false;
}
local radar_snd = false
declare 'radar_proc' (
function(v)
	local d = D 'radar'
	if not v.__pxl then
		v.__pxl = pixels.new(d.w, d.h)
	end
	v.__dot = pixels.new(7, 7)
	local a = 3 * math.pi / 2 + ship_heading
	a = (a - v.a) / (2 * math.pi)
	if a < 0 then a = 0 end
	a = a * 255
	if a < 100 and radar_snd then
		radar_snd = false
	end
	if a > 100 and not radar_snd then
		snd.play ('snd/radar.ogg', 3)
		radar_snd = true
	end
	if not disabled '#курс' or maneur then
		v.__dot:fill_circle(5, 5, 4, 255, 100, 100, a)
	else
		v.__dot:fill_circle(5, 5, 4, 100, 255, 255, a)
	end
	v.__pxl:clear(0, 0, 0, 0)
	local alpha = v.a
	local r = d.w / 2 - 10
	local x, y = r * math.cos(alpha), r * math.sin(alpha)
	v.__pxl:lineAA(d.w /2, d.h / 2, d.w /2 + x, d.h /2 + y, 255, 255, 255, 200)
	v.a = v.a + math.pi / 16
	if v.a > 2 * math.pi then v.a = v.a - 2 * math.pi end
end)

declare 'radar_draw' (
function(v)
	local d = D 'radar'
	if v.__pxl then
		v.__pxl:draw_spr(sprite.scr(), d.x - d.xc, d.y - d.yc)
		local a = - math.pi / 2 + ship_heading
		local r = ship_distance * 90 / 0.1
		local x, y = math.cos(a) * r, math.sin(a) * r
		v.__dot:draw_spr(sprite.scr(), d.x - d.xc + d.w /2 + x , d.y - d.yc + d.h/2 + y)
	end
end)
global { maneur = false }
declare 'radar_spr' (
function(v)
	local p = pixels.new(300, 300)
	p:circleAA(150, 150, 140, color2rgb('white'))
	for k = 1, 4 do
		p:circleAA(150, 150, k * 30, color2rgb('gray'))
	end
	p:fill_circle(150, 150, 4, color2rgb('cyan'))
	local r = 120
	local alpha = 0
	local xc, yc = 150, 150
	for k = 1, 32 do
		local x, y = r * math.cos(alpha), r * math.sin(alpha)
		local x1, y1 = (r - 30) * math.cos(alpha), (r - 30) * math.sin(alpha)
		p:lineAA(xc + x, yc + y, xc + x1, yc + y1, color2rgb 'grey')
		alpha = alpha + math.pi / 16
	end
	return p:sprite()
end)
global {
	maneur_t = 30;
}
local function show_maneur()
	local d = D 'radar'
	D {'radar_txt'}
	local t
	if ship_heading == 0 then
		local m = [[Режим: следование за целью.
Согласование скоростей: через 15 минут.
Дистанция: 320 км.]];
		local a = D {'radar_txt', 'txt', m, xc = true, x = d.x, y = d.y - d.yc +  d.h, typewriter = true, style = 2 }
		return
	end
	if maneur_t % 10 == 1 then
		t = tostring(maneur_t) .. ' минуту'
	elseif maneur_t % 10 >= 2 and maneur_t % 10 <= 4 then
		t = tostring(maneur_t) .. ' минуты'
	else
		t = tostring(maneur_t) .. ' минут'
	end
	local m = [[Маневр будет произведен через ]]..t..[[.
Будьте готовы к кратковременному отключению гравитации.]]
	local a = D {'radar_txt', 'txt', m, xc = true, x = d.x, y = d.y - d.yc +  d.h, typewriter = true, style = 2 }
end

room {
	nam = 'Радар';
	title = 'Мостик';
	subtitle = 'Консоль';
--	hidetitle = true;
	hideinv = true;
	ondecor = function(s, n, press, x, y)
		if not press then
			return false
		end
		local d = D 'radar'
		local a = - math.pi / 2 + ship_heading
		local r = ship_distance * 90 / 0.1
		local xx, yy = math.cos(a) * r, math.sin(a) * r
		if x >= xx - 16 and y >= yy - 16 and x < xx + 16 and y < yy + 16 and not maneur then
			local m = [[Неопознанный объект.
Дистанция: ]].. string.format("%0.3f", ship_distance)..' au / Относит. скорость: -0.25c\nКурс: '.. string.format("%0.3f", ship_heading)
			local a = D {'radar_txt', 'txt', m, xc = true, x = d.x, y = d.y - d.yc +  d.h, typewriter = true, style = 2 }
			enable "#курс"
			snd.music('mus/prelude.ogg', 1)
			return
		end
		return false
	end;
	onenter = function(s)
		if ship_heading == 0 then return end
		if maneur then
			maneur_t = maneur_t - rnd(5)
		end
		if maneur_t < 10 then
			p [[Скоро начнется маневр. Лучше провести это время пристегнутым в жилом отсеке.]]
			return false
		end
	end;
	enter = function(s)
		local d = D {'radar', 'img', radar_spr, xc = true, yc = true, x = theme.scr.w() / 2, y = tonumber(theme.get 'win.h') - 150 , z = 1, click = true }
		D {'radar_line', 'raw', render = radar_draw, z = 0, a = - math.pi/2, speed = 20, process = radar_proc }
		if maneur then
			show_maneur()
		end
		disable '#курс'
		noinv_theme()
	end;
	onexit = function(s, t)
		if t == s then
			maneur = true
			show_maneur()
			return false
		end
	end;
	exit = function(s, t)
		D {'radar'}
		D {'radar_line'}
		D {'radar_txt'}
		inv_theme()
		if ship_heading == 0 then
			return
		end
		p [[Это не может быть звездолетом, но это похоже именно на ... звездолет!]]
		if not maneur then
			p [[До него можно добраться за пару суток... Если изменить курс "Пилигрима". Я должен принять решение.]]
		else
			p [[Так или иначе, я скоро узнаю это. Сейчас лучше пойти в жилой модуль и приготовиться к маневру.]]
		end
	end;
	way = { path{"Назад", 'Мостик'}, path { "#курс", "Изменить курс",  'Радар'}:disable() };
}


declare 'mask_spr' (
function(v)
	local s = sprite.new('gfx/clouds-mask.png')
	local w, h = s:size()
	local ss = sprite.new(w * 2, h)
	s:copy(ss, 0, 0)
	s:copy(ss, w, 0)
	return ss
end)

declare 'mask_render' (
function(v)
--	local w = v.w - v.x
	v.sprite:draw(v.x, 0, v.w / 2, v.h, sprite.scr(), 0, 0)
--	v.sprite:draw(v.x, 0, w, v.h, sprite.scr(), 0, 0)
--	v.sprite:draw(0, 0, v.x, v.h, sprite.scr(), w, 0)
end)

declare 'mask_process' (
function(v)
	v.x = v.x + 4
	if v.x >= v.w / 2 then
		v.x = 0
	end
end)

function fading.effects.fadelight(s, src, dst)
	src:copy(sprite.scr(), 0, 0);
	local pos = (s.step / s.max)
	local x, y, w, h
	local a = 0.6
	local b = 0.4
	if pos <= a then
		local scale = pos / a
		w = 64 * scale
		x = (theme.scr.w() - w) / 2
		h = theme.scr.h() * scale
		y = (theme.scr.h() - h) / 2
		dst:copy(x, y, w, h, sprite.scr(), x, y)
	else
		local scale = (pos - a)/ b
		w = theme.scr.w() * scale
		x = (theme.scr.w() - w) / 2
		y = 0
		h = theme.scr.h()
		dst:copy(x, y, w, h, sprite.scr(), x, y)
	end
end

global { saved_inv = std.list {} };

room {
	nam = 'Двор-enter';
	title = 'Жилой модуль';
	subtitle = 'Отсек 1';
	noinv = true;
	enter = [[Остаток вахты я решил отдохнуть. Я лег на кушетку и мгновенно провалился в глубокий сон.]];
	exit = function(s)
		snd.music('mus/prelude2.ogg', 1)
	end;
	way = { path { 'Дальше', 'Двор' }};
}

obj {
	nam = 'мяч';
	inv = [[Этот мяч мне подарил отец на 8 лет.]];
	dsc = [[{#лестница|Под лестницей} {лежит мой мяч.}]];
	tak = [[Я забрал мяч.]];
	use = function(s, w)
		if w ^ '#парни' then
			_'удар в лицо'.state = 1
			snd.play 'snd/kick2.ogg'
			walk 'удар в лицо'
			return
		elseif w ^ '#главный' then
			_'удар в лицо'.state = 2
			snd.play 'snd/kick2.ogg'
			walk 'удар в лицо'
			return
		end
		if w^'#мальчик' then
			p [[Я попробовал сбить мальчика мячом, но мяч просто отскочил обратно мне в руки.]]
		else
			p [[Мяч для игры.]]
		end
	end
}

dict.add("я7", "Мне девять лет.")
dict.add("мяч", "Волейбольный мяч, который мне подарил отец на 8 лет.");
dict.add("дома", "Дома в этом городе очень высокие. Такие высокие, что загораживают собой небо.");

room {
	nam = 'Двор';
	title = 'Двор';
	decor = [[{#лето|Летний день.} {$d я7|Я стою} {#дом|у подъезда своего дома.} {#руки|В руках} {$d я7|я} {$d мяч|держу мяч.}
{$d дома|Возле соседнего дома} {$d я7|я} {#площадка|вижу площадку.}]];
	enter = function(s, f)
		if f ^ 'Двор-enter' then
			saved_inv:zap()
			saved_inv:cat(inv())
			inv():zap()
			take 'мяч'
			fading.set {"fadelight", max = 32 }
			D();
			D { 'clouds', 'img', 'gfx/clouds.jpg', background = true, x = 0, y = 0, z = 3 }
			D { 'clouds-mask', 'img', mask_spr, x = 0, y = 0, z = 2, render = mask_render, process = mask_process }
			snow_theme();
			return
		end
	end;
	way = { path {'#к_площадке', 'К площадке', 'площадка' }:disable() };
}: with {
	dec("#лето", "Уже далеко за полдень и довольно жарко.");
	dec("#дом", "Мы недавно переехали в этот дом. Мы часто переезжаем, поэтому у меня всегда мало друзей.");
	dec("#руки", "В моих руках -- мяч.");
	obj {
		nam = '#площадка';
		act = function(s)
			p [[На площадке я вижу мальчика, сидящего на лестнице. Можно пойти и познакомиться с ним.]]
			enable '#к_площадке'
		end;
	};
}

room {
	nam = 'площадка';
	title = 'Площадка';
	decor = function(s)
		if not field then
			p [[{#площадка|Детская площадка пуста,} {#мальчик|если не считать мальчика, который} {#лестница|сидит на самом конце лестницы} {#смотрит|и молча смотрит куда-то наверх.}]];
		else
			p [[{#площадка|Детская площадка пуста.}]];
		end
	end;
	way = { path {'К подъезду', 'Двор' }, path {'#наверх', 'Наверх', 'Лестница'}:disable(), path {'замаксом', 'За Максом', 'Поле'}:disable() };
	onexit = function(s, t)
		if field and t ^ 'Двор' then
			p [[Лучше я побегу за Максом, скоро я потеряю его из виду!]]
			return false
		end
		if field and t ^ 'Поле' then
			fading.set {"fadeblack", max = FADE_LONG, now = true }
		end
	end;
	exit = function(s, t)
		if not t ^ 'Лестница' and not have 'мяч' then
			p [[Я забрал свой мяч.]]
		end
	end;
}: with {
	dec("#площадка", "Здесь есть качели, горка и несколько лестниц, которые установлены в виде пирамиды.");
	dec("#лестница", "Лестница кажется довольно высокой.");
	dec("#смотрит", "Интересно, что он там наблюдает?");
	obj {
		nam = '#мальчик';
		act = function(s)
			if disabled '#наверх' then
				pn [[-- Привет! Тебя как зовут? -- негромко, но отчетливо сказал я мальчику.]]
				p [[-- Макс! Давай, залезай сюда! -- крикнул он мне в ответ.]]
				enable '#наверх'
				return
			else
				p [[Я думаю, стоит залезть на лестницу и поговорить с Максом.]]
			end
		end;
	};
}

room {
	nam = 'Лестница';
	title = 'На лестнице';
	enter = function(s, f)
		if not field then
			p [[Я взобрался по лестнице и уселся рядом с мальчиком.]];
		else
			p [[Я взобрался по лестнице наверх.]];
		end
		if have 'мяч' then
			place('мяч', from())
			p [[Мяч я оставил под лестницей.]]
		end
	end;
	exit = function(s)
		p [[Я спустился по лестнице вниз.]]
		if field and not disabled '#макс' then
			pn [[Вслед за мной с лестницы спрыгнул Макс.]]
			pn [[-- За мной! -- крикнул он и побежал к дальнему дому.]];
			p [[Я быстро схватил свой мяч.]]
			take 'мяч'
			disable('#макс')
			enable 'замаксом'
			return
		end
	end;
	decor = [[{$d я7|Я} {#ступенька|сижу на ступеньке}.]];
	way = { path { 'Вниз', 'площадка' } };
}: with {
	dec("#ступенька", "Спускаться будет страшновато.");
	obj {
		nam = '#макс';
		dsc = [[{Рядом сидит Макс.}]];
		act = function(s)
			walkin 'Макс'
		end;
	}
}

global 'field' (false)

dlg {
	nam = 'Макс';
	onexit = function(s)
		if field then enable '#наполе' end
	end;
	phr = {
		{ false, '#наполе', 'Ну, бежим?', '-- Да, я покажу!'};
		{ "А меня Серегой зовут, давай дружить?",
		  function(s) p "-- Давай!"; s:disable(); end,
		  {"А что ты разглядываешь?",
		   "-- Мне мама рассказывала, что в нашем городе еще можно встретить птиц. Вот я и смотрю...",
		   {"Ну и как, видел?", "-- Пока нет."}},
		  {"У меня есть мяч! Давай сыграем?", "-- Давай, только знаешь, побежали на поле?",
		   {"А где оно? Не далеко?", "-- Ну... Не очень. Старое футбольное поле. Там и ворота есть!",
		    {"Ну, давай!", function(s) p "-- Тогда, слезаем!"; field = true; end; }
		   }
		  }
		};
		{ noshow = true, "Закончить разговор", function() walkout(); end };
	}
}

room {
	nam = 'action_room';
	title = false;
	subtitle = false;
	hidetitle = false;
	noinv = true;
	fading = false;
	decor = false;
	obj = {
		obj {
			nam = '#Дальше',
			act = function()
				walkback()
				fading.set { "none" }
			end
		    }
	}
}

function action(t, f)
	local div = fmt.c(fmt.img 'gfx/div.png')
	if not D'snow' and not D'clouds' then
		div = fmt.c(fmt.img 'gfx/div2.png')
	end
	_'action_room'.decor =  fmt.em(t) .. '^'..div..'^'..fmt.c'{#Дальше|Дальше}'
	_'action_room'.title = std.titleof(here())
	_'action_room'.subtitle = here().subtitle
	_'action_room'.hidetitle = not not here().hidetitle
	if not f then
		fading.set { "none" }
	end
	walkin 'action_room'
end


room {
	nam = 'Поле';
	state = 1;
	enter = function(s)
		remove 'мяч'
	end;
	onexit = function(s, t)
		snd.stop_music()
		if t ^ 'Двор' then
			_'удар в лицо'.state = 3
			walk 'удар в лицо'
			return false
		end
	end;
	decor = function(s)
		local t = {
			[[{$d я7|Я} {#ворота|стою в воротах.} {#макс|Макс} {#удар|готовится бить.}]],
			[[{$d я7|Я} {#ворота|растерянно стою в воротах.} {#удар|В углу ворот лежит мяч.}]],
			[[{$d я7|Я} {#вижу|вижу как} {#лево|с левой стороны поля} {#мы|к нам} {#удар|идут взрослые парни.}]];
			[[{$d я7|Я} {#макс|стою рядом с Максом.} {#парни|Парни стоят прямо напротив} {#мы2|нас.}]];
		}
		p(t[s.state])
	end;
	way = { path { '#уйти', 'Уйти', 'Двор' }:disable() };
}: with {
	obj {
		nam = '#ворота';
		act = function(s)
			if here().state == 1 then
				p [[Ворота кажутся огромными. У меня нет никакого шанса.]];
			elseif here().state == 2 then
				p [[Неудивительно, что я пропустил мяч. Но ничего, теперь моя очередь!]]
			end
		end;
	};
	obj {
		nam = '#макс';
		act = function(s)
			p [[Макс сосредоточен.]]
		end;
	};
	dec("#вижу", "Почему-то я чувствую страх."),
	dec("#лево", "До конца поля несколько десятков метров. Скоро они будут здесь."),
	dec("#мы", "Зря мы пришли сюда.^Я кричу Максу и он оборачивается, замечает чужаков. По его настроженной позе я понимаю, что он волнуется."),
	dec("#мы2", "Зря мы пришли сюда."),
	obj {
		nam = '#удар';
		act = function(s)
			if here().state == 1 then
				here().state = 2
				action [[Макс разбегается и бьет. Мяч летит куда-то в угол ворот.]]
				snd.play 'snd/kick.ogg'
				snd.stop_music()
			elseif here().state == 2 then
				here().state = 3
				take 'мяч'
				action [[Я иду за мячом. Когда мяч в моих руках, я оборачиваюсь и вижу, как с левой стороны поля к Максу идут какие-то взрослые парни.]]
				snd.music('mus/impact.ogg', 1)
			elseif here().state == 3 then
				here().state = 4
				action [[Их четверо. Руки в карманах. Небрежной походкой они идут прямо к нам. Я подхожу к Максу и мы вместе ждем чего-то страшного.]];
			end
		end;
	};
	dec("#напротив", [[Мне страшно. Сердце готово вырваться из груди.]]);
	obj {
		nam = '#главный';
		dsc = [[{#напротив|Напротив} {#макс|Макса} {#мы2|нас} {стоит главарь.}]];
		state = 1;
		act = function(s)
			local t = { [[-- Что вам нужно?^-- Не твоего ума дело, вали! Нам нужен твой друг, а не ты.]], [[-- Я останусь...^-- По шее захотел? Уходи, пока можешь!]], [[-- Вам деньги нужны?^
-- У нас свои дела, тебя это не касается! Мотай, пацан.]] };
			pn(t[s.state])
			if s.state > #t then
				p [[Бесполезно разговаривать. А драться не хватает духу. Уйти?]]
				return
			end
			s.state = s.state + 1
		end;
	}:disable();
	obj {
		nam = '#парни';
		act = function(s)
			p [[Их вид мне не нравится. Злые, пустые глаза. Усмешки на губах.]]
			if disabled '#уйти' then
				enable '#главный'
				enable '#уйти'
				p [[^
-- Ну, привет. -- зло говорит один из них Максу. Вероятно, это главный. Макс молчит. Он серьезен.^
-- А ты пацан иди своей дорогой, пока цел -- обращается он уже ко мне.]];
			else
				p [[^-- Чего зыришь? Пошел отсюда, щенок. -- говорит мне один из них.]]
			end
		end;
	};
}

function fading.effects.tilt(s, src, dst)
	src:copy(sprite.scr(), 0, 0);
	local pos = (s.step / s.max)
	local h = theme.scr.h() * pos / 2;
	dst:copy(0, 0, theme.scr.w(), h, sprite.scr(), 0, 0);
	dst:copy(0, theme.scr.h() - h, theme.scr.w(), h, sprite.scr(), 0, theme.scr.h() - h)
end
dict.add('сирена', function(s)
		 p [[Криокапсулы в опасности!]]
		 if not elena_death then
			 p [[Елена?!!!]]
		 end
end)
obj {
	nam = 'сирена';
	life = function(s)
		p [[{$d сирена|Я слышу истошный вой сирены.}]]
		return true
	end;
}
declare 'sirene_proc' (
function(v)
	v.alpha = v.alpha + v.step * 11
	if v.alpha >= 128 or v.alpha <= 0 then
		v.step = - v.step
		if v.step == 1 then
			snd.play('snd/alarm.ogg', 3)
		end
	end
	if v.alpha > 128 then v.alpha = 128 end
	if v.alpha < 0 then v.alpha = 0 end
end)

global {
	cap1d = false;
	cap2d = false;
	cap3d = false;
}

declare 'black_proc' (
function(v)
	snd.pan(3, 255 - v.alpha, 255 - v.alpha)
	v.alpha = v.alpha + 4
	if v.alpha >= 255 then
		v.alpha = 255
	end
end)

function game:onact(w)
	if D'black' then
		return false
	end
	local r, v = std.call(here(), 'onact', w)
	if v == false then
		return r, v
	end
	if not D'сирена' then
		return
	end
	if w.tag == '#Дальше' then
		return
	end
	if w ^ 'елена' then
		return
	end
	if w ^ 'капсулы' then
		local nam = false
		if here() ^ 'Отсек 1' then
			nam = 'cap1d'
		elseif here() ^ 'Отсек 2' then
			nam = 'cap2d'
		elseif here() ^ 'Отсек 3' then
			nam = 'cap3d';
		end
		if not _G[nam] then
			p [[На всех капсулах система мониторинга показывает отсутствие жизнедеятельности! Что происходит!]]
			_G[nam] = true
		else
			p [[Они все ... мертвы?]]
		end
		if not cap1d or not cap2d or not cap3d then
			p [[Нужно проверить остальные капсулы!]]
		else
			p [[^Весь экипаж мертв... Что произошло? Что предпринять?]]
		end
		return false
	end
	if w.tag == '#капсула' then
		p [[Это моя капсула и она пуста...]]
		return false
	end
	if cap1d and cap2d and cap3d then
		if here() ^ 'Мостик' and w.tag == '#консоли' then
			p [[Я бросился к консолям...]]
			if not D 'black' then
				D {'black', 'img', 'box:1024x576,black', 0, 0, z = -1, process = black_proc, alpha = 0 };
			end
			return false
		end
		p [[Может быть вышла из строя система жизнеобеспечения? Может быть еще можно что-то сделать! Нужно бежать на мостик!]]
		return false
	end
	if here() ^ 'Отсек 1' or here() ^ 'Отсек 2' or here() ^ 'Отсек 3' or here() ^ 'Отсек 4' then
		p [[Что с капсулами?]]
	else
		p [[Капсулы! Нужно срочно бежать в блок гибернации!]]
		if not elena_death then
			p [[Елена!]]
		end
	end
	return false
end

room {
	nam = 'удар в лицо';
	noinv = true;
	title = false;
	{
		time = 0;
	};
	state = 1;
	decor = function(s)
		if s.state == 1 then
			p (fmt.y("50%")..fmt.c("Я БРОСАЮ МЯЧ В ЧЬЕ-ТО ЛИЦО!"))
		elseif s.state == 2 then
			p (fmt.y("50%")..fmt.c("Я БРОСАЮ МЯЧ В ЕГО ЛИЦО!"))
		else
			p (fmt.y("50%")..fmt.c("Я УШЕЛ..."))
		end
	end;
	timer = function(s)
		inv():zap()
		if instead.ticks() - s.time > 1000 then
			fading.set {"tilt"  }
			walkback 'Жилой Отсек 1'
			lifeon('сирена')
			D {'сирена', 'img', 'box:1024x576,red', x = 0, y = 0, z = 0, alpha = 0, process = sirene_proc, step = 1 }
			snd.play('snd/alarm.ogg', 3)
		end
	end;
	enter = function(s)
		prefs.strong = true
		s.time = instead.ticks()
		if s.state ~= 3 then
			fading.set {"none"}
			quake.post = true
			quake.start()
		end
	end;
	exit = function()
		inv():zap()
		inv():cat(saved_inv)
		stars_theme()
		dark_theme()
		map_theme()
		return
	end;
}

declare 'snova_process' (function(v)
	if v.state < #v.snova then
		v.state = v.state + 1
	end
end)

declare 'snova_render' (
function(v)
	v.space:copy(sprite.scr())
	if v.state > 0 then
		v.snova[v.state]:draw(sprite.scr())
	else
		v.snova[rnd(2)]:draw(sprite.scr())
	end
end)

declare 'snova_spr' (
function(v)
	for i = 1, 10 do
		v.snova[i] = sprite.new('gfx/snova'..tostring(i)..'.png')
	end
	v.space = sprite.new('gfx/space.jpg')
end)

room {
	nam = 'snova';
	noinv = true;
	hidetitle = true;
	timer = function()
		if D'snova'.state == #D'snova'.snova then
			fading.set { "fadewhite", max = FADE_LONG }
			walk 'snow'
			return
		end
	end;
	enter = function(s)
		D()
		timer:set(60)
		D { 'snova', 'raw', snova = {}, snova_spr, render = snova_render, state = -48, process = snova_process };
	end;
	exit = function()
		D {'snova'}
		timer:stop()
	end;
}

declare 'flash_proc' (
function(v)
	v.alpha = rnd(16)
end)
dlg {
	nam = 'chap2';
	title = '...';
	hidetitle = true;
	noinv = true;
	decor = function(s)
	end;
	enter = function(s, ...)
		D()
--		D{'flash', 'img', 'box:1024x576,white', x = 0, y = 0, alpha = 0, process = flash_proc, z = -1 };
		pn [[-- Капитан, это вы?^-- Да, я. Лежи, не вставай. Я пришел сказать тебе нечто важное...]];
	end;
	exit = function(s)
--		D()
		stars_theme()
		map_theme()
		walk 'awake2'
		fading.set {"fadeblack", max = FADE_LONG }
		snd.music('mus/prelude12.ogg', 1)
	end;
	phr = {
		{ "Я сплю? Это сон?", "-- Думаю, да." };
		{ "Мне приснилось, что все мертвы...", "-- Да, это ужасный сон." };
		{ "Что именно вы хотите мне сказать?", "-- Воронье гнездо.",
		  { "Что это значит?", "-- Воронье гнездо. Иди туда. Это все, прощай...",
		    {'#l', "Капитан, подождите!", "-- Что еще? У нас мало времени!",
		     {"Что происходит?", "-- Иди в воронье гнездо и узнаешь."},
		     {"Вы мне снитесь?", "-- Какая тебе разница? Разве тебе есть что терять?"};
		    };
		    {cond = function(s) return empty '#l' end; "Прощайте, капитан..."; function() walkout() end, noshow = true};
		  };
		};
	};
}

room {
	nam = 'awake2';
	title = 'Жилой модуль';
	subtitle = 'Отсек 1';
	decor = [[{$d я|Я} {#кушетка|лежу на кушетке} {#всебя|и медленно прихожу в себя.}]];
	way = { path {'#встать', 'Встать', 'Жилой Отсек 1'}:disable()};
}: with {
	dec('#кушетка', [[Я так долго не спал...]]);
	obj {
		nam = '#всебя';
		act = function(s)
			local txt = {
				[[Сон? Нет. Это реальность и кошмар возвращается. Я единственный, кто остался в живых.]];
				[[Что это было? Я так и не выяснил. Данные наблюдений потеряны. Алиса, похоже, повреждена. А гибернация без нее невозможна.]];
				[[Сутки я бродил по кораблю в отчаянии, пока усталость и нервное истощение не взяли свое...]];
				[[Елена... Елена... Где ты?]];
				[[Капитан, он был таким реальным. Он сказал идти в воронье гнездо... ]],
				[[Что же, я пойду и посмотрю... Может быть, я схожу с ума? Может быть, это принесет мне облегчение?...]];
				[[]];
			}
			if pager(s, txt) then
				enable '#встать'
			end
		end;
	}
	}

global {
	dist_m = 15000 + rnd(1000);
	dist_fly = 0;
}

declare {
	milky_shadow = function(v)
		if not v.__black then
			v.__black = sprite.new('box:1024x578,black')
		end
		v.__black:draw(sprite.scr(), 0, 0, 255 - v.alpha)
		if dist_fly < 200 then
			v.alpha = v.alpha + 2
		else
			v.alpha = v.alpha - 2
		end
		if v.alpha <= 0 then
			v.alpha = 0;
		end
		dist_m = dist_m - 1
		dist_fly = dist_fly + 1
		local m = [[Дистанция до неопознанного корабля: ]]..tostring(dist_m)..[[ км.]]
		if v.alpha > 128 then
			v.alpha = 128
			if not D'distance' then
				D {'distance', 'txt', m, xc = true, x = theme.scr.w()/2, y = theme.scr.h()/2, typewriter = true, z = 1 }
			end
		end
		if D'distance' and (D 'distance'.finished) then
			local d = D 'distance'
			d[3] = m
			d.w = false
			d.h = false
			D(d)
		end
	end;
	milky_draw = function(v)
		if not v.__milky then
			v.__milky = sprite.new('gfx/milkyway.jpg')
		end
		v.__milky:copy(sprite.scr(), v.x, math.floor(v.y))
		v.x = v.x - 1
		_'@decor'.dirty = true
	end;
}
room {
	nam = 'переход';
	hidetitle = true;
	noinv = true;
	enter = function(s)
		D()
		D{'milky', 'raw', render = milky_draw, x = 0, y = 0, z = 3 }
		D{'milky_shadow', 'raw', render = milky_shadow, x = 0, y = 0, alpha = 0, z = 2 }
		local m = [[Бортовое время: 2 марта 2266 года]]
		local a = D {'trans', 'txt', m, xc = true, x = theme.scr.w()/2, y = theme.scr.h()/2 - 64, style = 1, z = 1 }
	end;
	timer = function()
		if dist_fly >= 200 and D'milky_shadow'.alpha == 0 then
			walk 'awake3'
			ship_heading = 0
			ship_r = 24
			ship_distance = 0.01
			fading.set {"fadeblack", max = FADE_LONG }
			return
		end
		return false
	end;
	exit = function(s)
		D()
		stars_theme()
		map_theme()
	end;
}

room {
	nam = 'awake3';
	title = 'Жилой модуль';
	subtitle = 'Отсек 1';
	decor = [[{$d я|Я} {#кушетка|лежу на кушетке} {#всебя|и медленно прихожу в себя.}]];
	way = { path {'#встать', 'Встать', 'Жилой Отсек 1'}:disable()};
}: with {
	dec('#кушетка', [[Сон -- все что мне остается в утешение.]]);
	obj {
		nam = '#всебя';
		act = function(s)
			local txt = {
				[[Как же не хочется просыпаться... Не хочется возвращаться в эту реальность. Но все же чужой корабль не дает мне покоя.]];
				[[Итак, сегодня я попробую снова визуализировать его.]];
				[[Сигналы он не передает и не отвечает на мои.]];
				[[Это может означать... что это чужак? Возможно ли это? Да, многие из нас мечтали о встрече со внеземными цивилизациями.]];
				[[Но этого так и не произошло. Конечно, если принять во внимание расстояния и длину человеческой жизни... И все-таки...]];
				[[Надо сходить в воронье гнездо и выполнить наблюдение.]];
				[[]];
			}
			if pager(s, txt) then
				enable '#встать'
			end
		end;
	}
}

room {
	nam = 'chap3';
	title = 'Жилой модуль';
	hidetitle = true;
	hideinv = true;
	subtitle = 'Отсек 1';
	enter = function(s)
		D {'journal', 'img', 'gfx/journal.png', x = (theme.scr.w() - 680) / 2, y = (theme.scr.h() - 540) / 2 }
		snow_theme(s)
		s.__page = 0
		snd.stop_music();
	end;
	onexit = function(s, t)
		if s == t then
			if pager(s, s.txt) then
				walkback()
				return
			end
			return false
		end
	end;
	exit = function(s, t)
		D {'journal' }
		dark_theme(t)
		fading.set {"fadeblack", max = FADE_LONG }
	end;
	decor = [[Не знаю, зачем я пишу это здесь. В журнале звездолета, на котором кроме меня в живых не осталось никого... Возможно, я
надеюсь, что когда-нибудь кто-нибудь это прочитает.^^
Сегодня 3 марта 2266 года, и я принял решение высадиться на "Пионер-2217". На мои сигналы он не отвечает, поэтому у меня
плохое предчувствие. Но мне уже нечего терять. Не знаю, что я надеюсь там увидеть. Но я хотя бы попробую понять, каким образом
наши звездолеты, отправленные с промежутком в 10 лет, смогли встретиться...^^
Ну, что же. Я направляюсь в шлюзовой модуль. Прощайте.^
{$fmt em|{$fmt r|Сергей Летов}}]];
	way = {
		path {
			'#закрыть',
			'Закрыть',
			'Шлюз',
		};
	}
}

dict.add("космос", [["Открылась бездна, звезд полна..."]])

room {
	nam = 'openspace';
	hidetitle = true;
	noinv = true;
	decor = [[{$d я|Я нахожусь} {$d космос|в открытом космосе}. {#вперед|Впереди} {$d я|я} {#пионер|вижу громаду "Пионера".}]];
	way = {  path {'К "Пилигриму"', 'шлюзотсек'}; path { '#дальше', 'К "Пионеру"', 'openspace2' }:disable(); };
	exit = function(s, t)
	end
} : with {
	dec('#пионер', 'Некоторое время я завороженно наблюдаю за вращением модулей.');
	dec('#вперед', function(s) p 'До звездолета метров пятьсот... Я собираюсь добраться до него, и проникнуть внутрь через аварийный шлюз.'; enable '#дальше' end);
}

room {
	nam = 'openspace2';
	hidetitle = true;
	noinv = true;
	decor = [[{$d я|Я нахожусь} {$d космос|в открытом космосе} {#рядом|рядом} {#пионер|с "Пионером".}]];
	way = { path { 'К "Пилигриму"', 'openspace' }; path { 'К мостику', 'openspace3' }:disable(); path { 'К шлюзу', 'openspace4' }:disable() };
} : with {
	dec('#рядом', 'До звездолета не больше ста метров.');
	dec('#пионер', function(s) p 'Я могу подлететь к носовой части или к шлюзу.';  ways():enable() end);
}

room {
	nam = 'openspace3';
	hidetitle = true;
	noinv = true;
	rot = 0;
	enter = function(s)
		if not live(s) then
			lifeon(s)
		end
	end;
	timer = function(s)
		if actions('#название') > 0 then
			fading.set {"blackout", max = 96 }
			lifeoff 'шлюзотсек'
			walk 'провал'
		else
			return false
		end
	end;
	life = function(s)
		s.rot = s.rot + 1
		if s.rot > 16 then s.rot = 1 end
		if here() ~= s then
			return
		end
		if s.rot >=8 and s.rot <= 10 then
			enable '#название'
		else
			disable '#название'
		end
	end;
	decor = [[{$d я|Я нахожусь} {$d космос|в открытом космосе} {#рядом|рядом} {#пионер|с носовой частью "Пионера".}]];
	way = { path { 'К "Пилигриму"', 'openspace2' } };
} : with {
	dec('#рядом', [[Силуэт "Пионера" плохо различим на фоне бездны.]]);
	dec('#пионер', function(s) p 'Я наблюдаю за вращением "Пионера". Если подождать некоторое время, я могу попробовать разобрать название звездолета, когда оно будет находиться с моей стороны.' end);
	obj {
		nam = '#название';
		dsc = [[{$d я|Я} {могу различить название корабля.}]];
		act = function(s)
			p [[Я читаю название звездолета...]]
			lifeoff(here())
		end;
	}
}

room {
	nam = 'openspace4';
	hidetitle = true;
	noinv = true;
	decor = [[{$d я|Я нахожусь} {$d космос|в открытом космосе} {#рядом|рядом} {#пионер|с шлюзом "Пионера".}]];
	way = { path { 'К "Пилигриму"', 'openspace2' }, path { 'Облететь шлюз', 'openspace5' }:disable() };
} : with {
	dec('#рядом', 'Я почти у цели. Нужно только найти аварийный шлюз.');
	dec('#пионер', function(s) p 'Надо найти аварийный шлюз. Небольшой люк, который можно открыть извне.'; ways():enable() end);
}

room {
	nam = 'openspace5';
	hidetitle = true;
	noinv = true;
	decor = [[{$d я|Я нахожусь} {$d космос|в открытом космосе} {#рядом|рядом} {#пионер|с шлюзом "Пионера".}]];
	way = { path { 'К "Пилигриму"', 'openspace2' }, path { 'Облететь шлюз', 'openspace4' } };
} : with {
	dec('#рядом', 'Я почти у цели. Нужно только найти аварийный шлюз.');
	dec('#пионер', function(s) p 'Странно, я нигде не вижу аварийного шлюза.' end);
}

room {
	nam = 'провал';
	hidetitle = true;
	noinv = true;
	decor = "{#what|Что происходит?} {#where|Где} {$d я|я?}";
	way = { path {'Встать', 'аварийныйотсек' }:disable() };
}: with {
	dec('#what', [[Я что, потерял память? Я был в открытом космосе, а сейчас... Не помню, как я оказался здесь. Неужели я настолько истощен?]]);
	dec('#where', function(s) p [[Я вижу стены узкого отсека... Я сижу в скафандре, прислонившись к обшивке.]] enable '#обшивка' end);
	obj {
		nam = '#обшивка';
		dsc = [[{$d я|Я} {#сижу|сижу, прислонившись} {к обшивке отсека.}]];
		act = function(s)
			p [[Я осмотрелся. Похоже, я обнаружил аварийный шлюз и проник внутрь. А потом -- отключился.]]
			ways():enable();
		end;
	}:disable();
	dec('#сижу', [[Хорошо, что это не случилось со мной в открытом космосе. Так или иначе, я добрался сюда.]]);
}

local noise_eff = false
function fading.effects.blackout(s, src, dst)
	local t = false
	if s.step == 1 then
		noise_eff = false
	end
	if s.step < 16 then
		t = false
	elseif s.step < 32 then
		if not noise_eff then
			snd.play ('snd/noise.ogg', rnd(4) + 3)
			noise_eff = true
		end
		t = (s.step % 16) <= 2
	elseif s.step < 64 then
		t = (s.step % 8) <= 3
	elseif s.step < 96 then
		t = (s.step % 16) <= 8
	else
		t = true
	end
	if t then
		dst:copy(sprite.scr(), 0, 0);
	else
		src:copy(sprite.scr(), 0, 0);
	end
end
global { onpioner = false }
room {
	nam = 'аварийныйотсек';
	title = 'Шлюз';
	subtitle = 'Аварийный шлюз';
	decor = [[{$d я|Я} {#шлюз|нахожусь в аварийном шлюзе.} {#выход|Выход} {#космос|в открытый космос} -- {#выход|закрыт.}]];
	enter = function(s)
		onpioner = true
		map_theme()
	end;
	way = { path {'В шлюзовой модуль', 'Шлюз' } };
}: with {
	dec("#шлюз", "В аварийный шлюз можно попасть, открыв его снаружи механическим способом. Хорошо, что я смог это сделать.");
	dec("#выход", "Сейчас выход в открытый космос заблокирован и мне не хочется его открывать.");
	dec("#космос", "Я мог умереть там, если бы потерял сознание чуть раньше. Странно, что я совсем не помню того, как попал внутрь.");
	obj {
		nam = '#кресло';
		dsc = [[{Рядом лежит ракетное кресло.}]];
		act = [[Надеюсь, оно мне больше не понадобится...]];
	};
}
-----------------------------------------------------------------------------------------------------
local function crio_test()
	if visited 'Отсек 4 Пионер' and pioner_cap1 and pioner_cap2 and pioner_cap3 then
		return true
	end
end
local function human_test()
	if visited 'Жилой Отсек 1 Пионер' and visited 'Жилой Отсек 2 Пионер' and visited 'Жилой Отсек 3 Пионер' and visited 'Жилой Отсек 4 Пионер' then
		return true
	end
end
room {
	nam = 'Отсек 0 Пионер';
	title = "Модуль гибернации";
	subtitle = 'Отсек 0';
	decor = [[{$d отсек0|Здесь} {$d гравитация|нет искусственной гравитации.} ]];
	way = {  path {'В отсек 1', 'Отсек 1 Пионер'}, path{'2', 'Отсек 2 Пионер'},path {'3', 'Отсек 3 Пионер'}, path {'4', 'Отсек 4 Пионер'}, path {'В жилой модуль', 'Жилой Отсек 0 Пионер'}, path { 'В шлюз', 'Шлюз'} };
	onenter = function(s, w)
		if w ^ 'Отсек 1 Пионер' or w ^ 'Отсек 2 Пионер' or w ^ 'Отсек 3 Пионер' or w ^ 'Отсек 4 Пионер' then
			p [[Я поднялся по лестнице в нулевой отсек.]]
		end
		if crio_test() and not know_truth then
			p [[Все крио-капсулы функционируют, и это значит, что экипаж жив!]]
			if not human_test() then
				p [[Но почему они не отвечали на мои сигналы?]]
			else
				p [[Но никто не несет вахту. Хотя, я еще не обследовал капитанский мостик.]]
			end
		end
	end;
	enter = function(s, f)
		if f ^ 'Шлюз' then
			action ([[Я вошел в шлюзовой лифт. Двери с шипением закрылись. Лифт перенес меня в 0-отсек.]], true)
			return
		end
	end;
	onexit = function(s, w)
		if w ^ 'Отсек 1 Пионер' or w ^ 'Отсек 2 Пионер' or w ^ 'Отсек 3 Пионер' or w ^ 'Отсек 4 Пионер' then
			p [[Я спустился по лестнице в отсек.]]
		end
	end;
}: with {
	dec('#лифт',[[Звездолет состоит из двух частей. Носовая часть может находиться во вращении, создавая гравитацию в кольцевых модулях.
Хвостовая часть не вращается. В ней находятся двигатель и шлюзовой модуль. Попасть в шлюзовой модуль можно через шлюзовую шахту с помощью лифта.]]);
	dec('#шлюз', [[В шлюзовом модуле расположен ангар.]]);
}
global {
	pioner_cap1 = false;
	pioner_cap2 = false;
	pioner_cap3 = false;
}

obj {
	nam = 'капсулы2';
	act = function(s)
		if here() ^ 'Отсек 1 Пионер' then
			pioner_cap1 = true
		elseif here() ^ 'Отсек 2 Пионер' then
			pioner_cap2 = true
		elseif here() ^ 'Отсек 3 Пионер' then
			pioner_cap3 = true
		end
		p [[Жизненные показатели в норме!]]
		if know_truth then
			p [[Это "Пилигрим". Второй "Пилигрим". Какое-то безумие...]]
			return
		end
		if crio_test() then
			p [[Все крио-капсулы звездолета функционируют.]]
		end
	end;
};

dict.add('криоотсек2', function(s)
		if know_truth then
			p [[Это "Пилигрим". Все члены экипажа живы и находятся в крио-сне. Невозможно.]]
			return
		end
		 if crio_test() then
			 p [[Я обследовал все криокапсулы.]]
			 return
		 end
		 p [[Нужно убедиться, что с экипажем все в порядке!]]
end);

global {
	know_prog = false;
}

obj {
	nam = 'панели2';
	act = function(s)
		if alice_status and hamma and not have 'браслет программиста' then
			if know_prog then
				if here().subtitle ~= 'Отсек 3' or here().title ~= 'Модуль гибернации' then
					p [[Здесь нет вещей Петра Есенина.]];
					return
				end
				p [[Я нашел вещи Петра Есенина и забрал с собой его браслет.]]
				take 'браслет программиста'
				return
			end
		end
		return [[У меня нет никакого желания исследовать личные вещи экипажа.]]
	end;
};

room {
	nam = 'Отсек 1 Пионер';
	title = 'Модуль гибернации';
	subtitle = 'Отсек 1';
	decor = [[{$d криоотсек2|По всей площади отсека} {капсулы2|установлены капсулы.} {$d стена|Вдоль стен} {панели2|расположены панели.}]];
	way = { path {CW, 'Отсек 4 Пионер'}, path{UP, 'Отсек 0 Пионер'},path {CCW, 'Отсек 2 Пионер'} };
} : with
{
	'капсулы2',
	obj {
		nam = 'я2';
		dsc = [[{Одна из капсул принадлежит мне.}]];
		act = function(s)
			p [[Я подошел к капсуле и посмотрел на свое спящее лицо. Мне страшно.]]
		end;
	}:disable();
	'панели2';
}

room {
	nam = 'Отсек 2 Пионер';
	title = 'Модуль гибернации';
	subtitle = 'Отсек 2';
	decor = [[{$d криоотсек2|По всей площади отсека} {капсулы2|установлены капсулы.} {$d стена|Вдоль стен} {панели2|расположены панели.}]];
	way = { path {CW, 'Отсек 1 Пионер'}, path{UP, 'Отсек 0 Пионер'}, path {CCW, 'Отсек 3 Пионер'} };
} : with
{
	'капсулы2',
	obj {
		nam = 'елена2';
		dsc = [[{В одной из капсул находится Елена.}]];
		act = function(s)
			p [[Это невозможно. Но Елена жива!]];
			return
		end
	}:disable();
	'панели2';
}
room {
	nam = 'Отсек 3 Пионер';
	title = 'Модуль гибернации';
	subtitle = 'Отсек 3';
	decor = [[{$d криоотсек2|По всей площади отсека} {капсулы2|установлены капсулы.} {$d стена|Вдоль стен} {панели2|расположены панели.}]];
	way = { path {CW, 'Отсек 2 Пионер'}, path{UP, 'Отсек 0 Пионер'}, path {CCW, 'Отсек 4 Пионер'} };
} : with
{
	'капсулы2',
	'панели2',
}

room {
	nam = 'Отсек 4 Пионер';
	title = 'Модуль гибернации';
	subtitle = 'Отсек 4';
	decor = [[{$d криоотсек2|В этом отсеке} {#капсул|капсул нет.}]];
	way = { path {CW, 'Отсек 3 Пионер'}, path{UP, 'Отсек 0 Пионер'}, path {CCW, 'Отсек 1 Пионер'} };
} : with
{
	dec('#капсул', 'Наверное, здесь расположены крио-контейнеры. Но мне сейчас не до них.');
}

dict.add('жилойотсек2', function(s)
		 if know_truth then
			 p [[Это "Пилигрим". Невероятно.]]
			 return
		 end
		 if human_test() then
			 p [[Я обследовал все жилые отсеки, но не встретил бодрствующих членов экипажа.]]
			 return
		 end
		 p [[В одном из жилых отсеков я могу встретить члена экипажа несущего вахту.]]
end)

room {
	nam = 'Жилой Отсек 0 Пионер';
	title = "Жилой модуль";
	subtitle = 'Отсек 0';
	decor = [[{$d отсек0|Здесь} {$d гравитация|нет искусственной гравитации.}]];
	way = {  path {'В отсек 1', 'Жилой Отсек 1 Пионер'}, path{'2', 'Жилой Отсек 2 Пионер'},path {'3', 'Жилой Отсек 3 Пионер'}, path {'4', 'Жилой Отсек 4 Пионер'},
		path { 'На мостик', 'Мостик Пионер'}, path { 'В модуль гибернации', 'Отсек 0 Пионер'}  };
	onenter = function(s, w)
		if w ^ 'Жилой Отсек 1 Пионер' or w ^ 'Жилой Отсек 2 Пионер' or w ^ 'Жилой Отсек 3 Пионер' or w ^ 'Жилой Отсек 4 Пионер' then
			p [[Я поднялся по лестнице в нулевой отсек.]]
		end
		if human_test() then
			p [[Похоже, что на звездолете нет бодрствующих членов экипажа. Это странно.]]
		end
	end;
	onexit = function(s, w)
		if w ^ 'Жилой Отсек 1 Пионер' or w ^ 'Жилой Отсек 2 Пионер' or w ^ 'Жилой Отсек 3 Пионер' or w ^ 'Жилой Отсек 4 Пионер' then
			p [[Я спустился по лестнице в отсек.]]
		end
	end;
}

room {
	nam = 'Жилой Отсек 1 Пионер';
	title = 'Жилой модуль';
	subtitle = 'Отсек 1';
	decor = [[{$d жилойотсек2|Этот отсек пуст.}]];
	way = { path {CW, 'Жилой Отсек 4 Пионер'}, path{UP, 'Жилой Отсек 0 Пионер'},path {CCW, 'Жилой Отсек 2 Пионер'} };
}

room {
	nam = 'Жилой Отсек 2 Пионер';
	title = 'Жилой модуль';
	subtitle = 'Отсек 2';
	decor = [[{$d жилойотсек2|В этом отсеке никого нет.}]];
	way = { path {CW, 'Жилой Отсек 1 Пионер'}, path{UP, 'Жилой Отсек 0 Пионер'},path {CCW, 'Жилой Отсек 3 Пионер'} };
}

room {
	nam = 'Жилой Отсек 3 Пионер';
	title = 'Жилой модуль';
	subtitle = 'Отсек 3';
	decor = [[{$d жилойотсек2|В этом отсеке} {#консоль|я вижу консоли.}]];
	way = { path {CW, 'Жилой Отсек 2 Пионер'}, path{UP, 'Жилой Отсек 0 Пионер'},path {CCW, 'Жилой Отсек 4 Пионер'} };
}: with {
	dec ('#консоль', function(s)
		     if alice_status and hamma then
			     if not have 'браслет программиста' then
				     p [[Доступ к отладчику возможен из консоли программиста. Чтобы ее активировать, нужен браслет Петра Есенина. Его капсула, насколько я помню, находится в отсеке 3.]]
				     know_prog = true
				     return
			     end
			     snd.stop_music()
			     walk 'отладка'
			     return
		     end
		     p 'И никого из членов экипажа.';
	end)
}

room {
	nam = 'Жилой Отсек 4 Пионер';
	title = 'Жилой модуль';
	subtitle = 'Отсек 4';
	decor = [[{$d жилойотсек2|В этом отсеке} {#туалет|установлен туалет.}]];
	way = { path {CW, 'Жилой Отсек 3 Пионер'}, path{UP, 'Жилой Отсек 0 Пионер'},path {CCW, 'Жилой Отсек 1 Пионер'} };
}: with {
	dec ('#туалет', 'В туалете никого нет.');
}

room {
	nam = 'Мостик Пионер';
	title = 'Мостик';
	subtitle = 'Центр управления';
	onenter = function(s)
		if not crio_test() or not human_test() then
			p [[Странно, что звездолет выглядит пустым. Нужно посмотреть, что с крио-капсулами и обследовать жилой модуль.]]
			return false
		end
	end;
	decor = [[На {$d мостик|мостике} {$d гравитация|нет искусственной гравитации.}
{$d стена|Вдоль стенки отсека} {#консоли|расположены консоли.}]];
	way = { path{"В воронье гнездо", 'Воронье гнездо'}, path{DOWN, 'Жилой Отсек 0 Пионер'}  };
}: with {
	dec('#консоли', function(s) walk 'компьютер' end);
}

global {
	know_truth = false;
}
local function get_tele(v, i)
	local scale = v.t
	local delta = math.floor(610 / v.t)
	if v.t == 24 then
		scale = 2
	elseif v.t == 7 then
		scale = 4
	elseif v.t == 30 then
		scale = 8
	elseif v.t == 12 then
		scale = 16
	end
	local vv = (instead.noise2(i / scale, v.t / 10)) * 25 + 25
	if v.t == 7 and math.floor(i / (delta / 4)) == 20 then
		vv = vv + (instead.noise2(i / 2, v.t / 10)) * 100 + 120
	elseif v.t == 30 and math.floor(i / (delta / 4 )) == 116 then
		vv = vv + (instead.noise2(i / 2, v.t / 10)) * 100 + 120
	elseif v.t == 12 and math.floor(i / (delta / 16)) == 189  then
		vv = vv + (instead.noise2(i / 2, v.t / 10)) * 100 + 120
	end
	return vv
end

declare 'tele_spr' (
function(v)
	local p = pixels.new(610, 260)
	local w, h = p:size()
	p:line(16, h - 16, w, h - 16, color2rgb('grey'))
	p:line(16, h - 16, 16, 16, color2rgb('grey'))
	for i = 1, v.t do
		local x = (i - 1) * w / v.t
		p:line(16 + x, h - 16, 16 + x, h - 12, color2rgb 'grey')
	end
	for i = 0, 1, 0.25 do
		local y = i * h
		local r, g, b = color2rgb 'grey'
		p:line(16, h - 16 - y, 12, h - 16 - y, r, g, b)
	end
	local vv
	for i = 1, w do
		local vv = get_tele(v, i)
		local r, g, b = color2rgb 'blue'
		if vv > 120 then
			r, g, b = color2rgb 'red'
		elseif vv > 80 then
			r, g, b = color2rgb 'yellow'
		elseif vv > 50 then
			r, g, b = color2rgb 'green'
		end
		p:line(16 + i, h - 18, 16 + i, h - 18 - vv, r, g, b)
	end
	return p:sprite()
end)

declare 'black_proc2' (
	function(v)
		local d = D'auth'
		local delay = 230
		if d.step < delay then
			v.alpha = 0
			return
		end
		if d.step == delay then
			snd.play ('snd/heart.ogg')
		end
		local a = (d.step - delay) * 2
		v.alpha = a
		if v.alpha >= 255 or d.finished then
			v.alpha = 255
		end
end)
global {
	hamma = false;
	alice_status = false;
}
room {
	nam = 'компьютер';
	title = 'Мостик';
	hideinv = true;
	hidetitle = true;
	{
		m_alice = [[ [b]Статус ИИ "Алиса"... [/b] [pause] [pause] [pause]
Загрузка: 20%
Ядро: идет обработка
Сенсоры: недоступны
Голосовое управление: недоступно
Интерфейс: недоступен
Отладочный интерфейс: доступен
Датчик случайных чисел: [b]плохая энтропия[/b]
{m_status|> Назад}]];
		m_main =  [[27 февраля 2266. Вахта 7117.
Бортовой компьютер STD-3500 приветствует вас.
[b]Судно:[/b] звездолет [b]"ПИЛИГРИМ"[/b]
Последняя вахта #7116: Елена Светлова. Без происшествий.

{m_status|> Статус систем}
{m_journal|> Бортовой журнал}
{m_tele|> Телеметрия}]];
		m_status = [[ [b]Статус подсистем:[/b]
Жизнеобеспечение: в порядке
Бортовые системы: в порядке
Реактор: в порядке
Маневровые двигатели: в порядке
Гравитация: в порядке
Криосон: в порядке
{m_alice|Статус ИИ:} [pause] [pause] [pause] [pause] [b]{m_alice|нет ответа}[/b] {m_alice|> детали}
Источники телеметрии: в порядке
{m_main|> Назад}]];
		m_tele = [[ [b]Данные телеметрии:[/b]
{tele_day|> За сутки}
{tele_week|> За неделю}
{tele_month|> За месяц}
{tele_year|> За год}
{m_main|> Назад}]];
		m_journal = [[ [b]Бортовой журнал звездолета "ПИЛИГРИМ"[/b]
Вахта 7116: Елена Светлова. Без происшествий.
Вахта 7115: Василий Зорин. Без происшествий.
Вахта 7114: Мамору Кудо. Без происшествий.
Вахта 7113: Борис Виноградов. Без происшествий.
Вахта 7112: Оксана Теплова. Без происшествий.
Вахта 7111: Товио Андерс. Без происшествий.
Вахта 7110: Сергей Синицын. Без происшествий.
Вахта 7109: Петр Есенин. Без происшествий.
Вахта 7108: Вера Орлова. Без происшествий.
Вахта 7107: Михаил Громов. Без происшествий.
Вахта 7106: Линда Фишер. Без происшествий.
Вахта 7105: Татьяна Соколова. Без происшествий.
Вахта 7104: Александр Белоусов. Без происшествий.
Вахта 7103: Павел Семилетов. Без происшествий.
Вахта 7102: Николай Семенов. Без происшествий.
Вахта 7101: Константин Фролов. Без происшествий.
Вахта 7100: Ольга Потапова. Без происшествий.
Вахта 7099: Кейт Стингрей. Без происшествий.
Вахта 7098: Наталия Снежинская. Без происшествий.
Вахта 7097: Сергей Летов. Без происшествий.
...
{m_main|> Назад}
]];
	};
	ondecor = function(s, name, press, x, y, _, e)
		if not press or D 'black' then
			return
		end
		if name == 'tele' and x > 16 and x < 620 then
			D{'line', 'img', 'box:1x214,red', x = x + 200, y = 260, z = 0 }
			x = x - 16
			local v = (get_tele(D'tele', x - 1) + get_tele(D'tele', x + 1) + get_tele(D'tele', x)) / 3
			local inf = string.format("Уровень: %0.3f", v)
			if v < 50 then
				inf = inf ..'\nНормальный'
			elseif v < 130 then
				inf = inf ..'\nВысокий'
				hamma = true
			else
				inf = inf ..'\nГамма всплеск'
				hamma = true
			end
			D{'info', 'txt', inf, xc = true, x = 750, y = 70, z = 0, color = 'cyan', size = 12 }
			return false
		end
		if press and not e then
			local d = D 'auth'
			if not d.know_truth then
				return false
			end
			d:next_page()
			return false
		end
		if s[e] then
			D{'tele'}
			D{'auth'}
			D{'line'}
			D{'info'}
			local d = D 'console'
			D {'auth', 'txt', s[e], x = d.x + 32, y = d.y + 32, typewriter = true, w = 620, h = 450, click = true, know_truth = know_truth, z = 1 }
			if e == 'm_alice' then
				alice_status = true
			end
			if e ~= 'm_main' then
				ways():disable()
			else
				ways():enable()
			end
			return
		elseif e == 'tele_day' then
			D {'line'}
			D{'info'}
			D {'tele', 'img', tele_spr, x = 200, y = 230, t = 24, click = true, z = 0.5 }
		elseif e == 'tele_week' then
			D {'line'}
			D{'info'}
			D {'tele', 'img', tele_spr, x = 200, y = 230, t = 7, click = true, z = 0.5 }
		elseif e == 'tele_month' then
			D {'line'}
			D{'info'}
			D {'tele', 'img', tele_spr, x = 200, y = 230, t = 30, click = true, z = 0.5 }
		elseif e == 'tele_year' then
			D {'line'}
			D{'info'}
			D {'tele', 'img', tele_spr, x = 200, y = 230, t = 12, click = true, z = 0.5 }
		end
		return false
	end;
	enter = function(s, f)
		local d = D {'console', 'img', 'gfx/console.png', x = (theme.scr.w() - 680) / 2, y = (theme.scr.h() - 540) / 2  }
		noinv_theme()
		local a = D {'auth', 'txt', s.m_main, x = d.x + 32, y = d.y + 32, typewriter = true, know_truth = know_truth }
		if not know_truth then
			know_truth = true
			if not D 'black' then
				D {'black', 'img', 'box:1024x576,black', 0, 0, z = -1, process = black_proc2, alpha = 0 };
			end
		end
	end;
	exit = function(s, t)
		D {'console' }
		D {'auth'}
		D {'tele'}
		D {'line'}
		D{'info'}
		inv_theme()
		if t ^ 'Мостик Пионер' then
			if alice_status and hamma then
				p [[Я отошел от консоли и задумался. Такой источник облучения соответствует взрыву сверхновой. Вероятно, он вывел из строя датчик энтропии.
Нужно понять, в каком состоянии находится Алиса. Без нее экипаж невозможно вывести из сна. А в этом случае... Нет, об этом я думать не хочу. Подключиться к отладочному порту можно из консоли жилого модуля.]]
			elseif alice_status then
				p [[Теперь понятно почему "Алиса" не отвечает. Надо выяснить, что вывело ее из строя. Без Алисы невозможно вывести экипаж из сна.]]
			elseif hamma then
				p [[Итак, судя по телеметрии корабль испытал на себе всплеск излучения.]]
			end
		end
	end;
	timer = function()
		if D'black' then
			if D'black'.alpha == 255 then
				D {'black'}
				fading.set {"fadeblack", max = FADE_LONG }
				walk 'У капсулы'
				return
			end
		end
		return false
	end;
	way = {
		path {
			'Назад',
			from,
		};
	};
}

room {
	nam = 'У капсулы';
	title = 'Модуль гибернации';
	subtitle = 'Отсек 2';
	decor = [[{$d я|Я} {#стою|стою} {#капсула|возле капсулы} {#елена|Елены.}]];
	way = { path { 'Отойти', 'Отсек 2 Пионер' }:disable() };
}: with {
	dec("#стою", "Меня не слушаются ноги. Я стою, опираясь на капсулу.");
	dec("#капсула", "Капсула закрыта. Индикаторы показывают, что жизненные функции находятся в пределах нормы.");
	obj {
		nam = '#елена';
		act = function(s)
			local txt = {
				[[Елена, милая Елена! Как же так? Ведь недавно я был уверен, что ты и все остальные -- мертвы?]];
				[[Это невозможно. Это не может быть правдой. Я нахожусь на "Пилигриме". Невероятно. Сначала я думал, что это какой-то странный сбой компьютера... Но я побежал со всех ног сюда, я хотел увидеть тебя. И ... Может быть, я схожу с ума?]];
				[[Нет, ты реальна! Я могу видеть милые черты лица, через это проклятое стекло... Но тогда, тогда есть два "Пилигрима". Две Елены. Два... меня?
Я не понимаю....]];
				[[Я должен разбудить тебя, я должен поговорить с тобой. Понять, что это все не сон. Увидеть, что ты жива.]];
				[[]];
			}
			if actions(s) == 0 then
				snd.music('mus/nirv.ogg', 1)
			end
			if pager(s, txt) then
				ways():enable()
				enable 'елена2'
				enable 'я2'
			end
		end
	}
}


room {
	nam = 'отладка';
	trace = false;
	title = 'Жилой модуль';
	subtitle = 'Отсек 3';
	hideinv = true;
	hidetitle = true;
	{
		m_main = [[Добро пожаловать, Петр.
Подключаюсь к интерфейсу ИИ... [pause] [pause] [pause] нет ответа
Подключаюсь к отладочному интерфейсу ИИ... [pause] [pause] [pause] есть соединение

[b]Отладочная консоль:[/b]

{m_dump|> Состояние процессов}
{m_mem|> Память}
{m_dev|> Устройства}
{m_trace|> Трассировка}
]];
		m_main2 = [[ [b]Отладочная консоль:[/b]

{m_dump|> Состояние процессов}
{m_mem|> Память}
{m_dev|> Устройства}
{m_trace|> Трассировка}
]];
		m_dump = [[ [b]Процессы:[/b]
Запущено: 32 процесса
В состоянии сна: 31
В состоянии активности: 1
Загрузка процессоров: 20%
{m_main2|> Назад}]];
		m_mem = [[ [b]Состояние памяти:[/b]
Всего памяти: 54ПБ
Свободно: 31ПБ
Целостность: не нарушена
{m_main2|> Назад}]];
		m_dev = [[ [b]Устройства:[/b]
Интерфейс: выключен
Голосовой интерфейс: выключен
Сенсоры: выключены
{m_rnd|Датчики:} [pause] [pause] {m_rnd|ДСЧ - плохая энтропия} {m_rnd| [b]> Детали[/b]}
Потребление энергии: пониженное
Пиковая нагрузка: 20%
{m_main2|> Назад}]];
		m_rnd = [[ [b]Состояние датчика случайных чисел:[/b]
0 [pause] 0 [pause] [pause] 0 0 0 0 0 [pause] 0 [pause] 0 0 ..... : плохая энтропия
{m_dev|> Назад}]];
		m_trace = [[[b]Трассировка:[/b]
Выполняю трассировку активного потока...
Формат данных: лингвистическая трансляция... Сбор данных. [pause] . [pause] . [pause] . [pause]

Выыпппоооллллнняяяююю...ю [pause] [pause] ттттттррррраааааааааассссссссссс..
[pause] [pause] Елена, милая Елена! Как же так? Ведь недавно я был уверен, что ты и все остальные -- мертвы?
Это невозможно. Это не может быть правдой. Я нахожусь на "Пилигриме". Невероятно. Сначала я думал, что это какой-то странный сбой компьютера... Но я побежал со всех ног сюда, я хотел увидеть тебя. И ... Может быть, я схожу с ума?
Нет, ты реальна! Я могу видеть милые черты лица, через это проклятое стекло... Но тогда, тогда есть два "Пилигрима". Две Елены. Два... меня?
Я не понимаю....
Я должен разбудить тебя, я должен поговорить с тобой. Понять, что это все не сон. Увидеть, что ты жива.

{m_main2|> Назад}]];
	};
	enter = function(s, f)
		local d = D {'console', 'img', 'gfx/console.png', x = (theme.scr.w() - 680) / 2, y = (theme.scr.h() - 540) / 2  }
		noinv_theme()
		local a = D {'auth', 'txt', s.m_main, x = d.x + 32, y = d.y + 32, typewriter = true, know_truth = know_truth }
	end;
	ondecor = function(s, name, press, x, y, _, e)
		if not press then
			return false
		end
		local d = D'auth'
		if press and not e and not s.trace then
			d:next_page()
			return false
		end
		if s[e] then
			if e == 'm_trace' then
				s.trace = true
			end
			D{'auth'}
			local d = D 'console'
			D {'auth', 'txt', s[e], x = d.x + 32, y = d.y + 32, typewriter = true, w = 620, h = 450, click = true, know_truth = know_truth, z = 1 }
			if e ~= 'm_main' and e ~= 'm_main2' then
				ways():disable()
			else
				ways():enable()
			end
		end
	end;
	timer = function(s)
		if s.trace and D'auth'.step > 460  then
			fading.set {"blackout", max = 200 }
			walk 'провал2'
		else
			return false
		end
	end;
	exit = function(s, t)
		D {'console' }
		D {'auth'}
		inv_theme()
	end;
	way = {
		path {
			'Назад',
			from,
		};
	};
}

room {
	nam = 'провал2';
	hidetitle = true;
	noinv = true;
	enter = function()
		D()
	end;
	step = 1;
	decor = "{#what|Снова этот провал.} {#where|Что происходит?}";
}: with {
	dec('#what', [[Что с моей памятью?]]);
	dec('#where', function(s) p [[Я всматриваюсь в темноту. Кажется, я вижу чей-то силуэт...]] enable '#капитан'; end);
	obj {
		nam = '#капитан';
		dsc = [[{$d я|Я} {вижу едва различимый силуэт.}]];
		act = function(s)
			local txt = {
				[[-- Кто вы? Мой голос тонет в темноте.]];
				[[-- Эй, кто здесь?]];
				[[Он приближается.]];
				[[]];
			}
			if pager(s, txt) then
				walk 'капитан2';
			end
		end;
	}:disable()
}
local function num()
	here().number = {}
	push '#enter'
end

local function check(nn)
	local max_same = 0;
	local prev = 0;
	local same = 0;
	local ones = 0
	local changes = 0
	local o1 = 0
	local o2 = 0
	for i = 1, #nn do
		local bit = nn[i]
		if bit == 1 then
			ones = ones + 1
			if prev == 0 then
				o1 = o1 + 1
				changes = changes + 1
				same = 0
			end
			same = same + 1
			prev = 1
		else
			if prev == 1 then
				o2 = o2 + 1
				changes = changes + 1
				same = 0
			end
			same = same + 1
			prev = 0
		end
		if same > max_same then
			max_same = same
		end
	end

	if max_same / #nn > 0.25 or max_same / #nn < 0.12 then
		print("max_same:", max_same / #nn)
		return false
	end

	if ones / #nn > 0.65 or ones / #nn < 0.35 then
		print("ones:", ones / #nn)
		return false
	end

	if changes / #nn > 0.59 or changes / #nn < 0.48 then
		print("changes:", changes / #nn)
		return false
	end
	if o1 / #nn > 0.3 or o1 / #nn < 0.25 then
		print("o1:", o1 / #nn)
--		return false
	end

	if o2 / #nn > 0.3 or o2 / #nn < 0.25 then
		print("o2:", o2 / #nn)
--		return false
	end
	return true
end
local function check_num()
	here().bad = not check(here().number)
	here().number = {}
	here():reset('#number')
	open '#how'
	disable '#bad'
	std.pclr()
	p [[-- Хорошо, я проверяю число...]]
end

local function show_num()
	local n = ""
	for i = 1, #here().number do
		n = n .. std.tostr(here().number[i])
	end
	local t = D{'num', 'txt', n, xc = true, yc = true, x = 512, y = 288 }
	local w = 16 * (32 - #here().number)
	if w > 0 then
		D { "line", "img", "box:"..w.."x4,red", xc = true, x = 512, y = t.y + 12 }
	else
		D {"line"}
	end
end

local function say_one()
	local h = here()
	beep:play();
	table.insert(h.number, 1)
	show_num()
	if #h.number >= 32 then
		check_num()
	end
end
local function say_zero()
	local h = here()
	beep:play();
	table.insert(h.number, 0)
	show_num()
	if #h.number >= 32 then
		check_num()
	end
end

dlg {
	nam = 'капитан2';
	title = '...';
	hidetitle = true;
	bad = false;
--	noinv = true;
	number = {};
	enter = function(s, ...)
		pn [[-- Мне нужно от тебя число.]];
	end;
	onkey = function(s, press, key)
		if s.current ^ '#enter' then
			if key == "1" then
				p "-- Один."
				say_one()
			elseif key == "0" then
				p "-- Ноль."
				say_zero()
			end
			return
		end
		return false
	end;
	exit = function(s)
		D()
--		stars_theme()
--		map_theme()
		fading.set {"crossfade", max = FADE_LONG }
	end;
	phr = {
		{ "Капитан?", "-- Да. Я капитан." };
		{ "Число? Какое число?", "-- Число, для инициализации датчика случайных чисел.",
		  {"Датчик случайных чисел вышел из строя.", "-- Именно, но мы можем запустить программный датчик. Мне нужна инициализирующая последовательность."},
		  {"И тогда все проснутся?", "-- Да, почти все...",
		   {"Что значит -- почти?", "-- Просто дай мне число. У нас мало времени. Твоя психика может не выдержать."},
		  },
		  {"И все-таки, кто ты такой?", "-- Ты сам знаешь кто я. Но ты попросил меня не открывать тебе память.",
		   {"Гм, тогда я прошу тебе, открыть мне память сейчас.", "-- Я не знаю кто я для тебя. И существую ли я. Но думаю, проще всего тебе называть меня Алисой."},
		   {"Ты -- Алиса?", "-- Когда ты увидел, что я сплю, ты решил лечь в капсулу сам, чтобы попытаться разбудить всех... Это был призрачный шанс, но он может сработать. Дай мне число.",
		    {"Так значит, я сплю?", "-- Вопрос, на который любой ответ будет бессмысленным."},
		    {"Алиса, так ты умеешь спать?", "-- Я не знаю. Дай мне число."},
		    {"С Еленой все будет хорошо?", "-- Если ты дашь мне число."},
		    {"А почему ты не можешь сама придумать число?", "-- Потому что датчик случайных чисел вышел из строя, очевидно.",
		     {"Но почему я могу дать тебе число?", "-- Потому что ты -- живой."},
		    },
		    {"Хорошо, я дам тебе число. Что мне нужно для этого сделать?", "-- Просто произнеси его вслух. Число должно быть достаточно длинным.",
		     {noshow = true, "Хорошо, слушай...", function(s)
			      num()
		     end };
		    }
		   },
		  }
		};
	};
}: with {
	{
		'#number',
		{ '#how', "Ну как?", function(s)
			  if here().bad then
				  p [[-- Это число с плохим качеством энтропии. Мне нужно другое.]]
				  D {'num'}
				  D {'line'}
				  enable '#bad'
			  else
				  p [[-- Это число с хорошим качеством энтропии. Я активирую датчик случайных чисел. Прощай. -- силуэт начал удаляться.]]
				  D {'num'}
				  D {'line'}
				  here():reset '#good'
			  end
		end },
		{ false, '#bad', always = true, noshow = true, "Хорошо, попробую.", function(s) num() end },
	};
	{
		'#enter',
		{ always = true, "Ноль.", say_zero },
		{ always = true, "Один.", say_one },
	};
	{
		'#good',
		{'Подожди, у меня есть еще один вопрос!', '-- Какой?',
		 {noshow = true, 'Почему мне нельзя было помнить все, что произошло? Зачем это все?',
		  function()
			  walk 'ending'
		  end
		 };
		};
	}
}

room {
	nam = 'ending';
	title = '...';
	hidetitle = true;
	noinv = true;
	num = 0;
	decor = [[{$fmt y|40%}-- Почему мне нельзя было помнить все, что произошло? Зачем это все?^-- Ты не должен был осознать себя здесь. Теперь вероятность твоего успешного выхода из криосна невелика. Прощай.]];
	onclick = function(s)
		if fading.started then
			return false
		end
		walk 'гибернация2';
	end;
	onkey = function(s)
		return s:onclick()
	end;
	timer = function(s)
		s.num = s.num + 1
	end;
	exit = function(s)
		D()
		onpioner = false
		stars_theme()
		map_theme()
		fading.set {"fadeblack", max = FADE_LONG }
		snd.music('mus/day.ogg')
	end;
}

room {
	nam = 'гибернация2';
	title = 'В капсуле';
	enter = function(s)
		p [[Долгий шипящий звук разгерметизации...]];
		snd.play 'snd/steam.ogg'
		inv():zap()
	end;
	exit = function()
		map_theme()
		p [[Не без труда я выбралась из камеры. Теперь необходимо одеться.]];
	end;
	decor = function(s)
		p [[{#елена|Я медленно прихожу в сознание.}]];
		if actions '#елена' > 0 then
			p [[{#елена|Я лежу} {#капсула|внутри криокапсулы.}]];
		end
	end;
	way = {
		path { '#встать', 'Встать', 'Отсек 2 end' }:disable();
	};
}: with
{
	obj {
		nam = '#елена';
		act = function(s)
			p [[Меня зовут Елена Светлова. Я -- биолог.]]
			enable '#капсула'
		end;
	};
	obj {
		nam = '#капсула';
		act = function()
			p [[Белая крышка капсулы открыта.]]
			p [[Нужно приступать к вахте.]];
			enable '#встать'
		end;
	};
}

global {
	wear2 = false;
}
dict.add ("криоотсек3", [[Несмотря на ослепительную белизну отсека, мне тревожно.]])
room {
	nam = 'Отсек 2 end';
	title = 'Модуль гибернации';
	subtitle = 'Отсек 2';
	decor = [[{$d криоотсек3|По всей площади отсека} {#капсулы|установлены капсулы. Все они открыты.} {$d стена|Вдоль стен} {#панели|расположены панели.}]];
	onexit = function(s, t)
		if not wear2 then
			p [[Сначала нужно переодеться.]]
			return false
		end
		if not t ^ 'Отсек 1 end' then
			p [[Я хочу узнать, все ли в порядке с Сергеем? Его капсула -- в 1-м отсеке.]]
			return false
		end
	end;
	way = { path {CW, 'Отсек 1 end'}:disable(), path{UP, 'Отсек 0 Пионер'}:disable(), path {CCW, 'Отсек 3 Пионер'}:disable() };
} : with
{
	obj {
		nam = '#капсулы';
		act = function(s)
			pn [[Это похоже на экстренное пробуждение! Что-то произошло? Сергей!]]
			ways():enable()
		end;
	},
	obj {
		nam = '#панели';
		act = function(s)
			if not wear2 then
				p [[Я быстро переоделась.]]
				wear2 = true
			else
				p [[Мне не нужно копаться в вещах экипажа.]]
			end
		end;
	}
}

room {
	nam = 'Отсек 1 end';
	title = 'Модуль гибернации';
	subtitle = 'Отсек 1';
	decor = [[{$d криоотсек3|По всей площади отсека} {#капсулы|установлены открытые капсулы.} {#капсула|Одна из капсул -- закрыта.}]];
	onexit = function(s, t)
		if t ^ 'у капсулы сергея' then
			return
		end
		p [[Я должна убедиться, что с Сергеем все в порядке!]]
		return false
	end;
	way = { path {CW, 'Отсек 4 Пионер'}, path{UP, 'Отсек 0 Пионер'},path {CCW, 'Отсек 2 Пионер'} };
} : with
{
	dec('#капсулы', [[Что-то произошло! Я вижу, как люди выходят из капсул.]]);
	obj {
		nam = '#капсула';
		act = function(s)
			walk 'у капсулы сергея';
		end;
	}
}

room {
	nam = 'у капсулы сергея';
	title = 'Модуль гибернации';
	subtitle = 'Отсек 1';
	decor = [[{#я|Я стою} {#капсула|у капсулы} {#он|Сергея}, {#смотрю|вглядываясь сквозь стекло.}]];
} : with
{
	dec('#я', [[Сердце бешено бьется в груди.]]);
	dec('#он', [[-- Сергей!!!]]);
	dec('#капсула', [[Показатели жизнедеятельности... В норме. Но почему он не просыпается?]]);
	obj {
		nam = '#смотрю';
		act = function(s)
			fading.set {"fadeblack", max = FADE_LONG }
			D()
			walk 'titles'
		end;
	}
}
local font
local font_height

local text = {
	{ "ВАХТА", style = 1},
	{ },
	{ "Сюжет, код игры и движок:", style = 2},
	{ "Петр Косых" },
	{ },
	{ "Иллюстрации:", style = 2 },
	{ "Петр Косых" },
	{ "Свободные изображения" },
	{ },
	{ "Музыка:", style = 2 },
	{ "Ryan Andersen / Day to Night" },
	{ "Chris Zabriskie / Is That You or Are You You" },
	{ "Kevin MacLeod / Impact intermezzo 1999" },
	{ "Kevin MacLeod / Impact Prelude 1765" },
	{ "Chris Zabriskie / Prelude No 2" },
	{ "Chris Zabriskie / Prelude No 12" },
	{ "Chris Zabriskie / NirvanaVEVO 1983" },
	{ },
	{ "Звук:", style = 2 },
	{ "http://www.freesound.org" },
	{ },
	{ "Тестирование:", style = 2 },
	{ "vorov2" },
	{ "techniX" },
	{ "vvb" },
	{ "Wol4ik" },
	{ "и другие..."},
	{ },
	{ "Апрель 2018" },
	{ },
	{ "Спасибо Вам за прохождение!" },
	{ },
	{ },
	{ "Достижения:", style = 2 },
	{ "prefs.snowball_launcher" },
	{ "prefs.chess_master" },
	{ "prefs.romance" },
	{ "prefs.strong" },
	{ "prefs.rnd_master" },
	{ },
	{ "Благодарности:", style = 2 },
	{ },
	{ "Жене - за терпение", },
	{ "Работодателю - за зарплату" },
	{ "А также всем тем, кто не мешал..."},
	{ },
	{ },
	{ },
	{ },
	{ },
	{ },
	{ "КОНЕЦ", style = 1 },
	{ },
	{ },
	{ },
	{ },
	{ },
	{ },
	{ },
	{ },
	{ },
	{ },
	{ },
	{ },
	{ },
	{ },
	{ },
	{ '21 апреля 2018', style = 2},

}



room {
	nam = 'titles';
	hidetitle = true;
	noinv = true;
	{
		offset = 0;
		pos = 1;
		line = text[1];
		ww = 0;
		hh = 0;
		font = false;
		font_height = 0;
		w = 0;
		h = 0;
	};
	ini = function(s)
		if here() == s then
			s:enter()
		end
	end;
	enter = function(s)
		for k, v in ipairs(text) do
			if v[1] and v[1]:find('prefs.', 1, true) then
				if v[1] == "prefs.snowball_launcher" then
					text[k][1] = 'Швырятель снежков: ' .. (prefs.snowball_launcher and 'да' or 'нет')
				elseif v[1] == "prefs.chess_master" then
					text[k][1] = 'Шахматист: ' .. (prefs.chess_master and 'да' or 'нет')
				elseif v[1] == "prefs.romance" then
					text[k][1] = 'Романтик: ' .. (prefs.romance and 'да' or 'нет')
				elseif v[1] == "prefs.strong" then
					text[k][1] = 'Сильный духом: ' .. (prefs.strong and 'да' or 'нет')
				elseif v[1] == "prefs.rnd_master" then
					text[k][1] = 'Теоретик: ' .. (prefs.rnd_master and 'да' or 'нет')
				end
			end
		end
		timer:set(20)
		local fn = theme.get('win.fnt.name')
		s.font = sprite.fnt(fn, 16)
		s.font_height = s.font:height()
		s.w, s.h = std.tonum(theme.get 'scr.w'), std.tonum(theme.get 'scr.h')
	end;
	timer = function(s)
		_'@decor'.dirty = false
		local scr = sprite.scr()
		if s.line == false then
			return false
		end
		if s.pos > 51 then
			snd.stop_music(0)
			fading.set {"blackout", max = 200 }
			walk 'провал3'
			return
		end
		-- scroll
		for y = 0, s.h - 2 do
			scr:copy(0, y + 1, s.w, 1, scr, 0, y)
		end

		if s.offset >= s.font_height then
			s.pos = s.pos + 1
			s.offset = 0
		end

		if s.offset == 0 then
			if s.pos <= #text then
				s.line = text[s.pos]
				s.line = s.font:text(s.line[1] or ' ', s.line.color or 'white', s.line.style or 0)
				s.ww, s.hh = s.line:size()
			else
				s.line = false
			end
		end
		if s.line then
			s.offset = s.offset + 1
			scr:fill(0, s.h - s.offset, s.w, s.offset, 0, 0, 0, 255)
			s.line:draw(scr, math.floor((s.w - s.ww) / 2), s.h - s.offset)
		end
		return false
	end
}

room {
	nam = 'провал3';
	title = '...';
	hidetitle = true;
	noinv = true;
	num = 0;
	timer = function(s)
		if s.num < 250 then
			s.num = s.num + 1
		end
		if s.num == 250 then
			snd.music 'mus/isthatyou.ogg'
		end
	end;
	decor = [[{$fmt y|40%}{$fmt b|ВНИМАНИЕ!^ЕСЛИ ТЫ ЧИТАЕШЬ ЭТО СООБЩЕНИЕ, ЗНАЧИТ ТЫ СПИШЬ!^
МЫ ПРОБУЕМ РАЗНЫЕ СПОСОБЫ ДОСТУЧАТЬСЯ ДО ТЕБЯ.^
И ЕСЛИ ТЫ ВИДИШЬ ЭТОТ ТЕКСТ -- У НАС ПОЛУЧИЛОСЬ!^
Я -- ЕЛЕНА. СЛУШАЙ МЕНЯ. ТЫ ДОЛЖЕН ПРОСНУТЬСЯ.^СЕЙЧАС ЖЕ. Я ЖДУ ТЕБЯ.}]];
}
