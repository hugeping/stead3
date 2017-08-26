require "timer"
require "sprite"

local std = stead
loader = obj {
	old_timer = 0;
	loading = false;
	nam = "@loader";
	{
		d = {};
		load = false;
		__loaded = false;
	};
}

function loader.step(progress)
	loader.__progress = progress
	coroutine.yield()
end

function loader:loaded(st)
	local ov = self.__loaded
	if st ~= nil then self.__loaded = st end
	if self.__loaded then
		timer:set(loader.old_timer)
		loader.loading = false
	end
	return ov
end

function loader:data()
	return self.d
end

function timer:callback()
	if loader.loading then
		if loader:loaded() then
			return '@splash,loaded'
		end
		local t = instead.ticks()
		while coroutine.status(loader.load) ~= "dead" do
			coroutine.resume(loader.load, loader.d)
			if instead.ticks() - t > 20 then
				std.busy()
				return '@splash'
			end
		end
		loader:loaded(true)
		return '@splash,loaded'
	end
	return "@timer"
end

std.mod_start(function(onload)
	loader.load = coroutine.create(load)
	loader.old_timer = timer:get()
	loader.loading = true
	timer:set(20)
end)

std.mod_cmd(function(cmd)
	if cmd[1] ~= '@splash' then
		return
	end
	if cmd[2] == 'loaded' then
		onload()
		sprite.direct(false)
		return std.nop()
	end
	local scr
	if not sprite.direct() then
		sprite.direct(true)
		scr = sprite.scr()
		scr:fill('black')
	else
		scr = sprite.scr()
	end
	local w, h = scr:size()
	scr:fill(0, h - 16, w, 16, 'black')
	scr:fill(0, h - 16, w * loader.__progress or 0, 16, 'red')
end)
