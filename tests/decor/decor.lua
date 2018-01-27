require "sprite"
require "theme"
require "click"

local cache = {
}

function cache:new(max)
    local c = {
	cache = {};
	list = {};
	max = max or 16;
    }
    self.__index = self
    return std.setmt(c, self)
end

function cache:add(name, value)
    local v = self.cache[name]
    if v then
	v.value = value
	v.use = v.use + 1
	return v.value
    end
    v = { name = name, value = value, use = 1 }
    self.cache[name] = v
    table.insert(self.list, 1, v)
    return v.value
end

function cache:get(name)
    local v = self.cache[name]
    if not v then
	return
    end
    v.use = v.use + 1
    return v.value
end

function cache:clear()
    local nr = #self.list
    local list = {}
--    if nr <= self.max then
--	return
--    end
    for k, v in ipairs(self.list) do
	if v.use == 0 then
	    v.ttl = v.ttl - 1
	    if v.ttl <= 0 then
		self.cache[v.name] = nil
		print("cache purge: "..v.name)
	    else
		table.insert(list, v)
	    end
	else
	    table.insert(list, v)
	end
    end
    self.list = list
end

function cache:put(name)
    local v = self.cache[name]
    if not v then
	return
    end
    v.use = v.use - 1
    if v.use <= 0 then v.use = 0; v.ttl = 3; end
--    for k, vv in ipairs(self.list) do
--	if vv == v then
--	    table.remove(self.list, k)
--	    table.insert(self.list, #self.list, v)
--	    break
--	end
--    end
    return v.value
end

local img = {
    cache = cache:new();
}

function img:delete(v)

end

function img:clear()
    self.cache:clear()
end

function img:render(v)
    if v.fx and v.fy and v.w and v.h then
	v.sprite:draw(v.fx, v.fy, v.w, v.h, sprite.scr(), v.x - v.xc, v.y - v.yc)
    else
	v.sprite:draw(sprite.scr(), v.x - v.xc, v.y - v.yc)
    end
end

function img:new_spr(v, s)
    v.xc = v.xc or 0
    v.yc = v.yc or 0
    v.sprite = s
    local w, h = s:size()
    if v.w then w = v.w end
    if v.h then h = v.h end
    if v.xc == true then
	v.xc = math.floor(w / 2)
    end
    if v.yc == true then
	v.yc = math.floor(h / 2)
    end
    v.w, v.h = w, h
    return v
end

function img:new(v)
    local fname = v[3]
    if type(fname) ~= 'string' then
	std.err("Wrong filename in image")
    end
    local s = self.cache:get(fname)
    if not s then
	local sp = sprite.new(fname)
	if not sp then
	    std.err("Can not load sprite: "..fname, 2)
	end
	s = self.cache:add(fname, sp)
    end
    self.cache:put(fname)
    return self:new_spr(v, s)
end

local fnt = {
    cache = cache:new();
}

function fnt:key(name, size)
    return name .. std.tostr(size)
end

function fnt:clear()
    self.cache:clear()
    for k, v in ipairs(self.cache.list) do
	v.value.cache:clear()
    end
end

function fnt:_get(name, size)
    local f = self.cache:get(self:key(name, size))
    if not f then
	local fnt = sprite.fnt(name, size)
	if not fnt then
	    std.err("Can not load font", 2)
	end
	f = { fnt = fnt, cache = cache:new(1024) }
	self.cache:add(self:key(name, size), f)
    end
    return f
end

function fnt:get(name, size)
    return self:_get(name, size).fnt
end

function fnt:text_key(text, color, style)
    local key = std.tostr(color)..'#'..std.tostr(style or "")..'#'..tostring(text)
    return key
end

function fnt:text(name, size, text, color, style)
    local fn = self:_get(name, size);
    local key = self:text_key(text, color, style)
    local sp = fn.cache:get(key)
    if not sp then
	sp = fn.fnt:text(text, color, size)
	fn.cache:add(key, sp)
    end
    fn.cache:put(key)
    self:put(name, size)
    return sp
end

function fnt:put(name, size)
    self.cache:put(self:key(name, size))
end

local txt = {
}

local function make_align(l, width, t)
    if t == 'left' then
	return
    end
    if t == 'center' then
	local delta = math.floor((width - l.w) / 2)
	for _, v in ipairs(l) do
	    v.x = v.x + delta
	end
	return
    end
    if t == 'right' then
	local delta = math.floor(width - l.w)
	for _, v in ipairs(l) do
	    v.x = v.x + delta
	end
	return
    end
    if t == 'justify' then
	-- todo
	return
    end
end
function txt:new(v)
    local text = v[3]
    if type(text) == 'function' then
	text = text(v)
    end
    if type(text) ~= 'string' then
	std.err("Wrong text in txt decorator")
    end
    local align = v.align or 'left'
    local words = {}
    local style = v.style
    local color = v.color or theme.get('win.col.fg')
    local link_color = v.link_color or theme.get('win.col.link')
    local alink_color = v.alink_color or theme.get('win.col.alink')
    local font = v.font or theme.get('win.fnt.name')
    local intvl = v.intvl or std.tonum(theme.get 'win.fnt.height')
    local ww
    local y = 0;
    local x = 0;
    local sp, linksp
    local size = v.size or std.tonum(theme.get 'win.fnt.size')
    v.fnt = fnt:get(font, size)
    local spw, _ = v.fnt:size(" ")
    local lines = {}
    local line = { h = v.fnt:height() }
    local link_list = {}
    local W = 0
    local H = 0

    local function newline()
	line.y = y
	line.w = 0
	if #line > 0 then
	    line.w = line[#line].x + line[#line].w
	end
	y = y + v.fnt:height() * intvl
	if y > H then
	    H = y
	end
	table.insert(lines, line)
	line = { h = v.fnt:height() }
	x = 0
    end

    for w in text:gmatch("[^ \t]+") do
	while w and w ~= '' do
	    local s, _ = w:find("\n", 1, true)
	    if not s then
		ww = w
		w = false
	    elseif s > 1 then
		ww = w:sub(1, s - 1)
		w = w:sub(s)
	    else -- s == 1
		ww = '\n'
		w = w:sub(2)
	    end
	    if ww == '\n' then
		newline()
	    else
		local n
		local links = {}
		ww = std.for_each_xref_outer(ww,
			function(str)
			    str = str:gsub("^{", ""):gsub("}$", "")
			    local h = str:find("|", 1, true)
			    local l = str:sub(h + 1)
			    h = str:sub(1, h - 1)
			    table.insert(links, {h, l})
			    return '\3'..std.tostr(#links)..'\3'
		end)
		local t, col, act
		while ww do
		    s, _ = ww:find("\3[0-9]+\3", 1)
		    col = color
		    if s == 1 then
			n = std.tonum(ww:sub(s + 1, _ - 1))
			t = links[n][2]
			act = links[n][1]
			ww = ww:sub(_ + 1)
			col = link_color
		    elseif s then
			t = ww:sub(1, s - 1)
			ww = ww:sub(s)
		    else
			t = ww
			ww = false
		    end
		    sp = fnt:text(font, size, t, col, style)
		    if col == link_color then
			linksp = fnt:text(font, size, t, alink_color, style)
		    else
			linksp = false
		    end
		    local width, height = sp:size()
		    if height > line.h then
			line.h = height
		    end
		    local witem = { link = linksp, action = act, x = x, y = y, spr = sp, w = width, h = height }
		    if linksp then
			table.insert(link_list, witem)
		    end
		    table.insert(line, witem)
		    x = x + width
		end
		x = x + spw
		if x > W then
		    W = x
		end
	    end
	end
    end
    if #line > 0 then
	newline()
    end
    local spr = sprite.new(W, H)
    for _, l in ipairs(lines) do
	make_align(l, W, align)
	for _, w in ipairs(l) do
	    w.spr:copy(spr, w.x, w.y)
	end
    end
    v.__lines = lines
    v.__link_list = link_list
    return img:new_spr(v, spr)
end

function txt:render(v)
    local x, y = instead.mouse_pos()
    x = x - v.x + v.xc
    y = y - v.y + v.yc
    for _, w in ipairs(v.__link_list) do
	if x >= w.x and y>= w.y
	and x < w.x + w.w and y < w.y + w.h then
	    if not w.__active then
		w.__active = true
		w.link:copy(v.sprite, w.x, w.y)
	    end
	else
	    if w.__active then
		w.__active = false
		w.spr:copy(v.sprite, w.x, w.y)
	    end
	end
    end
    img:render(v)
end
function txt:delete(v)
    if v.sprite then
	fnt:put(v.font, v.size)
    end
end

decor = obj {
    nam = '@decor';
    {
	img = img;
	fnt = fnt;
	txt = txt;
    };
    objects = {
    };
    bgcol = 'black';
}
--[[
decor:img{ 'hello', 'img' }
]]--

function decor:new(v)
    local name = v[1]
    local t = v[2]
    if type(name) ~= 'string' then
	std.err("Wrong parameter to decor:new(): name", 2)
    end
    if type(t) ~= 'string' then
	std.err("Wrong parameter to decor:new(): type", 2)
    end
    if self.objects[name] then
	self[t]:delete(self.objects[name])
    end
    if not self[t] or type(self[t].new) ~= 'function' then
	std.err("Wrong type decorator: "..t, 2)
    end
    self.objects[name] = self[t]:new(v)
    return v
end;

function decor:get(n)
    if type(n) ~= 'string' then
	std.err("Wrong parameter to decor:get(): name", 2)
    end
    return self.objects[n]
end

local after_list = {}

function decor:render()
    local list = {}
    after_list = {}
    for _, v in pairs(self.objects) do
	local z = v.z or 0
	if z >= 0 then
	    table.insert(list, v)
	else
	    table.insert(after_list, v)
	end
    end
    table.sort(list, function(a, b)
		   return (a.z or 0) < (b.z or 0)
    end)
    table.sort(after_list, function(a, b)
		   return (a.z or 0) > (b.z or 0)
    end)
    sprite.scr():fill(self.bgcol)
    for _, v in ipairs(list) do
	self[v[2]]:render(v)
    end
end

sprite.render_callback(
    function()
	for _, v in ipairs(after_list) do
	    decor[v[2]]:render(v)
	end
end)

function decor:cache_clear()
    self.img:clear();
    self.fnt:clear();
end

function decor:load()
--	for _, v in pairs(self.fonts) do
--		self:fnt(v)
--	end
--	for _, v in pairs(self.sprites) do
--		self:spr(v)
--	end
	for _, v in pairs(self.objects) do
	    self:new(v)
	end
end

std.mod_start(
function(load)
	theme.set('scr.gfx.scalable', 5)
	if load then
		decor:load()
	end
	decor:render()
end)

std.mod_step(
function(state)
    if not state then
	if std.cmd[1] == '@timer' then
	    decor:cache_clear()
	    decor:render()
	end
	return
    end
    decor:cache_clear()
    decor:render()
end)


function D(n)
	return decor:get(n)
end
