local std = stead
local type = std.type
local table = std.table
local input = std.ref '@input'
local string = std.string
local okey
local txt = std.ref '@iface'

local kbden = {
	shifted = {
	["1"] = "!",
	["2"] = "@",
	["3"] = "#",
	["4"] = "$",
	["5"] = "%",
	["6"] = "^",
	["7"] = "&",
	["8"] = "*",
	["9"] = "(",
	["0"] = ")",
	["-"] = "_",
	["="] = "+",
	["["] = "{",
	["]"] = "}",
	["\\"] = "|",
	[";"] = ":",
	["'"] = "\"",
	[","] = "<",
	["."] = ">",
	["/"] = "?",
	}
}

local kbdru = {
	["q"] = "й",
	["w"] = "ц",
	["e"] = "у",
	["r"] = "к",
	["t"] = "е",
	["y"] = "н",
	["u"] = "г",
	["i"] = "ш",
	["o"] = "щ",
	["p"] = "з",
	["["] = "х",
	["]"] = "ъ",
	["a"] = "ф",
	["s"] = "ы",
	["d"] = "в",
	["f"] = "а",
	["g"] = "п",
	["h"] = "р",
	["j"] = "о",
	["k"] = "л",
	["l"] = "д",
	[";"] = "ж",
	["'"] = "э",
	["z"] = "я",
	["x"] = "ч",
	["c"] = "с",
	["v"] = "м",
	["b"] = "и",
	["n"] = "т",
	["m"] = "ь",
	[","] = "б",
	["."] = "ю",
	["`"] = "ё",

	shifted = {
	["q"] = "Й",
	["w"] = "Ц",
	["e"] = "У",
	["r"] = "К",
	["t"] = "Е",
	["y"] = "Н",
	["u"] = "Г",
	["i"] = "Ш",
	["o"] = "Щ",
	["p"] = "З",
	["["] = "Х",
	["]"] = "Ъ",
	["a"] = "Ф",
	["s"] = "Ы",
	["d"] = "В",
	["f"] = "А",
	["g"] = "П",
	["h"] = "Р",
	["j"] = "О",
	["k"] = "Л",
	["l"] = "Д",
	[";"] = "Ж",
	["'"] = "Э",
	["z"] = "Я",
	["x"] = "Ч",
	["c"] = "С",
	["v"] = "М",
	["b"] = "И",
	["n"] = "Т",
	["m"] = "Ь",
	[","] = "Б",
	["."] = "Ю",
	["`"] = "Ё",
	["1"] = "!",
	["2"] = "@",
	["3"] = "#",
	["4"] = ";",
	["5"] = "%",
	["6"] = ":",
	["7"] = "?",
	["8"] = "*",
	["9"] = "(",
	["0"] = ")",
	["-"] = "_",
	["="] = "+",
	}
}

local kbdlower = {
	['А'] = 'а',
	['Б'] = 'б',
	['В'] = 'в',
	['Г'] = 'г',
	['Д'] = 'д',
	['Е'] = 'е',
	['Ё'] = 'ё',
	['Ж'] = 'ж',
	['З'] = 'з',
	['И'] = 'и',
	['Й'] = 'й',
	['К'] = 'к',
	['Л'] = 'л',
	['М'] = 'м',
	['Н'] = 'н',
	['О'] = 'о',
	['П'] = 'п',
	['Р'] = 'р',
	['С'] = 'с',
	['Т'] = 'т',
	['У'] = 'у',
	['Ф'] = 'ф',
	['Х'] = 'х',
	['Ц'] = 'ц',
	['Ч'] = 'ч',
	['Ш'] = 'ш',
	['Щ'] = 'щ',
	['Ъ'] = 'ъ',
	['Э'] = 'э',
	['Ь'] = 'ь',
	['Ю'] = 'ю',
	['Я'] = 'я',
}


local function txt_esc(s)
	local rep = function(s)
		return txt:nb(s)
	end
	if not s then return end
	local r = s:gsub("[<>]+", rep):gsub("[ \t]", rep);
	return r
end

local function show_obj(s, v, pfx, verbose)
	local wh = v:where()
	if wh then
		wh = '@'..std.dispof(wh)
	else
		wh = ''
	end
	s:printf("%s%s%snam: %s%s | disp:%s | tag:%s\n",
		pfx or '',
		v:disabled() and '%' or '',
		v:closed() and '-' or '',
		std.tostr(std.nameof(v)),
		wh,
		std.dispof(v), v.tag or 'n/a')
	if verbose then
		for k, v in std.pairs(v) do
			s:printf("*[%s] = %s\n", std.tostr(k), std.dump(v) or 'n/a')
		end
		return
	end
	for k, v in std.ipairs(v.obj) do
		pfx = (pfx or '' .. '    ')
		show_obj(s, v, pfx)
	end
end

local function show_room(s, v)
	s:printf("nam: %s | title: %s | disp: %s | tag: %s\n", std.tostr(std.nameof(v)), std.titleof(v), std.dispof(v), v.tag or 'n/a')
	s:printf("    way: ")
	for k, v in std.ipairs(v.way) do
		if k ~= 1 then
			s:printf(" | ")
		end
		s:printf("%s ", std.tostr(std.nameof(v)))
	end
	s:printf("\n")
end

local take = take

local	commands = {
	{ nam = 'quit',
		act = function(s)
			s.on = false
			s:disable();
			return std.nop()
		end;
	};
	{ nam = 'show',
		{ nam = 'obj',
			act = function(s, par)
				if par == '*' then
					local objs = {}
					std.for_each_obj(function(v)
						if not v:type 'room' then
							table.insert(objs, v)
						end
					end)
					table.sort(objs, function(a, b)
						return std.tostr(std.nameof(a)) < std.tostr(std.nameof(b))
					end)
					for i = 1, #objs do
						show_obj(s, objs[i])
					end
					return
				end
				if not par then
					for i = 1, #std.here().obj do
						show_obj(s, std.here().obj[i])
					end
					return
				end
				s:printf("[object]\n")
				local st, r = std.pcall(function()
					show_obj(s, std.object(std.tonum(par) or par), '    ', true) end)
				if not st then
					s:printf("%s\n", r)
					return
				end
				return
			end;
		},
		{ nam = 'inv',
			act = function(s)
				s:printf("[inventory]\n")
				for k, v in std.ipairs(std.me():inventory()) do
					show_obj(s, v, '    ')
				end
			end;
		};
		{ nam = 'room',
			act = function(s, par)
				if par == '*' then
					local rooms = {}
					std.for_each_obj(function(v)
						if v:type 'room' then
							table.insert(rooms, v)
						end
					end)
					table.sort(rooms, function(a, b)
						return std.tostr(std.nameof(a)) < std.tostr(std.nameof(b))
					end)
					for i = 1, #rooms do
						show_room(s, rooms[i])
					end
					return
				end
				local r, v = std.pcall(function() return par and std.object(par) or std.here() end)
				if not r then
					s:printf("%s\n", v)
					return
				end
				s:printf("[room]\n    ")
				show_room(s, v)
				s:printf("[objects]\n")
				for k, v in std.ipairs(std.here().obj) do
					show_obj(s, v, '    ')
				end
			end;
		};
	};
	{ nam = 'take',
	  act = function(s, par)
		if not par then
			return
		end
		local st, r, v = s:eval(take, std.tonum(par) or par)
		if not st then
			s:printf("%s\n", r)
			return
		end
		return r, v
	  end;
	},
	{ nam = 'dump',
		act = function(s, par)
			if not par then
				return
			end
			local f, err = std.eval('return ('..par..')')
			if not f then
				s:printf("%s\n", err)
				return
			end
			err, f = std.pcall(f)
			if not err then
				s:printf("%s\n", f)
				return
			end
			if std.is_obj(f) then
				show_obj(s, f, '', true)
			else
				s:printf("%s\n", std.dump(f))
			end
		end
	};
	{ nam = 'eval',
		act = function(s, par)
			if not par then
				return
			end
			local f, err = std.eval(par)
			if not f then
				s:printf("%s\n", err)
				return
			end
			f, err = std.pcall(f)
			if not f then
				s:printf("%s\n", err)
				return
			end
		end
	};
	{ nam = 'walk',
		act = function(s, par)
			if not par then
				return
			end
			return s:eval(walk, par, true)
		end;
	};
	{ nam = 'cls',
		act = function(s)
			s:cls()
		end;
	};
	{ nam = 'help',
		act = function(s)
			s:printf([[Use <tab> key to complete words.
Use <up>/<down> for history.
Use ctrl-d or f6 to enter/exit debugger.
Some useful commands:
    show obj * - show all objects
    show room * - show all rooms
    show obj <name> - show object (in verbose mode)
    show room <name> - show room
    show room - show here
    walk <name> - walk anywhere
]]);
		end;
	};
	lookup = function(s, inp)
		local cmd = std.split(inp)
		local cur = s
		local found
		local last_found
		for k, v in std.ipairs(cmd) do
			found = nil
			for i, c in std.ipairs(cur) do
				if v == c.nam then
					cur = c
					found = k
					last_found = k
					break
				end
			end
			if not found then
				break
			end
		end
		local par
		if last_found then
			for i = last_found + 1, #cmd do
				par = (par and (par .. ' ') or '').. cmd[i]
			end
		else
			par = inp
		end
		return cur, par
	end;
	completion = function(s, inp)
		local cmd, par = s:lookup(inp)
		if not cmd then
			return
		end
		if #cmd == 0 then
			if par then
				local var = {}
				std.for_each_obj(function(v, var)
					if std.tostr(v.nam):find(par, 1, true) == 1 and std.tostr(v.nam) ~= par then
						table.insert(var, std.tostr(v.nam))
					end
				end, var)
				return var
			end
			return
		end
		local var = {}
		for i = 1, #cmd do
			if cmd[i].nam:find(par or '', 1, true) == 1 then
				table.insert(var, cmd[i].nam)
			end
		end
		return var
	end;
	save = function() end;
};

local embed =	{
	on = false;
	key_shift = false;
	key_ctrl = false;
	input = '';
	output = [[INSTEAD dbg 0.1
Written by Peter Kosyh in 2017
Type "help" to see help
]];
	hint = '';
	history = {};
	history_pos = 1;
	key_alt = false;
	key_ctrl = false;
	kbd_alt_xlat = false;
};

local old_get_picture
local old_get_fading


local dbg = std.obj {
	pri = 16384;
	nam = '@dbg';
	embed;
	{ commands = commands },
	enable = function(s)
		local instead = std.ref '@instead'
		old_get_picture = instead.get_picture
		old_get_fading = instead.get_fading
		std.rawset(instead, 'get_picture', function() end)
		std.rawset(instead, 'get_fading', function() end)
--		s.last_timer = timer:get()
--		timer:stop()
		s.last_disp = std.game:lastdisp()
		iface:raw_mode(true)
	end;
	disable = function(s)
		std.rawset(instead, 'get_picture', old_get_picture)
		std.rawset(instead, 'get_fading', old_get_fading)
		iface:raw_mode(false)
	--	timer:set(s.last_timer)
		std.game:lastdisp(s.last_disp)
	end;
	eval = function(s, fn, ...)
		local st, r, v = std.pcall(fn, ...)
		if not st then
			s:printf("%s\n", r)
		else
			s.on = false
			s:disable()
			return std.nop()
		end
	end;
	cls = function(s)
		s.output = '';
		s.hint = '';
	end;
	completion = function(s, edit)
		local hint = s.commands:completion(s.input)
		if not hint or #hint == 0 then
			s.hint = ''
			return
		end
		if #hint == 1 and edit ~= false then
			s.input = s.input:gsub("[ \t]+[^ \t]+$", " "):gsub("^[^ \t]+$", "")
			s.input = s.input .. hint[1]..' '
			s:completion(edit)
			return
		end
		s.hint = ''
		for k, v in std.ipairs(hint) do
			s.hint = s.hint .. v .. ' '
		end
	end;
	printf = function(s, fmt, ...)
		s.output = s.output .. std.string.format(fmt, ...)
	end;
	exec = function(s)
		local c, par = s.commands:lookup(s.input)
		if not c or not c.act then
			return s:completion()
		end
		if #s.history == 0 or s.history[#s.history] ~= s.input then
			table.insert(s.history, s.input)
		end
		s.history_pos = 0
		s:printf('======== [ '..s.input..' ] ========\n')
		s.input = ''
		s.hint = ''
		return c.act(s, par)
	end;
	dsc = function(s) -- display debugger
		pr (txt_esc(s.output))
		if s.kbd_alt_xlat then
			pr (txt:bold '&')
		else
			pr (txt:bold ' ')
		end
		pr (txt:bold '# '.. txt_esc(s.input) .. txt:bold '|'..'\n')
		pr (s.hint..'\n')
		pr (txt:anchor())
	end;
	key = function(s, press, key)
		if key:find 'shift' then
			s.key_shift = press
			return
		elseif key:find 'ctrl' then
			s.key_ctrl = press
			return
		elseif key:find 'alt' then
			s.key_alt = press
			if not press then
				s.kbd_alt_xlat = not s.kbd_alt_xlat
				return 'look'
			end
			return
		end
		if not press then
			return
		end
		if s.key_ctrl or s.key_alt then
			if key == 'q' or key == 'r' then
				return
			end
		end
		if s.key_shift then
			if key == 'up' or key == 'down' then
				return
			end
		end
		if key == 'f7' or (s.key_ctrl and key == 'd') then
			return '@dbg toggle'
		end

		if s.on then
			return '@dbg key '..string.format("%q", key)
		end
	end;
}
local timer = std.ref '@timer'

local function key_xlat(s)
	local kbd

	if s:len() > 1 then
		return
	end

	if dbg.kbd_alt_xlat and (std.game.codepage == 'UTF-8' or std.game.codepage == 'utf-8') then
		kbd = kbdru;
	else
		kbd = kbden
	end

	if kbd and dbg.key_shift then
		kbd = kbd.shifted;
	end

	if not kbd[s] then
		if dbg.key_shift then
			return s:upper();
		end
		return s;
	end
	return kbd[s]
end

std.mod_cmd(function(cmd)
	if cmd[1] ~= '@dbg' then
		if dbg.on then
			if cmd[1] == 'look' then
				std.abort()
				return std.call(dbg, 'dsc')
			end
			return nil, false
		end
		return
	end
	if cmd[2] == 'toggle' then
		dbg.on = not dbg.on
		if dbg.on then
			dbg:enable()
			std.abort()
			return std.call(dbg, 'dsc')
		else
			dbg:disable()
			return std.nop()
		end
	elseif cmd[2] == 'key' then
		local key = cmd[3]
		if key:find 'return' then
			local r, v = dbg:exec()
			if r ~= nil or v ~= nil then
				return r, v
			end
		elseif key:find '^backspace' and dbg.key_ctrl then
			if dbg.input == '' then
				return
			end
			if dbg.input:find("^[ \t]*[^ \t]+[ \t]*$") then
				dbg.input = ''
			else
				dbg.input = dbg.input:gsub("[ \t]+[^ \t]+[ \t]*$", " ")
			end
		elseif key:find '^backspace' then
			if dbg.input == '' then
				return
			end
			if dbg.input:byte(dbg.input:len()) >= 128 then
				dbg.input = dbg.input:sub(1, dbg.input:len() - 2);
			else
				dbg.input = dbg.input:sub(1, dbg.input:len() - 1);
			end
		elseif key:find '^space' then
			dbg.input = dbg.input .. ' '
		elseif key:find '^tab' then
			dbg:completion()
		elseif key:find '^up' then
			local s = dbg
			if #s.history == 0 then
				return
			end
			if s.history_pos == 0 then
				s.history_pos = #s.history + 1
			end
			s.history_pos = s.history_pos - 1
			if s.history_pos == 0 then
				s.history_pos = 1
			end
			s.input = s.history[s.history_pos]
		elseif key:find '^down' then
			local s = dbg
			if #s.history == 0 or s.history_pos == #s.history then
				return
			end
			s.history_pos = s.history_pos + 1
			if s.history_pos > #s.history then
				s.history_pos = #s.history
			end
			s.input = s.history[s.history_pos]
		elseif key_xlat(key) then
			dbg.input = dbg.input .. key_xlat(key)
		else
			return nil, false
		end
		dbg:completion(false)
		std.abort()
		return std.call(dbg, 'dsc'), true
	end
end, -1)

std.mod_start(function()
	iface:raw_mode(false)
	okey = input.key;
	std.rawset(input, 'key', function(self, ...) return dbg:key(...) end)
end, -1)

std.mod_done(function()
	iface:raw_mode(false)
	std.rawset(input, 'key', okey)
end)

-- std.rawset(_G, 'dbg',  std.ref '@dbg')
