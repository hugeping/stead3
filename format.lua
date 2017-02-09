local std = stead
local type = std.type
local iface = std.ref '@iface'

local fmt = std.obj {
	nam = '@format';
	para = false;
	nopara = '_';
	para_space = '    ';
	quotes = true;
	dash = true;
	filter = nil;
}

stead.fmt = stead.hook(stead.fmt, function(fn, str, state)
	local utf8
	local r = fn(str, state)
	if game.codepage == 'UTF-8' or game.codepage == 'utf-8' then
		utf8 = true
	end
	if type(r) ~= 'string' then
		return r
	end
	if type(fmt.filter) == 'function' then
		r = fmt.filter(r, state);
	end
	if not state then
		return r
	end
	if fmt.dash and utf8 then
		r = r:gsub('([^-])%-%-([^-])', '%1—%2');
		r = r:gsub('^%-%-([^-])', '—%1'):gsub("^—[ \t]+", "— ");
	end
	if fmt.quotes and utf8 then
		r = r:gsub('_"','«'):gsub('"_',"»");
		r = r:gsub('"([^"]*)"','«%1»');
		r = r:gsub(',,','„'):gsub("''",'”');
	end
	if fmt.para then
		r = r:gsub('\n([^\n])', '\001%1'):gsub('\001[ \t]*'..fmt.nopara,'\n'):gsub('\001[ \t]*', '\n'..iface:nb(fmt.para_space));
		r = r:gsub('^[ \t]*', '\001'):gsub('\001[ \t]*'..fmt.nopara,''):gsub('\001[ \t]*', iface:nb(fmt.para_space));
	end
	return r;
end)

format = fmt
