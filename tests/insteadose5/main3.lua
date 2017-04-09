--$Name: Инстедоз 5$
--$Version: 0.26$
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
		if s.curgame == 'spring' then
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

		if w ~= 'spring' then
			_'@mplayer':rand()
			_'@mplayer':start()
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

room {
	nam = 'main';
	title = 'ИНСТЕДОЗ 5';
	pic = 'gfx/fractal.gif';
	decor = function()
		pn (fmt.c(fmt.b[[ЖУРНАЛ (СОВЕРШЕННО СЕКРЕТНО)]]))
		pn ()
		pn (fmt.c [[{@game prolog|ПРОЛОГ}]]);
		pn (fmt.c [[{@game photohunt|ФОТООХОТА}]]);
		pn (fmt.c [[{@game walkout|НОЧНАЯ ПРОГУЛКА}]]);
		pn (fmt.c [[{@game spring|ВЕСНА}]]);
		pn (fmt.c [[{@game i_came_to_myself|Я ОЧНУЛСЯ}]]);
	end;
}

function init()
	take (stat {
		disp = [[АВТОРЫ ВЫПУСКА:^Андрей Лобанов (spline), Сергей Можайский (techniX), Башкиров Сергей, Irreman, Михаил Поздняков (casper_nn), Петр Косых^http://instead.syscall.ru^Апрель 2017]];
	})
end
