require "timer"
loadmod "decor"

function game:timer()
	D"box".x = D"box".x + 1

	for i = 1, 100 do
		local d = D("snow"..std.tostr(i))
		d.y = d.y + rnd(3)
		d.x = d.x + rnd(3) - 2
		if d.y > 600 then
			d.y = 0
			d.x = rnd(800)
		end
	end

	return false
end
local text = [[Проверка длинных {test a b|те кстов}, да еще с переносами строк.
Интересно сработает ли? А также интересно посмотреть на разные типы выравнивания!
И конечно, на принудительный {test a b|разрыв строк}!]];
_'main'.dsc = [[Привет мир!]];
local n = 1
function game:ondecor(name, a, b, x, y)
	if name ~= 'test' then
		return false
	end
	local j = { 'left', 'right', 'center', 'justify' };
	D"text".align = j[(n % #j) + 1];
	n = n + 1
	decor:new('text')
	p("click:", name, ":",a, " ", b, " ", x, ",", y)
end
function init()
	timer:set(50)
	for i = 1, 100 do
		decor:new {"snow"..std.tostr(i), "img", "box:4x4,black", x= rnd(800), y = rnd(600), xc = true, yc = true, z = -1 }
	end
	decor.bgcol = 'white'
	decor:new {"box", "img", "box:64x64,red", x= 12, y = 12, xc = true, yc = true }
--	decor:new {"box2", "img", "box:64x64,blue", x= 320, y = 12, xc = true, yc = true, z = -1 }
	decor:new {"text", "txt", text, xc = true, x = 400, w = 150, y = 100, align = 'left' }
end
