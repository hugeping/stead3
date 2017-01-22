local std = stead
local type = std.type
local table = std.table

std.phrase_prefix = '-- '
std.dlg = std.class({
	__dlg_type = true;
	new = function(s, v)
		if v.current == nil then
			v.current = false
		end
		v.dlg_onenter = v.onenter
		v.onenter = nil
		v.stack = {}
		v = std.room(v)
		std.setmt(v, s)
		return v
	end;
	onenter = function(s, ...)
		s:for_each(function(s) s:open() end) -- open all phrases
		if not s:select(s.current) then
			std.err("Wrong dialog: "..std.tostr(s), 2)
		end
		return std.call(s, s.dlg_onenter, ...)
	end;
	push = function(s, p)
		local r = s:select(p)
		if r ~= false then
			table.insert(s.stack, r)
		end
		return r
	end;
	peek = function(s)
		if #s.stack == 0 then
			return false
		end
		return s.stack[#s.stack]
	end;
	pop = function(s)
		if #s.stack == 0 then
			return false
		end
		local p
		while #s.stack > 0 do
			p = table.remove(s.stack, #s.stack)
			if not p:empty() then
				break
			end
		end
		return s:select(p)
	end;
	select = function(s, p)
		if #s.obj == 0 then
			return false
		end
		if not p then
			p = s.obj[1]
		end
		local c = s:lookup(p)

		if not c then
			std.err("Wrong dlg:select argumant: "..std.tostr(p), 2)
		end
		if c:disabled() or c:closed() then
			return false
		end
		if #c.obj == 0 then -- no choices
			return false
		end
--		c:select()
		s.current = c
		return c
	end;
	display = function(s)
		local r, nr
		nr = 1
		local oo = s.current
		if not oo then -- nothing to show
			return
		end
		for i = 1, #oo.obj do
			if r then
				r = r .. '^'
			end
			local o = oo.obj[i]
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
	__phr_type = true;
	new = function(s, v)
		local disabled
		local a = v
		local o = {
			obj = {}
		}
		for i = 1, #a do
			local v = a[i]
			print("i = ", i)
			if i == 1 and type(v) == 'boolean' then
				if not v then
					disabled = true
				else
					o.always = true
				end
				print("always = ", v)
			elseif o.tag == nil and v ~= nil and std.is_tag(v) then
				o.tag = v
				print("tag = ", v)
			elseif o.dsc == nil and v ~= nil then
				o.dsc = v
				print("dsc = ", v)
			elseif o.act == nil and v ~= nil then
				o.act = v
				print("act = ", v)
			elseif type(v) == 'table' then
				if not std.is_obj(v, 'phr') then
					print ("Before:", i)
					for kk, vv in ipairs(v) do
						print(kk, vv)
					end
					v = s:new(v)
				end
				table.insert(o.obj, v)
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
		o.act = nil
		o = std.obj(o)
		std.setmt(o, s)
		if disabled then o = o:disable() end
		return o
	end,
	empty = function(s)
		for i = 1, #s.obj do
			local o = s.obj[i]
			if not o:disabled() and not o:closed() then
				return false
			end
		end
		return true
	end;
	act = function(s, ...)
		local t
		if not s.always then
			s:close()
		end
		local cur = std.here().current
		local r, v = std.call(s, 'dsc')
		t = std.par(std.scene_delim, t, r)
		r, v = std.call(s, 'ph_act', ...)
		t = std.par(std.scene_delim, t, r)

		if std.me():moved() or cur ~= std.here().current then
			return r, v
		end
		if not std.here():push(s) then
			if std.here().current:empty() and not std.here():pop() then
				std.walkout(std.here():from())
			end
		end
		return t, v
	end,
	select = function(s)
	end;
}, std.obj)

--[[
false -- выключена (disabled)
true -- всегда (always = true)
nil -- обычная фраза, которая пропадает
                nam =,        act =,                obj =,
{ false | true, 'знакомство', 'Привет, что нового?',  '#привет', '#пока'  }
   nam =,    dsc = ,          act =,
{ '#привет', 'И тебе привет!', 'Я уже поздоровался' }
{ '#пока', 'Я устал я ухожу', 'Ну пока тогда' }

]]--
