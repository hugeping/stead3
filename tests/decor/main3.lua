require "timer"
loadmod "decor"

function game:timer()
	D"box".x = D"box".x + 20
	return false
end
local text = [[Проверка длинных текстов, да еще
с переносами строк. Интересно
сработает ли?]];
_'main'.dsc = [[Привет мир!]];
function init()
	timer:set(100)
	decor.bgcol = 'white'
	decor:new {"box", "img", "box:64x64,red", x= 12, y = 12, xc = true, yc = true }
	decor:new {"box2", "img", "box:64x64,blue", x= 320, y = 12, xc = true, yc = true, z = -1 }
	decor:new {"text", "txt", text, color = 'red', xc = true, x = 400, y = 200, align = 'center' }
end
