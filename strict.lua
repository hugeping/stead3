local declarations = {}

function stead.const(n)
	if stead.initialized then
		stead.err ("Use const only in global context", 2)
	end
	if type(n) == 'string' then
		declarations[n] = true
		return
	end
	if type(n) == 'table' then
		for k, v in stead.pairs(n) do
			declarations[k] = true
			stead.rawset(_G, k, v)
		end
		return
	end
	error ("Wrong parameter to declare", 2)
end

stead.setmt(_G, {
	__index = function(_, n)
		if declarations[n] then
			return
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
		if not declarations[k] and type(v) ~= 'function' and not stead.is_obj(v) then
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

const = stead.const
