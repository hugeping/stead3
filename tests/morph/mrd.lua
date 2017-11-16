local mrd = {
}

local msg = print

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
				if not dict or dict[tt] then
					local a = {}
					for kk, vv in pairs(an or {}) do
						a[kk] = an[kk]
					end
					for kk, vv in pairs(v.an) do
						a[kk] = v.an[kk]
					end
					local w = { t = tt, flex = nflex, an = a }
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

mrd:gramtab()
mrd:load(false, { ["ПОДОСИНОВИК"] = true })
mrd:dump()
