local lang = {
	norm = function(str)
	end;
	upper = function(str)
	end;
	lower = function(str)
	end;
}

local mrd = {
	lang = lang;
}

local msg = print

local function strip(str)
	str = str:gsub("^[ \t]+", ""):gsub("[ \t]$", "")
	return str
end

local function split(str, sep)
	local words = {}
	if not str then
		return words
	end
	for w in str:gmatch(sep or "[^ \t]+") do
		table.insert(words, w)
	end
	return words
end

local function empty(l)
	l = l:gsub("[ \t]+", "")
	return l == ""
end

function mrd:gramtab(path)
	local f, e = io.open(path or 'rgramtab.tab', 'rb')
	if not f then
		return false, e
	end
	self.gram = {
		an = {}; -- by ancodes
		t = {}; -- by types
	}
	for l in f:lines() do
		if not l:find("^[ \t]*//") and not empty(l) then -- not comments
			local w = split(l)
			if #w < 3 then
				msg("Skipping gram: "..l)
			else
				local a = split(w[4], '[^,]+')
				local an = {}
				for k, v in ipairs(a) do
					an[v] = true
				end
				an.t = w[3] -- type
				self.gram.an[w[1]] = an;
				self.gram.t[w[3]] = an;
			end
		end
	end
	f:close()
end

local function section(f, fn, ...)
	local n = tonumber(f:read("*line"))
	if not n then
		return false
	end
	if n == 0 then
		return true
	end
	for l in f:lines() do -- skip accents
		if fn then fn(l, ...) end
		n = n - 1
		if n == 0 then
			break
		end
	end
	return true
end

local function flex_fn(l, flex, an)
	l = l:gsub("//.*$", "")
	local fl = {}
	for w in l:gmatch("[^%%]+") do
		local ww = split(w, "[^%*]+")
		if #ww > 3 or #ww < 1 then
			msg("Skip lex: ", w, l);
		else
			local f = { }
			if #ww == 1 then
				f.an = ww[1]
				f.post = ''
			else
				f.post = ww[1]
				f.an = ww[2]
			end
			f.pre = ww[3] or ''
			local a = an[f.an]
			if not a then
				msg("Gram not found. Skip lex: "..f.an)
			else
				f.an_name = f.an
				f.an = a
				table.insert(fl, f)
			end
		end
	end
	table.insert(flex, fl)
end

local function pref_fn(l, pref)
	local p = split(l, "[^,]+")
	table.insert(pref, p)
end

local function dump(vv)
	local s = ''
	if type(vv) ~= 'table' then
		return string.format("%s", tostring(vv))
	end
	for k, v in pairs(vv) do
		s = s .. string.format("%s = %s ", k, v)
	end
	return s
end

local function word_fn(l, self, dict)
	local words = self.words
	local words_list = self.words_list
	local w = split(l)
	if #w ~= 6 then
		msg("Skipping word: "..l)
		return
	end
	if w[1] == '#' then w[1] = '' end
	local nflex = tonumber(w[2]) or false
	local an = w[5]
	if an == '-' then an = false end
	local an_name = an
	local npref = tonumber(w[6]) or false
	if not nflex then
		msg("Skipping word:"..l)
		return
	end
	nflex = self.flex[nflex + 1]
	if not nflex then
		msg("Wrong paradigm number for word: "..l)
		return
	end
	if an then
		an = self.gram.an[an]
		if not an then
			msg("Wrong ancode for word: "..l)
			return
		end
	end
	if npref then
		npref = self.pref[npref + 1]
		if not npref then
			msg("Wrong prefix for word: "..l)
			return
		end
	end
	local t = w[1]
	local num = 0
	local used = false
	for k, v in ipairs(nflex) do
		if v.an["им"] then
			for _, pref in ipairs(npref or { '' }) do
				local tt = pref..v.pre .. t .. v.post
				if self.lang.norm then
					tt = self.lang.norm(tt)
				end
				if not dict or dict[tt] then
					local a = {}
					for kk, vv in pairs(an or {}) do
						a[kk] = an[kk]
					end
					for kk, vv in pairs(v.an) do
						a[kk] = v.an[kk]
					end
					local w = { t = t, pref = pref, flex = nflex, an = a }
					local wds = words[tt] or {}
					table.insert(wds, w)
					nflex.used = true
					used = true
					if npref then
						npref.used = true
					end
					num = num + 1
					if #wds == 1 then
						words[tt] = wds
					end
				end
			end
		end
	end
	if used then
		table.insert(words_list, { t = w[1], flex = nflex, pref = npref, an = an_name })
	end
	self.words_nr = self.words_nr + num
	return
end

function mrd:load(path, dict)
	local f, e = io.open(path or 'morphs.mrd', 'rb')
	if not f then
		return false, e
	end
	local flex = {}
	if not section(f, flex_fn, flex, self.gram.an) then
		return false, "Error in section 1"
	end
	self.flex = flex
	if not section(f) then
		return false, "Error in section 2"
	end
	if not section(f) then
		return false, "Error in section 3"
	end
	local pref = {}
	if not section(f, pref_fn, pref) then
		return false, "Error in section 4"
	end
	self.pref = pref
	self.words_nr = 0
	self.words = {}
	self.words_list = {}
	if not section(f, word_fn, self, dict) then
		return false, "Error in section 4"
	end
	msg("Generated: "..tostring(self.words_nr).." word(s)");
	f:close()
	return true
end

function mrd:dump(path)
	local f, e = io.open(path or 'dict.mrd', 'wb')
	if not f then
		return false, e
	end
	local n = 0
	for k, v in ipairs(self.flex) do
		if v.used then
			v.norm_no = n
			n = n + 1
		end
	end
	f:write(string.format("%d\n", n))
	for k, v in ipairs(self.flex) do
		if v.used then
			local s = ''
			for kk, vv in ipairs(v) do
				s = s .. '%'
				if vv.post == '' then
					s = s..vv.an_name
				else
					s = s..vv.post..'*'..vv.an_name
				end
				if vv.pre ~= '' then
					s = s .. '*'..vv.pre
				end
			end
			f:write(s.."\n")
		end
	end
	f:write("0\n")
	f:write("0\n")
	n = 0
	for k, v in ipairs(self.pref) do
		if v.used then
			v.norm_no = n
			n = n + 1
		end
	end
	f:write(string.format("%d\n", n))
	for k, v in ipairs(self.pref) do
		if v.used then
			local s = ''
			for kk, vv in ipairs(v) do
				if s ~= '' then s = s .. ',' end
				s = s .. vv
			end
			f:write(s.."\n")
		end
	end
	f:write(string.format("%d\n", #self.words_list))
	for k, v in ipairs(self.words_list) do
		local s = ''
		if v.t == '' then
			s = '#'
		else
			s = v.t
		end
		s = s ..' '..tostring(v.flex.norm_no)
		s = s..' - -'
		if v.an then
			s = s .. ' '..v.an
		else
			s = s .. ' -'
		end
		if v.pref then
			s = s ..' '..tostring(v.pref.norm_no)
		else
			s = s .. ' -'
		end
		f:write(s..'\n')
	end
	f:close()
end

function mrd:score(an, g)
	local score = 0
	for kk, vv in ipairs(g or {}) do
		if vv:sub(1, 1) == '~' then
			vv = vv:sub(2)
			if an[vv] then
				score = -1
				break
			end
		elseif an[vv] then
			score = score + 1
		end
	end
	return score
end

function mrd:lookup(w, g)
	local cap, upper = self.lang.is_cap(w)
	local t = self.lang.upper(w)
	w = self.words[t]
	if not w then
		return false, "No word in dictionary"
	end
	local res = {}
	for k, v in ipairs(w) do
		local flex = v.flex
		local score = self:score(v.an, g)
		for _, f in ipairs(flex) do
			local sc = self:score(f.an, g)
			if sc < 0 then
				break
			end
			table.insert(res, { score = score + sc, pos = #res, word = v, flex = f })
		end
	end
	if #res == 0 then
		return false, "No gram"
	end
	table.sort(res, function(a, b)
		if a.score == b.score then
			return a.pos < b.pos
		end
		return a.score > b.score
	end)
--	for i = 1, #res do
--		local w = res[i]
--		print(self.lang.lower(w.word.pref .. w.flex.pre .. w.word.t .. w.flex.post), w.score)
--	end
	w = res[1]
	w = self.lang.lower(w.word.pref .. w.flex.pre .. w.word.t .. w.flex.post)
	if upper then
		w = self.lang.upper(w)
	elseif cap then
		w = self.lang.cap(w)
	end
	return w
end

function mrd:word(w)
	local s, e = w:find("/[^/]*$")
	local g = {}
	if s then
		local gg = w:sub(s + 1)
		w = w:sub(1, s - 1)
		g = split(gg, "[^, ]+")
	end
	local found = true
	w = w:gsub("[^ \t,%-!/:]+",
		   function(w)
			   local ww = self:lookup(w, g)
			   if not ww then
				   found = false
			   end
			   return ww or w
	end)
	if not found then
		msg("Can not find word: "..w)
	end
	return w
end

function mrd:file(f, dict)
	dict = dict or {}
	local ff, e = io.open(f, "rb")
	if not ff then
		return false, e
	end
	for l in ff:lines() do
		for w in l:gmatch('%-"[^"]+"') do
			w = w:gsub('^-"', ""):gsub('"$', "")
			for ww in w:gmatch("[^, %-]+") do
				dict[self.lang.upper(ww)] = true;
				print("added word: ", ww)
			end
		end
	end
	ff:close()
	return dict
end

local mt = getmetatable("")
function mt.__unm(v)
	return v
end

return mrd
--mrd:gramtab()
--mrd.lang = require "lang-ru"
--mrd:load(false, { [mrd.lang.upper "подосиновики"] = true, [mrd.lang.upper "красные"] = true })
--local w = mrd:word(-"красные подосиновики/рд")
--print(w)
--mrd:file("mrd.lua")
