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
			mp:compl_fill(mp:compl(mp.inp))
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
		args = {};
		vargs = {};
		debug = { trace_action = false };
		completions = {};
		hint = {
			live = 'live',
			neuter = 'neuter',
			male = 'male',
			female = 'female',
			plural = 'plural',
		};
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
		local inp = mp:docompl(self.inp)
		if inp == self.inp then
			mp:inp_insert(' ')
		else
			self.inp = inp
			self.cur = self.inp:len() + 1
		end
		return true
	end
	if key == 'tab' then
		self.inp = mp:docompl(self.inp)
		self.cur = self.inp:len() + 1
		return true
	end
	if key == 'backspace' then
		if self:inp_remove() then
			return true
		end
		return true -- avoid scrolling
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

local keys_en = {
	"A", "B", "C", "D", "E", "F",
	"G", "H", "I", "J", "K", "L",
	"M", "N", "O", "P", "Q", "R",
	"S", "T", "U", "V", "W", "X",
	"Y", "Z"
}
instead.get_inv = std.cacheable('inv', function(horiz)
	local pre, post = mp:inp_split()
	local ret = mp.prompt .. mp:esc(pre)..mp.cursor..mp:esc(post) .. '\n'
	local delim = instead.hinv_delim or ' | '
	for _, v in ipairs(mp.completions) do
		ret = ret .. iface:xref(v, mp, v) .. delim
	end
	if #mp.completions == 0 or mp.completions.eol then
		ret = ret .. iface:xref(mp.msg.enter or "<enter>", mp, "<enter>") .. delim
		if mp.completions.vargs then
			ret = ret .. iface:xref(mp.keyboard_space or "<space>", mp, "<space>") .. delim
			ret = ret .. iface:xref(mp.keyboard_backspace or "<backspace>", mp, "<backspace>") .. delim
			for _, v in ipairs(mp.keyboard or keys_en) do
				ret = ret .. iface:xref(v, mp, v, 'letter') .. delim
			end
		end
	end
	ret = ret:gsub(delim .."$", "")
	return ret
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
		local r = o:noun(attr, d)
		for k, v in ipairs(d) do
			table.insert(ww, { optional = w.optional, word = r[k], ob = o, alias = v.alias, hidden = (k ~= 1) })
		end
	end
	return ww
end

function mp:norm(t)
	return std.strip(mrd.lang.lower(mrd.lang.norm(t)))
end

function mp:eq(t1, t2)
	return self:norm(t1) == self:norm(t2)
end

function mp:pattern(t)
	local words = {}
	local pat = str_split(self:norm(t), "|,")
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
		if v:find("[^/]+/[^/]*$") then
			local s, e = v:find("/[^/]*$")
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
	table.insert(w.__Verbs, verb)
	return verb
end

function mp:verbs()
	return std.here().__Verbs or std.me().__Verbs or game.__Verbs or {}
end

function mp:lookup_verb(words, lev)
	local ret = {}
	local w = self:verbs()
	for _, v in ipairs(w) do -- verbs
		local found = false
		local lev_v = {}
		for _, vv in ipairs(v.verb) do
			for i, vvv in ipairs(words) do
				local verb = vv.word .. (vv.morph or "")
				local pfx = vv.word
				if lev then
					local lev = utf_lev(verb, vvv)
					table.insert(lev_v, { lev = lev, verb = v, verb_nr = i, word_nr = _ } )
				elseif verb == vvv or (vvv:find(pfx, 1, true) == 1 and i == 1) then
					v.verb_nr = i
					v.word_nr = _
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
				if mp:eq(w[i], t[ii]) then
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

function mp:docompl(str, maxw)
	local full = false
	if not maxw then
		full = false
		local compl = self:compl(str)
		for _, v in ipairs(compl) do
			if not maxw then
				full = true
				maxw = v.word
				--		elseif v.word:find(maxw, 1, true) == 1 then
				--			maxw = v.word
			else
				local maxw2 = ''
				for k = 1, utf_len(maxw) do
					if utf_char(maxw, k) == utf_char(v.word, k) then
						maxw2 = maxw2 .. utf_char(maxw, k)
					else
						full = false
						break
					end
				end
				maxw = maxw2
			end
		end
	else
		full = true
	end
	if maxw and maxw ~= '' then
		local words = str_split(str, inp_split)
		if not str:find(" $") then
			table.remove(words, #words)
		end
		str = ''
		table.insert(words, maxw)
		for _, v in ipairs(words) do
			str = str .. v .. ' '
		end
		if not full then
			str = str:gsub(" $", "")
		end
	end
	return str
end
function mp:startswith(w, v)
	return (self:norm(w)):find(self:norm(v), 1, true) == 1
end

function mp:compl_verb(words)
	local dups = {}
	local poss = {}
	for _, v in ipairs(self:verbs()) do
		for _, vv in ipairs(v.verb) do
			local verb = vv.word .. (vv.morph or "")
			table.insert(poss, { word = verb, hidden = (_ ~= 1) or vv.hidden })
		end
	end
	return poss
end

function mp:compl_fill(compl, eol, vargs)
	self.completions = {}
	self.completions.eol = eol
	self.completions.vargs = vargs

	for _, v in ipairs(compl) do
		if not v.hidden then
			table.insert(self.completions, v.word)
		end
	end
end

function mp:compl(str)
	local words = str_split(self:norm(str), inp_split)
	local poss
	local ret = {}
	local dups = {}
	local eol
	local e = str:find(" $")
	local vargs
	if #words == 0 or (#words == 1 and not e) then -- verb?
		poss, eol = self:compl_verb(words)
	else -- matches
		poss, eol, vargs = self:compl_match(words)
	end
	for _, v in ipairs(poss) do
		if #words == 0 or e or (self:startswith(v.word, words[#words]) and not e) then
			if not dups[v.word] then
				dups[v.word] = true
				table.insert(ret, v)
			end
		end
	end
	table.sort(ret, function(a, b)
			   return a.word < b.word
	end)
	return ret, eol, vargs
end

local function lev_sort(t)
	table.sort(t, function(a, b) return a.lev > b.lev end)
	local lev = t[1] and t[1].lev
	local res = {}
	local dup = {}
	for _, v in ipairs(t) do
		if v.lev ~= lev then
			break
		end
		res.lev = lev
		if v.word then
			if not dup[v.word] then
				table.insert(res, v.word)
				dup[v.word] = true
			end
		else
			for _, vv in ipairs(v) do
				if not dup[vv] then
					table.insert(res, vv)
					dup[vv] = true
				end
			end
		end
	end
	return res
end

function mp:compl_match(words)
	local verb = { words[1] }
	local verbs = self:lookup_verb(verb)
--	table.remove(words, 1) -- remove verb
	local matches = {}
	local hints = {}
	local res = {}
	local dup = {}
	local multi
	for _, v in ipairs(verbs) do
		local m, h, u, mu = self:match(v, words)
		if #m > 0 then
			table.insert(matches, { verb = v, match = m[1] })
		end
		if #h > 0 then
			table.insert(hints, h)
		end
		multi = multi or (#mu > 0)
	end
	hints = lev_sort(hints)
	if multi then -- #matches > 0 or #hints == 0 or multi then
		return res
	end
	for _, v in ipairs(hints) do
		if #matches > 0 and #matches[1].match > hints.lev then
			return res
		end
		local pat = self:pattern(v)
		for _, p in ipairs(pat) do
			table.insert(res, p)
		end
	end
	if #hints == 0 and #matches > 0 then
		return res, true, not not matches[1].match.vargs
	end
	return res, #matches > 0
end


function mp:match(verb, w)
	local matches = {}
	local found
	local hints = {}
	local unknown = {}
	local multi = {}
	local vargs
	for _, d in ipairs(verb.dsc) do -- verb variants
		local match = { args = {}, vargs = {}, ev = d.ev }
		local a = {}
		found = (#d.pat == 0)
		for k, v in ipairs(w) do
			if k ~= verb.verb_nr then
				table.insert(a, v)
			end
		end
		local all_optional = true
		for lev, v in ipairs(d.pat) do -- pattern arguments
			if v == '*' then
				found = true
				vargs = true
				break
			end
			local pat = self:pattern(v) -- pat -- possible words
			local best = #a + 1
			local best_len = 1
			local word
			local required
			found = false
			for _, pp in ipairs(pat) do -- single argument
				if not pp.optional then
					required = true
					all_optional = false
				end
				local k, len = word_search(a, pp.word)
				if found and self:eq(found.word, pp.word) and found.ob and pp.ob then -- few ob candidates
					table.insert(multi, { word = found.ob:noun(found.alias), lev = lev })
					table.insert(multi, { word = pp.ob:noun(pp.alias), lev = lev })
					found = false
					break
				elseif k and (k < best or len > best_len) then
					best = k
					word = pp.word
					found = pp
					best_len = len
				end
			end
			if found then
				a = tab_sub(a, best + best_len - 1)
				table.remove(a, 1)
				table.insert(match, word)
				table.insert(match.args, found)
			elseif required then
				for i = 1, best - 1 do
					table.insert(unknown, { word = a[i], lev = lev })
				end
				table.insert(hints, { word = v, lev = lev })
				break
			end
		end
		if #multi > 0 then
			matches = {}
			break
		end
		if found or all_optional then
			local fixed = verb.verb[verb.word_nr]
			fixed = fixed.word .. (fixed.morph or '')
			table.insert(match, 1, fixed) -- w[verb.verb_nr])
			table.insert(matches, match)
			if vargs then
				for _, v in ipairs(a) do
					table.insert(match.vargs, v)
				end
			else
				match.vargs = false
			end
		end
	end
	table.sort(matches, function(a, b) return #a > #b end)
	hints = lev_sort(hints)
	unknown = lev_sort(unknown)
	multi = lev_sort(multi)
	return matches, hints, unknown, multi
end

function mp:err(err)
	if err == "UNKNOWN_VERB" then
		local verbs = self:lookup_verb(self.words, true)
		local hint = false
		if verbs and #verbs > 0 then
			local verb = verbs[1]
			local fixed = verb.verb[verb.word_nr]
			if verb.lev < 4 then
				hint = true
				p (self.msg.UNKNOWN_VERB or "Unknown verb:", " ", self.words[verb.verb_nr], ".")
				pn(self.msg.UNKNOWN_VERB_HINT or "Did you mean:", " ", fixed.word .. (fixed.morph or ""), "?")
			end
		end
		if not hint then
			p (self.msg.UNKNOWN_VERB or "Unknown verb:", " ", self.words[1], ".")
		end
	elseif err == "INCOMPLETE" then
		local need_noun = #self.hints > 0 and self.hints[1]:find("^{noun}")
		if #self.unknown > 0 then
			if need_noun then
				p (self.msg.UNKNOWN_OBJ or "Do not see it here ", " (",self.unknown[1], ").")
			else
				p (self.msg.UNKNOWN_WORD or "Unknown word", " (", self.unknown[1], ").")
			end
		end
		p (self.msg.INCOMPLETE or "Incomplete sentence.")
		if #self.hints > 0 then
			p (self.msg.HINT_WORDS or "Possible words:", " ")
		end
		local first = true
		for _, v in ipairs(self.hints) do
			if v:find("^{noun}") or v:find("/[^/]*$") then
				if not first then
					pr (" ",mp.msg.HINT_OR or "or", " ")
				end
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
		pr (self.msg.MULTIPLE or "There are", " ", self.multi[1])
		for k = 2, #self.multi do
			pr (" ", mp.msg.HINT_AND or "and", " ", self.multi[k])
		end
		pr "."
	end
end

local function get_events(self, ev)
	local events = {}
	for _, v in ipairs(ev) do
		local ea = str_split(v)
		local e = ea[1]
		local args = {}
		table.remove(ea, 1)
		for _, vv in ipairs(ea) do
			local a = vv
			if vv:find("^%%[0-9]+$") then
				a = vv:gsub("%%", "")
				a = tonumber(a)
				a = self.args[a]
				if a then a = a.ob or a.word end
			end
			table.insert(args, a)
		end
		table.insert(events, { ev = e, args = args })
	end
	return events
end

function mp:call(ob, ev, ...)
	local r, v = std.call(ob, ev, ...)
	if self.debug.trace_action and r then dprint("mp:call ", ob, ev, ...) end
	return r, v
end

function mp:events_call(events, ob, t)
	if not t then t = '' else t = t .. '_' end
	for _, o in ipairs(ob) do
		for _, e in ipairs(events) do
			local ename = t .. e.ev
			local eany = t .. 'Any'
			local edef = t .. 'Default'
			local ob = o
			if o == 'obj' then
				ob = e.args[1]
				table.remove(e.args, 1)
			end
			local r, v
			if std.is_obj(ob) then
				r, v = self:call(ob, eany, std.unpack(e.args))
				if r then std.pr(r) end
				if not v then
					r, v = self:call(ob, ename, std.unpack(e.args))
					if r then std.pr(r) end
					if not v then
						r, v = self:call(ob, edef, std.unpack(e.args))
						if r then std.pr(r) end
					end
				end
			end
			if v then return v end
			if o == 'obj' then
				table.insert(e.args, 1, ob)
			end
		end
	end
	return false
end

function mp:action()
	local parsed = self.parsed
	local ev = str_split(parsed.ev, "|")
	local events = get_events(self, ev)
	local r

	if not self:events_call(events, { parser, game, std.me(), std.here(), 'obj' }, 'before') then
		r = self:events_call(events, { parser, game, std.me(), std.here(), 'obj' })
	end

	self:events_call(events, { 'obj', std.here(), std.me(), game, parser }, 'after')

	-- parser:before_Any
	-- parser:before_Take || before_Def
	-- game:before_Any
	-- game:before_Take || before_Def
	-- me():before_Any
	-- me():before_Take || before_Def
	-- here():before_Any
	-- here():before_Take || before_Def
	-- ob():before_Any
	-- ob():before_Take || before_Def

	-- game:Any
	-- game:Take || Def
	-- me():Any
	-- me():Take || Def
	-- here():Any
	-- here():Take || Def
	-- ob():Any
	-- ob():Take || Def
	-- parser:Any
	-- parser:Take || Def

	-- ob():after_Take || after_Def
	-- ob():after_Any
	-- here():after_Take || after_Def
	-- here():after_Any
	-- me():after_Take || after_Def
	-- me():after_Any
	-- game:after_Take || after_Def
	-- game:after_Any
	-- parser:after_Take || after_Def
	-- parser:after_Any
end

function mp:parse(inp)
	inp = inp:gsub("[ ]+", " "):gsub("["..inp_split.."]+", " ")
	pn(fmt.b(self.prompt .. inp))
	local r, v = self:input(self:norm(inp))
	if not r then
		self:err(v)
		return
	end
	local rinp = ''
	for _, v in ipairs(self.parsed) do
		if rinp ~= '' then rinp = rinp .. ' ' end
		rinp = rinp .. v
	end
	for _, v in ipairs(self.vargs and self.vargs or {}) do
		if rinp ~= '' then rinp = rinp .. ' ' end
		rinp = rinp .. v
	end
	if not self:eq(rinp, inp) then
		pn(fmt.em("("..rinp..")"))
	end
	local t = std.pget()
	std.pclr()
	-- here we do action
	mp:action()
	local tt = std.pget()
	std.pclr()
	pr(t, tt)
end

std.world.display = function(s, state)
	local l, av, pv
	local reaction = s:reaction() or nil
	if state then
		reaction = iface:em(reaction)
		av, pv = s:events()
		av = iface:em(av)
		pv = iface:em(pv)
		if s.player:need_scene() then
			l = s.player:look() -- objects [and scene]
		end
	end
	l = std.par(std.scene_delim, reaction or false,
		    av or false, l or false,
		    pv or false) or ''
	mp.text = mp.text ..  l .. '^^' .. fmt.anchor()
	return mp.text
end

function mp:completion(word)
	self.inp = self:docompl(self.inp, word)
	self.cur = self.inp:len() + 1
	self:compl_fill(self:compl(self.inp))
end

function mp:key_enter()
	local r, v = std.call(mp, 'parse', self.inp)
	self.inp = '';
	self.cur = 1;
	self:completion()
	return r, v
end

function mp:lookup_noun(w)
	local oo = {}
	local k, len
	local res = {}
	std.here():for_each(function(v)
		table.insert(oo, v)
	end)
	inv():for_each(function(v)
		table.insert(oo, v)
	end)
	for _, o in ipairs(oo) do
		local ww = {}
		o:noun(ww)
		for _, d in ipairs(ww) do
			k, len = word_search(w, d.word)
			if k and len == #w then
				d.ob = o
				table.insert(res, d)
			end
		end
	end
	if #res == 0 then
		return res
	end
	table.sort(res, function(a, b)
		return a.word:len() > b.word:len()
	end)
	return res
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
		-- match object?
		local ob = self:lookup_noun(w)
		if #ob > 1 then
			self.multi = {}
			for _, v in ipairs(ob) do
				table.insert(self.multi, v.ob:noun(v.alias))
			end
			return false, "MULTIPLE"
		end
		if #ob == 0 then
			return false, "UNKNOWN_VERB"
		end
		-- it is the object!
		table.insert(w, 1, self.default_verb or "examine")
		verbs = self:lookup_verb(w)
		if #verbs == 0 then
			return false, "UNKNOWN_VERB"
		end
	end
	local matches = {}
	for _, v in ipairs(verbs) do
		local m, h, u, mu = self:match(v, w)
		if #m > 0 then
			table.insert(matches, { verb = v, match = m[1] })
		else
			table.insert(hints, h)
			table.insert(unknown, u)
			table.insert(multi, mu)
		end
	end

	table.sort(matches, function(a, b) return #a.match > #b.match end)

	hints = lev_sort(hints)
	unknown = lev_sort(unknown)
	multi = lev_sort(multi)

	if #matches == 0 then
		self.hints = hints
		self.unknown = unknown
		self.multi = multi
		if #multi > 0 then
			self.multi = multi
			return false, "MULTIPLE"
		end
		return false, "INCOMPLETE"
	end
	self.parsed = matches[1].match
	self.args = self.parsed.args
	self.vargs = self.parsed.vargs
	return true
end

-- Verb { "#give", "отдать,дать", "{$inv/вн} ?для {$obj/вн} : give %2 %3|receive %3 %2"}

function Verb(t, w)
	return mp:verb(t, w)
end
std.rawset(_G, 'mp', mp)
std.mod_cmd(
function(cmd)
	if cmd[2] == '@metaparser' then
		if cmd[3] == '<enter>' then
			return mp:key_enter()
		end
		if cmd[3] == '<space>' then
			mp:inp_insert(' ')
			return true, false
		end
		if cmd[3] == '<backspace>' then
			mp:inp_remove()
			mp:compl_fill(mp:compl(mp.inp))
			return true, false
		end
		if cmd[4] == 'letter' then
			mp.inp = mp.inp .. cmd[3]
			mp.cur = mp.inp:len() + 1
		else
			mp:completion(cmd[3])
		end
		return true, false
	end
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
	mp:compl_fill(mp:compl(""))
end)

instead.mouse_filter(0)

function instead.fading()
	return instead.need_fading()
end
