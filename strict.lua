local declarations = {}
local variables = {}
local type = stead.type
local rawget = stead.rawget
local rawset = stead.rawset
local pairs = stead.pairs
local table = stead.table
local next = stead.next

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
		declarations[k] = {value = v, type = t}
		if t == 'global' then
			rawset(_G, k, v)
			variables[k] = true
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
			if stead.initialized and (d.type ~= 'const') then
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
			if d.type == 'const' then
				stead.err ("Modify read-only constant: "..k, 2)
			else
				d.value = v
				rawset(t, k, v)
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

local function depends(t, tables, deps)
	if type(t) ~= 'table' then return end
	if tables[t] then
		deps[t] = tables[t]
	end
	for k, v in pairs(t) do
		if type(v) == 'table' then
			depends(v, tables, deps)
		end
	end
end

local function makedeps(nam, depends, deps)
	local ndeps = {}
	local rc = false

	local t = rawget(_G, nam)
	if type(t) ~= 'table' then
		return
	end
	if type(depends[nam]) ~= 'table' then
		return
	end
	local d = depends[nam]
	for k, v in pairs(d) do
		local dd = depends[v]
		if dd and k ~= t then
			ndeps[k] = v
			rc = rc or makedeps(v, depends, deps)
		end
	end
	if not next(ndeps) then
		depends[nam] = nil
		table.insert(deps, t)
		rc = true
	else
		depends[nam] = ndeps
	end
	return rc
end

local function mod_save(fp)
	-- save global variables
	stead.tables = {}
	local tables = {}
	local deps = {}
	for k, v in pairs(declarations) do -- name all table variables
		local o = rawget(_G, k) or v.value
		if type(o) == 'table' then
			if not tables[o] then
				tables[o] = k
			end
		end
	end

	for k, v in pairs(variables) do
		local d = {}
		local o = rawget(_G, k)
		depends(o, tables, d)
		if k == tables[o] then -- self depend
			d[o] = nil
		end
		if next(d) then
			deps[k] = d
		end
	end

	stead.tables = tables -- save all depends

	for k, v in pairs(variables) do -- write w/o deps
		local o = rawget(_G, k)
		if not deps[k] then
			stead.save_var(o, fp, k)
		end
	end
	for k, v in pairs(variables) do
		local d = {}
		while makedeps(k, deps, d) do
			for i=1, #d do
				stead.save_var(d[i], fp, k)
			end
			d = {}
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
