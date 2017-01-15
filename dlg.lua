local std = stead
std.phrase_prefix = '-- '
std.dlg = std.class({
	__dlg_type = true;
	display = function(s)
		local r, nr
		nr = 1
		for i = 1, #s.obj do
			if r then
				r = r .. '^'
			end
			local o = s.obj[i]
			if not o:disabled() and not o:closed() then
				local d = std.call(o, 'dsc')
				if type(d) == 'string' then
					if type(std.phrase_prefix) == 'string' then
						d = std.phrase_prefix .. d
					elseif type(std.phrase_prefix) == 'function' then
						d = std.phrase_prefix(nr) .. d
					end
					d = o:xref(d)
					r = (r or '').. d
					nr = nr + 1
				end
			end
		end
		return r
	end;
}, std.room)

function std.phr(...)
	local disabled
	local a = {...}
	local o = {
	}
	for i = 1, #a do
		local v = a[i]
		if i == 1 and type(v) == 'boolean' then
			if not v then
				disabled = true
			else
				o.always = true
			end
		elseif o.tag == nil and v ~= nil then
			o.tag = v
		elseif o.dsc == nil and v ~= nil then
			o.dsc = v
		elseif o.act == nil and v ~= nil then
			o.act = v
		else

		end
	end
end
--[[
false -- выключена (disabled)
true -- всегда (always = true)
nil -- обычная фраза, которая пропадает
                nam =,        act =,                obj =,
{ false | true, 'знакомство', 'Привет, что нового?', { '#привет', '#пока' } }
   nam =,    dsc = ,          act =,
{ '#привет', 'И тебе привет!', 'Я уже поздоровался' }
{ '#пока', 'Я устал я ухожу', 'Ну пока тогда' }

]]--