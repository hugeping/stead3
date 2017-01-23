local std = stead
local type = std.type
local table = std.table

std.phrase_prefix = '-- '

local function phr_prefix(d, nr)
	if type(std.phrase_prefix) == 'string' then
		d = std.phrase_prefix .. d
	elseif type(std.phrase_prefix) == 'function' then
		d = std.phrase_prefix(nr) .. d
	end
	return d
end

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
	scene = function(s)
		local title, dsc, lact
		title = iface:title(std.titleof(s))
		dsc = std.call(s, 'dsc')
		if not std.me():moved() then
			s.lact = std.game:lastreact() or s.lact
			lact = iface:em(s.lact)
		end
		return std.par(std.scene_delim, title, lact or false, dsc)
	end;
	onact = function(s, w) -- show dsc by default
		local r, v = std.call(w, 'dsc')
		if type(r) == 'string' then
			return phr_prefix(r)
		end
		return r, v
	end;
	onenter = function(s, ...)
		s.lact = false
		s.current = s.obj[1] -- todo
		s:for_each(function(s) s:open() end) -- open all phrases
		if not s:select(s.current) then
			std.err("Wrong dialog: "..std.tostr(s), 2)
		end
		return std.call(s, s.dlg_onenter, ...)
	end;
	push = function(s, p)
		local c = s.current
		local r = s:select(p)
		if r ~= false then
			table.insert(s.stack, c)
		end
		return r
	end;
	pop = function(s, phr)
		if #s.stack == 0 then
			return false
		end

		if phr then
			local l = {}
			for i = 1, #s.stack do
				table.insert(l, s.stack[i])
				if s.stack[i] == phr then
					break
				end
			end
			s.stack = l
		end
		local p
		while #s.stack > 0 do
			p = table.remove(s.stack, #s.stack) -- remove top
			p = s:select(p)
			if p then
				return p
			end
		end
	end;
	select = function(s, p)
		if #s.obj == 0 then
			return false
		end
		if not p then -- get first one
			p = s.obj[1]
		end

		local c = s:lookup(p)

		if not c then
			std.err("Wrong dlg:select argumant: "..std.tostr(p), 2)
		end

		c:select()

		if c:empty() then -- no choices
			return false
		end

		if c:disabled() then -- select always enables phrase
			c:enable()
		end
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
			o:check()
			if not o:disabled() and not o:closed() then
				local d = std.call(o, 'dsc')
				if type(d) == 'string' then
					d = phr_prefix(d, nr)
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
			if i == 1 and type(v) == 'boolean' then
				if not v then
					disabled = true
				else
					o.always = true
				end
			elseif o.tag == nil and v ~= nil and std.is_tag(v) then
				o.tag = v
			elseif o.dsc == nil and v ~= nil then
				o.dsc = v
			elseif o.act == nil and v ~= nil then
				o.act = v
			elseif type(v) == 'table' then
				if not std.is_obj(v, 'phr') then
					v = s:new(v)
				end
				table.insert(o.obj, v)
			end
		end

		for k, v in std.pairs(a) do
			if type(k) == 'string' then
				o[k] = v
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
	check = function(s)
		if type(s.cond) == 'function' then
			if s:cond() then
				s:enable()
			else
				s:disable()
			end
		end
	end;
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

		local r, v = std.call(s, 'ph_act', ...)

		if std.me():moved() or cur ~= std.here().current then
			return r, v
		end

		if not std.here():push(s) then
			if std.here().current:empty() and not std.here():pop() then
				std.walkout(std.here():from())
			end
		end
		return r, v
	end,
	select = function(s)
		for i = 1, #s.obj do
			s.obj[i]:check()
		end
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
