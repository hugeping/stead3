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

-- dialogs
std.phr.word = function(s)
	return tostring(s.__ph_idx) or std.dispof(s)
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
