require "fmt"

local lang = require "lang-ru"

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

local okey = input.key

function input:key(press, key)
	local a
	if press then
		if key == 'space' or key == 'backspace' or key == 'return' or key:len() == 1 then
			for _, v in std.ipairs {press, key} do
				a = (a and (a..', ') or ' ') .. std.dump(v)
			end
			return '@mp_key '.. (a or '')
		end
	end
	if okey then
		return okey(self, press, key)
	end
end

local mp = std.obj {
	nam = '@metaparser';
	{
		inp = '';
		cur = 1;
		cursor = fmt.b("|")
	}
}

function mp:inp_left()
	if self.cur > 1 then
		local i = utf_bb(self.inp, self.cur - 1)
		self.cur = self.cur - i
	end
	if self.cur < 1 then self.cur = 1 end
end

function mp:inp_right()
	if self.cur <= self.inp:len() then
		local i = utf_ff(self.inp, self.cur)
		self.cur = self.cur + i
	end
	if self.cur > self.inp:len() then self.cur = self.inp:len() + 1 end
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

instead.get_inv = std.cacheable('inv', function(horiz)
	local pre, post = mp:inp_split()
	return iface:esc(pre)..mp.cursor..iface:esc(post)
end)

std.mod_cmd(function(cmd)
	if cmd[1] ~= '@mp_key' then
			return
	end
	local key = cmd[3]
	if key == 'backspace' then
		if mp:inp_remove() then
			return true, false
		end
		return false
	end
	key = lang.kbd[key]
	if key then
		mp:inp_insert(key)
		return true, false
	end
	return false
end)
