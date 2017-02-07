-- raw interface to sound

local std = stead

local instead = std.ref '@instead'

instead.sound_load = instead_sound_load
instead.sound_free = instead_sound_free
instead.sounds_free = instead_sounds_free
instead.sound_channel = instead_sound_channel
instead.sound_volume = instead_sound_volume
instead.sound_panning = instead_sound_panning
instead.sound_load_mem = instead_sound_load_mem
instead.music_callback = instead_music_callback
instead.is_sound = instead_sound

local snd = std.obj {
	nam = '@snd';
}

function instead.get_music()
	return snd.__music, snd.__music_loop
end

function instead.set_music(mus, loop)
	snd.__music = mus
	snd.__loop = loop or 0
end

function instead.get_music_fading()
	return snd.__music_fadeout, snd.__music_fadein
end

function instead.set_music_fading(o, i)
	if o == 0 or not o then o = -1 end
	if i == 0 or not i then i = -1 end
	snd.__music_fadeout = o
	snd.__music_fadein = i or o
end

function instead.finish_music()
	if (snd.__music_loop or 0) == 0 then
		return false
	end
	snd.__music_loop = -1
	return true
end

function instead.get_sound()
	return snd.__sound, snd.__sound_channel, snd.__sound_loop
end

function instead.add_sound(s, chan, loop)
	if type(s) ~= 'string' then
		std.err("Wrong parameter to instead.add_sound()", 2)
	end
	if type(instead.__sound) ~= 'string' then
		return instead.set_sound(s, chan, loop)
	end
	if std.tonum(chan) then
		s = s..'@'..std.tostr(chan);
	end
	if std.tonum(loop) then
		s = s..','..std.tostr(loop)
	end
	instead.set_sound(instead.__sound..';'..s, snd.__sound_channel, snd.__sound);
end

function instead.set_sound(sound, chan, loop)
	snd.__sound = sound
	snd.__sound_loop = loop or 1
	snd.__sound_channel = chan or -1
end

function instead.stop_sound(chan, fo)
	local str = '@-1'

	if (chan and type(chan) ~= 'number') or (fo and type(fo) ~= 'number') then
		std.err("Wrong parameter to instead.stop_sound", 2)
	end

	if chan then
		str = '@'..std.tostr(chan)
	end

	if fo then
		str = str .. ',' .. std.tostr(fo)
	end
	return instead.add_sound(str);
end

function instead.stop_music()
	instead.set_music(nil, -1);
end

std.mod_done(function(s)
	instead.stop_music()
	instead.set_sound('@-1'); -- halt all
end)

std.mod_cmd(function(s)
	instead.set_sound(); -- empty sound
end)

-- aliases

snd.set = instead.set_sound
snd.play = instead.add_sound
snd.stop = instead.stop_sound
snd.music = instead.set_music
snd.stop_music = instead.stop_music
snd.music_fading = instead.music_fading

function snd.load(a, b, t)
	if type(a) == 'string' then
		return instead.sound_load(a);
	elseif type(t) == 'table' then
		return instead.sound_load_mem(a, b, t) -- hz, channel, t
	end
end

function snd.music_callback(...)
	return instead.music_callback(...)
end

function snd.free(key)
	return instead.sound_free(key);
end

function snd.playing(s,...)
	if type(s) ~= 'number' then
		return instead.is_sound()
	end
	return instead.sound_channel(s,...)
end

function snd.pan(c, l, r, ...)
	return instead.sound_panning(c, l, r, ...)
end

function snd.vol(v, ...)
	return instead.sound_volume(v, ...)
end
