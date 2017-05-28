--$Name: Инстедоз 5$
--$Version: 0.6$
--$Author: http://instead.syscall.ru$
--$Info: Сборник коротких игр$
require 'fmt'
require 'snd'
require 'timer'

local old_timer = timer.callback

std.timer = function()
	_'@mplayer':timer()
	return old_timer(timer)
end

obj {
	nam = '@mplayer';
	{
		tracks = {};
	};
	pos = 1;
	curgame = false;
	timer = function(s)
		if s.curgame == 'spring' or s.curgame == 'lenochka' or s.curgame == 'structure' or s.curgame == 'spy' then
			return
		end
		if snd.music_playing() then
			return
		end
		s:next()
	end;
	rand = function(s)
		s.pos = rnd(#s.tracks)
	end;
	next = function(s)
		s.pos = s.pos + 1
		if s.pos > #s.tracks then
			s.pos = 1
		end
		print("Next track: ", s.tracks[s.pos])
		snd.music('mus/'..s.tracks[s.pos], 1)
	end;
	load = function(s)
		s.tracks = {
			'RoccoW_-_01_-_Welcome.ogg',
			'RoccoW_-_02_-_Echiptian_Swaggah.ogg',
			'RoccoW_-_08_-_Sweet_Self_Satisfaction.ogg',
		}
		table.sort(s.tracks)
		return s
	end;
	start = function(s)
		if #s.tracks == 0 then
			return
		end
		snd.music('mus/'..s.tracks[s.pos], 1)
		timer:set(1000)
	end;
}:load():start()

obj {
	nam = '@game';
	act = function(s, w)
		gamefile('games/'..w..'/main3.lua', true)

		_'@mplayer'.curgame = w

		if w ~= 'spring' and w ~= 'lenochka' and w ~= 'structure' and w ~= 'spy' then
			_'@mplayer':rand()
			_'@mplayer':start()
		elseif w == 'spring' or w == 'structure' then
			if rawget(_G, 'js') then
				snd.music('') -- js hack
			end
		end
		if _'game'.pic == nil then
			_'game' 'pic'('gfx/fractal.gif');
		end
	end;
}

obj {
	nam = '@restart';
	act = function(s, w)
		instead.restart()
	end;
}
game.pic = 'gfx/fractal.gif';
room {
	nam = 'main';
	title = 'ИНСТЕДОЗ 5 // ПЯТОЕ ИЗМЕРЕНИЕ';
	decor = function()
		pn (fmt.c(fmt.b[[ЖУРНАЛ (СОВЕРШЕННО СЕКРЕТНО)]]))
		pn ()
		pn (fmt.c [[{@game prolog|ПРОЛОГ}]]);
		pn (fmt.c [[{@game spy|ШПИОН}]]);
		pn (fmt.c [[{@game photohunt|ФОТООХОТА}]]);
		pn (fmt.c [[{@game walkout|НОЧНАЯ ПРОГУЛКА}]]);
		pn (fmt.c [[{@game spring|ВЕСНА}]]);
		pn (fmt.c [[{@game structure|СТРУКТУРА}]]);
		pn (fmt.c [[{@game exploring|РАЗВЕДКА БОЕМ}]]);
		pn (fmt.c [[{@game i_came_to_myself|Я ОЧНУЛСЯ}]]);
		pn (fmt.c [[{@game lenochka|ЛЕНОЧКА}]]);
		pn()
		pn (fmt.c (fmt.img 'box:200x1,black'))
		pn()
		pn (fmt.c [[{#about|Об этом сборнике}]])
	end;
}: with {
	obj {
		nam = '#about';
		act = function() walk 'about' end;
	}
}

room {
	nam = 'about';
	title = 'О сборнике';
	decor = function()
		p [[Перед вами сборник приключенческих игр, написанных на движке INSTEAD. Этот сборник составлен
в рамках мероприятия, которое носит название "ИНСТЕДОЗ".^^
Время от времени несколько авторов INSTEAD собираются вместе и создают такой сборник небольших игр, объединенных
общей темой или сюжетом. Темой этого, пятого по счету сборника, стало пятое измерение и путешествие по параллельным
мирам.^^
Если вы любите текстовые квесты и научную фантастику -- "Инстедоз" для вас! Играйте и оставляйте отзывы на форуме INSTEAD,
чтобы авторы могли улучшить свои игры или написать новые.^^
Если вы хотите попробовать написать свою игру -- для вас есть хорошая новость! Дело в том, что
"ИНСТЕДОЗ 5" продолжается. Так что вы можете сделать этот сборник лучше, написав интересную историю!^^
До встречи!^^]];
		pn(fmt.r (fmt.em "http://instead.syscall.ru"))
		pn(fmt.r (fmt.em "http://club.syscall.ru"))
		pn(fmt.r (fmt.em "апрель 2017"))
		p(fmt.c "{#back|К журналу}")
	end;
	obj = {
		obj { nam = '#back', act = function() walkout() end; };
	}
}

function init()
	take (stat {
		disp = [[АВТОРЫ ВЫПУСКА:^
Irremann,
Сергей Можайский (techniX),
Петр Косых,
Михаил Поздняков (casper_nn),
Андрей Лобанов (spline),
Башкиров Сергей,
MAlischka^^
http://instead.syscall.ru^
Апрель 2017]];
	})
end
