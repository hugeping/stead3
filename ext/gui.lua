local std = stead

std.rawset(_G, 'instead', {})

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

function instead.get_picture()
end

function instead.get_fading()
	if std.me():moved() or iface.curcmd[1] == 'load' then
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

function iface:xref(str, o, ...)
	if std.type(str) ~= 'string' then
		std.err ("Wrong parameter to iface:xref: "..std.tostr(str), 2)
	end
	if not std.is_obj(o) or std.is_obj(o, 'stat') then
		return str
	end
	local a = { ... }
	local args = ''
	for i = 1, #a do
		if std.type(a[i]) ~= 'string' and std.type(a[i]) ~= 'number' then
			std.err ("Wrong argument to iface:xref: "..std.tostr(a[i]), 2)
		end
		args = args .. ' '..std.dump(a[i])
	end
	if std.here().way:lookup(o) then
		return std.string.format("<a:go %s%s>", std.deref_str(o), args)..str.."</a>"
	end
	if std.me():lookup(o) then
		return std.string.format("<a:%s%s>", std.deref_str(o), args)..str.."</a>"
	end
	return std.string.format("<a:act %s%s>", std.deref_str(o), args)..str.."</a>"
end

function iface:em(str)
	if std.type(str) == 'string' then
		return '<i>'..str..'</i>'
	end
end

function iface:center(str)
	if std.type(str) == 'string' then
		return '<c>'..str..'</c>'
	end
end
