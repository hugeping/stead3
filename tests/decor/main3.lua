require "timer"
loadmod "decor"

function game:timer()
    D"cat".x = D"cat".x + 2

    if D"cat".x > 200 then
	if D'cat'.x < 600 then
	    D"text".hidden = false
	else
	    D"text".hidden = true
	end
    end

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

room {
    nam = 'main';
    title = 'ДЕКОРАТОРЫ';
    dsc = [[Привет, мир!]];
}

local text = [[Проверка длинных {test a b|текстов}, да еще с переносами строк.
Интересно сработает ли? А также интересно посмотреть на разные типы выравнивания!
И конечно, на принудительный {test a b|разрыв строк}!]];

local n = 1

function game:ondecor(press, x, y, btn, name, a, b)
    if name == 'cat' and press then
	local mew = { 'Мяу!', 'Муррр!', 'Мурлык!', 'Мяуууу! Мяуууу!', 'Дай поесть!' };
	p (mew[rnd(#mew)])
	return
    end
    if name ~= 'test' then
	return false
    end
    local j = { 'left', 'right', 'center', 'justify' };
    D"text".align = j[(n % #j) + 1];
    n = n + 1
    D(D'text')
    p("click:", name, ":",a, " ", b, " ", x, ",", y)
end

function init()
	timer:set(50)
	for i = 1, 100 do
		decor:new {"snow"..std.tostr(i), "img", "box:4x4,black", x= rnd(800), y = rnd(600), xc = true, yc = true, z = -1 }
	end
	decor.bgcol = 'white'
	D {"cat", "img", "anim.png", x = -64, y = 48, frames = 3, w = 64, h = 54, delay = 100, click = true }
	D {"box", "img", "box:64x64,red", x= 12, y = 12, xc = true, yc = true, click = true }
	D {"text", "txt", text, xc = true, x = 400, w = 150, y = 100, align = 'left', hidden = true }
	D {"box"} -- delete decorator
end
