instead = {
}

iface.inv_delim = '\n'
iface.hinv_delim = ' | '
iface.ways_delim = ' | '

instead.get_title = stead.cacheable('title', function()
	return stead.titleof(stead.here())
end)

instead.get_ways = stead.cacheable('ways', function()
	local str = iface:cmd("way");
	if str then
		str = stead.string.gsub(str, '\n$','');
		str = stead.string.gsub(str, '\\?['..stead.delim ..']',
			{ [stead.delim] = iface.ways_delim, [ '\\'..stead.delim ] = stead.delim });
		return iface:center(str);
	end
	return str
end)

instead.get_inv = stead.cacheable('inv', function(horiz)
	local str = iface:cmd("inv");
	if str then
		str = stead.string.gsub(str, '\n$','');
		if not horiz then
			str = stead.string.gsub(str, '\\?['.. stead.delim ..']',
				{ [stead.delim] = iface.inv_delim, ['\\'..stead.delim] = stead.delim });
		else
			str = stead.string.gsub(str, '\\?['.. stead.delim ..']',
				{ [stead.delim] = iface.hinv_delim, ['\\'..stead.delim] = stead.delim });
		end
	end
	return str
end)

function instead.get_picture()
end

function instead.get_fading()
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

function iface:xref(str, o, ...)
	if stead.type(str) ~= 'string' then
		stead.err ("Wrong parameter to iface:xref: "..stead.tostr(str), 2)
	end
	if not stead.is_obj(o) then
		return str
	end
	local a = { ... }
	local args = ''
	for i = 1, #a do
		if stead.type(a[i]) ~= 'string' and stead.type(a[i]) ~= 'number' then
			stead.err ("Wrong argument to iface:xref: "..stead.tostr(a[i]), 2)
		end
		args = args .. ' '..stead.dump(a[i])
	end
	if stead.here().way:lookup(o) then
		return stead.string.format("<a:go %s%s>", stead.deref_str(o), args)..str.."</a>"
	end
	if stead.me():lookup(o) then
		return stead.string.format("<a:%s%s>", stead.deref_str(o), args)..str.."</a>"
	end
	return stead.string.format("<a:act %s%s>", stead.deref_str(o), args)..str.."</a>"
end

function iface:em(str)
	if stead.type(str) == 'string' then
		return '<i>'..str..'</i>'
	end
end

function iface:center(str)
	if stead.type(str) == 'string' then
		return '<c>'..str..'</c>'
	end
end
