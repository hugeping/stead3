require "sprite"
require "theme"
require "timer"

local W, H = theme.scr.w(), theme.scr.h()

local tiles = {}

local WX, HY = 64, 64

local WW, HH = math.floor(W / WX), math.floor(H / HY)

local pad = 2
local book_spr = sprite.new "book.png"
local wh1_spr = sprite.new "wheel1.png"
local wh2_spr = sprite.new "wheel2.png"
local instead_spr = sprite.new "instead.png"
local shadow_spr = { sprite.new "shadow.png", sprite.new "shadow2.png" }
local rotate = 0
local rotate_spr = {}

function logo_init()
	for r = 1, 359 do
		local a = r
		rotate_spr[r] = {}
		rotate_spr[r][1] = wh1_spr:rotate(-a)
		rotate_spr[r][2] = wh2_spr:rotate(a * 2)
	end
end

function logo()
	local w, h = instead_spr:size()
	local ww, hh = theme.scr.w(), theme.scr.h()
--	instead_spr:draw(sprite.scr(), (ww - w) / 2, (hh - h)/ 2 - 122)

	local book, wh1, wh2 = book_spr, wh1_spr, wh2_spr
	local r = math.floor(rotate)
	local x, y = (theme.scr.w() - 250) / 2, (theme.scr.h() - 256) / 2
	if r > 0 then
		wh1, wh2 = rotate_spr[r][1], rotate_spr[r][2]
	end
	book:draw(sprite.scr(), x, 92 + y)
	local w, h = wh1:size()
	for _ = 1, 3 do
		shadow_spr[rnd(2)]:draw(sprite.scr(), x - 20, y - 16)
	end
	wh1:draw(sprite.scr(), x + 86 - w/ 2, 92 + y - 16 - h / 2)
	local w, h = wh2:size()
	wh2:draw(sprite.scr(), x + 174 - w / 2, 92 + y + 12 - h /2)
	rotate = rotate + 1
	if rotate >= 360 then rotate = 0 end
end

function draw_tiles()
	for y = 1, HY do
		for x = 1, WX do
			local a = tiles[y][x].lev / 255
			local COL = tiles[y][x].col
			local col = string.format("#%02x%02x%02x", COL[1] * a, COL[2] * a, COL[3] * a)
			sprite.scr():fill((x - 1) * WX + pad, (y - 1) * HY + pad, WX - pad * 2, HY - pad * 2, col)
		end
	end
end
local DIST = 6
local slides = {}
local slides_pool = {}

function scale_slide(v)
	local x, y
	local distance = rnd(10000) / 10000
	v.dist = distance
	local scale = 1 / 8 + (1 - v.dist) * 1 / 2
	local smooth = true
	v.spr = sprite.new(v.nam):scale(scale, scale, smooth)
	v.w, v.h = v.spr:size()
	v.dir = rnd(4)
	if v.dir == 1 then
		x = - (v.w + rnd(v.w))
		y = rnd(theme.scr.h()) - rnd(v.h)
	elseif v.dir == 2 then
		x = theme.scr.w() + rnd(v.w)
		y = rnd(theme.scr.h()) - rnd(v.h)
	elseif v.dir == 3 then
		x = rnd(theme.scr.w()) - rnd(v.w)
		y = -(v.h + rnd(v.h))
	else
		x = rnd(theme.scr.w()) - rnd(v.w)
		y = theme.scr.h() + (v.h + rnd(v.h))
	end
	v.x, v.y = x, y
end

function process_slides(delta)
	local x, y, once
	for k, v in ipairs(slides) do
		if v.dir == 1 then
			v.x = v.x + (delta * (2 * (1 - v.dist) +1))
		elseif v.dir == 2 then
			v.x = v.x - (delta * (2 * (1 - v.dist) +1))
		elseif v.dir == 3 then
			v.y = v.y + (delta * (2 * (1 - v.dist) +1))
		else
			v.y = v.y - (delta * (2 * (1 - v.dist) +1))
		end
		if not once and (v.x > theme.scr.w() and v.dir == 1 or v.x < -v.w and v.dir == 2
			or v.y > theme.scr.h() and v.dir == 3 or v.y < - v.h and v.dir == 4) then
			once = k
		end
--		v.spr:copy(sprite.scr(), v.x, v.y)
	end
	if once then
		local v = slides[once]
		table.remove(slides, once)
		table.insert(slides_pool, v)
		local n = rnd(#slides_pool)
		v = slides_pool[n]
		scale_slide(v)
--		print("scale", n)
		table.insert(slides, v)
		table.remove(slides_pool, n)
		table.sort(slides, function(a, b) return a.dist > b.dist end)
	end
end

function draw_slides()
	for k, v in ipairs(slides) do
		v.spr:copy(sprite.scr(), v.x, v.y)
	end
end

local SLIDES_NR = 8
function load_slides()
	scandir()
	for _ = 1, SLIDES_NR do
		if #slides_pool == 0 then
			break
		end
		local n = rnd(#slides_pool)
		table.insert(slides, slides_pool[n])
		table.remove(slides_pool, n)
	end
	DIST = #slides
	for k, v in ipairs(slides) do
		scale_slide(v)
	end
	table.sort(slides, function(a, b) return a.dist > b.dist end)
end

function process_tiles()
	local y = rnd(HH)
	local x = rnd(WW)
	local cell = tiles[y][x]
	if cell.dir == 1 then
		cell.lev = cell.lev + (rnd(64) + 32)
	else
		cell.lev = cell.lev - (rnd(64) + 32)
	end
	if cell.lev > 255 then
		cell.dir = 2
		cell.lev = 255
		color(x, y)
	elseif cell.lev < 0 then
		cell.dir = 1
		cell.lev = 0
		color(x, y)
	end
end
function color(x, y)
	local COL = tiles[y][x].col
	COL[1] = 0 -- rnd(255)
	COL[2] = 255 -- rnd(255)
	COL[3] = 255 -- rnd(255)
end

local last_t = 0

function game:timer()
	local t = instead.ticks()
	local delta = t - last_t
	if last_t == 0 then
		delta = 1.0
	end
	last_t = t
	process_tiles()
	process_slides(delta / 20)
	sprite.scr():fill 'black'
	draw_tiles()
	draw_slides()
	logo(0, 0)
end

function scandir()
	for d in std.readdir 'screen' do
		if d:find("%.png$") then
			table.insert(slides_pool, { nam = "screen/"..d })
		end
		dprint("Scan: ", d)
	end
end

function start()
	if not sprite.direct(true) then
		error("Включите собственные темы игр")
	end
	sprite.scr():fill 'black'
	for y = 1, HY do
		if not tiles[y] then
			tiles[y] = {}
		end
		for x = 1, WX do
			tiles[y][x] = { lev = rnd(128), dir = rnd(2), col = {} }
			color(x, y)
		end
	end
	load_slides()
	logo_init()
	timer:set(10)
end
