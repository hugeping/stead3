require "mp-ru"

obj {
	life = 'яблоко лежит';
	-"красное яблоко,яблоко/ср";
	nam = 'яблоко';
}: dict {
--	['яблоко/дт,мн'] = 'кустом слово для объекта';
}

obj {
	life = 'яблоко лежит';
	-"зеленое яблоко,яблоко/ср";
	nam = 'яблоко2';
}: dict {
--	['зеленое яблоко/дт,мн'] = 'кустом слово для объекта';
}

-- lifeon 'яблоко'

game: dict {
--	['красное яблоко/дт,мн'] = 'кустом слово для игры';
}

Verb { "#take", "взять,забрать,схват/ить,забери,возьми,бери", "{noun}/вн : take %1" }
Verb { "#examine", 
    "осм/отреть,смотр/еть,рассмотр/еть,изуч/ить,посмотр/еть", 
    "{noun}/вн : Exam %1",
    "Exam" }

Verb { 'сказ/ать', "{noun}/дт * : Talk" }

function parser.token.topic(w)
	return "пароль"
end


Verb { "сказ/ать", " : Talk"}

room {
	nam = 'main';
}: with { 'яблоко', 'яблоко2' }

function start()
	print(_'яблоко':noun('тв,мн')) -- даст яблокам
--	for k, v in pairs(_'яблоко':gram()) do
--		print(k, v)
--	end
end
