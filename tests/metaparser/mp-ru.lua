loadmod "mp"
loadmod "mplib"

local lang = require "morph/lang-ru"
local mp = _'@metaparser'
local utf = mp.utf

_'@compass'.word = -"север,с|восток,в|запад,з|юг,ю|наверх,вверх,верх|вниз,низ";
_'@compass'.dirs = { 'n_to', 'e_to', 'w_to', 's_to', 'u_to', 'd_to' };
_'@compass'.before_Default = 'Попробуйте глагол "идти".'
mp.msg.COMPASS_NOWAY = "Этот путь недоступен."
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
mp.msg.MULTIPLE = "Тут есть"
mp.default_Event = "Exam"
mp.default_Verb = "осмотреть"

--"доступен"
mp.msg.ACCESS1 = "{#First} отсюда не{#word/доступен,#first}."
mp.msg.ACCESS2 = "{#Second} отсюда не{#word/доступен,#second}."

mp.msg.Look.HEREIS = "Здесь есть"
mp.msg.Look.HEREARE = "Здесь есть"

mp.msg.Exam.NOTHING = "ничего нет."
mp.msg.Exam.IS = "находится"
mp.msg.Exam.ARE = "находятся"
mp.msg.Exam.IN = "В {#first/пр,2}"
mp.msg.Exam.ON = "На {#first/пр,2}"
--"увидеть"
mp.msg.Exam.DEFAULT = "{#Me} не {#word/увидеть,#me,прш} {#vo/{#first/пр}} ничего необычного.";

--"открыт"
mp.msg.Exam.OPENED = "{#First} {#word/открыт,нст,кр,#first}."
--"закрыт"
mp.msg.Exam.CLOSED = "{#First} {#word/закрыт,нст,кр,#first}."

--"мочь"
--"закрыт"
--"держать"
--"залезть"
mp.msg.Enter.ALREADY = "{#Me} уже {#if_has/first,supporter,на,в} {#first/пр,2}."
mp.msg.Enter.INV = "{#Me} не {#word/мочь,#me,нст} зайти в то, что {#word/держать,#me,нст} в руках."
mp.msg.Enter.IMPOSSIBLE = "Но в/на {#first/вн} невозможно войти, встать, сесть или лечь."
mp.msg.Enter.CLOSED = "{#First} {#word/закрыт,#first}, и {#me} не {#word/мочь,#me,нст} зайти туда."
mp.msg.Enter.ENTERED = "{#Me} {#word/залезть,прш,#me} {#if_has/first,supporter,на,в} {#first/вн}."

mp.msg.Exit.NOTHERE = "Но {#me} сейчас не {#if_has/first,supporter,на,в} {#first/пр,2}."
mp.msg.Exit.NOWHERE = "Но {#me/дт} некуда выходить."

--"покинуть"
--"слезть"
mp.msg.Exit.EXITED = "{#Me} {#if_has/first,supporter,{#word/слезть с,#me,прш} {#first/рд},{#word/покинуть,#me,прш} {#first/вн}}."

mp.msg.AND = "и"

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

mp.msg.verbs.take = -"взять,#me,прш"

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
	local w = std.split(hint)
	w = w[#w]
	if mp.utf.len(w) > 2 and
		(lang.is_vowel(utf.char(w, 1)) or
		lang.is_vowel(utf.char(w, 2))) then
		return "в ".. hint
	end
	return "во ".. hint
end

function mp.shortcut.so(hint)
	local w = std.split(hint)
	w = w[#w]
	if mp.utf.len(w) > 2 and
		(lang.is_vowel(utf.char(w, 1)) or
		lang.is_vowel(utf.char(w, 2))) then
		return "с ".. hint
	end
	return "со ".. hint
end

function mp:Exam(w)
	if not w then
		std.me():need_scene(true)
	end
	return false
end

Verb { "#Enter",
	"идти,иду,иди,войти,войд/и,зайти,зайд/и,залез/ть,бежать,бег/и,влез/ть,ехать,поехать,едь,поеду,сесть,сядь,сяду,лечь,ляг",
	"на|в|к {noun}/вн : Enter",
	"{noun_obj}/@compass : Enter" }

Verb { "#Exit",
	"выйти,выйд/и,вылез/ти,выхо/ди,обратно,назад,выбраться,выберись,выберусь,выбираться,слез/ть",
	"из|с|со ?{noun}/рд : Exit",
	"Exit" }

Verb { "#Examine",
	"осм/отреть,смотр/еть,рассмотр/еть,изуч/ить,посмотр/еть,гляд/еть,разгляд/еть,погляд/еть",
	"?на {noun}/вн : Exam",
	"?всё : Exam" }

-- Dialog
std.phr.default_Event = "Exam"

Verb ({"сказать", "{select} : Exam" }, std.dlg)

parser = mp
