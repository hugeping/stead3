require "timer"
loadmod "decor"

function game:timer()
	D"box".x = D"box".x + 20
	return false
end
local text = [[Проверка длинных {test|текстов}, да еще с переносами строк.
Интересно сработает ли? А также интересно посмотреть на разные типы выравнивания!
И конечно, на принудительный разрыв строк!]];
_'main'.dsc = [[Привет мир!]];
local n = 1
function game:ondecor(name, x, y)
	local j = { 'left', 'right', 'center', 'justify' };
	D"text".align = j[(n % #j) + 1];
	n = n + 1
	decor:new('text')
	p("click:", name, ":",x, ",", y)
end
function init()
	timer:set(100)
	decor.bgcol = 'white'
	decor:new {"box", "img", "box:64x64,red", x= 12, y = 12, xc = true, yc = true }
--	decor:new {"box2", "img", "box:64x64,blue", x= 320, y = 12, xc = true, yc = true, z = -1 }
	decor:new {"text", "txt", text, xc = true, x = 400, w = 150, y = 100, align = 'left' }
end
