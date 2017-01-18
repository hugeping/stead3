local std = stead
local type = std.type
local table = std.table

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

std.phr = std.class({
	new = function(s, v)
		local disabled
		local a = v
		local o = {
			phr = {}
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
				if not std.is_tag(v) then
					std.err("Wrong tag: "..std.tostr(v), 2)
				end
				o.tag = v
			elseif o.dsc == nil and v ~= nil then
				o.dsc = v
			elseif std.is_tag(v) then
				table.insert(o.phr, v)
			elseif o.act == nil and v ~= nil then
				o.act = v
			end
		end
		if o.dsc ~= nil and o.act == nil then
			o.act = o.dsc
			o.dsc = nil
		end
		if o.act == nil then
			std.err("Wrong phrase (no act)", 2)
		end
		o.ph_act = o.act
		o = std.obj(o)
		std.setmt(v, s)
		if disabled then o = o:disable() end
		return o
	end,
	act = function(s, ...)
		local r, v = std.call(s, 'ph_act', ...)
		return r, v
	end,
}, std.obj)

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
