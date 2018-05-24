require "fmt"

local mrd = require "morph/mrd"
local inp_split = " :.,!?"

local input = std.ref '@input'

local function utf_bb(b, pos)
	if type(b) ~= 'string' or b:len() == 0 then
		return 0
	end
	local utf8 = (std.game.codepage == 'UTF-8' or std.game.codepage == 'utf-8')
	if not utf8 then return 1 end
	local i = pos or b:len()
	local l = 0
	while b:byte(i) >= 0x80 and b:byte(i) <= 0xbf do
		i = i - 1
		l = l + 1
		if i <= 1 then
			break
		end
	end
	return l + 1
end

local function utf_ff(b, pos)
	if type(b) ~= 'string' or b:len() == 0 then
		return 0
	end
	local utf8 = (std.game.codepage == 'UTF-8' or std.game.codepage == 'utf-8')
	if not utf8 then return 1 end
	local i = pos or 1
	local l = 0
	if b:byte(i) < 0x80 then
		return 1
	end
	i = i + 1
	l = l + 1
	while b:byte(i) >= 0x80 and b:byte(i) <= 0xbf do
		i = i + 1
		l = l + 1
		if i > b:len() then
			break
		end
	end
	return l
end

local function utf_len(b)
	local i = 1
	local n = 0
	if b:len() == 0 then
		return 0
	end
	while i <= b:len() do
		i = i + utf_ff(b, i)
		n = n + 1
	end
	return n
end

local function utf_char(b, c)
	local i = 1
	local n = 0
	local s
	while i <= b:len() do
		s = i
		i = i + utf_ff(b, i)
		n = n + 1
		if n == c then
			return b:sub(s, i - 1)
		end
	end
	return
end

-- Returns the Levenshtein distance between the two given strings
-- https://gist.github.com/Badgerati/3261142

local function utf_lev(str1, str2)
	local len1 = utf_len(str1)
	local len2 = utf_len(str2)
	local matrix = {}
	local cost = 0

        -- quick cut-offs to save time
	if (len1 == 0) then
		return len2
	elseif (len2 == 0) then
		return len1
	elseif (str1 == str2) then
		return 0
	end

        -- initialise the base matrix values
	for i = 0, len1, 1 do
		matrix[i] = {}
		matrix[i][0] = i
	end
	for j = 0, len2, 1 do
		matrix[0][j] = j
	end

        -- actual Levenshtein algorithm
	for i = 1, len1, 1 do
		for j = 1, len2, 1 do
			if (utf_char(str1, i) == utf_char(str2, j)) then
				cost = 0
			else
				cost = 1
			end

			matrix[i][j] = math.min(matrix[i-1][j] + 1, matrix[i][j-1] + 1, matrix[i-1][j-1] + cost)
		end
	end

        -- return the last value - this is the Levenshtein distance
	return matrix[len1][len2]
end
local okey = input.key
local mp

function input:key(press, key)
	local a
	local mod
	if key:find("alt") then
		mp.alt = press
		mod = true
	elseif key:find("ctrl") then
		mp.ctrl = press
		mod = true
	elseif key:find("shift") then
		mp.shift = press
		mod = true
	end
	if key:find("enter") or key:find("return") then key = 'enter' end

	if press and not mod and not (mp.ctrl or mp.alt) then
		if mp:key(key) then
			return '@mp_key '..tostring(key)
		end
	end
	if okey then
		return okey(self, press, key)
	end
end

mp = std.obj {
	nam = '@metaparser';
	{
		inp = '';
		cur = 1;
		cursor = fmt.b("|");
		prompt = "> ";
		ctrl = false;
		shift = false;
		alt = false;
		words = {};
		parsed = {};
		hints = {};
		unknown = {};
		multi = {};
		token = {};
		msg = {};
		mrd = mrd;
	};
	text = '';
	-- dict = {};
}

function mp:key(key)
	if key == 'left' then
		return self:inp_left()
	end
	if key == 'right' then
		return self:inp_right()
	end
	if key == 'space' then
		mp:inp_insert(' ')
		return true
	end
	if key == 'backspace' then
		if self:inp_remove() then
			return true
		end
		return false
	end
	if key == 'enter' then
		return true
	end
	if key:len() > 1 then
		return false
	end
	key = mp.shift and mrd.lang.kbd.shifted[key] or mrd.lang.kbd[key] or key
	if key then
		mp:inp_insert(key)
		return true
	end
	return false
end

function mp:inp_left()
	if self.cur > 1 then
		local i = utf_bb(self.inp, self.cur - 1)
		self.cur = self.cur - i
		return true
	end
end

function mp:inp_right()
	if self.cur <= self.inp:len() then
		local i = utf_ff(self.inp, self.cur)
		self.cur = self.cur + i
		return true
	end
end

function mp:inp_split()
	local pre = self.inp:sub(1, self.cur - 1);
	local post = self.inp:sub(self.cur);
	return pre, post
end

function mp:inp_insert(k)
	local pre, post = self:inp_split()
	self.cur = self.cur + k:len()
	self.inp = pre .. k .. post
end

function mp:inp_remove()
	local pre, post = self:inp_split()
	if not pre or pre == '' then
		return false
	end
	local i = utf_bb(pre)
	self.inp = self.inp:sub(1, pre:len() - i) .. post
	self.cur = self.cur - i
	return true
end

function mp:esc(s)
	local rep = function(str)
		return fmt.nb(str)
	end
	if not s then return end
	local r = s:gsub("[<>]+", rep):gsub("[ \t]", rep);
	return r
end

instead.get_inv = std.cacheable('inv', function(horiz)
	local pre, post = mp:inp_split()
	return mp.prompt .. mp:esc(pre)..mp.cursor..mp:esc(post)
end)

local function str_strip(str)
	return std.strip(str)
end

local function str_split(str, delim)
	local a = std.split(str, delim)
	for k, _ in ipairs(a) do
		a[k] = str_strip(a[k])
	end
	return a
end

function mp.token.noun(w)
	local attr = w.morph
	local oo = {}
	local ww = {}
	std.here():for_each(function(v)
			table.insert(oo, v)
			   end)
	inv():for_each(function(v)
			table.insert(oo, v)
			   end)
	for _, o in ipairs(oo) do
		local d = {}
		o:noun(attr, d)
		for _, v in ipairs(d) do
			table.insert(ww, { optional = w.optional, word = v.word, ob = o })
		end
	end
	return ww
end

function mp:pattern(t)
	local words = {}
	local pat = str_split(mrd.lang.lower(mrd.lang.norm(t)), "|,")
	for _, v in ipairs(pat) do
		local w = {}
		if v:sub(1, 1) == '?' then
			v = v:sub(2)
			v = str_strip(v)
			w.optional = true
		end
		if v:sub(1, 1) == '~' then
			v = v:sub(2)
			v = str_strip(v)
			w.hidden = true
		end
		if v:find("[^/]+/[^/]+$") then
			local s, e = v:find("/[^/]+$")
			w.morph = v:sub(s + 1, e)
			v = v:sub(1, s - 1)
			v = str_strip(v)
		end
		if v:find("^{[^}]+}$") then -- completion function
			v = v:gsub("^{", ""):gsub("}$", "")
			if type(self.token[v]) ~= 'function' then
				std.err("Wrong subst function: ".. v, 2);
			end
			local tok = self.token[v](w)
			while type(tok) == 'string' do
				tok = self:pattern(tok)
			end
			if type(tok) == 'table' then
				for _, xw in ipairs(tok) do
					table.insert(words, xw)
				end
			end
		else
			w.word = v
			table.insert(words, w)
		end
	end
	return words
end

function mp:verb(t, w)
	w = w or game
	if type(t) ~= 'table' then
		std.err("Wrong 1-arg to mp:verb()", 2)
	end
	if type(w) ~= 'table' then
		std.err("Wrong 2-arg to mp:verb()", 2)
	end
	if not w.__Verbs then
		w.__Verbs = {}
	end
	local verb = {}
	local n = 1
	if std.is_tag(t[1]) then
		verb.tag = t[1]
		n = 2
	end
	if type(t[n]) ~= 'string' then
		std.err("Wrong verb pattern in mp:verb()", 2)
	end
	verb.verb = self:pattern(t[n])
	n = n + 1
	if type(t[n]) ~= 'string' then
		std.err("Wrong verb descriptor mp:verb()", 2)
	end
	verb.dsc = {}
	while type(t[n]) == 'string' do
		local dsc = str_split(t[n], ":")
		local pat
		if #dsc == 1 then
			table.insert(verb.dsc, { pat = {}, ev = dsc[1] })
		elseif #dsc == 2 then
			pat = str_split(dsc[1], ' ')
			table.insert(verb.dsc, { pat = pat, ev = dsc[2] })
		else
			std.err("Wrong verb descriptor: " .. t[n])
		end
		n = n + 1
	end
	table.insert(w, verb)
	return verb
end

function mp:lookup_verb(words, w, lev)
	local ret = {}
	w = w or game
	for _, v in ipairs(w) do -- verbs
		local found = false
		local lev_v = {}
		for _, vv in ipairs(v.verb) do
			for i, vvv in ipairs(words) do
				if lev then
					local lev = utf_lev(vv.word, vvv)
					table.insert(lev_v, { lev = lev, verb = v, verb_nr = i, word_nr = _ } )
				elseif vv.word == vvv then
					v.verb_nr = i
					table.insert(ret, v)
					break
				end
			end
		end
		if lev and #lev_v > 0 then
			table.sort(lev_v, function(a, b)
					   return a.lev < b.lev
			end)
			lev_v[1].verb.verb_nr = lev_v[1].verb_nr
			lev_v[1].verb.word_nr = lev_v[1].word_nr
			lev_v[1].verb.lev = lev_v[1].lev
			table.insert(ret, lev_v[1].verb)
		end
	end
	if lev then
		table.sort(ret, function(a, b)
				   return a.lev < b.lev
		end)
		ret = { ret[1] }
	end
	return ret
end

local function word_search(t, w)
	w = str_split(w, " ")
	for k, v in ipairs(t) do
		local found = true
		for i = 1, #w do
			local found2 = false
			for ii = k, k + #w - 1 do
				if w[i] == t[ii] then
					found2 = true
					break
				end
			end
			if not found2 then
				found = false
				break
			end
		end
		if found then
			return k, #w
		end
	end
end

local function tab_sub(t, s, e)
	local r = {}
	e = e or #t
	for i = s, e do
		table.insert(r, t[i])
	end
	return r
end

function mp:match(verb, w)
	local matches = {}
	local found
	local hints = {}
	local unknown = {}
	local multi = {}
	for _, d in ipairs(verb.dsc) do
		local match = { args = {} }
		local a = {}
		found = (#d.pat == 0)
		for k, v in ipairs(w) do
			if k ~= verb.verb_nr then
				table.insert(a, v)
			end
		end
		for _, v in ipairs(d.pat) do
			local pat = self:pattern(v) -- pat -- possible words
			local best = #a + 1
			local best_len = 1
			local word
			local required
			for _, pp in ipairs(pat) do
				if not pp.optional then
					required = true
				end
				local k, len = word_search(a, pp.word)
				if found and found.word == pp.word and found.ob and pp.ob then -- few ob candidates
					table.insert(multi, found.ob:noun())
					table.insert(multi, pp.ob:noun())
					found = false
				elseif k and ( k < best or len > best_len) then
					best = k
					word = pp.word
					found = pp
				end
			end
			if found then
				a = tab_sub(a, best)
				table.remove(a, 1)
				table.insert(match, word)
				table.insert(match.args, found)
			elseif required then
				for i = 1, best - 1 do
					table.insert(unknown, a[i])
				end
				table.insert(hints, v)
				break
			end
		end
		if found then
			table.insert(match, 1, w[verb.verb_nr])
			table.insert(matches, match)
		end
	end
	table.sort(matches, function(a, b)
			   return #a > #b
	end)
	return matches, hints, unknown, multi
end

function mp:err(err)
	if err == "UNKNOWN_VERB" then
		local verbs = self:lookup_verb(self.words, nil, true)
		local hint = false
		if verbs and #verbs > 0 then
			local verb = verbs[1]
			local fixed = verb.verb[verb.word_nr]
			if verb.lev < 4 then
				hint = true
				p (self.msg.UNKNOWN_VERB or "Unknown verb:", " ", self.words[verb.verb_nr], ".")
				pn(self.msg.UNKNOWN_VERB_HINT or "Did you mean:", " ", fixed.word, "?")
			end
		end
		if not hint then
			p (self.msg.UNKNOWN_VERB or "Unknown verb:", " ", self.words[1], ".")
		end
	elseif err == "INCOMPLETE" then
		local need_noun = #self.hints > 0 and self.hints[1]:find("^{noun}")
		if #self.unknown > 0 then
			if need_noun then
				p (self.msg.UNKNOWN_OBJ or "Do not see", " ",self.unknown[1], ".")
			else
				p (self.msg.UNKNOWN_WORD or "Unknown word", " ", self.unknown[1], ".")
			end
		end
		p (self.msg.INCOMPLETE or "Incomplete sentence.")
		if #self.hints > 0 then
			p (self.msg.HINT_WORDS or "Possible words:", " ")
		end
		local first = true
		for _, v in ipairs(self.hints) do
			if v:find("^{noun}") then
				if mp.err_noun then
					mp:err_noun(v)
				else
					pr ("noun")
				end
			else
				local pat = self:pattern(v)
				for _, vv in ipairs(pat) do
					if not first then
						pr (mp.msg.HINT_OR or "or", " ", vv.word)
					else
						pr (" ", vv.word)
					end
				end
			end
			first = false
		end
		p "."
	elseif err == "MULTIPLE" then
		p (self.msg.MULTIPLE or "There are", " ", self.multi[1], " ", mp.msg.HINT_AND or "and", " ", self.multi[2], ".")
	end
end

function mp:parse(inp)
	inp = inp:gsub("[ ]+", " "):gsub("["..inp_split.."]+", " ")
	pn(fmt.b(inp))
	local r, v = self:input(mrd.lang.lower(mrd.lang.norm(inp)))
	if not r then
		self:err(v)
		return
	end
	local rinp = ''
	for _, v in ipairs(self.parsed) do
		if rinp ~= '' then rinp = rinp .. ' ' end
		if type(v) == 'table' then
		for kk, vv in pairs(v) do
			print(kk, vv)
		end
		end
		rinp = rinp .. v
	end
	if mrd.lang.lower(mrd.lang.norm(rinp)) ~= mrd.lang.lower(mrd.lang.norm(inp)) then
		pn(fmt.em("("..rinp..")"))
	end
end

std.world.display = function(s, state)
	local l, av, pv
	local reaction = s:reaction() or nil
	if state then
		reaction = iface:em(reaction)
		av, pv = s:events()
		av = iface:em(av)
		pv = iface:em(pv)
		l = s.player:look() -- objects [and scene]
	end
	l = std.par(std.scene_delim, reaction or false,
		    av or false, l or false,
		    pv or false) or ''
	mp.text = mp.text .. fmt.anchor().. l .. '^'
	return mp.text
end

function mp:key_enter()
	local r, v = std.call(mp, 'parse', self.inp)
	self.inp = '';
	self.cur = 1;
	return r, v
end

function mp:input(str)
	local hints = {}
	local unknown = {}
	local multi = {}
	local w = str_split(str, inp_split)
	self.words = w
	if #w == 0 then
		return false, "EMPTY_INPUT"
	end
	local verbs = self:lookup_verb(w)
	if #verbs == 0 then
		return false, "UNKNOWN_VERB"
	end
	local matches = {}
	for _, v in ipairs(verbs) do
		local m, h, u, mu = self:match(v, w)
		if #m > 0 then
			table.insert(matches, { verb = v, match = m[1] })
		else
			for _, v in ipairs(h) do
				table.insert(hints, v)
			end
			table.insert(unknown, u)
			table.insert(multi, mu)
		end
	end
	table.sort(matches, function(a, b)
			   return #a.match > #b.match
	end)
	if #matches == 0 then
		self.hints = hints
		self.unknown = {}
		self.multi = {}
		if #multi > 0 and #multi[1] > 0 then
			self.multi = multi[1]
			return false, "MULTIPLE"
		end
		for i = 1, #unknown[1] do
			local u = unknown[1][i]
			local yes = true
			for _, v in ipairs(unknown) do
				if v[i] ~= u or not v[i] then
					yes = false
					break
				end
			end
			if yes then
				table.insert(self.unknown, u)
			end
		end
		return false, "INCOMPLETE"
	end
	self.parsed = matches[1].match
	return true
end

-- Verb { "#give", "отдать,дать", "{$inv/вн} ?для {$obj/вн} : give %2 %3|receive %3 %2"}

function Verb(t, w)
	return mp:verb(t, w)
end
std.rawset(_G, 'mp', mp)
std.mod_cmd(
function(cmd)
	if cmd[1] == '@mp_key' and cmd[2] == 'enter' then
		return mp:key_enter()
	end
	if cmd[1] ~= '@mp_key' then
		return
	end
	return true, false
end)

std.mod_start(
function()
	mrd:gramtab("morph/rgramtab.tab")
	if not mrd:load("dict.mrd") then
		mrd:create("dict.mrd")
	end
end)
