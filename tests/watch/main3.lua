--$Name:Вахта$

require "fmt"
require "timer"
require "keys"
require "snd"
require "fmt"
fmt.dash = true
fmt.quotes = true
loadmod "decor"
loadmod "fading"
loadmod "instfmt"
loadmod "quake"

include "dict"
include "display"

include "intro"
include "game"
global 'watch' (1883)

const 'FADE_LONG' (128)

function instead.titlefmt(w)
	if type(w) ~= 'string' or w == ''  then
		return w
	end
	if here().hidetitle then
		return
	end
	if D'clouds' then
		return fmt.l(fmt.b(w))
	end
	local col = theme.get('win.col.fg')
	local hr = fmt.img('box:'..theme.get('win.w')..'x1,'..col)
	local subtitle = std.call(here(), 'subtitle') or 'Вахта'
	return fmt.l(w)..fmt.tab('100%')..fmt.nb(subtitle)..'\n'..hr
end

function instead.wayfmt(w)
	local col = theme.get('win.col.fg')
	local hr = fmt.img('box:'..theme.get('win.w')..'x1,'..col)
	return fmt.c(w)..'\n'..hr
end

declare 'newitem' (function(i)
	local o = { nam = 'Яблоко #'..tostring(i) };
	return obj(o)
end)

function init()
	if theme.name() ~= '.' then
		std.err("Пожалуйста, включите поддержку собственных тем игры.")
	end
	decor.bgcol = theme.get 'scr.col.bg'

	walk 'intro'
end

function start()
	theme_select()
end
