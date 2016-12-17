local declarations = {}
local variables = {}

local function __ref(n, t)
	if stead.type(t) ~= 'table' then
		return
	end
	local ref = stead.tables[t] or { key = n, ref = {} }
	ref.ref[n] = true
	stead.tables[t] = ref
end

local function __deref(n, t)
	if stead.type(t) ~= 'table' then
		return
	end
	local ref = stead.tables[t]
	if not ref then
		return
	end
	ref.ref[n] = nil
	local k, v = stead.next(ref.ref)
	if not k then
		stead.tables[t] = nil
	elseif n == ref.key then
		ref.key = k
	end
	return
end

local function __declare(n, t)
	if stead.initialized then
		stead.err ("Use "..t.." only in global context", 2)
	end
	if stead.type(n) ~= 'table' then
		stead.err ("Wrong parameter to "..n, 2)
	end
	for k, v in stead.pairs(n) do
		if declarations[k] then
			stead.err ("Duplicate declaration: "..k, 2)
		end
		declarations[k] = {value = v, type = t}
		__ref(k, v)
	end
	return n
end

function stead.const(n)
	return __declare(n, 'const')
end

function stead.global(n)
	return __declare(n, 'global')
end

function stead.declare(n)
	return __declare(n, 'declare')
end

stead.setmt(_G,
{
	__index = function(_, n)
		local d = declarations[n]
		if d then --
			if d.type == 'declare' and stead.initialized then
				stead.rawset(_, n, d.value)
			end
			return d.value
		end
		local f = stead.getinfo(2, "S").source
		if f:byte(1) == 0x3d then
			return
		end
		if f:byte(1) ~= 0x40 then
			print ("Uninitialized global variable: "..n.." in "..f)
		else
			error ("Uninitialized global variable: "..n.." in "..f, 2)
		end
	end;
	__newindex = function(t, k, v)
		local d = declarations[k]
		if d then
			if v == d.value then
				return --nothing todo
			end
			__deref(k, d.value)
			if not stead.initialized then
				d.value = v
				__ref(k, v)
				return
			end
			if d.type == 'declare' then
				stead.rawset(t, k, v)
				d.value = v
			elseif d.type == 'const' then
				stead.err ("Modify read-only constant: "..k, 2)
			elseif d.type == 'global' then
				stead.rawset(t, k, v)
				d.value = v
				variables[k] = true
			end
			return
		end
		if type(v) ~= 'function' and not stead.is_obj(v) then
			local f = stead.getinfo(2, "S").source
			if f:byte(1) ~= 0x40 then
				print ("Set uninitialized variable: "..k.." in "..f)
			else
				error ("Set uninitialized variable: "..k.." in "..f, 2)
			end
		end
		stead.rawset(t, k, v)
	end
})

stead.obj {
	nam = '@strict';
	save = function(s, fp, n)
		for k, v in stead.pairs(stead.tables) do
			if variables[v.key] then
				stead.save_var(stead.rawget(_G, v.key), fp, v.key)
			end
		end
		for k, v in stead.pairs(variables) do
			local o = stead.rawget(_G, k)
			if not stead.tables[o] then
				stead.save_var(o, fp, k)
			end
		end
	end
}

local function mod_init()
end

local function mod_done()
	for k, v in stead.pairs(declarations) do
		stead.rawset(_G, k, nil)
		if stead.type(v) == 'table' then
			stead.tables[v] = nil
		end
	end
	declarations = {}
	variables = {}
end

stead.mod_init(mod_init)
stead.mod_done(mod_done)

const = stead.const
global = stead.global
declare = stead.declare
