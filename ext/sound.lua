-- raw interface to sound

local std = stead

local instead = std.ref '@instead'

local snd = std.obj {
	nam = '@snd';
}

function instead.get_music()
	return snd.music, snd.music_loop
end

function instead.set_music(mus, loop)
	snd.music = mus
	snd.loop = std.tonum(loop) or 0
end

function instead.get_music_fading()
	return snd.music_fadeout, snd.music_fadein
end

function instead.finish_music()
	if (snd.music_loop or 0) == 0 then
		return false
	end
	snd.music_loop = -1
	return true
end

function instead.get_sound()
	return snd.sound, snd.sound_channel, snd.sound_loop
end

function instead.set_sound(sound, chan, loop)
	snd.sound = sound
	snd.sound_loop = std.tonum(loop) or 1
	snd.sound_channel = std.tonum(chan) or -1
end

std.mod_done(function(s)
	instead.set_music(nil, -1); -- stom music
	instead.set_sound('@-1'); -- halt all
end)

std.mod_cmd(function(s)
	instead.set_sound(); -- empty sound
end)
