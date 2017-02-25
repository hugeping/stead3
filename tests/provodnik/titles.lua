require "sprites"
require "theme"
require "timer"
local w, h

local font
local font_height

local text = {
	{ "ПРОВОДНИК", style = 1},
	{ },
	{ "Сюжет и код игры:", style = 2},
	{ "Петр Косых" },
	{ },
	{ "Иллюстрации:", style = 2 },
	{ "Петр Косых" },
	{ },
	{ "Музыка:", style = 2 },
	{ "Петр Советов" },
	{ },
	{ "Тестирование:", style = 2 },
	{ "kerber" },
	{ "Петр Советов" },
	{ },
	{ "Игра написана в ферале 2017" },
	{ "Для тестирования движка STEAD3"},
	{ },
	{ "Спасибо Вам за прохождение!" },
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
	{ },
	{ },

}

local offset = 0
local pos = 1
local line
local ww, hh

function game:timer()
	local scr = sprite.scr()
	-- scroll
	scr:copy(0, 1, w, h - 1, scr, 0, 0)

	if offset >= font_height then
		pos = pos + 1
		offset = 0
	end

	if offset == 0 then
		if pos <= #text then
			line = text[pos]
			line = font:text(line[1] or ' ', line.color or 'white', line.style or 0)
			ww, hh = line:size()
		else
			line = false
		end
	end
	if line then
		offset = offset + 1
		scr:fill(0, h - offset, w, offset, 'black')
		line:draw(scr, math.floor((w - ww) / 2), h - offset)
	end
end
room {
	nam = 'legacy_titles',
	title = false,
	decor = function(s)
		for k, v in ipairs(text) do
			if v.style == 1 then
				pn(txt:center(txt:bold(v[1] or '')))
			elseif v.style == 2 then
				pn(txt:center(txt:em(v[1] or '')))
			else
				pn(txt:center(v[1] or ''))
			end
		end
	end;
}

global 'ontitles' (false)

function end_titles()
	offset = 0
	ontitles = true
	if not sprite.direct(true) then
		instead.fading = 32
		walk ('legacy_titles', false)
		return
	end
	walk ('legacy_titles', false)
	w, h = std.tonum(theme.get 'scr.w'), std.tonum(theme.get 'scr.h')
	local fn = theme.get('win.fnt.name')
	font = sprite.fnt(fn, 16)
	font_height = font:height()
	sprite.scr():fill 'black'
	timer:set(30)
	return true
end