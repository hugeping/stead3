local mrd =
{

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

function mrd:load_section(f)
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
	if not n or n == 0 then
		return false
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

local function word_fn(l, words, self)
	local w = split(l)
	if #w ~= 6 then
		msg("Skipping word: "..l)
		return
	end
	if w[1] == '#' then w[1] = '' end
	local nflex = tonumber(w[2]) or false
	local an = w[5]
	if an == '-' then an = false end
	local npref = tonumber(w[6]) or false
	if nflex then
		nflex = self.flex[nflex + 1]
		if not nflex then
			msg("Wrong paradigm number for word: "..l)
			return
		end
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
	if nflex then
		for k, v in ipairs(nflex) do
			if v.an["им"] then
				local tt = v.pre .. t .. v.post
			end
		end
	else

	end
end

function mrd:load(path)
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

	local words = {}
	if not section(f, word_fn, words, self) then
		return false, "Error in section 4"
	end
	self.words = words
	f:close()
end

mrd:gramtab()
mrd:load()
