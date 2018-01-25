require "sprite"
require "theme"
require "click"

decor = obj {
	nam = '@decor';
	{
		sprites = {
			images = {
			}
		};
	};
	objects = {
	};
	bgcol = 'black';
	new = function(self, v)
		local name = v[1]
		local t = v[2]
		if type(name) ~= 'string' then
			std.err("Wrong parameter to decor:new(): name", 2)
		end
		if type(t) ~= 'string' then
			std.err("Wrong parameter to decor:new(): type", 2)
		end
		if self.objects[name] then
			self.objects[name] = nil
		end
		if not self["make_"..t] then
			std.err("Wrong type decorator: "..t, 2)
		end
		self["make_"..t](self, v);
		self.objects[name] = v;
		return v
	end;
}

function decor:get(n)
	if type(n) ~= 'string' then
		std.err("Wrong parameter to decor:get(): name", 2)
	end
	return self.objects[n]
end

function decor:make_image(v)
	local fname = v[3]
	if type(fname) ~= 'string' then
		std.err("Wrong filename in image")
	end
	if not self.sprites.images[fname] then
		self.sprites.images[fname] = sprite.new(fname)
	end
	local sp = self.sprites.images[fname]
	if not sp then
		std.err("Can not load sprite: "..fname)
	end
	v.xc = v.xc or 0
	v.yc = v.yc or 0
	v.sprite = sp
	local w, h = sp:size()
	if v.w then w = v.w end
	if v.h then h = v.h end
	if v.xc == true then
		v.xc = math.floor(w / 2)
	end
	if v.yc == true then
		v.yc = math.floor(h / 2)
	end
end

function decor:make_text(v)

end

function decor:render()
	local list = {}
	for _, v in pairs(self.objects) do
		local z = v.z or 0
		if z >= 0 then
			table.insert(list, v)
		end
	end
	table.sort(list, function(a, b)
		return (a.z or 0) < (b.z or 0)
	end)
	sprite.scr():fill(self.bgcol)
	for _, v in ipairs(list) do
		if v.fx and v.fy and v.w and v.h then
			v.sprite:draw(v.fx, v.fy, v.w, v.h, sprite.scr(), v.x - v.xc, v.y - v.yc)
		else
			v.sprite:draw(sprite.scr(), v.x - v.xc, v.y - v.yc)
		end
	end
end

function decor:load()
	for _, v in pairs(self.objects) do
		self:new(v)
	end
end

std.mod_start(
function(load)
	if load then
		decor:load()
	end
	decor:render()
end)

std.mod_step(
function(state)
	if not state then
		return
	end
	decor:render()
end)


function D(n)
	return decor:get(n)
end
