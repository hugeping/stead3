require "mp-ru"

game:dict {
--	['я/вн'] = 'себя'; -- возвратное местоимение
}


function parser:before_Take(w)
	if have(w) then
		p "У {#me/вн} и так {#firstit} уже есть."
		return
	end
	return false
end

function parser:Take(w)
	take(w)
end

function parser:after_Take(w)
	if not self.reaction then
		p ("{#Me} {#verb/take} {#first/вн}.");
	end
end

obj {
	-"красное яблоко,яблоко/ср,test|облако",
	life = 'яблоко лежит';
	nam = 'яблоко';
	default_Verb = 'взять красное яблоко';
}: dict {
--	['яблоко/дт,мн'] = 'кустом слово для объекта';
}

obj {
	-"зеленое яблоко,яблоко/ср",
	life = 'яблоко лежит';
	nam = 'яблоко2';
}: dict {
--	['зеленое яблоко/дт,мн'] = 'кустом слово для объекта';
}

-- lifeon 'яблоко'
parser.debug.trace_action = true

--game: dict {
--	['красное яблоко/дт,мн'] = 'кустом слово для игры';
--}

Verb { "#take", "взять,забрать,схват/ить,забери,возьми,бери", "{noun}/вн : Take" }
Verb { 'сказ/ать', "{noun}/дт * : Talk" }
Verb { 'идти', "на северо-восток|север : Walk" }
Verb { '~север', ": Walk" }

function parser.token.topic(w)
	return "пароль"
end

pl.word = -"я/од,мр,1л";


room {
	nam = 'main';
	dsc = 'Вы в комнате';
}: with { 'яблоко', 'яблоко2' }


function start()
	print(_'яблоко':noun('тв,мн')) -- даст яблокам
	print(pl:Noun('тв')) -- даст мной
	print(parser.mrd:noun(-"взять/прш,од,1л"))
	print(parser.mrd:noun(-"нужен/жр"))

	print(pl:noun())
--	for k, v in pairs(_'яблоко':gram()) do
--		print(k, v)
--	end
end
