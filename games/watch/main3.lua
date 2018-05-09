--$Name:Вахта$
--$Version:1.0$
--$Author:Петр Косых$
--$Info:Апрель 2018$

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
		std.err("Пожалуйста, включите поддержку собственных тем игры.", 2)
	end
	if not std.ref '$fmt' then
		std.err("Пожалуйста, обновите INSTEAD до последней версии.", 2)
	end
	decor.bgcol = theme.get 'scr.col.bg'

--	walk 'intro'
end

room {
	nam = 'main';
	hidetitle = true;
	decor = function()
		p(fmt.y "40%")
		pn ([[В этой игре нужно читать. Если вы умеете читать, для продолжения
нажмите на слово {#помощь|"помощь".} Для тех кто не умеет читать -- другая кнопка.^
^
{#дальше|Дальше}]])
	end;
	obj = {
		obj {
			nam = '#помощь';
			act = function(s)
				walk 'help'
			end;
		};
		obj {
			nam = '#дальше';
			act = function(s) walk 'nogame' end
		}
	}
}

room {
	nam = 'nogame';
	hidetitle = true;
	decor = function()
		p(fmt.y "50%")
		pn ([[{$fmt b|Эта игра вам не понравится. Вы разучились читать. До свидания!}]])
	end;
}

room {
	nam = 'help';
	hidetitle = true;
	decor = function()
		p(fmt.y "20%")
		pn ([[{#other|Отлично!^
В этой игре вы можете нажимать на слова, даже если они не выглядят как ссылки. Предметы инвентаря могут использоваться на другие предметы в тексте. Для этого нажмите на предмет в инвентаре, а затем -- на другой предмет.
Если вы хотите осмотреть предмет инвентаря -- нажмите на него два раза.^^
Спасибо за внимание!} {#начало|Мы начинаем.}]])
	end;
}: with {
	dec('#other', 'Реакции на действия появляются под чертой. Реакции не имеют ссылок. Теперь нажмите на "Мы начинаем"');
	obj {
		nam = '#начало';
		act = function(s)
			walk 'intro'
			fading.set {"fadeblack", max = FADE_LONG }
		end;
	}
}

function start()
	theme_select()
end
