require "timer"
loadmod "decor"

function game:timer()
	D"box".x = D"box".x + 20
	decor:render()
	return false
end

function start()
	timer:set(100)
	decor:new {"box", "img", "box:64x64,red", x= 12, y = 12, xc = true, yc = true }
end
