loadmod "mp"
loadmod "mplib"

local lang = require "morph/lang-ru"
local mp = _'@metaparser'
local utf = mp.utf

_'@compass'.word = function()
	local dir = -"север,с|восток,в|запад,з|юг,ю"
	local up = -"наверх,вверх,верх|вниз,низ"
	local inp, pre = mp:compl_ctx()
	if pre == '' then
		return dir .. '|'.. up
	end
	if pre == "на " then
		return dir
	end
	return up
end
_'@darkness'.word = -"тьма,темнота,темень"
_'@darkness'.before_Any = "Полная, кромешная тьма."
_'@darkness':attr 'persist'

_'@compass'.dirs = { 'n_to', 'e_to', 'w_to', 's_to', 'u_to', 'd_to' };
_'@compass'.before_Default = 'Попробуйте глагол "идти".'

mp.door.word = -"дверь";
mp.msg.WHEN_DARK = "Кромешная тьма."
mp.msg.UNKNOWN_THEDARK = "Возможно, это потому что в темноте ничего не видно?"
mp.msg.COMPASS_NOWAY = "Этот путь недоступен."
mp.msg.COMPASS_EXAM_NO = "В этом направлении не видно ничего примечательного."
mp.msg.TAKE_BEFORE = function(w)
	pn (iface:em("(сначала взяв "..w:noun'вн'..")"))
end
mp.msg.DISROBE_BEFORE = function(w)
	pn (iface:em("(сначала сняв "..w:noun'вн'..")"))
end

--"находиться"
mp.msg.SCENE = "{#Me} {#word/находиться,#me,нст} {#if_has/here,supporter,на,в} {#here/пр,2}.";
mp.msg.INSIDE_SCENE = "{#Me} {#word/находиться,#me,нст} {#if_has/where,supporter,на,в} {#where/пр,2}.";

mp.msg.COMPASS_EXAM = function(dir, ob)
	if dir == 'u_to' then
		p "Вверху"
	elseif dir == 'd_to' then
		p "Внизу"
	else
		p "На {#first/пр,2}"
	end
	if ob:hint'plural' then
		p "находятся"
	else
		p "находится"
	end
	p (ob:noun(),".")
end

mp.msg.enter = "<ввод>"
mp.mrd.lang = lang
mp.msg.EMPTY = 'Простите?'
mp.msg.UNKNOWN_VERB = "Непонятный глагол"
mp.msg.UNKNOWN_VERB_HINT = "Возможно, вы имели в виду"
mp.msg.INCOMPLETE = "Нужно дополнить предложение."
mp.msg.UNKNOWN_OBJ = "Такого предмета тут нет"
mp.msg.UNKNOWN_WORD = "Слово не распознано:"
mp.msg.HINT_WORDS = "Возможно, вы имели в виду"
mp.msg.HINT_OR = "или"
mp.msg.HINT_AND = "и"
mp.msg.AND = "и"
mp.msg.MULTIPLE = "Тут есть"
mp.msg.LIVE_ACTION = "{#Firstit/дт} это не понравится."
mp.msg.NOTINV = function(t)
	p (lang.cap(t:noun'вн') .. " сначала нужно взять.")
end
--"надет"
mp.msg.WORN = function(w)
	local hint = w:gram().hint
	pr (" (",mp.mrd:word('надет/' .. hint), ")")
end
--"открыт"
mp.msg.OPEN = function(w)
	local hint = w:gram().hint
	pr (" (",mp.mrd:word('открыт/' .. hint), ")")
end
mp.msg.EXITBEFORE = "Возможно, {#me/дт} нужно сначала {#if_has/where,supporter,слезть,вылезти из} {#where/рд}."

mp.default_Event = "Exam"
mp.default_Verb = "осмотреть"

--"доступен"
mp.msg.ACCESS1 = "{#First} отсюда не{#word/доступен,#first}."
mp.msg.ACCESS2 = "{#Second} отсюда не{#word/доступен,#second}."

mp.msg.Look.HEREIS = "Здесь есть"
mp.msg.Look.HEREARE = "Здесь есть"
--"включён"
--"выключен"
mp.msg.Exam.SWITCHSTATE = "{#First} сейчас {#if_has/first,on,{#word/включён,#first},{#word/выключен,#first}}."
mp.msg.Exam.NOTHING = "ничего нет."
mp.msg.Exam.IS = "находится"
mp.msg.Exam.ARE = "находятся"
mp.msg.Exam.IN = "В {#first/пр,2}"
mp.msg.Exam.ON = "На {#first/пр,2}"
--"видеть"
mp.msg.Exam.DEFAULT = "{#Me} не {#word/видеть,#me,нст} {#vo/{#first/пр}} ничего необычного.";

--"открыт"
mp.msg.Exam.OPENED = "{#First} {#word/открыт,нст,#first}."
--"закрыт"
mp.msg.Exam.CLOSED = "{#First} {#word/закрыт,нст,#first}."
--"находить"
mp.msg.LookUnder.NOTHING = "{#Me} не {#word/находить,нст,#me} под {#first/тв} ничего интересного."
--"могу"
--"закрыт"
--"держать"
--"залезать"
mp.msg.Enter.ALREADY = "{#Me} уже {#if_has/first,supporter,на,в} {#first/пр,2}."
mp.msg.Enter.INV = "{#Me} не {#word/могу,#me,нст} зайти в то, что {#word/держать,#me,нст} в руках."
mp.msg.Enter.IMPOSSIBLE = "Но в/на {#first/вн} невозможно войти, встать, сесть или лечь."
mp.msg.Enter.CLOSED = "{#First} {#word/закрыт,#first}, и {#me} не {#word/мочь,#me,нст} зайти туда."
mp.msg.Enter.ENTERED = "{#Me} {#word/залезать,нст,#me} {#if_has/first,supporter,на,в} {#first/вн}."
mp.msg.Enter.DOOR_NOWHERE = "{#First} никуда не ведёт."
--"закрыт"
mp.msg.Enter.DOOR_CLOSED = "{#First} {#word/закрыт,#first}."

mp.msg.Walk.ALREADY = mp.msg.Enter.ALREADY
mp.msg.Walk.WALK = "Но {#first} и так находится здесь."

mp.msg.Enter.EXITBEFORE = "Сначала нужно {#if_has/where,supporter,слезть с,покинуть} {#where/вн}."

mp.msg.Exit.NOTHERE = "Но {#me} сейчас не {#if_has/first,supporter,на,в} {#first/пр,2}."
mp.msg.Exit.NOWHERE = "Но {#me/дт} некуда выходить."
mp.msg.Exit.CLOSED = "Но {#first} {#word/закрыт,#first}."


--"покидать"
--"слезть"
mp.msg.Exit.EXITED = "{#Me} {#if_has/first,supporter,{#word/слезть с,#me,нст} {#first/рд},{#word/покидать,#me,нст} {#first/вн}}."

mp.msg.Inv.NOTHING = "У {#me/рд} с собой ничего нет."
mp.msg.Inv.INV = "У {#me/рд} с собой"

--"открывать"
mp.msg.Open.OPEN = "{#Me} {#word/открывать,нст,#me} {#first/вн}."
mp.msg.Open.NOTOPENABLE = "{#First/вн} невозможно открыть."
--"открыт"
mp.msg.Open.WHENOPEN = "{#First/вн} уже {#word/открыт,#first}."
--"заперт"
mp.msg.Open.WHENLOCKED = "Похоже, что {#first/} {#word/заперт,#first}."

--"закрывать"
mp.msg.Close.CLOSE = "{#Me} {#word/закрывать,нст,#me} {#first/вн}."
mp.msg.Close.NOTOPENABLE = "{#First/вн} невозможно закрыть."
--"закрыт"
mp.msg.Close.WHENCLOSED = "{#First/вн} уже {#word/закрыт,#first}."

mp.msg.Lock.IMPOSSIBLE = "{#First/вн} невозможно запереть."
--"заперт"
mp.msg.Lock.LOCKED = "{#First} уже {#word/заперт,#first}."
--"закрыть"
mp.msg.Lock.OPEN = "Сначала необходимо закрыть {#first/вн}."
--"подходит"
mp.msg.Lock.WRONGKEY = "{#Second} не {#word/подходит,#second} к замку."
--"запирать"
mp.msg.Lock.LOCK = "{#Me} {#word/запирать,#me,нст} {#first/вн}."

mp.msg.Unlock.IMPOSSIBLE = "{#First/вн} невозможно отпереть."
--"заперт"
mp.msg.Unlock.NOTLOCKED = "{#First} не {#word/заперт,#first}."
--"подходит"
mp.msg.Unlock.WRONGKEY = "{#Second} не {#word/подходит,нст,#second} к замку."
--"отпирать"
mp.msg.Unlock.UNLOCK = "{#Me} {#word/отпирать,#me,нст} {#first/вн}."

mp.msg.Take.HAVE = "У {#me/вн} и так {#firstit} уже есть."
mp.msg.Take.TAKE = "{#Me} {#verb/take} {#first/вн}."
mp.msg.Take.SELF = "{#Me} есть у {#me/рд}."
--"находиться"
mp.msg.Take.WHERE = "Нельзя взять то, в/на чём {#me} {#word/находиться,#me}."

mp.msg.Take.LIFE = "{#First/дт} это вряд ли понравится."
--"закреплён"
mp.msg.Take.STATIC = "{#First} жестко {#word/закреплён,#first}."
mp.msg.Take.SCENERY = "{#First/вн} невозможно взять."
mp.msg.Take.PARTOF = "{#First} является частью {#firstwhere/рд}."

mp.msg.Remove.WHERE = "{#First} не находится {#if_has/second,supporter,на,в} {#second/пр,2}."
mp.msg.Remove.REMOVE = "{#First} {#if_has/second,supporter,поднят,извлечён из} {#second/рд}."

mp.msg.Drop.SELF = "У {#me/рд} не хватит ловкости."
mp.msg.Drop.WORN = "{#First/вн} сначала нужно снять."
--"помещать"
mp.msg.Insert.INSERT = "{#Me} {#word/помещать,нст,#me} {#first/вн} в {#second/вн}."
mp.msg.Insert.CLOSED = "{#Second} {#word/закрыт,#second}."
mp.msg.Insert.NOTCONTAINER = "{#Second} не {#if_hint/second,plural,могут,может} что-либо содержать."
mp.msg.Insert.WHERE = "Нельзя поместить {#first/вн} внутрь себя."
mp.msg.Insert.ALREADY = "Но {#first} уже и так {#word/находиться,#first} там."
mp.msg.PutOn.NOTSUPPORTER = "Класть что-либо на {#second} бессмыслено."
--"класть"
mp.msg.PutOn.PUTON = "{#Me} {#word/класть,нст,#me} {#first/вн} на {#second/вн}."
mp.msg.PutOn.WHERE = "Нельзя поместить {#first/вн} на себя."

--"брошен"
mp.msg.Drop.DROP = "{#First} {#word/брошен,#first}."

mp.msg.ThrowAt.NOTLIFE = "Бросать {#first/вн} в {#second/вн} бесполезно."
mp.msg.ThrowAt.THROW = "У {#me/рд} не хватает решимости бросить {#first/вн} в {#second/вн}."


mp.msg.Wear.NOTCLOTHES = "Надеть {#first/вн} невозможно."
mp.msg.Wear.WORN = "{#First} уже на {#me/дт}."
--"надевать"
mp.msg.Wear.WEAR = "{#Me} {#word/надевать,#me,нст} {#first/вн}."

mp.msg.Disrobe.NOTWORN = "{#First} не на {#me/дт}."
--"снимать"
mp.msg.Disrobe.DISROBE = "{#Me} {#word/снимать,#me,нст} {#first/вн}."

mp.msg.SwitchOn.NONSWITCHABLE = "{#First/вн} невозможно включить."
--"включён"
mp.msg.SwitchOn.ALREADY = "{#First} уже {#word/включён,#first}."
--"включать"
mp.msg.SwitchOn.SWITCHON = "{#Me} {#word/включать,#me,нст} {#first/вн}."

mp.msg.SwitchOff.NONSWITCHABLE = "{#First/вн} невозможно выключить."
--"выключён"
mp.msg.SwitchOff.ALREADY = "{#First} уже {#word/выключён,#first}."
--"выключать"
mp.msg.SwitchOff.SWITCHOFF = "{#Me} {#word/выключать,#me,нст} {#first/вн}."

--"годится"
mp.msg.Eat.NOTEDIBLE = "{#First} не {#word/годится,#first} в пищу."
--"съедать"
mp.msg.Eat.EAT = "{#Me} {#word/съедать,нст,#me} {#first/вн}."
mp.msg.Drink.IMPOSSIBLE = "Выпить {#first/вн} невозможно."

mp.msg.Push.STATIC = "{#First/вн} трудно сдвинуть с места."
mp.msg.Push.SCENERY = "{#First/вн} двигать невозможно."
mp.msg.Push.PUSH = "Ничего не произошло."

mp.msg.Pull.STATIC = "{#First/вн} трудно сдвинуть с места."
mp.msg.Pull.SCENERY = "{#First/вн} двигать невозможно."
mp.msg.Pull.PUSH = "Ничего не произошло."

mp.msg.Turn.STATIC = "{#First/вн} трудно сдвинуть с места."
mp.msg.Turn.SCENERY = "{#First/вн} двигать невозможно."
mp.msg.Turn.PUSH = "Ничего не произошло."

mp.msg.Wait.WAIT = "Проходит немного времени."

mp.msg.Touch.LIVE = "Не стоит давать волю рукам."
mp.msg.Touch.TOUCH = "Никаких необычных ощущений нет."
mp.msg.Touch.MYSELF = "{#Me} на месте."

mp.msg.Rub.RUB = "Тереть {#first/вн} бессмысленно."
mp.msg.Sing.SING = "С таким слухом и голосом как у {#me/рд} этого лучше не делать."

mp.msg.Give.MYSELF = "{#First} и так у {#me/рд} есть."
mp.msg.Give.GIVE = "{#Second/вн} это не заинтересовало."
mp.msg.Show.SHOW = "{#Second/вн} это не впечатлило."

mp.msg.Burn.BURN = "Поджигать {#first/вн} бессмысленно."
mp.msg.Burn.BURN2 = "Поджигать {#first/вн} {#second/тв} бессмысленно."
--"поверь"
mp.msg.Wake.WAKE = "Это не сон, а явь."
mp.msg.WakeOther.WAKE = "Будить {#first/вн} не стоит."
mp.msg.WakeOther.NOTLIVE = "Бессмысленно будить {#first/вн}."

mp.msg.PushDir.PUSH = "Передвигать это нет смысла."

mp.hint.live = 'од'
mp.hint.neuter = 'ср'
mp.hint.male = 'мр'
mp.hint.female = 'жр'
mp.hint.plural = 'мн'
mp.hint.first = '1л'
mp.hint.second = '2л'
mp.hint.third = '3л'

mp.keyboard_space = '<пробел>'
mp.keyboard_backspace = '<удалить>'

mp.msg.verbs.take = -"брать,#me,нст"

local function dict(t, hint)
	local g = std.split(hint, ",")
	for _, v in ipairs(g) do
		if t[v] then
			return t[v]
		end
	end
end

function mp:myself(w, hint)
	local ww = dict({
			["вн"] = "себя";
			["дт"] = "себе";
			["тв"] = "собой";
			["пр"] = "себе";
			["рд"] = "себя";
		 }, hint)
	return { ww }
end

function mp:it(w, hint)
	hint = hint or ''
	if w:hint'plural' then
		return mp.mrd:noun(-"они/"..hint)
	elseif w:hint'neuter' then
		return mp.mrd:noun(-"оно/"..hint)
	elseif w:hint'female' then
		return mp.mrd:noun(-"она/"..hint)
	end
	return mp.mrd:noun(-"он/"..hint)
end

function mp:synonyms(w, hint)
	local t = self:it(w, hint)
	local w = { t }
	if t == 'его' or t == 'её' or t == 'ее' then t = 'н'..t; w[2] = t end
	return w
end

mp.keyboard = {
	'А','Б','В','Г','Д','Е','Ё','Ж','З','И','Й',
	'К','Л','М','Н','О','П','Р','О','С','Т','У','Ф',
	'Х','Ц','Ч','Ш','Щ','Ь','Ы','Ъ','Э','Ю','Я'
}

local function hints(w)
	local h = std.split(w, ",")
	local hints = {}
	for _, v in ipairs(h) do
		hints[v] = true
	end
	return hints
end

function mp:err_noun(noun)
	local hint = std.split(noun, "/")
	p "существительное в"
	if #hint == 2 then
		local h = hints(hint[2])
		local acc = 'именительном'
		if h["им"] then
			acc = 'именительном'
		elseif h["рд"] then
			acc = 'родительном'
		elseif h["дт"] then
			acc = 'дательном'
		elseif h["вн"] then
			acc = 'винительном'
		elseif h["тв"] then
			acc = 'творительном'
		elseif h["пр"] or h["пр2"] then
			acc = 'предложном'
		end
		pr (acc, " падеже")
	else
		pr "именительном падеже"
	end
end

function mp.shortcut.vo(hint)
	return "в ".. hint
--	local w = std.split(hint)
--	w = w[#w]
--	if mp.utf.len(w) > 2 and
--		(lang.is_vowel(utf.char(w, 1)) or
--		lang.is_vowel(utf.char(w, 2))) then
--		return "в ".. hint
--	end
--	return "во ".. hint
end

function mp.shortcut.so(hint)
	return "с ".. hint
--	local w = std.split(hint)
--	w = w[#w]
--	if mp.utf.len(w) > 2 and
--		(lang.is_vowel(utf.char(w, 1)) or
--		lang.is_vowel(utf.char(w, 2))) then
--		return "с ".. hint
--	end
--	return "со ".. hint
end


Verb { "#Enter",
	"идти,иду,подой/ти,иди,войти,войд/и,зайти,зайд/и,залез/ть,бежать,бег/и,влез/ть,ехать,поехать,едь,поеду,сесть,сядь,сяду,лечь,ляг,лез/ть,влез/ть",
	"на|в {noun}/вн,scene,enterable : Enter",
	"к {noun}/дт,scene : Walk",
	"{noun_obj}/@compass : Walk" }

Verb { "#Exit",
	"выйти,выйд/и,уйти,уйд/и,вылез/ти,выхо/ди,обратно,назад,выбраться,выберись,выберусь,выбираться,слез/ть",
	"из|с|со {noun}/рд,scene : Exit",
	"Exit" }

Verb { "#Examine",
       "осм/отреть,смотр/еть,рассмотр/еть,посмотр/еть,гляд/еть,разгляд/еть,погляд/еть",
       "?на {noun}/вн : Exam",
       "?всё : Look",
       "~ под {noun}/тв : LookUnder",
       "~ под {noun}/вн : LookUnder",
       "~ в|во|на {noun}/пр,2 : Search",
}

Verb { "#Search",
       "иск/ать,обыскать,ищ/и,обыщ/и,изуч/ать,исслед/овать",
       "{noun}/вн : Search",
       "в|во|на {noun}/пр,2 : Search",
       "под {noun}/тв : LookUnder",
}

Verb { "#Open",
	"откр/ыть,распах/нуть,раскр/ыть,отпереть,отопр/и",
	"{noun}/вн : Open",
	"{noun}/вн {noun}/тв : Unlock",
	"~ {noun}/тв {noun}/вн : Unlock reverse",
}

Verb { "#Close",
	"закр/ыть,запереть",
	"{noun}/вн : Close",
	"{noun}/вн {noun}/тв : Lock",
	"~ {noun}/тв {noun}/вн : Lock reverse",
}

Verb { "#Inv",
       "инв/ентарь,с собой",
       "Inv" }

Verb { "#Take",
       "вз/ять,возьм/и,брать,забрать,забер/и,бери/,доста/ть,схват/ить,укра/сть,извле/чь,вын/уть,вытащ/ить",
       "{noun}/вн,scene : Take",
       "{noun}/вн из|с|со|у {noun}/рд,inside: Remove",
       "~ из|с|со|у {noun}/рд,container {noun}/вн: Remove reverse",
}

Verb { "#Drop",
       "полож/ить,класть,клади/,вставь/,помест/ить,сун/уть,засун/уть,воткн/уть,втык/ать,встав/ить,влож/ить",
       "{noun}/вн,held : Drop",
       "{noun}/вн,held в|во {noun}/вн,inside : Insert",
       "~ {noun}/вн внутрь {noun}/рд : Insert",
       "~ {noun}/вн на {noun}/вн : PutOn",
       "~ в|во {noun}/вн {noun}/вн : Insert reverse",
       "~ внутрь {noun}/рд {noun}/вн : Insert reverse",
       "~ на {noun}/вн {noun}/вн : PutOn reverse",
}

Verb {
	"#Throw",
	"брос/ить,выбро/сить,кин/уть,кида/ть,швыр/нуть,метн/уть,метать",
	"{noun}/вн,held : Drop",
	"{noun}/вн,held в|во|на {noun}/вн : ThrowAt",
	"~ в|во|на {noun}/вн {noun}/вн : ThrowAt reverse",
	"~ {noun}/вн {noun}/дт : ThrowAt",
	"~ {noun}/дт {noun}/вн : ThrowAt reverse",

}

Verb {
	"#Wear",
	"наде/ть,оде/ть,облачи/ться",
	"{noun}/вн,held : Wear",
}

Verb {
	"#Disrobe",
	"снять,сним/ать",
	"{noun}/вн,worn : Disrobe",
}

Verb {
	"#SwitchOn",
	"включ/ить,вруб/ить,активи/ровать",
	"{noun}/вн : SwitchOn",
}

Verb {
	"#SwitchOff",
	"выключ/ить,выруб/ить,деактиви/ровать",
	"{noun}/вн : SwitchOff",
}

Verb {
	"#Eat",
	"есть,съе/сть,куша/ть,скуша/ть,сожр/ать,жри,жрать,ешь",
	"{noun}/вн,held : Eat",
}

Verb {
	"#Drink",
	"пить,выпить,выпей,выпью,пью",
	"{noun}/вн,held : Drink",
}

Verb {
	"#Push",
	"толк/ать,пих/ать,нажим/ать,нажм/и,нажать,двига/ть,задви/нуть,запих/нуть,затолк/ать",
	"?на {noun}/вн : Push",
	"{noun}/вн на|в|во {noun}/вн : Transfer",
	"{noun}/вн {noun_obj}/@compass : Transfer",
	"~ на|в|во {noun}/вн {noun}/вн : Transfer reverse",
	"~ {noun_obj}/@compass {noun}/вн : Transfer reverse"
}

Verb {
	"#Pull",
	"тян/уть,тащ/ить,тягать,волоч/ь,волок/ти,дёрн/уть,дёрг/ать,потян/уть,потащ/ить,поволо/чь",
	"?за {noun}/вн : Pull",
	"{noun}/вн на|в|во {noun}/вн : Transfer",
	"{noun}/вн {noun_obj}/@compass : Transfer",
	"~ на|в|во {noun}/вн {noun}/вн : Transfer reverse",
	"~ {noun_obj}/@compass {noun}/вн : Transfer reverse"
}

Verb {
	"#Turn",
	"враща/ть,поверн/уть,верт/есть,поверт/еть",
	"{noun}/вн : Turn"
}

Verb {
	"#Wait",
	"ждать,жди,жду,подожд/ать,ожид/ать",
	"Wait"
}

Verb {
	"#Rub",
	"тереть,потр/и,потереть,тру,три",
	"{noun}/вн : Rub"
}

Verb {
	"#Sing",
	"петь,спеть,спою,спой/,пой",
	"Sing"
}

Verb {
	"#Touch",
	"трога/ть,потрог/ать,трон/уть,косну/ться,касать/ся,прикосн/уться,щупа/ть,пощупа/ть",
	"{noun}/вн : Touch",
	"~ до {noun}/рд : Touch",
	"~ к {noun}/дт : Touch",
	"~ {noun}/рд : Touch",
}

Verb {
	"#Give",
	"дать,отда/ть,предло/жить,предла/гать,дам,даю,дадим",
	"{noun}/вн,held {noun}/дт,live : Give",
	"~ {noun}/дт,live {noun}/вн,held : Give reverse",
}

Verb {
	"#Show",
	"показ/ать,покаж/и",
	"{noun}/вн,held {noun}/дт,live : Show",
	"~ {noun}/дт,live {noun}/вн,held : Show reverse",
}

Verb {
	"#Burn",
	"жечь,жг/и,поджечь,подожги/,поджиг/ай,зажг/и,зажиг/ай,зажечь",
	"{noun}/вн : Burn",
	"{noun}/вн {noun}/тв,held : Burn",
	"~ {noun}/тв,held {noun}/вн reverse",
}

Verb {
	"#Wake",
	"будить,разбуд/ить,просн/уться,бужу",
	"{noun}/вн,live : WakeOther",
	"Wake",
}
-- Dialog
std.phr.default_Event = "Exam"

Verb ({"~ сказать", "{select} : Exam" }, std.dlg)

parser = mp
