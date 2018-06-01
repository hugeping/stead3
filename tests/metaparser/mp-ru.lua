require "mp"
local lang = require "morph/lang-ru"
local mp = _'@metaparser'
mp.msg.enter = "<ввод>"
mp.mrd.lang = lang
mp.msg.UNKNOWN_VERB = "Непонятный глагол"
mp.msg.UNKNOWN_VERB_HINT = "Возможно, вы имели в виду"
mp.msg.INCOMPLETE = "Нужно дополнить предложение."
mp.msg.UNKNOWN_OBJ = "Такого предмета тут нет"
mp.msg.UNKNOWN_WORD = "Слово не распознано:"
mp.msg.HINT_WORDS = "Возможно, Вам следует добавить:"
mp.msg.HINT_OR = "или"
mp.msg.HINT_AND = "и"
mp.msg.MULTIPLE = "Тут есть"
mp.default_Verb = "осмотреть"

mp.hint.live = 'од'
mp.hint.neuter = 'ср'
mp.hint.male = 'мр'
mp.hint.female = 'жр'
mp.hint.plural = 'мн'

mp.keyboard_space = '<пробел>'
mp.keyboard_backspace = '<удалить>'

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
	p "существительно в"
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

parser = mp
