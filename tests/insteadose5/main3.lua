--$Name: Инстедоз 5$
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
	timer = function(s)
		if snd.music_playing() then
			return
		end
		s.pos = s.pos + 1
		if s.pos > #s.tracks then
			s.pos = 1
		end
		print("Next track: ", s.tracks[s.pos])
		snd.music('mus/'..s.tracks[s.pos], 1)
	end;
	start = function(s)
		for f in std.readdir 'mus' do
			if f:find('%.ogg$') then
				table.insert(s.tracks, f)
			end
		end
		table.sort(s.tracks)
		if #s.tracks == 0 then
			return
		end
		timer:set(1000)
	end
}:start()

obj {
	nam = '@game';
	act = function(s, w)
		gamefile('games/'..w..'/main3.lua', true)
		_'@mplayer':start()
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
	decor = function()
		pn (fmt.c(fmt.b[[ЖУРНАЛ (СОВЕРШЕННО СЕКРЕТНО)]]))
		pn ()
		pn (fmt.c [[{@game photohunt|ФОТООХОТА}]]);
		pn (fmt.c [[{@game walkout|НОЧНАЯ ПРОГУЛКА}]]);
	end;
}
