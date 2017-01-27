local std = stead

local fmt = std.obj {
	nam = '@format';
	para = false;
	para_space = '    ';
	quotes = false;
	dash = false;
	filter = nil;
	nopara = '_';
}

stead.fmt = stead.hook(stead.fmt, function(f, str, state)
	local utf8
	local r = f(str, state)
	if game.codepage == 'UTF-8' or game.codepage == 'utf-8' then
		utf8 = true
	end
	if stead.type(r) == 'string' and state then
		if stead.type(fmt.filter) == 'function' and stead.state then
			r = fmt.filter(r);
		end
		if fmt.dash and utf8 then
			r = r:gsub('([^-])%-%-([^-])', '%1—%2');
			r = r:gsub('^%-%-([^-])', '—%1');
		end
		if fmt.quotes and utf8 then
			r = r:gsub('_"','«'):gsub('"_',"»");
			r = r:gsub('"([^"]*)"','«%1»');
			r = r:gsub(',,','„'):gsub("''",'”');
		end
		if fmt.para then
			r = r:gsub('\n([^\n])', '<&para;>%1'):gsub('<&para;>[ \t]*'..fmt.nopara,'\n'):gsub('<&para;>[ \t]*', '\n'..iface:nb(fmt.para_space));
			r = r:gsub('^[ \t]*', '<&para;>'):gsub('<&para;>[ \t]*'..fmt.nopara,''):gsub('<&para;>[ \t]*', iface:nb(fmt.para_space));
		end
	end
	return r;
end)

format = fmt
