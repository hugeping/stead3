require "noinv"
require "nolife"

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
	elseif here().title == 'Жилой модуль' then
		y = y - 51
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

obj {
	nam = 'капсулы';
	act = function(s)
		if here().subtitle == 'Отсек 1' then
			pn [[В этом отсеке установлено 7 гибернационных капсул.]]
		elseif here().subtitle == 'Отсек 2' then
			pn [[В этом отсеке установлено 7 гибернационных капсул.]]
		elseif here().subtitle == 'Отсек 3' then
			pn [[В этом отсеке установлено 6 гибернационных капсул.]]
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
Диаметр нулевого отсека примерно соответствует человеческому росту, так что тут довольно тесно.
]], false)

dict.add('гравитация', [[
Только в жилом модуле и модуле гибернации за счет вращения поддерживается гравитация. В остальных отсеках
гравитации нет.]], false)

dict.add('ботинки', [[
Нужна определенная привычка, чтобы чувствовать себя в них естественно.
Ботинки очень крепко магнитятся к стенам корабля и перед тем как оторвать ногу от поверхности, нужно
особым образом повернуть ногу... У меня уже почти получается делать это рефлекторно.]], false)

room {
	nam = 'Отсек 0';
	title = "Модуль гибернации";
	subtitle = 'Отсек 0';
	decor = [[{$d отсек0|Здесь} {$d гравитация|нет искусственной гравитации.} {$d ботинки|Звук от магнитных ботинок глухо отражается} {$d стена|от изогнутых стен.}]];
	way = { path {'В жилой модуль', 'Жилой Отсек 0'}, path {'В отсек 1', 'Отсек 1'}, path{'2', 'Отсек 2'},path {'3', 'Отсек 3'}, path {'4', 'Отсек 4'} };
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
время полета составляет всего 3.5 года. На Земле за это время пройдет 75 лет...]]
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

obj {
	nam = 'браслет';
	inv = function(s)
		p [[Этот браслет следит за пульсом, а также позволяет Алисе слышать меня из любого уголка звездолета.
Алиса -- наш бортовой компьютер. У него, вернее нее, очень приятный голос.]];
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
				p [[На запястье я одел свой браслет, который лежал в нагрудном кармане комбинезона.]]
				remove 'одежда'
				take 'браслет'
				pn [[Теперь можно поесть. Кухня находится в жилом модуле.]]
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
			pn [["Пилигрим" -- второй звездолет в конвое, который был отправлен на Глизе 667 Cc. Мы везем
оборудование и эмбрионы животных.]];
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
	way = { path { 'В модуль гибернации', 'Отсек 0'}, path {'В отсек 1', 'Жилой Отсек 1'}, path{'2', 'Жилой Отсек 2'},path {'3', 'Жилой Отсек 3'}, path {'4', 'Жилой Отсек 4'} };
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

dict.add('жилойотсек', [[Жилой модуль -- это второй модуль "Пилигрима" в котором поддерживается искусственная гравитация.
Четыре отсека позволяют с относительным комфортом провести свободные часы вахты. И не сойти с ума от одиночества.
Так же как и в модуле гибернации, на стадии разгона и торможения боковые стены отсеков становятся полом.]])

global 'breakfast' (false)
dict.add('кубрик', [[Кубрик -- отсек жилого модуля предназначенный для отдыха экипажа. Свободное пространство
на звездолете это роскошь, но кубрик дает возможность проводить вахты с относительным комфортом. А успех миссии напрямую
зависит от психологического здоровья экипажа.]]);

obj {
	nam = 'шахматы';
	dsc = [[{#стол|На столе} {$d я|я} {вижу шахматную доску.}]];
	act = function(s)
		if chess_puzzle_solved then
			p [[Я никогда не любил шахматы. Все-таки хорошо, что я не подвел команду белых.]]
		else
			p [[Весь экипаж разделен на две команды: белые и черные. Каждый из нас во время вахты делает один ход.
Это еще один способ избежать одиночества. Я играю за белых.]];
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
			pn [[Кушетки индивидуально подстраиваются под анатомические особенности человека. На них можно удобно поспать несколько часов.
Обычным сном, не входя в анабиоз. А можно просто полежать, погрузившись в свои мысли.]];
			if disabled '#журнал' then
				p [[На одной из кушеток я заметил журнал экипажа.]]
				enable '#журнал'
			end
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
			p [[Кубрик рассчитан на одновременное нахождение в нем до четырех членов экипажа.
Правда, пока мы движемся на крейсерской скорости, вахту несет только один член экипажа. В данный момент -- это я.]]
		end;
	};
	obj {
		nam = '#журнал';
		dsc = [[{#кровати|На кушетке} {лежит журнал.}]];
		act = function(s)
			p [[Журнал из обычной бумаги -- еще один способ поддерживать связь. Связь между людьми из разных вахт.]]
			p [[Здесь есть что угодно: стихи, мысли, анекдоты, наброски. Все, что составляет обычное человеческое общение, которого так не хватает.]]
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
	decor = [[{$d жилойотсек|Основное пространство отсека} {#кухня|занимает кухня.} {#кафе|В другом конце} {#кресла|установлены мягкие кресла},
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
		if not breakfast then
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
			p [[Кухня синтезирует пищу которую мы едим. Чтобы не испортить аппетит, я стараюсь не думать о том, как это происходит.]];
			p [[Пища появляется из панели выдачи на специальном подносе. Использованные подносы отправляются в принимающую панель.]]
		end;
	}: with {
		obj {
			nam = 'поднос';
			eaten = false;
			dsc = function(s)
				if where(s) ^ '#кухня' then
					p [[{#кухня|Возле панели выдачи стоит} {поднос с моим завтраком}.]];
				else
					p [[{#столик|На столике стоит} {поднос с моим завтраком}.]];
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
	decor = [[{$d я|Я} {$d жилойотсек|нахожусь в инженерном отсеке.}]];
	way = { path {CW, 'Жилой Отсек 2'}, path{UP, 'Жилой Отсек 0'},path {CCW, 'Жилой Отсек 4'} };
}

room {
	nam = 'Жилой Отсек 4';
	title = 'Жилой модуль';
	subtitle = 'Отсек 4';
	way = { path {CW, 'Жилой Отсек 3'}, path{UP, 'Жилой Отсек 0'},path {CCW, 'Жилой Отсек 1'} };
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
	dec ('#удовольствие', [[После выхода из гибернации аппетит никто не жалуется на отсутствие аппетита.]]);
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
				[[-- Я знаю, что не увижу тебя здесь. У тебя не было выбора. Ведь ты такой умный и должен был лететь ради... Ради нашего будущего. Так что не вини себя. А что будет здесь на Земле, никто точно не знает. Так что я рада, очень рада, что ты улетел.]],
				[[-- Ох, я опять все испортила! В общем, просто подумай о нас, а мы с папой будем всегда с тобой, что бы не случилось!]],
				[[-- Время передачи кончается, а я опять потратила его зря. Сынок, до связи! Я буду ждать!]],
				[[Экран снова загорелся голубым светом. Я думал о том, что мама получит (уже получила 12 лет назад) сообщение, которое я записал... Я даже не помнил точно. И мне не хотелось
уточнять это у Алисы, которая деликатно молчала. Время полностью разладилось, разорвалось в клочья. Оно осталось только в нашей вере и любви. Зачем я здесь?]],
				[[-- Передача из центра звездных полетов от 11 апреля 2254 года -- спокойный голос Алисы вывел меня из задумчивости.^-- Да, спасибо, Алиса.]],
				[[-- Центр "Пилигриму". Передача 7297. -- на экране появилось лицо лысеющего сотрудника центра.]];
				[[-- Получена передача номер 683 от "Ковчега". Полет проходит в штатном режиме.]];
				[[-- Получена передача номер 3670 от "Пионера-2217". Полет проходит... в штатном режиме.]];
				[[-- Таким образом по нашим наблюдениям выполнение программы идет по плану.]];
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
				D { 'fig-'..std.tostr(x)..std.tostr(y), 'img', chess_spr, z = 1, x = xx, y = yy, white = white, fig = n }
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
	local boardx, boardy = d.x, d.y
	x = math.floor(x / CS) + 1
	y = math.floor(y / CS) + 1
	local c = chess_cell(x, y)
	if not c and not chess_selected then
		return false
	end
	if seen '#назад' then
		return false
	end
	if not chess_selected or c then
		chess_selected = string.format('fig-%d%d', x, y)
		D {'selection', 'img', selector_spr, x = boardx + (x - 1) * CS, y = boardy + (y - 1) * CS, z = 0 }
	else
		local d = D(chess_selected)
		if chess_selected == 'fig-22' and x == 4 then
			chess_puzzle_solved = true
		end
		chess_selected = false
		D {'selection' }
		d.x = (x - 1) * CS + boardx
		d.y = (y - 1) * CS + boardy
		enable '#назад'
	end
end

room {
	nam = 'игра-шахматы';
	title = 'Жилой модуль';
	noinv = true;
	subtitle = 'Отсек 1';
	hidetitle = true;
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
		if not chess_puzzle_solved then
			if not s.hint then
				pn [[-- Позволю себе заметить, белые делают мат в два хода -- послышался голос Алисы.^
-- Хм, а я думал что тебе запрещено давать подсказки...^
-- Ох. Прошу прощения, не выдержала.]]
				s.hint = true
			else
				pn [[Гм, я как буд-то слышу грустный вздох Алисы. Интересно, она так же подсказывает и команде черных? Алиса сказала, что белые делают мат в два хода.]]
			end
			p [[Похоже, есть смысл попробовать найти верный ход.]];
		else
			p [[-- Хочу заметить, вы сделали прекрасный ход! -- раздался голос Алисы.]]
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
obj {
	nam = '$fmt';
	act = function(s, w, t)
		return fmt[w](t)
	end
}

room {
	nam = 'журнал';
	title = 'Жилой модуль';
	noinv = true;
	hidetitle = true;
	subtitle = 'Отсек 1';
	enter = function(s)
		D {'journal', 'img', 'gfx/journal.png', x = (theme.scr.w() - 680) / 2, y = (theme.scr.h() - 540) / 2 }
		snow_theme()
	end;
	onexit = function(s, t)
		if s == t then
			pager(s, s.txt)
			return false
		end
	end;
	exit = function(s, t)
		D {'journal' }
		dark_theme()
	end;
	dsc = [[{$fmt b|{$fmt c|Журнал экипажа звездолета "ПИЛИГРИМ"}}]];
	{txt = {
[[Сегодня, пока я валялся в кубрике и пялился на звезды, мне пришла в голову странная мысль.^
Сколько бы тысяч световых лет не было между нами, я влияю на каждую звезду, которую вижу!^
Ведь если принять во внимание квантовые
взаимодействия, то я (мой глаз и сознание) действуют на звездный свет таким образом, что фотон проявляет
себя! Пока свет не попал ко мне в глаз, мозг, сознание... он существует только в состоянии
суперпозиции. А существует ли он тогда вообще? Не могу успокоиться, эта мысль меня вдохновляет! Считайте меня
конченным солипсистом, но в этом что-то есть!^

{$fmt r|Н.С.}]];
[[Николай, мне кажется тебе стоит поменьше думать. Ты так долго смотрел в космос, что космос
стал смотреть в тебя. Я понимаю к чему ты клонишь, но, друг, просто расслабься! У Алисы
есть все серии "Инспектора Коломбо", рекомендую.^
{$fmt r|Павел}]];

	}};
	way = {
		path {
			'#закрыть',
			'Закрыть',
			from,
		};
		path {
			'#листать',
			'Листать',
			'журнал',
		};
	}
}
local roster = {
	{ "капитан", "Михаил Громов"},
	{ "старпом", "Сергей Синицын"},
	{ "главный инженер", "Борис Виноградов" },
	{ "судовой врач", "Татьяна Соколова" },
	{ "астроном", "Оксана Теплова" },
	{ "механик", "Константин Фролов" },
	{ "связист", "Василий Зорин"},
	{ "рулевой", "Мамору Кудо"},
	{ "бортинженер", "Сергей Летов" },
	{ "биолог", "Елена Светлова" },
	{ "штурман", "Павел Семилетов"},
	{ "кок", "Ольга Потапова" },
	{ "оператор", "Вера Орлова" },
	{ "программист", "Петр Есенин" },
	{ "медсестра", "Кейт Стингрей"},
	{ "боцман", "Товио Андерс"},
	{ "астронавт", "Линда Фишер"},
	{ "астронавт", "Григорий Туполев"},
	{ "астронавт", "Александр Белоусов"},
	{ "астронавт", "Николай Семенов" },
}
