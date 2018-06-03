require "mp-ru"
require "fmt"

fmt.para = true

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
	return false
end

function parser:after_Take(w)
	if not self.reaction then
		p ("{#Me} {#verb/take} {#first/вн}.");
	end
end

obj {
	-"красное яблоко,яблоко/ср",
	life = 'яблоко лежит';
	dsc = [[На столе есть яблоко.]];
	nam = 'яблоко';
--	Take = 'взял';
--	Take = function(s) walk 'main2' end;
}: dict {
--	['яблоко/дт,мн'] = 'кустом слово для объекта';
}

obj {
	-"стол";
	nam = 'стол';
	dsc  = [[Здесь есть стол.]];
} : with 'яблоко' : attr "container,openable,open"

obj {
	-"зеленое яблоко,яблоко/ср",
	life = 'яблоко лежит';
	nam = 'яблоко2';
}: dict {
--	['зеленое яблоко/дт,мн'] = 'кустом слово для объекта';
} : attr "~open,container"

print("attr", _'яблоко2':has 'container')
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
}: with { 'стол' }


function start()
	print(_'яблоко':noun('тв,мн')) -- даст яблокам
	print(pl:Noun('тв')) -- даст мной
	print(parser.mrd:noun(-"взять/прш,од,1л"))
	print(parser.mrd:noun(-"нужен/жр"))
	print("ACCESS:", _'яблоко':access())
	print(pl:noun())
--	for k, v in pairs(_'яблоко':gram()) do
--		print(k, v)
--	end
end

dlg {
	nam = 'main2';
	disp = '...';
	phr = {
		[[У тебя одна минута на то, чтобы объяснить мне, как добраться до хранилища.^
— Что?^
Бац! В глазах сверкнуло и боль такая сильная, что кажется, будто она — единственное, что я сейчас чувствую. Даже сильнее страха.^
— Одна минута, — говорит он и прижимает холодный кружок дула к моему лбу.]];
		{
			'#что?',
			'Что?',
			[[Бац! Оказывается, может быть ещё больнее, чем в первый раз.^
— Ещё раз скажешь "что", выстрелю.]]
		},
		{
			'#что2',
			'Что?',
			function(s) p [[Он стискивает зубы и стреля...]]; walk 'theend' end,
			cond = function(s) return closed '#что?' end,
		},
		{
			'Но я здесь не работаю...',
			[[ — Но я здесь не работаю, я вообще не знаю, где тут что!^
		— Какого чёрта тогда ты делаешь в кабинке оператора? ]],
			next = '#кто ты?',
		},
		{
			'#про подвал',
			'Хранилище в подвале.',
			[[— Хранилище находится в подвале...^
		— Уже лучше. А теперь, как туда добраться?]],
			next = '#хранилище';
		}
	};
	obj = {
		{
			'#кто ты?',
			{
				'Я техник.',
				[[— Я просто техник, мне позвонили и попросили починить компьютер.
Они иногда вызывают меня сюда, но я не знаю, где тут сейф, честное слово!^
— Занятно. Тогда почему на твоём бейдже написано "Старший кассир"?]],
				{
					'Я его одолжил, чтобы через турникет пройти.',
					function()
						p [[— Я его одолжил, чтобы пройти через турникет, я часто так делаю, а то они никак мне собственный не сделают...^
— У кого одолжил?^
Пальцем в толстого очкарика на полу, тут же затрясшего головой.^
— Окей, спасибо, техник, — и спускает куро...]];
						walk 'theend'
					end
				},
			},
			{
				'Я от вас прячусь.',
				[[ — Я тут от вас прячусь...^
— А, ты один из посетителей?^
— Да.^
— Я вот не видел, как ты сюда пробегал, ты сюда зашёл ещё до того, как я вошёл в здание?^
— Да!^
— А как же ты через турникет прошёл?]],
				next = '#лжец'
			},
			{
				'Тоже решил денег взять.',
				[[— Да я вот решил тоже денег взять. Под шумок, так сказать. Хе-хе.^
— А, вон оно что. Но на тебе форма сотрудника банка. То есть, ты не только лжец, но ещё и вор? Двадцать секунд. Хе-хе.]],
				next = '#лжец'
			},
		},
		{
			'#лжец',
			{ alias = '#что?' },
			{ alias = '#что2' },
			{ alias = '#про подвал' },
		};
		{
			'#хранилище',
			onempty = function()
				enable "#нет пути"
			end,
			{
				"По лестнице...",
				[[— Вон за той дверью в подвал ведёт лестница, по ней можно спуститься до главного коридора, из него в архив, а уже через архив к двери хранилища.^
— Ещё что-нибудь, о чём мне как грабителю полезно было бы узнать?]],
				next = '#лестница'
			},
			{
				'#на лифте',
				"На лифте...",
				[[— В кабинете управляющего есть лифт, спускающийся прямо в хранилище. Только вряд ли вы до него доберётесь.^
— Почему это?]],
				next =  '#лифт'
			},
			{
				false,
				"#нет пути",
				"Нет",
				[[— К сожалению, больше путей нет.^
— Вот же задачка. Монетку бросить что ли... Это всё? Может ещё что-нибудь знаешь?]],
				next = "#про деньги",
			},
		},
		{
			'#лестница',
			onempty = function(s)
				p "— А другой путь есть?"
				pop();
			end,
			{
				"О лестинце...",
				[[— На лестнице сторожит охранник с оружием.^
— Каким оружием?]],
				next = '#оружие',
			},
			{
				"О коридоре...",
				[[— Поперёк коридора идут лазерные лучи.^
— Красные или зелёные?]],
				next = '#коридор'
			},
			{
				"Об архиве...",
				function()
					p [[— В архиве люди пропадают...^
— Что?!^
— Люди, говорю, в архиве пропадают.^
— Да это я понял! Почему пропадают?^
— Не знаю, но, поговаривают, что нужно быть поосторожнее со шкафами F.^
— Почему?^
— Пропали сотрудники Фриманн, Фрекель, Фаркопс и Фонг. У вас какая фамилия?^
— Фицжеральд.^
— О...]];
					if not empty '#лестница' then p '^— Дальше.' end
				end
			},
			{
				"О двери в хранилищие...",
				function()
					p [[— Толщина двери в хранилище полтора метра.^
— Ого...
— И замок «Sargent & Greenleaf».^
— Ой...^
— Пол внутри под напряжением десять тысяч вольт.^
— Ох...^
— А снаружи камеры.]];
					if not empty '#лестница' then p '^— Понятно. Дальше.' end
				end
			}
		},
		{
			'#коридор',
			{
				"Красные.",
				function()
					p [[— Красные, кажется. А что есть какая-то разница?]];
					if not empty '#лестница' then p '^— Не твоего ума дело, дальше давай.';  end
					pop()
				end
			},
			{
				"Зелёные.",
				function()
					p [[— Зелёные, кажется, а что?^
— Проклятье, у меня дейтеранопия.^
— Зелёный цвет не различаете?^
— Да.^
— Сочувствую.]];
					if not empty '#лестница' then p '^— Спасибо. Дальше.'; end
					pop()
				end
			},
		},
		{
			'#оружие',
			{
				"Ружьё какое-то...",
				function()
					p [[— Не знаю, я не разбираюсь.]]
					if not empty '#лестница' then p '^— Дальше.'; end
					pop()
				end
			},
			{
				"Benelli M4...",
				function()
					p [[— Benelli M4 Super 90, шестизарядный, с телескопическим прикладом, пистолетной рукояткой, планкой Пикатинни...]]
					if not empty '#лестница' then p '^— Всё, заткнись, давай дальше.'; end
					pop()
				end
			}
		},
		{
			"#лифт",
			onempty = function()
				p "— А другой путь есть?"
				pop()
			end,
			{
				"Управляющий.",
				function()
					p [[— В кабинете скорее всего сидит сам управляющий.^
— И чего?^
— Он чемпион города по гарлемскому боксу.^
— Впервые слышу про такой бокс.^
— Основная особенность его в том, что во время боя разрешено использовать кастеты, биты и автоматическое оружие.]]

					if not empty '#лифт' then
						p "— Хмм, ну ладно, допустим, я с ним разберусь, что ещё?"
					end
				end
			},
			{
				"Собаки.",
				function()
					p [[— Собаки.^
— Собаки?^
— Да.^
— Большие?^
— Очень.^
— Много?^
— Четыре.]]
					if not empty '#лифт' then
						p "— Ох... Ну допустим, с собаками я как-нибудь управлюсь. Что-то ещё?."
					end
				end
			},
			{
				"Системы идентификации.",
				[[— В лифте стоят системы идентификации, которые пропускают только управляющего.^
— Какие системы?]],
				next = '#идентификация',
			},
		},
		{
			"#идентификация",
			onempty = function()
				enable "#по системам все";
			end,
			{
				false,
				'#по системам все',
				[[- По системам идентификации всё.]];
				function()
					if not empty '#лифт' then
						p "Ещё что-нибудь по лифту?"
					end
					pop()
				end
			},
			{
				"Отпечатки.",
				[[— Сканер отпечатка правой ладони.^
— Это, теоретически, можно обойти. Дальше.]],
			},
			{
				"Сетчатка глаза.",
				[[— Для этого у меня есть инструменты и необходимые навыки, — он зловеще ухмыляется. — Дальше.]],
			},
			{
				"Вес.",
				[[— Датчик веса.^
— Хм. Сколько весит местный управляющий?^
— 124 килограмма. А вы сколько весите?^
— 61. Мда. Тут даже клонирующая машина бы не помогла. Ладно, дальше.]],
			},
		},
		{
			"#про деньги",
			{
				"Про деньги.",
				function(s)
					p [[— Знаю про деньги в хранилище.^
— Так, и что с ними?^
— Их там нет.^
— Как нет?!^
— Ну мы переезжаем в другой район города и все деньги и ценности уже перевезли сегодня ночью.^
— Так почему ты сразу не сказал?!^
— Ну про это вы как раз не спрашивали.^
— Проклятье!^^

И с этими словами он выбегает из отделения банка, где его ловит
экипаж инкассаторской машины, приехавшей, чтобы как раз перевезти
содержимое хранилища в другой район города. Хе-хе.]]
				  walk 'theend'
				end
			},
		}
	}
}
