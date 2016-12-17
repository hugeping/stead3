local declarations = {}
local variables = {}

local function __declare(n, t)
	if stead.initialized then
		stead.err ("Use "..t.." only in global context", 2)
	end
	if stead.type(n) ~= 'table' then
		stead.err ("Wrong parameter to "..n, 2)
	end
	for k, v in stead.pairs(n) do
		declarations[k] = {value = v, type = t}
		if stead.type(v) == 'table' and not stead.tables[v] then -- name of tables
			stead.tables[v] = k
		end
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
			if not stead.initialized then
				d.value = v
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
		for k, v in stead.pairs(variables) do
			stead.save_var(stead.rawget(_G, k), fp, k)
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
stead.mod_done(mod_init)

const = stead.const
global = stead.global
declare = stead.declare
