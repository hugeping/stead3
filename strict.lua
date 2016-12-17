local declarations = {}
local variables = {}
local type = stead.type
local rawget = stead.rawget
local rawset = stead.rawset
local pairs = stead.pairs

local function __declare(n, t)
	if stead.initialized then
		stead.err ("Use "..t.." only in global context", 2)
	end
	if type(n) ~= 'table' then
		stead.err ("Wrong parameter to "..n, 2)
	end
	for k, v in stead.pairs(n) do
		if declarations[k] then
			stead.err ("Duplicate declaration: "..k, 2)
		end
		if type(v) == 'table' and not stead.getmt(v) then
			stead.array(v)
		end
		declarations[k] = {value = v, type = t}
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
				rawset(_, n, d.value)
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
			if not stead.initialized then
				d.value = v
				return
			end
			if d.type == 'declare' then
				rawset(t, k, v)
			elseif d.type == 'const' then
				stead.err ("Modify read-only constant: "..k, 2)
			elseif d.type == 'global' then
				rawset(t, k, v)
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
		rawset(t, k, v)
	end
})

local function mod_save(fp)
	-- save global variables
	stead.tables = {}
	local tables = {}
	for k, v in pairs(declarations) do -- name all table variables
		local o = _G[k]
		if type(o) == 'table' then
			if not tables[o] then
				tables[o] = k
			end
			if stead.dirty(o) then
				variables[k] = true
				rawset(_G, k, v.value)
			end
		end
	end
	for k, v in pairs(tables) do
		if variables[v] then
			local o = rawget(_G, v)
			stead.save_var(o, fp, v)
		end
	end
	stead.tables = tables
	for k, v in pairs(variables) do
		local o = rawget(_G, k)
		if not stead.tables[o] then
			stead.save_var(o, fp, k)
		end
	end
end

local function mod_init()
end

local function mod_done()
	for k, v in pairs(declarations) do
		rawset(_G, k, nil)
	end
	stead.tables = {}
	declarations = {}
	variables = {}
end

stead.mod_init(mod_init)
stead.mod_done(mod_done)
stead.mod_save(mod_save)

const = stead.const
global = stead.global
declare = stead.declare
