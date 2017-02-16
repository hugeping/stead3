require "format"
format.para = true
--std.debug_xref = false
--std.debug_output = true
--std.debug_input = true

game.inv = [[Зачем мне это?]];
-- nouse
game.use = function(s, w, ww)
	local r, v
	if w.nouse then
		r, v = std.call(w, 'nouse', ww)
	end
	if v == true then
		return r, v
	end
	if w.noused then
		r, v = std.call(ww, 'noused', w)
	end
	if v == true then
		return r, v
	end
	p [[Гм... Мне кажется, здесь это не поможет.]]
end

game.act = 'Ничего не произошло...'

function human(v)
	v.human = true
	if not v.female then
		v.female = false
	end
	v.noused = function(s)
		if s.female then
			p [[Ей это не понравится.]]
		else
			p [[Ему это не понравится.]]
		end
	end
	return obj(v)
end

-- create own class container
cont = std.class({
	display = function(s)
		local d = std.obj.display(s)
		if s:closed() or #s.obj == 0 then
			return d
		end
		local c = s.cont or 'Здесь есть: '
		local empty = true
		for i = 1, #s.obj do
			local o = s.obj[i]
			if o:visible() then
				empty = false
				if c > 1 then c = c .. ', ' end
				c = c..std.dispof(o)
			end
		end
		if empty then
			return d
		end
		c = c .. '.'
		return std.par(std.space_delim, d, c)
	end
}, std.obj)

room {
	nam = 'main';
	title = 'Улица';
	disp = 'На улицу';
	enter = [[Была середина Февраля. Редкие, но колючие снежинки кружились в темноте улиц.
Тусклый свет фонарей разливался по асфальту причудливыми пятнами. Я шел быстрым шагом,
укутавшись в пальто и рассеяно рассматривая пустынные переулки. В этот момент меня кто-то окликнул.^^
-- Дай на хлеб, дружок!]];
	decor = [[Я нахожусь на пустынной, слабо-освещенной {#улица|улице}. Справа от себя я вижу коричневую стену старого {#здание|здания}. На улице стоит {#бомж|нищий}, который довольно бесцеремонно меня разглядывает.]];
	obj = {
		obj {
			nam = '#улица';
			act = 'Улица тускло освещена бледным светом уличных фонарей.';
		};
		obj {
			nam = '#здание';
			act = [[Здание выглядит старым. Я хожу по этой улице почти каждый день, но совершенно
не знаю, что это за постройка. Здесь мог бы располагаться театр или банк.]];
		};
		obj {
			nam = '#бомж';
			act = function()
				if not visited 'dlg1' then walkin 'dlg1'; return; end;
				p [[Надо сходить в это здание... Странный тип.]]
			end;
		}
	};
	onexit = function(s, t)
		if t/'здание' then
			return
		end
		p [[Я хотел пройти мимо нищего, но тот нагло загородил мне путь.]];
		return false
	end;
	way = {
		room { disp = 'Уйти' };
		'здание';
	}
}

dlg {
	nam = 'dlg1';
	title = 'Разговор';
	enter = [[-- Дай на хлеб, родной! -- хриплый голос нищего вызывал раздражение.]];
	dsc = [[Одет он, вроде бы, тепло. Хотя пальто, конечно, драное. На лице -- щетина. Глаз не разглядеть в темноте.]];
}:with {
{
	{ 'У меня нет денег.', '-- Ха, ха, ха - тебе самому не смешно?' };
	{ 'На, держи немного...', '-- Ух ты! Хотя, знаешь, лучше не давай мне денег.',
		{ 'Почему?', '-- Потому что я их пропью, но у меня есть идея!', next = '#идея' };
		{ 'Ну я пошел...', '-- Подожди, у меня есть идея!', next = '#идея'; };
	};
	{ 'Ты же все пропьешь...',
	'-- Если честно, ты прав, прав, как же ты прав... Но знаешь, у меня есть идея!',
	next = '#идея';
	};
	{ 'Я не хочу с тобой разговаривать..',
	[[-- Откровенно говоря, я тоже не хочу с тобой разговаривать. Но мне нужны деньги!]]
	}
},
{ '#идея',
	{ 'Ну, и что за идея?', next = '#идея2' },
	{ 'Не хочу слушать никаких идей!', next = '#идея2' },
};
{ '#идея2', [[-- Вот, послушай! Сходи в магазин, и купи мне хлеба! Что тебе стоит? Мне так хочется есть...]],
	{ '#согласен',
	'Ну хорошо, я схожу.', [[-- Спасибо, брат! Ходить далеко не придется. Вот здесь есть магазин на первом этаже.]],
	next = '#идея3' };
	{ 'Да здесь магазина нет!', [[-- А вот и есть! Вот прямо здесь, видишь?]], next = '#идея3' };
	{ 'Слушай, возьми лучше денег!', [[-- Ты хочешь, что бы я умер от цирроза печени?]],
		{ 'Да', function() p '-- Но я этого не хочу!'; pop(); end };
		{ 'Нет', function() p '-- Вот видишь?'; pop(); end};
	};
};
{ '#идея3', [[С этими словами он показал своим скрюченным пальцем в сторону ближайшего массивного здания.]],
	{ cond = function()
		return not  closed '#согласен'
	end;
	'Ну хорошо, я схожу и куплю тебе еды.',
	function() p '-- Спасибо! Давай, скорее, он скоро закроется!';
		walkout(); enable 'здание' end
	};
	{ 'Что то я не вижу вывески.', '-- Но магазин то там есть! Я точно знаю, я часто клянчу там вып... гм.. еду.' };
	onempty = function()
		walkout(); enable 'здание'
		p [[Да, похоже придется сходить и купить ему еды.]]
	end;
};
};


floor = function()
	return cont {
		nam = '#пол';
	}
end

room {
	nam = 'здание';
	disp = 'В здание';
	title = 'Коридор';
	enter = function(s, f)
		if not visited() then
			p [[Я открыл массивную деревянную дверь и очутился в темном коридоре. Было
темно и тихо.]]
			lifeon 'зал'
		end
	end;
	decor = [[Я нахожусь в темном длинном коридоре.]];
	onexit = function(s, t)
		if t/'main' then
			p [[Я должен купить хлеба для нищего.]]
			return false
		end
	end;
	obj = { floor(),
		obj {
			nam = 'монета';
			name = false;
			readed = false;
			dsc = [[На полу я вижу что-то {блестящее}.]];
			tak = [[Я поднял с пола предмет. Гм, похоже это золотая монета! Или подделка?]];
			nouse = [[Деньги не всегда решают проблемы.]];
			inv = function(s)
				p [[Какая красивая вещица!]];
				if s.name then
					s.readed = true
					pn [[Я внимательно повертел ее перед глазами. О нет! На обратной стороне я прочитал:]]
					pn [["Вадим Владимирович, 1977 года рождения. UID: 7099931130045. 305. Миссия ,,поиск''".]];
					p "Что за?..."
				end
			end;
			use = function(s, w)
				if w/'#люди' then
					p [[Я сунул монету какому-то толстому мужчине. -- У меня такая-же -- промычал он мне и отвернулся.]]
					return
				end
				if w.human then
					if w.female then
						p [[Я сунул ей монету.]]
					else
						p [[Я попытался сунуть ему монету.]]
					end
					p [[Никакой реакции.]]
					return
				end
				return false
			end;
		}
	};
	way = { 'main', path {'В конец коридора', 'зал' } }
}:disable()

room {
	nam = 'зал';
	title = 'Холл';
	enter = function(s, f)
		p [[Я очутился в довольно просторном холле.]];
	end;
	life = function(s)
		if here()/'здание' then
			p [[Мне кажется, я слышу какой-то шум, который доносится с конца коридора.]]
		elseif here() == s then
			p [[Я слышу шум голосов и звон посуды справа.]]
		else

		end
		return false
	end;
	decor = [[Неяркий свет освещает {#лестница|лестницу}. Справа находится двустворчатая {#дверь|дверь}.]];
	obj = {
		obj {
			nam = '#лестница';
			act = [[Лестница ведет на второй этаж.]];
		};
		obj {
			nam = '#дверь';
			act = function(s)
				if s:closed() then
					s:open()
					p [[Я взялся за массивную ручку и потянул на себя.
Скрип открывающейся двери раздался в пустом холле.]];
					open '#двери'
				end
				p [[Двери открыты.]]
			end;
		}:close();
	};
	way = { path{'В коридор', 'здание'},
		path{'#двери', 'В дверь', 'гостиная'}:close()
	};
}

room {
	nam = 'гостиная';
	title = 'Гостиная';
	enter = function(s, f)
		if not visited() then
			p [[Не без трепета я вошел в залитую светом гостиную. Свет и шум застолья взбудоражил и застал меня врасплох.
Гостиная была великолепна! В ее центре был расположен стол, за которым сидели люди.]]
		end
	end;
	decor = [[Я нахожусь в просторной, залитой светом гостиной. Посреди гостиной стоит {#стол|стол}, заправленный
красной скатертью, которую, впрочем, едва заметна за обилием {#еда|еды и выпивки}. За столом сидят несколько {#люди|людей}. Слышен звон бокалов, голоса и женский смех. На меня, кажется, никто не обращает внимания.]];
}: with {
obj {
	nam = '#стол';
		act = [[Красная скатерть едва видна из-за обилия блюд.]];
};
obj {
	nam = '#еда';
	act = [[Я вижу как стол ломится от выпивки и закуски.]];
};
obj {
	nam = '#люди';
	act = function(s)
		if s:actions() == 0 then
			pn [[-- Извините, вы не знаете, здесь есть магазин? -- неуверенно спросил я у компании.]]
			pn [[Речь за столом стихла -- они смотрели на меня. -- Новенький -- послышался мне чей-то
шепот..]]
			pn [[Затем раздался громкий, неприятный смех. И гостиная снова наполнилась звуками.]]
		else
			pn [[Мне не нравятся эти люди. И, похоже, я им тоже не нравлюсь.]]
		end
		p [[Я вижу, что один из стульев пустует.]]
		enable '#стул'
	end;
};
obj {
	nam = '#стул';
	dsc = [[Рядом со столом есть один свободный {стул}.]];
	act = function(s)
		walkin "За столом"
	end
}:disable()}

obj {
	nam = 'еда';
	inv = [[Пара бутербродов с маслом и красной икрой.]];
	use = function(s, w)
		if w.human then
			p [[Покормить? Ну уж нет...]]
			return
		end
		p [[Бутерброды испачкаются.]]
	end;
}

room {
	nam = 'За столом';
	enter = [[Я подошел к столу и нагло сел на свободный стул. Кажется, никто не обратил на это ни малейшего внимания.]];
	decor = [[Напротив себя я вижу полного {#мужчина|мужчину}, который о чем-то разговаривает с {#женщина|женщиной},
которая сидит справа от него. Рядом со мной сидит {#парень|молодой парень}, лет 20 и что-то пишет на клочке бумаги. На другом
конце стола я вижу очень худого {#странный|человека} неопределенного возраста, который мрачно смотрит перед собой. На столе полно {#еда|еды}.]];
	way = { room {nam = "Встать из-за стола", onenter = function() walkout "гостиная" end} };
	onexit = function(s, t)
		if t/'гостиная' and have 'еда' then
			p [[Я уже собрался встать из-за стола, когда глухой, но властный голос окликнул меня.
-- Куда вы собрались, милейший? Это был худой, угрюмый человек, который находился на другом конце стола.]];
			walkin 'председатель'
		end
	end;
}:with {
	obj {
		nam = '#еда';
		act = function(s)
			p [[Может, водочки? Гм.. Нет. Я вообще тут задержался.]]
			if not have 'еда'  then
				if visited 'председатель' then
					pn [[Движимой непонятной силой я снова взял пару бутербродов.]]
					take 'еда'
					return
				else
					pn [[Интересно, а что если вместо хлеба взять пару бутербродов с икрой? Я думаю, нищему это понравится.]]
				end
				take 'еда'
				p [[Я взял немного еды со стола.]]
			end
		end;
	};
	human {
		nam = "#мужчина";
		act = function(s)
		end;
	};
	human {
		nam = "#женщина";
		female = true;
		act = function(s)
		end;
	};
	human {
		nam = "#парень";
		used = function(s, w)
			if w/'монета' then
				if w.readed then
					p [[Парень только отмахнулся от меня. -- Не мешай, у меня расчеты.. ]];
					return
				end
				w.name = true
				pn [[Я сунул монету парню под нос. Он рассеяно посмотрел на нее.]]
				pn [[-- Гм, Вадим Владимирович, не отвлекайте меня, мне нужно найти решение!]]
				p [[Как он узнал мое имя?!!!]]
				return
			end
			return false
		end;
		act = function(s)
			pn [[-- Послушайте...]]
			p [[-- Ох, не мешайте мне!]];
		end;
	};
	human {
		nam = "#странный";
		act = function(s)
			pn [[-- Ммм.. Любезный ... -- я запнулся, когда мужчина окинул меня своим холодным взглядом.]]
		end;
		used = function(s, w)
			p [[Он слишком далеко от меня.]]
		end;
	};
}
dlg {
	nam = 'председатель';
	title = [[Разговор с угрюмым человеком]];
	enter = function(s)
		if visited() then
			s:push '#снова'
			disable '#омонете'
			p [[-- Как я погляжу, наш воришка снова украл!^]]
			p [[-- Вы, умалишенный, отстаньте от меня!^]]
			p [[-- Я председатель!]]
		else
			p [[-- Как я заметил, вы что-то украли? -- в его голосе слышалась угроза.]];
		end
	end;
}: with {{
		{"Да я просто взял пару бутербродов!", "-- Вот именно! Извольте объясниться!", next = '#кража',
		 cond = function(s) return not closed '#кража' end };
		{'#кража', "Украл? Я ничего не крал!", "-- А бутерброды, которые вы бережно держите в руке?",
		 {"Разве это кража?", "-- А что по вашему тогда называется кражей? Молчите, это риторический вопрос!"},
		 {"Хорошо, я положу их назад.", "-- Вам придется их съесть!",
		  {'#бред', "Что? Что за бред! Я могу их съесть?", [[-- Вам придется их съесть! Так как за этим столом едят.]]},
		  {"А можно их съесть потом?", function() close '#бред'; p [[-- Вы можете их съесть потом, но только за этим столом!.]] end},
		  {"Что за бредовые правила?", [[-- Это не вашего ума дела! Я здесь председатель!]],
		   { '#снова', "Председатель?", [[-- Да, я председатель!]],
		     { '#a', "Председатель чего?", [[-- Общества, в котором вы находитесь!]],
		       {"Я не состою в вашем обществе!", function()
				if have 'монета' then push '#омонете'; return "-- Вас обличает золотая монета!" end
				p [[-- Вы сидите за нашим столом!]];
		       end }
		     },
		     { false, '#омонете',
		       { "Что вы знаете о монете?", "-- У каждого члена нашего общества своя монета. Свой долг.",
			 { "И у вас есть монета?", "-- НЕ ЛЕЗЬТЕ НЕ В СВОЕ ДЕЛО! Моя монета не важна! Я председатель! Кто-то должен за всеми следить! И это я! Я! Я взял на себя эту обязанность! Какое дело вам, воришке, до моей монеты?"}
		       },
		       { "Я не крал монету!", "Умалишенный громко засмеялся. -- Конечно, вы не крали ее." },
		       onempty = function() p "-- Ладно, вернемся к вашей краже!"; pop() end;
		     };
		     { '#b', "Да вы сумасшедший!",
		       [[Это не относится к делу. Может быть и вы сумасшедший, но важно не это, важно -- что вы вор!]],
		     };
		     { cond = function() return closed '#a' and closed '#b' end;
		       [[Ладно, я сдаюсь.]], function(s) remove 'еда'; p [[С этими словами я затолкал бутерброды в рот и съел их. -- Так то лучше! -- одобрил мой поступок председатель. И больше никаких нарушений!]]; walkout() end;
		     }
		   },
		  },
		 },
		 {"Мне они нужны, чтобы покормить нищего.", "-- Это не относится к делу."},
		}
	}}
function start()
end
