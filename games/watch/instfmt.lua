require "fmt"

local get_ways = instead.get_ways

instead.wayfmt = function(str)
	return fmt.c(str)
end

instead.titlefmt = function(str)
	return fmt.c(fmt.b(str))
end

local function get_bool(o, nam)
	if type(o[nam]) == 'boolean' then
		return o[nam]
	end
	if type(o[nam]) == 'function' then
		return o:nam()
	end
	return nil
end

instead.get_ways = std.cacheable('ways', function()
	if get_bool(instead, 'noways') then
		return
	end
	local str = iface:cmd("way");
	if str then
		str = std.string.gsub(str, '\n$','');
		str = std.string.gsub(str, '\\?['..std.delim ..']',
			{ [std.delim] = instead.ways_delim, [ '\\'..std.delim ] = std.delim });
		return instead.wayfmt(str);
	end
	return str
end)

instead.get_title = std.cacheable('title', function()
	if get_bool(instead, 'notitle') then
		return
	end
	return iface:fmt(instead.titlefmt(std.titleof(stead.here())), false)
end)
