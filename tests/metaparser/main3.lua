require "mp-ru"

obj {
	-"красное яблоко,яблоко/ср,test|облако",
	life = 'яблоко лежит';
	nam = 'яблоко';
	default_Verb = 'взять красное яблоко';
	before_Take = function(s)
		p "Я беру {/вн}.";
		print(s:hint'neuter')
	end;
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

game: dict {
--	['красное яблоко/дт,мн'] = 'кустом слово для игры';
}

parser.Exam = function(s, w)
	if not w then
		std.me():need_scene(true)
	end
	return false
end

Verb { "#take", "взять,забрать,схват/ить,забери,возьми,бери", "{noun}/вн : Take %1" }
Verb { "#examine",
	"осм/отреть,смотр/еть,рассмотр/еть,изуч/ить,посмотр/еть",
	"{noun}/вн : Exam %1",
	"Exam" }

Verb { 'сказ/ать', "{noun}/дт * : Talk" }
Verb { 'идти', "на северо-восток|север : Walk" }
Verb { '~север', ": Walk" }

function parser.token.topic(w)
	return "пароль"
end

pl.word = -"я/од,мн";

game:dict {
	['я/вн'] = 'себя'; -- возвратное местоимение
}

room {
	nam = 'main';
	dsc = 'Вы в комнате';
}: with { 'яблоко', 'яблоко2' }

function start()
	print(_'яблоко':noun('тв,мн')) -- даст яблокам
	print(pl:Noun('тв')) -- даст мной
--	for k, v in pairs(_'яблоко':gram()) do
--		print(k, v)
--	end
end
