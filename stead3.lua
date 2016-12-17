stead = {
	space_delim = ' ';
	scene_delim = '^^';
	call_top = 0,
	call_ctx = { txt = nil, self = nil },
	objects = {};
	tables = {};
	tostr = tostring;
	tonum = tonumber;
	type = type;
	err = error;
	setmt = setmetatable;
	getmt = getmetatable;
	table = table;
	pairs = pairs;
	ipairs = ipairs;
	rawset = rawset;
	rawget = rawget;
	string = string;
	next = next;
	getinfo = debug.getinfo;
	__mod_init = {},
	__mod_done = {},
	__mod_start = {},
	__mod_cmd = {},
	__mod_save = {},
	mod_init = function(f, ...)
		if stead.type(f) ~= 'function' then
			error ("Wrong parameter to mod_init.", 2);
		end
		stead.table.insert(stead.__mod_init, f);
		f();
	end;
	mod_done = function(f, ...)
		if stead.type(f) ~= 'function' then
			error ("Wrong parameter to mod_done.", 2);
		end
		stead.table.insert(stead.__mod_done, f);
	end;
	mod_start = function(f, ...)
		if stead.type(f) ~= 'function' then
			error ("Wrong parameter to mod_start.", 2);
		end
		stead.table.insert(stead.__mod_start, f);
	end;
	mod_cmd = function(f, ...)
		if stead.type(f) ~= 'function' then
			error ("Wrong parameter to mod_cmd.", 2);
		end
		stead.table.insert(stead.__mod_cmd, f);
	end;
	mod_save = function(f, ...)
		if stead.type(f) ~= 'function' then
			error ("Wrong parameter to mod_save.", 2);
		end
		stead.table.insert(stead.__mod_save, f);
	end;
}

if _VERSION == "Lua 5.1" then
	stead.eval = loadstring
	stead.unpack = unpack
else
	stead.eval = load
	stead.unpack = table.unpack
	stead.table.maxn = table_get_maxn
	string.gfind = string.gmatch
	math.mod = math.fmod
	math.log10 = function(a)
		return stead.math.log(a, 10)
	end
end

stead.fmt = function(...)
	local res
	local a = {...};

	for i = 1, #a do
		if stead.type(a[i]) == 'string' then
			local s = stead.string.gsub(a[i],'[\t ]+', stead.space_delim);
			s = stead.string.gsub(s, '[\n]+', stead.space_delim);
			s = stead.string.gsub(s, '\\?[\\^]', { ['^'] = '\n', ['\\^'] = '^', ['\\\\'] = '\\'} );
			res = stead.par('', res, s);
		end
	end
	return res
end

local lua_keywords = {
	["and"] = true,
	["break"] = true,
	["do"] = true,
	["else"] = true,
	["elseif"] = true,
	["end"] = true,
	["false"] = true,
	["for"] = true,
	["function"] = true,
	["goto"] = true,
	["if"] = true,
	["in"] = true,
	["local"] = true,
	["nil"] = true,
	["not"] = true,
	["or"] = true,
	["repeat"] = true,
	["return"] = true,
	["then"] = true,
	["true"] = true,
	["until"] = true,
	["while"] = true,
}

stead.setmt(stead, {
	__call = function(s, k)
		return stead.ref(k)
	end;
})

function stead.is_obj(v, t)
	if stead.type(v) ~= 'table' then
		return false
	end
	return v['__'..(t or 'obj')..'_type']
end

function stead.class(s, inh)
	s.__call = function(s, ...)
		return s:new(...)
	end;
	s.__tostring = function(s)
		return stead.dispof(s)
	end;
	s.__dirty = function(s, v)
		local o = s.__dirty_flag
		if v ~= nil and stead.initialized then
			stead.rawset(s, '__dirty_flag', v)
		end
		return o
	end;
	s.__index = function(t, k)
		local v = stead.rawget(t, '__ro')
		if v then
			v = stead.rawget(v, k)
			if v ~= nil then
				return v
			end
		end
		return s[k]
	end;
	s.__newindex = function(t, k, v)
		local ro
		if stead.is_obj(t) and stead.type(k) == 'string' then
			ro = t.__ro
		end
		if not stead.initialized and ro then
			stead.rawset(ro, k, v)
			return
		end
		s:__dirty(true)
		if ro then
			if stead.type(v) ~= 'function' then
				t.__var[k] = true
			end
			ro[k] = nil
		end
		if stead.is_obj(v, 'list') then
			if stead.type(t.__list) == 'table' then
				t:attach(v)
			end
		end
		stead.rawset(t, k, v)
	end
	stead.setmt(s, inh or { __call = s.__call })
	return s
end

stead.list = stead.class {
	__list_type = true;
	new = function(s, v)
		if stead.type(v) ~= 'table' then
			stead.err ("Wrong argument to stead.list:"..stead.tostr(v), 2)
		end
		if stead.is_obj(v, 'list') then -- already list
			return v
		end
		v.__list = {} -- list of obj
		stead.setmt(v, s)
		return v
	end;
	ini = function(s)
		for i = 1, #s do
			local k = s[i]
			s[i] = stead.ref(k)
			if s[i] == nil then
				stead.err("Wrong item in list: "..stead.tostr(k), 2)
			end
			s:attach(s[i])
		end
	end;
	look = function(s)
		local r
		for i = 1, #s do
			if r then
				r = r .. stead.space_delim
			end
			local o = s[i]
			if not o:disabled() then
				local d = o:xref(stead.call(s[i], 'dsc'))
				if stead.type(d) == 'string' then
					r = (r or '').. d
				end
				if not o:closed() then
					d = o.obj:look()
					if stead.type(d) == 'string' then
						r = (r or '') .. d
					end
				end
			end
		end
		return r
	end;
	disable = function(s)
		for i = 1, #s do
			s[i]:disable()
		end
	end;
	enable = function(s)
		for i = 1, #s do
			s[i]:enable()
		end
	end;
	close = function(s)
		for i = 1, #s do
			s[i]:close()
		end
	end;
	open = function(s)
		for i = 1, #s do
			s[i]:open()
		end
	end;
	attach = function(s, o)
		s:detach(o)
		stead.table.insert(o.__list, s)
	end;
	detach = function(s, o)
		for i = 1, #o.__list do
			if o.__list[i] == s then
				stead.table.remove(o.__list, i)
				break
			end
		end
	end;
	add = function(s, n, pos)
		if s:lookup(n) then
			return -- already here
		end
		if not pos then
			local o = stead.ref(n)
			s:__dirty(true)
			s:attach(o)
			stead.table.insert(s, o)
			return o
		end
		if stead.type(pos) ~= 'number' then
			stead.err("Wrong parameter to list.add:"..stead.tostr(pos), 2)
		end
		if pos > #s then
			pos = #s
		elseif pos < 0 then
			pos = #s + pos + 1
		end
		if pos <= 0 then
			pos = 1
		end
		local o = stead.ref(n)
		s:__dirty(true)
		s:attach(o)
		stead.table.insert(s, o)
		return o
	end;
	lookup = function(s, n)
		local o = stead.ref(n)
		for i = 1, #s do
			if s[i] == o then
				return o, i
			end
		end
	end;
	seen = function(s, n)
		for i = 1, #s do
			local o = stead.ref(s[i])
			if stead.dispof(o) == n then
				return o, i
			end
		end
	end;
	del = function(s, n)
		local o, i = s:lookup(n)
		if i then
			s:__dirty(true)
			s:detach(o)
			return o
		end
	end;
	save = function(s, fp, n)
		if not s:__dirty() then
			return
		end
		fp:write(stead.string.format("%s = stead.list { ", n))
		for i = 1, #s do
			local vv = stead.deref(s[i])
			if not vv then
				stead.err ("Can not do deref on: "..stead.tostr(s[i]), 2)
			end
			if i ~= 1 then
				fp:write(stead.string.format(", %q", vv))
			else
				fp:write(stead.string.format("%q", vv))
			end
		end
		fp:write(" }\n")
	end;
}
stead.save_var = function(vv, fp, n)
	if stead.type(vv) == 'boolean' or stead.type(vv) == 'number' then
		fp:write(stead.string.format("%s = ", n))
		fp:write(stead.tostr(vv)..'\n')
	elseif stead.type(vv) == 'string' then
		fp:write(stead.string.format("%s = ", n))
		fp:write(stead.string.format("%q\n", vv))
	elseif stead.type(vv) == 'table' then
		if stead.tables[vv] then
			local k = stead.tables[vv]
			fp:write(stead.string.format("%s = %s\n", n, k))
		elseif stead.is_obj(vv) then
			local d = stead.deref(vv)
			if not d then
				stead.err("Can not deref object:"..stead.tostr(vv), 2)
			end
			fp:write(stead.string.format("%s = ", n))
			if stead.type(d) == 'string' then
				fp:write(stead.string.format("stead %q\n", d))
			else
				fp:write(stead.string.format("stead(%d)\n", d))
			end
		elseif stead.type(vv.save) == 'function' then
			vv:save(fp, n)
		else
			fp:write(stead.string.format("%s = %s\n", n,  stead.dump(vv)))
--			stead.save_table(vv, fp, n)
		end
	end
end

stead.save_table = function(vv, fp, n)
	local l
	fp:write(stead.string.format("%s = {}\n", n))
	for k, v in stead.pairs(vv) do
		l = nil
		if stead.type(k) == 'number' then
			l = stead.string.format("%s%s", n, stead.varname(k))
			stead.save_var(v, fp, l)
		elseif stead.type(k) == 'string' then
			l = stead.string.format("%s%s", n, stead.varname(k))
			stead.save_var(v, fp, l)
		end
	end
end

function stead.save(fp)
	for i = 1, #stead.__mod_save do
		stead.__mod_save[i](fp);
	end
	local oo = stead.objects
	for i = 1, #oo do
		oo[i]:save(fp, stead.string.format("stead(%d)", i))
	end
	for k, v in stead.pairs(oo) do
		if stead.type(k) == 'string' then
			v:save(fp, stead.string.format("stead %q", k))
		end
	end
end

function stead.init(fp)
	local oo = stead.objects
	for i = 1, #oo do
		oo[i]:ini()
	end
	for k, v in stead.pairs(oo) do
		if stead.type(k) ~= 'number' then
			v:ini()
		end
	end
	for i = 1, #stead.__mod_init do
		stead.__mod_init[i]();
	end
	stead.initialized = true
end

function stead.done(fp)
	stead.initialized = false
	for i = 1, #stead.__mod_init do
		stead.__mod_done[i]();
	end
	local objects = {}
	for k, v in stead.pairs(stead.objects) do
		if stead.type(k) == 'string' and k:byte(1) == 0x40 then
			objects[k] = v
		end
	end
	stead.objects = objects
end

function stead.dirty(o)
	if stead.type(o) ~= 'table' or stead.type(o.__dirty) ~= 'function' then
		return false
	end
	return o:__dirty()
end

function stead.varname(k)
	if stead.type(k) == 'number' then
		return stead.string.format("[%d]", k)
	elseif stead.type(k) == 'string' then
		if not lua_keywords[k] then
			return stead.string.format(".%s", k)
		else
			return stead.string.format("[%q]", k)
		end
	end
end

stead.obj = stead.class {
	__obj_type = true;
	new = function(self, v)
		if stead.initialized and not stead.__in_new then
			stead.err ("Use stead.new() to create dynamic objects:"..stead.tostr(v), 2)
		end
		local oo = stead.objects
		if stead.type(v) ~= 'table' then
			stead.err ("Wrong argument to stead.obj:"..stead.tostr(v), 2)
		end
		if v.nam == nil then
			stead.rawset(v, 'nam', #oo + 1)
		end
		if stead.type(v.nam) ~= 'string' and stead.type(v.nam) ~= 'number' then
			stead.err ("Wrong .nam in object.", 2)
		end
		if oo[v.nam] then
			stead.err ("Duplicated object: "..v.nam, 2)
		end
		local ro = {}
		local vars = {}
		for i = 1, #v do
			for key, val in stead.pairs(v[i]) do
				if stead.type(key) ~= 'string' then
					stead.err("Wrong var name: "..stead.tostr(key), 2)
				end
				vars[key] = true
				stead.rawset(v, key, val)
			end
		end
		for i = 1, #v do
			stead.table.remove(v, 1)
		end
		if not v.obj then
			stead.rawset(v, 'obj', {})
		end
		if stead.type(v.obj) ~= 'table' then
			stead.err ("Wrong .obj attr in object:" .. v.nam, 2)
		end
		v.obj = stead.list(v.obj)
		stead.table.insert(v.obj.__list, v)
		for key, val in stead.pairs(v) do
			ro[key] = val
			stead.rawset(v, key, nil)
		end
		stead.rawset(v, '__ro', ro)
		stead.rawset(v, '__var', vars)
		stead.rawset(v, '__list', {}) -- in list(s)
		oo[ro.nam] = v
		stead.setmt(v, self)
		return v
	end;
	ini = function(s)
		for k, v in stead.pairs(s) do
			if stead.type(v) == 'table' and stead.type(v.ini) == 'function' then
				v:ini()
			end
		end

		for k, v in stead.pairs(s.__ro) do
			if stead.type(v) == 'table' and stead.type(v.ini) == 'function' then
				v:ini()
			end
		end
	end;
	where = function(s)
		local list = s.__list
		local r = { }
		for i = 1, #list do
			local l = list[i]
			local ll = l.__list
			for k = 1, #ll do
				stead.table.insert(r, ll[k])
			end
		end
		return r[1], r
	end;
	close = function(s)
		s.__closed = true
	end;
	open = function(s)
		s.__closed = false
	end;
	closed = function(s)
		return s.__closed
	end;
	disable = function(s)
		s.__disabled = true
	end;
	enable = function(s)
		s.__disabled = false
	end;
	disabled = function(s)
		return s.__disabled
	end;
	save = function(s, fp, n)
		if s.__dynamic then -- create
			local l = stead.string.format("stead.new(%q, %s) -- %s\n", s.__dynamic.fn, s.__dynamic.arg, n)
			fp:write(l)
		end
		for k, v in stead.pairs(s.__var) do
			local l = stead.string.format("%s%s", n, stead.varname(k))
			stead.save_var(s[k], fp, l)
		end
		for k, v in stead.pairs(s.__ro) do
			if stead.dirty(v) then
				local l = stead.string.format("%s%s", n, stead.varname(k))
				stead.save_var(s[k], fp, l)
			end
		end
	end;
	xref = function(self, str)
		function xrefrep(str)
			local s = stead.string.gsub(str,'[\001\002]','');
			return iface.xref(self, s);
		end
		if stead.type(str) ~= 'string' then
			return
		end
		local s = stead.string.gsub(str, '\\?[\\{}]',
			{ ['{'] = '\001', ['}'] = '\002', [ '\\{' ] = '{', [ '\\}' ] = '}' }):gsub('\001([^\002]+)\002', xrefrep):gsub('[\001\002]', { ['\001'] = '{', ['\002'] = '}' });
		return s;
	end
};

stead.room = stead.class({
	__room_type = true;
	from  = function(self)
		return s.__where or self
	end;
	new = function(self, v)
		if stead.type(v) ~= 'table' then
			stead.err ("Wrong argument to stead.room:"..stead.tostr(v), 2)
		end
		if not v.way then
			stead.rawset(v, 'way',  {})
		end
		if stead.type(v.way) ~= 'table' then
			stead.err ("Wrong .way attr in object:" .. v.nam, 2)
		end
		v.way = stead.list(v.way)
		stead.table.insert(v.way.__list, v)
		v = stead.obj(v)
		stead.setmt(v, self)
		return v
	end;
}, stead.obj);

stead.game = stead.class({
	__game_type = true;
	new = function(self, v)
		if stead.type(v) ~= 'table' then
			stead.err ("Wrong argument to stead.pl:"..stead.tostr(v), 2)
		end
		if not v.player then
			v.player = 'player'
		end
		v = stead.obj(v)
		if v.lifes == nil then
			stead.rawset(v, 'lifes', {})
		end
		v.lifes = stead.list(v.lifes)
		stead.setmt(v, self)
		return v
	end;
	ini = function(s)
		stead.rawset(s, 'player', stead.ref(s.player))
		if not s.player then
			stead.err ("Wrong player", 2)
		end
		stead.obj.ini(s)
	end;
	life = function(s)
		for i = 1, #s.lifes do
			local v
			local pre
			local o = s.lifes[i]
			if not o:disabled() then
				v, pre = stead.call(o, 'life');
			end
		end
	end;
	disp = function(s, reaction, state)
		local r, objs

		r = stead.here()

		if state then
			objs = r.obj:look()
		end
		return stead.par(stead.scene_delim, reaction, objs), state
	end;
	cmd = function(s, cmd)
		local r, v, pv, av
		if cmd[1] == nil or cmd[1] == 'look' then
			r, v = s.player:look()
		end
		if v == false then
			return r, false -- wrong cmd?
		end
		if v then -- game:step
--			pv, av = s:step()
		end
		return s:disp(r, v)
	end;
}, stead.obj);

stead.player = stead.class ({
	__player_type = true;
	new = function(self, v)
		if stead.type(v) ~= 'table' then
			stead.err ("Wrong argument to stead.pl:"..stead.tostr(v), 2)
		end
		if not v.room then
			v.room = 'main'
		end
		v = stead.obj(v)
		stead.setmt(v, self)
		return v
	end;
	ini = function(s)
		stead.rawset(s, 'room', stead.ref(s.room))
		if not s.where then
			std.err ("Wrong player location", 2)
		end
		stead.obj.ini(s)
	end;
	reaction = function(s, t)
		local o = s.__reaction
		if t == nil then
			return o
		end
		s.__reaction = t
		return o
	end;
	look = function(s)
		local r = s:where()
		local title = iface.title(stead.titleof(r))
		local dsc = stead.call(r, 'dsc')
		return stead.par(stead.scene_delim, title, dsc), true
	end;
	useit = function(s, w1, w2)
		local r, v, t
		w1 = stead.ref(w)
		w2 = stead.ref(w2)

		if w2 and w1 ~= w2 then
			return s:call('use', w1, w2)
		end
		-- inv mode?
		return s:call('inv', w1, w2)
	end;
	call = function(s, m, w, w2, ...)
		if stead.type(m) ~= 'string' then
			stead.err ("Wrong method in player.call: "..stead.tostr(m), 2)
		end

		w = stead.ref(w)
		if not stead.is_obj(w) then
			stead.err ("Wrong parameter to player.call: "..stead.tostr(w), 2)
		end

		local r, v, t
		r, v = stead.call(game, 'on'..m, w, w2, ...)
		t = stead.par(stead.space_delim, t, r)
		if v == false then
			return t, true
		end
		if v ~= true then
			r, v = stead.call(s, 'on'..m, w, w2, ...)
			t = stead.par(stead.space_delim, t, r)
			if v == false then
				return t, true
			end
		end
		if v ~= true then
			r, v = stead.call(s:where(), 'on'..m, w, w2, ...)
			t = stead.par(stead.space_delim, t, r)
			if v == false then
				return t, true
			end
		end
		if m == 'use' and w2 then
			r, v = stead.call(w2, 'onuse', w, w2, ...)
			if r ~= nil or v ~= nil then
				return r, false -- stop chain
			end
		end
		r, v = stead.call(w, m, w, w2, ...)
		t = stead.par(stead.space_delim, t, r)
		if v ~= nil or r ~= nil then
			return t, v
		end
		r, v = stead.call(game, m, w, w2, ...)
		t = stead.par(stead.space_delim, t, r)
		return t, v
	end;
	action = function(s, w, ...)
		return s:call('act', w, ...)
	end;
	walkin = function(s, w)
		return s:walk(w, true, false)
	end;
	walkout = function(s, w)
		if w == nil then
			w = s:where():from()
		end
		return s:walk(w, false, true)
	end;
	walk = function(s, w, noexit, noenter)
		w = stead.ref(w)
		if not w then
			stead.err("Wrong parameter to walk: "..stead.tostr(w))
		end

		local inwalk = s.__in_walk

		s.__in_walk = w

		if inwalk then
			return
		end

		local r, v, t
		local f = s:where()
		r, v = stead.call(game, 'onwalk', s.__in_walk)
		t = stead.par(stead.scene_delim, t, r)

		if v == false then -- stop walk
			s.__in_walk = nil
			return t, true
		end

		if v ~= true then
			r, v = stead.call(s, 'onwalk', s.__in_walk)
			t = stead.par(stead.scene_delim, t, r)
			if v == false then
				s.__in_walk = nil
				return t, true
			end
		end

		if v ~= true then
			if not noexit then
				r, v = stead.call(s:where(), 'onexit', s.__in_walk)
				t = stead.par(stead.scene_delim, t, r)
				if v == false then
					s.__in_walk = nil
					return t, true
				end
			end
			if not noenter then
				r, v = stead.call(s.__in_walk, 'onenter', s:where())
				t = stead.par(stead.scene_delim, t, r)
				if v == false then
					s.__in_walk = nil
					return t, true
				end
			end
		end
		if not noexit then
			r, v = stead.call(s:where(), 'exit', s.__in_walk)
			t = stead.par(stead.scene_delim, t, r)
		end
		if not noenter then
			s.room = s.__in_walk
			s.room.__from = f
			r, v = stead.call(s.__in_walk, 'enter', f)
			t = stead.par(stead.scene_delim, t, r)
		end
		s.room = s.__in_walk
		s.__in_walk = nil
		return t, true
	end;
	where = function(s)
		return s.room
	end;
}, stead.obj)

-- merge strings with "space" as separator
stead.par = function(space, ...)
	local res
	local a = { ... };
	for i = 1, #a do
		if stead.type(a[i]) == 'string' then
			if res == nil then
				res = ""
			else
				res = res .. space;
			end
			res = res .. a[i];
		end
	end
	return res;
end
-- add to not nill string any string
stead.cat = function(v,...)
	if not v then
		return nil
	end
	if type(v) ~= 'string' then
		stead.err("Wrong parameter to stead.cat: "..stead.tostr(v), 2);
	end
	local a = { ... }
	for i = 1, #a do
		if stead.type(a[i]) == 'string' then
			v = v .. a[i];
		end
	end
	return v;
end

stead.cctx = function()
	return stead.call_ctx[stead.call_top];
end

stead.callpush = function(v, ...)
	stead.call_top = stead.call_top + 1;
	stead.call_ctx[stead.call_top] = { txt = nil, self = v, action = false };
end

stead.callpop = function()
	stead.call_ctx[stead.call_top] = nil;
	stead.call_top = stead.call_top - 1;
	if stead.call_top < 0 then
		stead.err ("callpush/callpop mismatch")
	end
end

stead.pclr = function()
	stead.cctx().txt = nil
end

stead.pget = function()
	return stead.cctx().txt or '';
end

stead.p = function(...)
	local a = {...}
	if stead.cctx() == nil then
		error ("Call from global context.", 2);
	end
	for i = 1, #a do
		stead.cctx().txt = stead.par('', stead.cctx().txt, stead.tostr(a[i]));
	end
	stead.cctx().txt = stead.cat(stead.cctx().txt, stead.space_delim);
end


function stead.dump(t)
	local rc = '';
	if stead.type(t) == 'string' then
		rc = stead.string.format("%q", t):gsub("\\\n", "\\n")
	elseif stead.type(t) == 'number' then
		rc = stead.tostr(t)
	elseif stead.type(t) == 'boolean' then
		rc = stead.tostr(t)
	elseif stead.type(t) == 'table' then
		if stead.tables[t] then
			local k = stead.tables[t]
			return stead.string.format("%s", k)
		elseif stead.is_obj(t) then
			local d = stead.deref(t)
			if stead.type(d) == 'number' then
				rc = stead.string.format("stead(%d)", d)
			else
				rc = stead.string.format("stead %q", d)
			end
			return rc
		end
		local k,v
		local nkeys = {}
		local keys = {}
		for k,v in pairs(t) do
			if type(k) == 'number' then
				table.insert(nkeys, { key = k, val = v })
			else
				table.insert(keys, { key = k, val = v })
			end
		end
		table.sort(nkeys, function(a, b) return a.key < b.key end)
		rc = "{ "
		local n
		for k = 1, #nkeys do
			v = nkeys[k]
			if v.key == k then
				rc = rc .. stead.dump(v.val)..", "
			else
				n = k
				break
			end
		end
		if n then
			for k = n, #nkeys do
				v = nkeys[k]
				rc = rc .. "["..tostring(v.key).."] = "..stead.dump(v.val)..", "
			end
		end
		for k = 1, #keys do
			v = keys[k]
			if type(v.key) == 'string' then
				if v.key:find("^[a-zA-Z_]+[a-zA-Z0-9_]*$") and not lua_keywords[v.key] then
					rc = rc .. v.key .. " = "..stead.dump(v.val)..", "
				else
					rc = rc .. "[" .. string.format("%q", v.key) .. "] = "..stead.dump(v.val)..", "
				end
			else
				rc = rc .. tostring(v.key) .. " = "..stead.dump(v.val)..", "
			end
		end
		rc = rc:gsub(",[ \t]*$", "") .. " }"
	end
	return rc
end

function stead.new(fn, ...)
	if stead.type(fn) ~= 'string' then
		std.err ("Wrong parameter to stead.new", 2)
	end
	local arg = { ... }
	local l = ''
	for i = 1, #arg do
		if i ~= 1 then
			l = ", "..l
		end
		l = stead.string.format("%s%s", l, stead.dump(arg[i]))
	end
	stead.__in_new = true
	local f, r = stead.eval("return "..fn.."("..l..")")
	stead.__in_new = false
	local o
	if stead.type(r) == 'string' then
		stead.err("Wrong constructor: "..r, 2)
	end
	if stead.type(f) == 'function' then
		o = f()
	end
	if stead.type(o) ~= 'table' then
		stead.err ("Constructor did not return object:"..fn.."("..l..")", 2)
	end
	stead.rawset(o, '__dynamic', { fn = fn, arg = l })
	return o
end

function stead.delete(s)
	if stead.is_obj(s) then
		if stead.type(s.nam) == 'number' then
			stead.table.remove(stead.objects, s.nam)
			for i = s.nam, #stead.objects do
				stead.rawset(stead.objects[i], 'nam', i)
			end
		else
			stead.objects[s.nam] = nil
		end
	else
		stead.err("Delete non object table", 2)
	end
end

function stead.var(v)
	if stead.type(v) ~= 'table' then
		stead.err ("Wrong argument to stead.var:"..stead.tostr(v), 2)
	end
	return v
end

function stead.dispof(o)
	o = stead.ref(o)
	if not stead.is_obj(o) then
		stead.err("Wrong parameter to stead.dispof", 2)
		return
	end
	if o.disp ~= nil then
		return stead.call(o, 'disp')
	end
	return o.nam
end

function stead.titleof(o)
	o = stead.ref(o)
	if not stead.is_obj(o) then
		stead.err("Wrong parameter to stead.titleof", 2)
		return
	end
	if o.title ~= nil then
		return stead.call(o.title)
	end
	return stead.dispof(o)
end

function stead.ref(o)
	if type(o) == 'table' then
		return o
	end
	local oo = stead.objects
	if oo[o] then
		return oo[o]
	end
end

function stead.deref(o)
	if stead.is_obj(o) then
		return o.nam
	elseif stead.ref(o) then
		return o
	end
end

stead.method = function(v, n, ...)
	if stead.type(v) ~= 'table' then
		stead.err ("Call on non table object:"..stead.tostr(n), 2);
	end
	if v[n] == nil then
		return
	end
	if stead.type(v[n]) == 'string' then
		return v[n], true;
	end
	if stead.type(v[n]) == 'function' then
		stead.callpush(v, ...)
		local a, b = v[n](v, ...);
		if stead.type(a) ~= 'string' then
			a, b = stead.pget(), a
		end
		stead.callpop()
		return a, b
	end
	if stead.type(v[n]) == 'boolean' then
		return v[n], true
	end
	if stead.type(v[n]) == 'table' then
		return v[n], true
	end
	stead.err ("Method not string nor function:"..stead.tostr(n), 2);
end

stead.call = function(v, n, ...)
	local r, v = stead.method(v, n, ...)
	if stead.type(r) == 'string' then return r end
	return
end

local function get_token(inp)
	local q, k
	local rc = ''
	k = 1
	if inp:sub(1, 1) == '"' then
		q = true
		k = k + 1
	end
	while true do
		local c = inp:sub(k, k)
		if c == '' then
			if q then
				return false
			end
			return rc, k
		end
		if c == '"' and q then
			k = k + 1
			break
		end
		if not q and (c == ' ' or c == ',' or c == '\t') then
			break
		end
		if q and c == '\\' then
			k = k + 1
			c = inp:sub(k, k)
			rc = rc .. c
		else
			rc = rc .. c
		end
		k = k + 1
	end
	if not q and stead.tonum(rc) then rc = stead.tonum(rc) end
	return rc, k
end

local function cmd_parse(inp)
	local cmd = {}
	if stead.type(inp) ~= 'string' then
		return false
	end
	inp = inp:gsub("[ \t]*$", "")
	while true do
		inp = inp:gsub("^[ ,\t]*","")
		local v, i = get_token(inp)
		inp = inp:sub(i)
		if not v or v == '' then
			break
		end
		stead.table.insert(cmd, v)
	end
	return cmd
end

function stead.me()
	return game.player
end

function stead.here()
	return stead.me().room
end

iface = {
	cmd = function(inp)
		local cmd = cmd_parse(inp)
		if not cmd then
			return "Error in cmd arguments", false
		end
		local r, v = game:cmd(cmd)
		if v == false then
			return r, false
		end
		if v == true then
			r = iface.fmt(r)
		end
		return r, v
	end;
	xref = function(obj, str)
		obj = stead.ref(obj)
		if not obj then
			return str;
		end
		return stead.cat(str, "("..stead.deref(obj)..")");
	end;
	title = function(str)
		return "[ "..stead.tostr(str).." ]"
	end;
	fmt = function(str)
		if stead.type(str) ~= 'string' then
			return
		end
		local s = stead.string.gsub(str,'[\t \n]+', stead.space_delim);
		s = stead.string.gsub(s, '\\?[\\^]', { ['^'] = '\n', ['\\^'] = '^', ['\\\\'] = '\\'} );
		return s
	end
};

stead.game { nam = 'game', player = 'player' }
stead.room { nam = 'main' }
stead.player { nam = 'player', room = 'main' }

require "strict"
