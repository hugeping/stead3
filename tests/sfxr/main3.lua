require "snd"
require "timer"

local sfxr = require("sfxr")
local last = true

room {
	nam = 'main';
	timer = function()
		if snd.playing(3) then
			p [[PLAYING]]
			last = true
			return
		elseif last then
			last = false
			p [[Нажмите на {button|кнопку} для эффекта.]];
		end
		return false
	end
}:with{
	obj {
		nam = 'button';
		act = function(s)
			local sound = sfxr.newSound()
			sound:randomize(rnd(32768))
			local sounddata = sound:generateSoundData(22050)
			local source = snd.new(22050, 1, sounddata)
			source:play(3)
		end
	}
}

function start()
	timer:set(100)
end
