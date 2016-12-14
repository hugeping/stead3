stead = {
	space_delim = ' ';
	scene_delim = '^^';
	call_top = 0,
	call_ctx = { txt = nil, self = nil },
	objects = {};
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

function stead.class(s, inh)
	s.__dirty = function(s, v)
		local o = s.__dirty_flag
		if v ~= nil then
			stead.rawset(s, '__dirty_flag', v)
		end
		return o
	end;
	s.__index = function(t, k)
		local v = stead.rawget(t, '__const')
		if v then
			v = stead.rawget(v, k)
			if v ~= nil then
				return v
			end
		end
		return s[k]
	end;
	s.__newindex = function(t, k, v)
		s:__dirty(true)
		if stead.type(t.__const) == 'table' and stead.type(k) == 'string' then
			if stead.type(v) ~= 'function' and t.__const[k] ~= v then
				t.__var[k] = true
			end
		end
		stead.rawset(t, k, v)
	end
	if inh then
		stead.setmt(s, inh)
	end
	return s
end

stead.list_mt = stead.class {
	__list_type = true;
	ini = function(s)
		for i = 1, #s do
			local k = s[i]
			s[i] = stead.ref(k)
			if s[i] == nil then
				stead.err("Wrong item in list: "..stead.tostr(k), 2)
			end
		end
	end;
	dsc = function(s)
		local r
		for i = 1, #s do
			r = (r or '')
			if r ~= '' then
				r = r .. stead.space_delim
			end
			r = r .. stead.call(s[i], 'dsc')
		end
		return r
	end;
	add = function(s, n, pos)
		if not pos then
			local o = stead.ref(n)
			s:__dirty(true)
			stead.table.insert(s, o)
			return o
		end
		if s:lookup(n) then
			return -- already here
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
		stead.table.insert(s, o)
		return o
	end;
	lookup = function(s, n)
		local o = stead.ref(n)
		for i = 1, #s do
			if s[i] == n then
				return o, i
			end
		end 
	end;
	del = function(s, n)
		local o, i = s:lookup(n)
		if i then
			s:__dirty(true)
			stead.table.remove(s, i)
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
		local d = stead.deref(vv)
		if d then
			fp:write(stead.string.format("%s = ", n))
			if stead.type(d) == 'string' then
				fp:write(stead.string.format("stead %q\n", d))
			else
				fp:write(stead.string.format("stead(%d)\n", d))
			end
		elseif stead.type(vv.save) == 'function' then
			vv:save(fp, n)
		else
			stead.save_table(vv, fp, n)
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

function stead.ini(fp)
	local oo = stead.objects
	for i = 1, #oo do
		oo[i]:ini()
	end
	for k, v in stead.pairs(oo) do
		v:ini()
	end
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

stead.obj_mt = stead.class {
	__obj_type = true;
	ini = function(s)
		for k, v in stead.pairs(s) do
			if stead.type(v) == 'table' and stead.type(v.ini) == 'function' then
				v:ini()
			end
		end
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
		for k, v in stead.pairs(s.__const) do
			if stead.dirty(v) then
				local l = stead.string.format("%s%s", n, stead.varname(k))
				stead.save_var(s[k], fp, l)
			end
		end
	end;
};

stead.room_mt = stead.class({
--	way = false;
	__room_type = true;
}, stead.obj_mt);

stead.game_mt = stead.class({
	__game_type = true;
	ini = function(s)
		stead.rawset(s, 'player', stead.ref(s.player))
		if not s.player then
			stead.err ("Wrong player", 2)
		end
		stead.obj_mt.ini(s)
	end;
	cmd = function(s, cmd)
		if cmd[1] == nil or cmd[1] == 'look' then
			return s.player:look()
		end
	end;
}, stead.obj_mt);

stead.player_mt = stead.class ({
	__player_type = true;
	ini = function(s)
		stead.rawset(s, 'where', stead.ref(s.where))
		if not s.where then
			std.err ("Wrong player location", 2)
		end
		stead.obj_mt.ini(s)
	end;
	look = function(s)
		local r = s.where
		local dsc = stead.call(r, 'dsc')
		local objs = stead.call(r.obj, 'dsc')
		return stead.par(stead.scene_delim, dsc, objs)
	end;
	act = function(s, w)
	end;
	walk = function(s, w)
		w = stead.ref(w)
	end;
}, stead.obj_mt)

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
	return stead.cctx().txt;
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

function stead.list(v)
	if stead.type(v) ~= 'table' then
		stead.err ("Wrong argument to stead.list:"..stead.tostr(v), 2)
	end
	stead.setmt(v, stead.list_mt)
	return v
end

function stead.obj(v)
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
	if not stead.getmt(v) then
		stead.setmt(v, stead.obj_mt)
	end
	local const = {}
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
	for key, val in stead.pairs(v) do
		if stead.rawget(v, key) ~= nil then
			const[key] = val
			stead.rawset(v, key, nil)
		end
	end
	stead.rawset(v, '__const', const)
	stead.rawset(v, '__var', vars)
	oo[v.nam] = v
	return v
end
function stead.dump(t)
	local rc = '';
	if type(t) == 'string' then
		rc = string.format("%q", t):gsub("\\\n", "\\n")
	elseif type(t) == 'number' then
		rc = tostring(t)
	elseif type(t) == 'boolean' then
		rc = tostring(t)
	elseif type(t) == 'table' then
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
	local f, r = stead.eval("return "..fn.."("..l..")")
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

function stead.var(v)
	if stead.type(v) ~= 'table' then
		stead.err ("Wrong argument to stead.var:"..stead.tostr(v), 2)
	end
	return v
end

function stead.player(v)
	if stead.type(v) ~= 'table' then
		stead.err ("Wrong argument to stead.pl:"..stead.tostr(v), 2)
	end
	if not v.where then
		v.where = 'main'
	end
	stead.setmt(v, stead.player_mt)
	v = stead.obj(v)
	return v
end

function stead.game(v)
	if stead.type(v) ~= 'table' then
		stead.err ("Wrong argument to stead.pl:"..stead.tostr(v), 2)
	end
	if not v.player then
		v.player = 'player'
	end
	stead.setmt(v, stead.game_mt)
	v = stead.obj(v)
	return v
end

function stead.room(v)
	if stead.type(v) ~= 'table' then
		stead.err ("Wrong argument to stead.room:"..stead.tostr(v), 2)
	end
	if not stead.getmt(v) then
		stead.setmt(v, stead.room_mt)
	end
	if not v.way then
		stead.rawset(v, 'way',  {})
	end
	if stead.type(v.way) ~= 'table' then
		stead.err ("Wrong .way attr in object:" .. v.nam, 2)
	end
	v.way = stead.list(v.way)
	v = stead.obj(v)
	return v
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
	return o.nam
end

stead.call = function(v, n, ...)
	if stead.type(v) ~= 'table' then
		stead.err ("Call on non table object:"..stead.tostr(n), 2);
	end
	if v[n] == nil then
		return nil, nil
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
		return stead.tostr(v[n]), true
	end
	stead.err ("Method not string nor function:"..stead.tostr(n), 2);
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

iface = {
	cmd = function(inp)
		local cmd = cmd_parse(inp)
		if not cmd then
			return "Error in cmd arguments", false
		end
		local r, v = game:cmd(cmd)
		print(r)
	end
};

game = stead.game { nam = 'game', player = 'player' }
pl = stead.player { nam = 'player', where = 'main' }
stead.room { nam = 'main' }
