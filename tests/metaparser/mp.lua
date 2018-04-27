require "fmt"

local lang = require "morph/lang-ru"
local mrd = require "morph/mrd"

mrd.lang = lang

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
	if press and not mod and not (mp.ctrl or mp.alt) then
		if mp:key(key) then
			return '@mp_key'
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
		ctrl = false;
		shift = false;
		alt = false;
	};
	dict = {};
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
	if key:len() > 1 then
		return false
	end
	key = mp.shift and lang.kbd.shifted[key] or lang.kbd[key] or key
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
	return mp:esc(pre)..mp.cursor..mp:esc(post)
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
	verb.pattern = str_split(pattern, ',')
	if #verb.pattern == 0 then
		std.err("Wrong verb pattern: " .. verb.pattern, 2)
	end
	n = n + 1
	if type(t[n]) ~= 'string' then
		std.err("Wrong verb descriptor mp:verb()", 2)
	end
	verb.event = t[n]
	table.insert(w, verb)
	return verb
end

-- Verb { "#give", "отдать|дать,{inv}/вн,?для,{obj}/вн", "give %2 %3|receive %3 %2"}

std.mod_cmd(
function(cmd)
	if cmd[1] ~= '@mp_key' then
		return
	end

	return true, false
end)

std.mod_start(
function()
	mrd:gramtab("morph/rgramtab.tab")
	if not mrd:load("dict.mrd") then
		local dict = {}
		for f in std.readdir(instead.gamepath()) do
			if f:find("%.lua$") then
				mrd:file(f, dict)
			end
		end
		mrd:load("morph/morphs.mrd", dict)
		mrd:dump("dict.mrd")
	end
end)
