--[[attributes from Inform 6
absent. The object is currently not at its usual location(s).
animate. The object is some sort of creature or person.
clothing. The player character can wear this object; it's clothing.
concealed. The object is here but can't be seen.
container. This object can have other objects inside it.
door. The object is a door.
edible. The object is edible; it's food.
enterable. The PC can be located inside or on top of this object.
female. The object is female, or has the female gender.
general. No predefined meaning. The author may mark an object as "general" for any reason.
light. The object provides light; it is lit.
lockable. The object can be locked and unlocked.
locked. The object is locked.
male. The object is male, or has the male gender.
moved. The object has been moved from its original location.
neuter. The object has the neuter gender.
on. The object is turned on; it is activated.
open. The object is open.
openable. The object can be opened and closed.
pluralname. The object has a plural name, such as "clouds".
proper. The object has a proper name, such as "Robert".
scenery. The object is a feature of its location; compare with static.
scored. The points associated with this object have been awarded.
static. The object is fixed in place; compare with scenery.
supporter. This object can have other objects on top of it.
switchable. The object can be turned on and off.
talkable. This object can be talked to, e.g.: telephone, microphone.
transparent. The object's contents can be seen (assuming there's light).
visited. The player character has visited this location.
workflag. This object has been temporarily selected by the Inform library for some reason.
worn. The player character is currently wearing this object.
]]--
mp.door = std.class({
	before_Enter = function(s)
		if not s:has 'open' then
			local r = std.call(s, 'when_closed')
			p (r or mp.msg.Enter.DOOR_CLOSED)
			return
		end
		local r = std.call(s, 'door_to')
		if not r then
			p (mp.msg.Enter.DOOR_NOWHERE)
			return
		end
--		walk(r)
		if not move(std.me(), r) then return true end
	end;
}, std.obj):attr 'enterable,openable,door'
local function pnoun(noun, ...)
	local ctx = mp:save_ctx()
	mp.first = noun
	mp.first_hint = noun:gram().hint
	p(...)
	mp:restore_ctx(ctx)
end

mp.cutscene =
std.class({
	enter = function(s)
		s.__num = 1
	end;
	title = false;
	nouns = function() return {} end;
	dsc = function(s)
		p (s.text[s.__num])
	end;
	Next = function(s)
		s.__num = s.__num + 1
		if s.__num > #s.text then
			local r = std.call(s, 'next_to')
			if r then
				walk(r)
			else
				walkback()
			end
			return
		end
		p (s.text[s.__num])
	end;
}, std.room)

-- player
mp.msg.Look = {}

function std.obj:multi_alias()
	return self.__word_alias
end

std.room.dsc = function(s)
	p (mp.msg.SCENE);
end

std.obj.inside_dsc = function(s)
	p (mp.msg.INSIDE_SCENE);
end

function mp:thedark()
	return not mp:offerslight()
end

function std.obj:scene()
	local s = self
	local title = iface:title(std.titleof(mp:visible_scope(s)))

	return title
end

std.room.scene = std.obj.scene

local owalk = std.player.walk

std.obj.from = std.room.from

function std.player:walk(w, doexit, doenter, dofrom)
	w = std.object(w)
	if std.is_obj(w, 'room') then
		if w == std.here() then
			self.__room_where = false
			self:need_scene(true)
			return nil, true
		end
		local r, v = owalk(self, w, doexit, doenter, dofrom)
		self.__room_where = false
		return r, v
	end
	if std.is_obj(w) then -- into object
		if dofrom ~= false and std.me():where() ~= w then
			w.__from = std.me():where()
		end
		self.__room_where = w
		if w:inroom() == std.ref(self.room) then
			self:need_scene(true)
			return nil, true
		end
		return owalk(self, w:inroom(), doexit, doenter, dofrom)
	end
	std.err("Can not enter into: "..std.tostr(w), 2)
end

function std.player:walkout(w, ...)
	if w == nil then
		w = self:where():from()
	end
	return self:walk(w, true, false, ...)
end;

std.player.where = function(s, where)
	if type(where) == 'table' then
		table.insert(where, std.ref(s.__room_where or s.room))
	end
	return std.ref(s.__room_where or s.room)
end

std.room.display = function(s)
	local c = std.call(mp, 'content', s)
	return c
end
function mp:visible_scope(s)
	local h = s
	if s:has 'transparent' or s:has 'supporter' then
		mp:trace(s, function(v)
				 h = v
				 if not v:has'transparent' and not v:has'supporter' then
					 return nil, false
				 end
		end)
	end
	return h
end

std.obj.display = function(s)
	local c = std.call(mp, 'content', mp:visible_scope(s))
	return c
end

std.player.look = function(s)
	local scene
	local r = s:where()
	if s:need_scene() then
		scene = r:scene()
	end
--	local c = std.call(mp, 'room_content', s:where())
--	return (std.par(std.scene_delim, scene or false, c))
	return (std.par(std.scene_delim, scene or false, r:display() or false))
end;

--

function std.obj:access()
	local plw = {}
	local ww = {}
	if std.me():where() == self then
		return true
	end

	if self:has 'persist' then
		if not self.found_in then
			return true
		end
		local r, v = std.call(self, 'found_in')
		return v
	end
	local wh = std.me():where()
	if std.is_obj(wh.scope, 'list') then
		if wh.scope:lookup(self) then
			return true
		end
	end
	mp:trace(std.me(), function(v)
		if v:has 'concealed' then
			return nil, false
		end
		table.insert(plw, v)
		if v:has 'container' or v:has 'supporter' then
			return nil, false
		end
	end)
	return mp:trace(self, function(v)
		if v:has 'concealed' then
			return nil, false
		end
		for _, o in ipairs(plw) do
			if v == o then
				return true
			end
		end
		if v:has 'container' and not v:has 'open' then
			return nil, false
		end
	end)
end

function mp:offerslight(what)
	local w = std.me()
	if w:has'light' then
		return true
	end
	if what and (what:has'light' or std.me():lookup(what)) then
		return true
	end
	local l = mp:trace(w, function(v)
		if v:has 'light' then
			return true
		end
		if not v:has 'transparent' and not v:has 'open' and not v:has 'supporter' then
			return nil, false
		end
	end)
	return l
end

function std.obj:visible()
	local plw = { }
	local ww = {}
	if not mp:offerslight(self) then
		return false
	end
	if std.me():where() == self then
		return true
	end

	if self:has 'persist' then
		if not self.found_in then
			return true
		end
		local r, v = std.call(self, 'found_in')
		return v
	end

	local wh = std.me():where()

	if std.is_obj(wh.scope, 'list') then
		if wh.scope:lookup(self) then
			return true
		end
	end

	mp:trace(std.me(), function(v)
		if v:has 'concealed' then
			return nil, false
		end
		table.insert(plw, v)
		if v:has 'container' and not v:has 'transparent' then
			return nil, false
		end
	end)
	return mp:trace(self, function(v)
		if v:has 'concealed' then
			return nil, false
		end
		for _, o in ipairs(plw) do
			if v == o then
				return true
			end
		end
		if v:has 'container' and not v:has 'transparent' then
			return nil, false
		end
	end)
end

-- dialogs
std.phr.raw_word = function(s)
	local dsc = std.call(s, 'dsc')
	return dsc .. '|'.. (tostring(s.__ph_idx) or std.dispof(s))
end

std.phr.Exam = function(s, ...)
	std.me():need_scene(true)
	return s:act(...)
end

std.phr.__xref = function(s, str)
	return str
end

std.dlg.scene = std.room.scene

std.dlg.nouns = function(s)
	local r, nr
	local nouns = {}
	nr = 1
	local oo = s.current
	if not oo then -- nothing to show
		return
	end

	for i = 1, #oo.obj do
		local o = oo.obj[i]
		o = o:__alias()
		std.rawset(o, '__ph_idx', nr)
	end

	for i = 1, #oo.obj do
		local o = oo.obj[i]
		o = o:__alias()
		if o:visible() then
			std.rawset(o, '__ph_idx', nr)
			nr = nr + 1
			table.insert(nouns, o)
		end
	end
	return nouns
end;

std.phrase_prefix = function(n)
	if not n then
		return ''
	end
	return (string.format("%d) ", n))
end

obj {
	"north,n|south,s|east,e|west,w|up,u|down,d";
	nam = '@compass';
	{
		dirs = { 'n_to', 's_to', 'e_to', 'w_to', 'u_to', 'd_to' };
	};
	default_Event = 'Enter';
	found_in = function(s)
		for _, v in ipairs(s.dirs) do
			if std.here()[v] then return true end
		end
		return false or true
	end;
--	before_Default = [[Can't do it with direction.]];
--	visible = function() return true end;
	before_Exam = function(s)
		local d = s.dirs[s:multi_alias()]
		local r = std.call(std.here(), d)
		if not r or std.object(r):type 'room' then
			p (mp.msg.COMPASS_EXAM_NO)
			return
		end
		p (mp.msg.COMPASS_EXAM(d, std.object(r)))
	end;
	before_Walk = function(s)
		local d = s.dirs[s:multi_alias()]
		if d == 'out_to' then
			mp:xaction("Exit", std.me():where())
			return
		end
		if not std.me():where():type'room' then
			p (mp.msg.Enter.EXITBEFORE)
			return
		end
		local r = std.call(std.here(), d)
		if not r then
			local r = std.call(std.here(), 'cant_go')
			p (r or mp.msg.COMPASS_NOWAY)
			return
		end
		if std.object(r):type 'room' then
			if not move(std.me(), r) then return true end
		else
			mp:xaction("Enter", std.object(r))
		end
	end;
	before_Enter = function(s, ...)
		return s:before_Walk(...)
	end;
	dir = function(self)
		return self.dirs[self:multi_alias()]
	end
}:persist():attr'multi,enterable,light'

mp.compass_dir = function(w, dir)
	if not dir then
		return w == _'@compass' and w:dir()
	end
	return w == _'@compass' and w:dir() == dir
end

-- VERBS
local function if_has(w, a, t, f)
	return w:has(a) and t or f
end

mp.msg.Exam = {}
function mp:content(w)
	if w:type 'dlg' then
		return
	end
	local oo = {}
	local ooo = {}
	if w == std.me():where() then
		pn()
		local dsc
		if not mp:offerslight(w) then
			dsc = std.call(w, 'when_dark')
			dsc = dsc or mp.msg.WHEN_DARK
		else
			dsc = std.call(w, w:type'room' and 'dsc' or 'inside_dsc')
		end
		p(dsc)
	end
	self:objects(w, oo, false)
	local something
	for _, v in ipairs(oo) do
		local r = std.call(v, 'dsc')
		if r and not v:has'scenery' then
			p(r)
			something = true
		elseif not v:has'scenery' then
			table.insert(ooo, v)
		end
	end
	if #ooo > 0 then
		p(std.scene_delim)
	end
	oo = ooo
	if #oo == 0 then
		if mp.first == w and not something then
			if w:has 'supporter' then
				pnoun (w, mp.msg.Exam.ON)
			else
				pnoun (w, mp.msg.Exam.IN)
			end
			p (mp.msg.Exam.NOTHING)
		end
	elseif #oo == 1 and not oo[1]:hint 'plural' then
		if std.me():where() == w then
			p (mp.msg.Look.HEREIS)
		else
			if w:has 'supporter' then
				pnoun (w, mp.msg.Exam.ON)
			else
				pnoun (w, mp.msg.Exam.IN)
			end
			p (mp.msg.Exam.IS)
		end
		p(oo[1]:noun(), ".")
	else
		if std.me():where() == w then
			p (mp.msg.Look.HEREARE)
		else
			if w:has 'supporter' then
				pnoun (w, mp.msg.Exam.ON)
			else
				pnoun (w, mp.msg.Exam.IN)
			end
			p (mp.msg.Exam.ARE)
		end
		for _, v in ipairs(oo) do
			if _ ~= 1 then
				if _ == #oo then
					p (" ", mp.msg.AND or "and")
				else
					p ","
				end
			end
			pr (v:noun())
		end
		p "."
	end
-- expand?
	for _, o in ipairs(oo) do
		if (o:has'supporter' or o:has'transparent') and not o:closed() then
			self:content(o)
		end
	end
end

std.room:attr 'enterable,light'

function mp:before_Any(ev)
	if ev == 'Exam' then
		return false
	end
	if self.first and not self.first:access() and not self.first:type'room' then
		p (self.msg.ACCESS1 or "{#First} is not accessible.")
		if std.here() ~= std.me():where() then
			p (mp.msg.EXITBEFORE)
		end
		return
	end

	if self.second and not self.second:access() and not self.first:type'room' then
		p (self.msg.ACCESS2 or "{#Second} is not accessible.")
		if std.here() ~= std.me():where() then
			p (mp.msg.EXITBEFORE)
		end
		return
	end
	return false
end

function mp:Look()
	std.me():need_scene(true)
	return false
end

function mp:after_Look()
end

function mp:Exam(w)
	return false
end

function mp:after_Exam(w)
	local r, v = std.call(w, 'description')
	if not v then
		r, v = std.call(w, 'dsc')
	end
	if v then
		p(r)
		return false
	end
	if w:has 'container' and (w:has'transparent' or w:has'open') then
		self:content(w)
	elseif w:has 'supporter' then
		self:content(w)
	else
		if w:has'openable' then
			if w:has 'open' then
				local r = std.call(w, 'when_open')
				p (r or mp.msg.Exam.OPENED);
			else
				local r = std.call(w, 'when_closed')
				p (r or mp.msg.Exam.CLOSED);
			end
			return
		end
		if w:has'switchable' then
			local r
			if w:has'on' then
				r = std.call(w, 'when_on')
			else
				r = std.call(w, 'when_off')
			end
			p (mp.msg.Exam.SWITCHSTATE)
			return
		end
		if w == std.here() then
			std.me():need_scene(true)
		else
			p (mp.msg.Exam.DEFAULT);
		end
	end
end

mp.msg.Enter = {}

function mp:Enter(w)
	if mp:check_live(w) then
		return
	end
	if w == std.me():where() then
		p (mp.msg.Enter.ALREADY)
		return
	end

	if seen(w, me()) then
		p (mp.msg.Enter.INV)
		return
	end

--	if std.me():where() ~= std.here() then
--		p (mp.msg.Enter.EXITBEFORE)
--		return
--	end

	if not w:has 'enterable' then
		p (mp.msg.Enter.IMPOSSIBLE)
		return
	end
	if w:has 'container' and not w:has 'open' then
		p (mp.msg.Enter.CLOSED)
		return
	end
	if not move(std.me(), w) then return true end
	return false
end

function mp:after_Enter(w)
	p (mp.msg.Enter.ENTERED)
end

mp.msg.Walk = {}

function mp:Walk(w)
	if w == std.me():where() then
		p (mp.msg.Walk.ALREADY)
		return
	end

	if seen(w, me()) then
		p (mp.msg.Walk.INV)
		return
	end

--	if std.me():where() ~= std.here() then
--		p (mp.msg.Enter.EXITBEFORE)
--		return
--	end
	return false
end

function mp:after_Walk(w)
	p (mp.msg.Walk.WALK)
end

mp.msg.Exit = {}

function mp:before_Exit(w)
	if not w then
		self:xaction('Exit', std.me():where())
		return true
	end
	return false
end

function mp:Exit(w)
	local wh = std.me():where()
	w = w or std.me():where()
	if wh ~= w then
		p (mp.msg.Exit.NOTHERE)
		return
	end
	if wh:has'container' and not wh:has'open' then
		p (mp.msg.Exit.CLOSED)
		return
	end
	if wh:from() == wh then
		p (mp.msg.Exit.NOWHERE)
		return
	end
	local r = std.call(w, 'out_to')
	walkback(r)
	return false
end

function mp:after_Exit(w)
	if w then
		p (mp.msg.Exit.EXITED)
	end
end

mp.msg.Inv = {}
function mp:after_Inv()
	local oo = {}
	self:objects(std.me(), oo, false)
	if #oo == 0 then
		p(mp.msg.Inv.NOTHING)
		return
	end
	p(mp.msg.Inv.INV)
	for _, v in ipairs(oo) do
		pr(v:noun())
		if v:has'worn' then
			mp.msg.WORN(v)
		elseif v:has'openable' and v:has'open' then
			mp.msg.OPEN(v)
		end
		if _ == #oo - 1 then
			pr(" ",mp.msg.AND, " ")
		elseif _ ~= #oo then
			pr(', ')
		end
	end
	pr(".")
end

mp.msg.Open = {}

function mp:Open(w)
	if mp:check_live(w) then
		return
	end
	if not w:has'openable' then
		p(mp.msg.Open.NOTOPENABLE)
		return
	end
	if w:has'open' then
		local r = std.call(w, 'when_open')
		p(r or mp.msg.Open.WHENOPEN)
		return
	end
	if w:has'locked' then
		local r = std.call(w, 'when_locked')
		p(r or mp.msg.Open.WHENLOCKED)
		return
	end
	w:attr'open'
	return false
end

function mp:after_Open(w)
	p(mp.msg.Open.OPEN)
	if w:has'container' then
		self:content(w)
	end
end

mp.msg.Close = {}

function mp:Close(w)
	if not w:has'openable' then
		p(mp.msg.Close.NOTOPENABLE)
		return
	end
	if not w:has'open' then
		local r = std.call(w, 'when_closed')
		p(r or mp.msg.Close.WHENCLOSED)
		return
	end
	w:attr'~open'
	return false
end

function mp:after_Close(w)
	p(mp.msg.Close.CLOSE)
end
function mp:check_live(w)
	if self:animate(w) then
		p(mp.msg.LIVE_ACTION)
		return true
	end
	return false
end

function mp:check_held(t)
	if have(t) or std.me() == t then
		return false
	end
	mp.msg.TAKE_BEFORE(t)
	mp:subaction('Take', t)
	if not have(t) then
--		mp.msg.NOTINV(t)
		return true
	end
	return false
end

function mp:check_worn(w)
	if w:has'worn' then
		mp.msg.DISROBE_BEFORE(w)
		mp:subaction('Disrobe', w)
		if w:has'worn' then
--			p (mp.msg.Drop.WORN)
			return true
		end
	end
	return false
end

mp.msg.Lock = {}
function mp:Lock(w, t)
	if mp:check_held(t) then
		return
	end
	local r = std.call(w, 'with_key')
	if not w:has 'lockable' or not r then
		p(mp.msg.Lock.IMPOSSIBLE)
		return
	end
	if w:has 'locked' then
		p(mp.msg.Lock.LOCKED)
		return
	end
	if w:has 'open' then
		p(mp.msg.Lock.OPEN)
		return
	end
	if std.object(r) ~= t then
		p(mp.msg.Lock.WRONGKEY)
		return
	end
	w:attr'locked'
	return false
end

function mp:after_Lock(w, t)
	p(mp.msg.Lock.LOCK)
end

mp.msg.Unlock = {}
function mp:Unlock(w, t)
	if mp:check_held(t) then
		return
	end
	local r = std.call(w, 'with_key')
	if not w:has 'lockable' or not r then
		p(mp.msg.Unlock.IMPOSSIBLE)
		return
	end
	if not w:has 'locked' then
		p(mp.msg.Unlock.NOTLOCKED)
		return
	end
	if std.object(r) ~= t then
		p(mp.msg.Unlock.WRONGKEY)
		return
	end
	w:attr'~locked'
	w:attr'open'
	return false
end

function mp:after_Unlock(w, t)
	p(mp.msg.Unlock.UNLOCK)
end

function mp:inside(w, wh)
	return mp:trace(w, function(v)
			 if v == wh then return true end
	end)
end
function move(w, wh)
	wh = wh or std.here()
	wh = std.object(wh)
	w = std.object(w)
	local r, v = std.call(wh, 'before_Receive', w)
	if r then p(r) end
	if v == true then
		return false
	end
	if w:type'player' then
		r, v = w:walk(wh)
		if r then p(r) end
	else
		place(w, wh)
		if mp:inside(std.me(), w) then
			r, v = w:walk(wh)
			if r then p(r) end
		end
	end
	w:attr 'moved'
	r, v = std.call(wh, 'after_Receive', w)
	if r then p(r) end
	return true
end

mp.msg.Take = {}
function mp:Take(w, ww)
	if w == std.me() then
		p (mp.msg.Take.SELF)
		return
	end
	if have(w) then
		p (mp.msg.Take.HAVE)
		return
	end
	local n = mp:trace(std.me(), function(v)
		if v == w then return true end
	end)
	if n then
		p (mp.msg.Take.WHERE)
		return
	end
	if mp:animate(w) then
		p (mp.msg.Take.LIFE)
		return
	end
	if w:has'static' then
		p (mp.msg.Take.STATIC)
		return
	end
	if w:has'scenery' then
		p (mp.msg.Take.SCENERY)
		return
	end
	if not w:where():type'room' and
		not w:where():has'container' and
		not w:where():has'supporter' then
		p (mp.msg.Take.PARTOF)
		return
	end
	if not move(w, std.me()) then return true end
	return false
end

function mp:after_Take(w)
	p (mp.msg.Take.TAKE)
end
mp.msg.Remove = {}
function mp:Remove(w, wh)
	if w:where() ~= wh then
		p (mp.msg.Remove.WHERE)
		return
	end
	mp:xaction('Take', w)
end

function mp:after_Remove(w, wh)
	p (mp.msg.Remove.REMOVE)
end

mp.msg.Drop = {}
function mp:Drop(w)
	if mp:check_held(w) then
		return
	end
	if mp:check_worn(w) then
		return
	end
	if w == std.me() then
		p (mp.msg.Drop.SELF)
		return
	end
	if not move(w, std.me():where()) then return true end
	return false
end

function mp:after_Drop(w)
	p (mp.msg.Drop.DROP)
end

mp.msg.Insert = {}

function mp:Insert(w, wh)
	if wh == std.me() then
		mp:xaction('Take', w)
		return
	end
	if w == std.me() then
		mp:xaction('Enter', wh)
		return
	end
	if wh == w:where() then
		p (mp.msg.Insert.ALREADY)
		return
	end
	if wh == std.me():where() or mp.compass_dir(wh, 'd_to') then
		mp:xaction('Drop', w)
		return
	end
	if mp:check_held(w) then
		return
	end
	if mp:check_live(wh) then
		return
	end

	local n = mp:trace(wh, function(v)
		if v == w then return true end
	end)
	if n or w == wh then
		p (mp.msg.Insert.WHERE)
		return
	end

	if not wh:has'container' then
		p(mp.msg.Insert.NOTCONTAINER)
		return
	end
	if not wh:has'open' then
		p(mp.msg.Insert.CLOSED)
		return
	end
	if not move(w, wh) then return true end
	return false
end

function mp:after_Insert(w, wh)
	p(mp.msg.Insert.INSERT)
end

mp.msg.PutOn = {}

function mp:PutOn(w, wh)
	if wh == std.me() then
		mp:xaction('Take', w)
		return
	end
	if w == std.me() then
		mp:xaction('Enter', wh)
		return
	end
	if wh == std.me():where() or mp.compass_dir(wh, 'd_to') then
		mp:xaction('Drop', w)
		return
	end
	if mp:check_held(w) then
		return
	end
	if mp:check_live(wh) then
		return
	end
	if mp:check_worn(w) then
		return
	end
	local n = mp:trace(wh, function(v)
		if v == w then return true end
	end)
	if n or w == wh then
		p (mp.msg.PutOn.WHERE)
		return
	end
	if not wh:has'supporter' then
		p(mp.msg.PutOn.NOTSUPPORTER)
		return
	end
	if not move(w, wh) then return true end
	return false
end

function mp:after_PutOn(w, wh)
	p(mp.msg.PutOn.PUTON)
end

mp.msg.ThrowAt = {}

function mp:ThrowAt(w, wh)
	if mp:check_held(w) then
		return
	end
	if mp:check_worn(w) then
		return
	end
	if not self:animate(wh) then
		if wh:has'container' then
			mp:xaction("Insert", w, wh)
			return
		end
		p(mp.msg.ThrowAt.NOTLIFE)
		return
	end
	if mp:runmethods('life', 'ThrowAt', wh, w) then
		return false
	end
	p(mp.msg.ThrowAt.THROW)
end

mp.msg.Wear = {}

function mp:Wear(w)
	if mp:check_held(w) then
		return
	end
	if not w:has'clothes' then
		p (mp.msg.Wear.NOTCLOTHES)
		return
	end
	if w:has'worn' then
		p (mp.msg.Wear.WORN)
		return
	end
	w:attr'worn'
	return false
end

function mp:after_Wear(w)
	p (mp.msg.Wear.WEAR)
end

mp.msg.Disrobe = {}

function mp:Disrobe(w)
	if not w:has'worn' then
		p (mp.msg.Disrobe.NOTWORN)
		return
	end
	w:attr'~worn'
	return false
end

function mp:after_Disrobe(w)
	p (mp.msg.Disrobe.DISROBE)
end

mp.msg.SwitchOn = {}

function mp:SwitchOn(w)
	if not w:has'switchable' then
		p (mp.msg.SwitchOn.NONSWITCHABLE)
		return
	end
	if w:has'on' then
		p (mp.msg.SwitchOn.ALREADY)
		return
	end
	w:attr'on'
	return false
end

function mp:after_SwitchOn(w)
	p (mp.msg.SwitchOn.SWITCHON)
end

mp.msg.SwitchOff = {}

function mp:SwitchOff(w)
	if not w:has'switchable' then
		p (mp.msg.SwitchOff.NONSWITCHABLE)
		return
	end
	if not w:has'on' then
		p (mp.msg.SwitchOn.ALREADY)
		return
	end
	w:attr'~on'
	return false
end

function mp:after_SwitchOff(w)
	p (mp.msg.SwitchOff.SWITCHOFF)
end

mp.msg.Search = {}

function mp:Search(w)
	mp:xaction('Exam', w)
end

mp.msg.LookUnder = {}
function mp:LookUnder(w)
	p (mp.msg.LookUnder.NOTHING)
end

mp.msg.Eat = {}

function mp:Eat(w)
	if not w:has'edible' then
		p (mp.msg.Eat.NOTEDIBLE)
		return
	end
	if mp:check_held(w) then
		return
	end
	if mp:check_worn(w) then
		return
	end
	remove(w)
	return false
end

function mp:after_Eat(w)
	p (mp.msg.Eat.EAT)
end

mp.msg.Drink = {}

function mp:after_Drink(w)
	p (mp.msg.Drink.IMPOSSIBLE)
end

mp.msg.Transfer = {}

function mp:Transfer(w, ww)
	if mp.compass_dir(ww) then
		mp:xaction('PushDir', w, ww)
		return
	end
	if ww:has 'supporter' then
		mp:xaction('PutOn', w, ww)
		return
	end
	mp:xaction('Insert', w, ww)
end

mp.msg.Push = {}

function mp:Push(w)
	if w:has 'switchable' then
		if w:has'on' then
			mp:xaction('SwitchOff', w)
		else
			mp:xaction('SwitchOn', w)
		end
		return
	end
	if w:has 'static' then
		p (mp.msg.Push.STATIC)
		return
	end
	if w:has 'scenery' then
		p (mp.msg.Push.SCENERY)
		return
	end
	if mp:check_live(w) then
		return
	end
	p (mp.msg.Push.PUSH)
end

mp.msg.Pull = {}

function mp:Pull(w)
	if w:has 'static' then
		p (mp.msg.Pull.STATIC)
		return
	end
	if w:has 'scenery' then
		p (mp.msg.Pull.SCENERY)
		return
	end
	if mp:check_live(w) then
		return
	end
	p (mp.msg.Pull.PULL)
end

mp.msg.Turn = {}

function mp:Turn(w)
	if w:has 'static' then
		p (mp.msg.Turn.STATIC)
		return
	end
	if w:has 'scenery' then
		p (mp.msg.Turn.SCENERY)
		return
	end
	if mp:check_live(w) then
		return
	end
	p (mp.msg.Turn.TURN)
end

mp.msg.Wait = {}
function mp:after_Wait()
	p (mp.msg.Wait.WAIT)
end

mp.msg.Rub = {}

function mp:Rub(w)
	p (mp.msg.Rub.RUB)
end

mp.msg.Sing = {}

function mp:Sing(w)
	p (mp.msg.Sing.SING)
end

mp.msg.Touch = {}

function mp:Touch(w)
	if w == std.me() then
		p (mp.msg.Touch.MYSELF)
		return
	end
	if self:animate(w) then
		p (mp.msg.Touch.LIVE)
		return
	end
	p (mp.msg.Touch.TOUCH)
end

mp.msg.Give = {}

function mp:Give(w, wh)
	if mp:check_held(w) then
		return
	end
	if wh == std.me() then
		p (mp.msg.Give.MYSELF)
		return
	end
	if mp:runmethods('life', 'Give', wh, w) then
		return false
	end
	p (mp.msg.Give.GIVE)
end

mp.msg.Show = {}

function mp:Show(w, wh)
	if mp:check_held(w) then
		return
	end
	if wh == std.me() then
		mp:xaction("Exam", w)
		return
	end
	if mp:runmethods('life', 'Show', wh, w) then
		return false
	end
	p (mp.msg.Show.SHOW)
end

mp.msg.Burn = {}

function mp:Burn(w, wh)
	if wh and mp:check_held(wh) then
		return
	end
	if wh then
		p (mp.msg.Burn.BURN2)
	else
		p (mp.msg.Burn.BURN)
	end
end

mp.msg.Wake = {}

function mp:Wake()
	p (mp.msg.Wake.WAKE)
end

mp.msg.WakeOther = {}

function mp:WakeOther(w)
	if w == std.me() then
		mp:xaction('Wake')
		return
	end
	if not mp:animate(w) then
		p (mp.msg.WakeOther.NOTLIVE)
		return
	end
	if mp:runmethods('life', 'WakeOther', w) then
		return false
	end
	p (mp.msg.WakeOther.WAKE)
end

mp.msg.PushDir = {}
function mp:PushDir(w, wh)
	if mp:check_live(w) then
		return
	end
	p (mp.msg.PushDir.PUSH)
end

mp.msg.Kiss = {}
function mp:Kiss(w)
	if not mp:animate(w) then
		p (mp.msg.Kiss.NOTLIVE)
		return
	end
	if mp:runmethods('life', 'Kiss', w) then
		return false
	end
	if w == std.me() then
		p (mp.msg.Kiss.MYSELF)
		return
	end
	p (mp.msg.Kiss.KISS)
end

mp.msg.Think = {}
function mp:Think()
	p (mp.msg.Think.THINK)
end

mp.msg.Smell = {}
function mp:Smell(w)
	if w then
		p (mp.msg.Smell.SMELL2)
		return
	end
	p (mp.msg.Smell.SMELL)
end

mp.msg.Listen = {}
function mp:Listen(w)
	if w then
		p (mp.msg.Listen.LISTEN2)
		return
	end
	p (mp.msg.Listen.LISTEN)
end

mp.msg.Dig = {}
function mp:Dig(w, wh)
	if w and mp:check_live(w) then
		return
	end
	if wh then
		if mp:check_held(wh) then
			return
		end
		p (mp.msg.Dig.DIG3)
		return
	end
	if w then
		p (mp.msg.Dig.DIG2)
		return
	end
	p (mp.msg.Dig.DIG)
end

mp.msg.Cut = {}
function mp:Cut(w, wh)
	if mp:check_live(w) then
		return
	end
	if wh then
		if mp:check_live(wh) then
			return
		end
		if mp:check_held(wh) then
			return
		end
		p (mp.msg.Cut.CUT2)
		return
	end
	if w then
		p (mp.msg.Cut.CUT)
		return
	end
end

mp.msg.Tie = {}

function mp:Tie(w, wh)
	if mp:check_live(w) then
		return
	end
	if wh and mp:check_live(wh) then
		return
	end
	if wh then
		p (mp.msg.Tie.TIE2)
		return
	end
	p (mp.msg.Tie.TIE)
end

mp.msg.Blow = {}

function mp:Blow(w)
	if mp:check_live(w) then
		return
	end
	p (mp.msg.Blow.BLOW)
end

mp.msg.Attack = {}

function mp:Attack(w)
	if mp:animate(w) and mp:runmethods('life', 'Attack', w) then
		return false
	end
	if mp:animate(w) then
		p (mp.msg.Attack.LIFE)
		return
	end
	p (mp.msg.Attack.ATTACK)
end

mp.msg.Sleep = {}

function mp:Sleep()
	p (mp.msg.Sleep.SLEEP)
end

mp.msg.Swim = {}

function mp:Swim()
	p (mp.msg.Swim.SWIM)
end

mp.msg.Consult = {}

function mp:Consult(w, a)
	p (mp.msg.Consult.CONSULT)
end

mp.msg.Fill = {}
function mp:Fill(w)
	p (mp.msg.Fill.FILL)
end

mp.msg.Jump = {}
function mp:Jump()
	p (mp.msg.Jump.JUMP)
end

mp.msg.JumpOver = {}
function mp:JumpOver(w)
	p (mp.msg.JumpOver.JUMPOVER)
end

mp.msg.WaveHands = {}
function mp:WaveHands()
	p (mp.msg.WaveHands.WAVE)
end

mp.msg.Wave = {}
function mp:Wave(w)
	if mp:check_held(w) then
		return
	end
	p (mp.msg.Wave.WAVE)
end

function mp:Climb(w)
	mp:xaction('Enter', w)
end

function mp:GetOff(w)
	mp:xaction('Exit', w)
end

mp.msg.Buy = {}
function mp:Buy(w)
	p (mp.msg.Buy.BUY)
end

mp.msg.Talk = {}
function mp:Talk(w)
	local r = std.call(w, 'talk_to')
	if r then
		walkin(r)
		return
	end
	if w == std.me() then
		p (mp.msg.Talk.SELF)
		return
	end
	if not mp:animate(w) then
		p (mp.msg.Talk.NOTLIVE)
		return
	end
	p (mp.msg.Talk.LIVE)
end
