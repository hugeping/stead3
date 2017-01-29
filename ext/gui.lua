local std = stead

std.rawset(_G, 'instead', {})

local iface = std '@iface'
local type = std.type

iface.inv_delim = '\n'
iface.hinv_delim = ' | '
iface.ways_delim = ' | '

instead.get_title = std.cacheable('title', function()
	return std.titleof(stead.here())
end)

instead.get_ways = std.cacheable('ways', function()
	local str = iface:cmd("way");
	if str then
		str = std.string.gsub(str, '\n$','');
		str = std.string.gsub(str, '\\?['..std.delim ..']',
			{ [std.delim] = iface.ways_delim, [ '\\'..std.delim ] = std.delim });
		return iface:center(str);
	end
	return str
end)

instead.get_inv = std.cacheable('inv', function(horiz)
	local str = iface:cmd("inv");
	if str then
		str = std.string.gsub(str, '\n$','');
		if not horiz then
			str = std.string.gsub(str, '\\?['.. std.delim ..']',
				{ [std.delim] = iface.inv_delim, ['\\'..std.delim] = std.delim });
		else
			str = std.string.gsub(str, '\\?['.. std.delim ..']',
				{ [std.delim] = iface.hinv_delim, ['\\'..std.delim] = std.delim });
		end
	end
	return str
end)

instead.get_picture = std.cacheable('pic', function()
	local s = stead.call(std.here(), 'pic')
	if not s then
		s = stead.call(std.ref 'game', 'pic')
	end
	return s
end)

function instead.get_fading()
	if std.me():moved() or std.cmd[1] == 'load' then
		if not iface.fading or iface.fading == 0 then
			return false
		end
		return true, iface.fading
	end
end

function instead.get_restart()
	return false
end

function instead.get_menu()
	return false
end

function instead.isEnableSave()
end

function instead.isEnableAutosave()
end

function instead.autosave()
end

function instead.get_autosave()
	return false
end

function iface:title() -- hide title
	return
end

std.stat = std.class({
	__stat_type = true;
	new = function(self, v)
		if type(v) ~= 'table' then
			std.err ("Wrong argument to std.stat:"..std.tostr(v), 2)
		end
		v = std.obj(v)
		std.setmt(v, self)
		return v
	end;
}, std.obj);

std.menu = std.class({
	__menu_type = true;
	new = function(self, v)
		if type(v) ~= 'table' then
			std.err ("Wrong argument to std.menu:"..std.tostr(v), 2)
		end
		v = std.obj(v)
		std.setmt(v, self)
		return v
	end;
	inv = function(s, ...)
		local r, v = std.call(s, 'act', ...)
		if r ~= nil then
			return r, v
		end
		return true, false -- menu mode
	end;
}, std.obj);

function iface:xref(str, o, ...)
	if type(str) ~= 'string' then
		std.err ("Wrong parameter to iface:xref: "..std.tostr(str), 2)
	end
	if not std.is_obj(o) or std.is_obj(o, 'stat') then
		return str
	end
	local a = { ... }
	local args = ''
	for i = 1, #a do
		if type(a[i]) ~= 'string' and type(a[i]) ~= 'number' then
			std.err ("Wrong argument to iface:xref: "..std.tostr(a[i]), 2)
		end
		args = args .. ' '..std.dump(a[i])
	end
	if std.here().way:lookup(o) then
		return std.string.format("<a:go %s%s>", std.deref_str(o), args)..str.."</a>"
	end
	if not o:type 'menu' and std.me():lookup(o) then
		return std.string.format("<a:%s%s>", std.deref_str(o), args)..str.."</a>"
	end
	return std.string.format("<a:act %s%s>", std.deref_str(o), args)..str.."</a>"
end

function iface:em(str)
	if type(str) == 'string' then
		return '<i>'..str..'</i>'
	end
end

function iface:center(str)
	if type(str) == 'string' then
		return '<c>'..str..'</c>'
	end
end

function iface:just(str)
	if type(str) == 'string' then
		return '<j>'..str..'</j>'
	end
end

function iface:left(str)
	if type(str) == 'string' then
		return '<l>'..str..'</l>'
	end
end

function iface:right(str)
	if type(str) == 'string' then
		return '<r>'..str..'</r>'
	end
end

function iface:bold(str)
	if type(str) == 'string' then
		return '<b>'..str..'</b>'
	end
end

function iface:top(str)
	if type(str) == 'string' then
		return '<t>'..str..'</t>'
	end
end

function iface:bottom(str)
	if type(str) == 'string' then
		return '<d>'..str..'</d>'
	end
end

function iface:middle(str)
	if type(str) == 'string' then
		return '<m>'..str..'</m>'
	end
end

function iface:nb(str)
	if type(str) == 'string' then
		return "<w:"..str:gsub("\\", "\\\\\\\\"):gsub(">","\\>"):gsub("%^","\\^")..">";
	end
end

function iface:anchor()
	return '<a:#>'
end

function iface:img(str)
	if type(str) == 'string' then
		return "<g:"..str..">"
	end
end;

function iface:imgl(str)
	if type(str) == 'string' then
		return "<g:"..str.."\\|left>"
	end
end;

function iface:imgr(str)
	if type(str) == 'string' then
		return "<g:"..str.."\\|right>"
	end
end

function iface:under(str)
	if type(str) == 'string' then
		return "<u>"..str.."</u>"
	end
end;

function iface:st(str)
	if type(str) == 'string' then
		return "<s>"..str.."</s>"
	end
end

function iface:tab(str, al)
	if std.tonum(str) then
		str = std.tostr(str)
	end
	if type(str) ~= 'string' then
		return
	end
	if al == 'right' then
		str = str .. ",right"
	elseif al == 'center' then
		str = str .. ",center"
	end
	return '<x:'..str..'>'
end

function iface:y(str, al)
	if stead.tonum(str) then
		str = stead.tostr(str)
	end
	if stead.type(str) ~= 'string' then
		return nil;
	end
	if al == 'middle' then
		str = str .. ",middle"
	elseif al == 'top' then
		str = str .. ",top"
	end
	return '<y:'..str..'>'
end;

-- some aliases
menu = std.menu
stat = std.stat
