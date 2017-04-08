-- $Name: Фотоохота (ИНСТЕДОЗ 5)$
-- $Version: 0.3$
-- $Author: techniX$
--[[

Если Вы еще не играли в эту игру, 
не читайте, пожалуйста, код дальше, 
чтобы не испортить удовольствие от игры :)

История версий:
0.1
  первая версия
0.2
  добавлены дополнительные реакции у предметов
0.3
  добавлены достижения, улучшены некоторые загадки
  
]]--

require "noinv"
require "snd"
require "fmt"
require "prefs"

prefs.photo = { total = 0; cat = false; selfie = false; profi = false; reader = false; mystery = false; }
prefs:load();

fmt.para = true
game.pic = "gfx/smena.png"

local book = {
  [[Это были "25 уроков фотографии". ]],
  [[Заголовок гласил: "Тригонометрические таблицы Брадиса". ]],
  [[Это оказался толстенный том "Квантовая физика в двух словах. Том 5". ]],
  [[Тоненькая книжка была посвящена проблемам создания машин лунных баз, как следовало из заголовка. ]],
  [[Потрепанная книга "Аргонавты Вселенной", вопреки его ожиданиям, оказалась научной фантастикой. ]],
}

local pf = true
local bk = 0
local paperf = true

obj {
  nam = "Фиксаж";
  dsc = "В шкафу, на второй полке лежал пакет с {фиксажем} для пленки.";
  tak = "Валерка взял пакет с фиксажем.";
  inv = [[Бумажный пакет с порошком фиксажа. На пакете написано: "Ф - фиксаж универсальный. Инструкция: медленно растворить содержимое пакета в 250 мл воды."]];
}

obj {
  nam = "Проявитель";
  dsc = "Пакет с {проявителем} валялся на третьей полке шкафа.";
  tak = "Подумав, Валерка захватил с собой пакет проявителя.";
  inv = [[Бумажный пакет с порошком проявителя. На пакете написано: "ПФ - проявитель для негативных катушечных фотопленок. Инструкция: медленно растворить содержимое пакета в 250 мл воды."]];
}

obj {
  nam = "Колба";
  disp = function(s,w)
    if s.with_water then
      p("Колба с водой")
    elseif s.is_broken then
      p("Треснутая колба")
    else
      p("Колба")
    end
  end;
  dsc = "На столе стояла химическая {колба}, непонятно как тут оказавшаяся.";
  tak = "Решив, что колба еще может пригодиться, Валерка взял её со стола. Колба, правда, оказалась треснутой.";
  inv = function(s,w)
    if s.with_water then
      p("Колба, заполненная водой.")
    elseif s.is_broken then
      p("Треснутая химическая колба.")
    else
      p("Пустая химическая колба, тщательно обмотанная изолентой.")
    end
  end;
  used = function(s,w)
    if w^"Проявитель" or w^"Фиксаж" then
      p"Рассудив, что в колбе растворять реактивы будет неудобно, Валерка решил поискать что-то более подходящее."
    end
    if w^"Изолента" then
      p"Валерка тщательно обмотал колбу изолентой."
      s.is_broken = false
    end
  end,
  with_water = false;
  is_broken = true;
}

-- glass handler
-- 0 - empty, 1 - water, 2 - proyav, 3 - fix
glass_dsc = function(s,w)
  local d = ".";
  if s.cont == 1 then
    d = " с водой."
  elseif s.cont == 2 then
    d = " с раствором проявителя."
  elseif s.cont == 3 then
    d = " с раствором фиксажа."
  end
  p(s.descr .. d)
end;
glass_act = function(s,w)
  local name = "Стеклянная банка"
  local d = ", совершенно пустая."
  if s.cont == 1 then
    d = " с водой."
  elseif s.cont == 2 then
    d = " с раствором проявителя."
  elseif s.cont == 3 then
    d = " с раствором фиксажа."
  end
  p(name .. d)
end;
glass_used = function(s,w)
  if w^"Колба" then
    if w.with_water then
      if s.cont == 0 then
        p"Валерка осторожно налил в банку воды."
        s.cont = 1
      else
        p"Пожалуй, воды было достаточно."
      end
    else
      p[["Из пустой колбы банку не наполнишь." -- подумал Валерка.]]
    end
  elseif w^"Проявитель" then
    if s.cont == 0 then
      p"Валерка глянул в инструкцию. Так и есть, проявитель нужно растворить в воде, а не сыпать в пустую банку."
      pf = false
    else
      if s.cont == 1 then
        p"Открыв пакет с проявителем, Валерка растворил его в воде, медленно помешивая, как предписывала инструкция."
        s.cont = 2
        purge "Проявитель"
      else
        p"Валерка решил отложить эксперимент со смешиванием реактивов на потом."
        pf = false
      end
    end
  elseif w^"Фиксаж" then
    if s.cont == 0 then
      p"Сыпать фиксаж в пустую банку Валерка не стал. Инструкция гласила, что фиксаж нужно растворить в воде."
      pf = false
    else
      if s.cont == 1 then
        p"Открыв пакет с фиксажем, Валерка высыпал его содержимое в банку. Пара минут - и порошок полностью растворился."
        s.cont = 3
        purge "Фиксаж"
      else
        p"Сопротивляясь искушению поэкспериментировать с реактивами, Валерка нехотя убрал пакет с фиксажем."
        pf = false
      end
    end
  elseif w^"Бачок для проявки" then
    if w.ready_to_process then
      if s.cont == 0 then
        p[["Это же пустая банка!" - подумал Валерка и оставил банку в покое.]]
        pf = false
      elseif w.process_stage == 0 and s.cont == 2 then
        p"Валерка залил проявитель в бачок и стал старательно вращать ручку бачка, чтобы пленка проявилась равномерно."
        s.cont = 0
        w.process_stage = 1
      elseif w.process_stage == 1 and s.cont == 3 then
        p"Теперь настала очередь фиксажа. Валерка слил проявитель из бачка, залил из банки фиксаж и снова стал крутить ручку. Через несколько минут все было готово."
        s.cont = 0
        w.process_stage = 2
      else
        p[["А не напутал ли я чего?" - испугался Валерка и оставил банку в покое.]]
        pf = false
      end
    else
      if s.process_stage == 2 then
        p[[Пленка уже проявлена.]]
      else
        p[["Рано еще" - подумал Валерка и оставил банку в покое.]]
      end
    end
  end
end;

local achievement_names = { cat = "Котограф"; selfie = "Портрет"; profi = "Профи"; reader = "Читатель"; mystery = "Тайна" }

obj {
  nam = "Банка1",
  descr = "На столе с фотопринадлежностями стояла {стеклянная банка}";
  cont = 0;
  dsc = glass_dsc;
  act = glass_act;
  used = glass_used;
}

obj {
  nam = "Банка2",
  descr = "Рядом с ней - другая {банка}";
  cont = 0;
  dsc = glass_dsc;
  act = glass_act;
  used = glass_used;
}

obj {
  nam = "Ключ";
  disp = "Ключ от кабинета";
  inv = "Ключ от кабинета Петра.";
};

obj {
  nam = "Изолента";
  dsc = "В ящике с инструментами лежал {моток изоленты}, слегка присыпанный пылью.";
  inv = "Синяя изолента. Целый моток.";
  tak = "Валерка вытащил изоленту из ящика и сунул в карман.";
};

obj {
  nam = "Инструкция";
  dsc = "На полу лежал {обрывок бумаги}, видимо, выпавший из книги.";
  tak = "Валерка взял обрывок бумаги с пола. Это оказался фрагмент инструкции по проявке фотопленки.";
  inv = function()
    if here().is_darkness then
      p[[Достав инструкцию, Валерка заметил, что она слабо светится в темноте. Перевернув лист, он обнаружил
      надпись, сделанную фосфоресцирующими чернилами:^
      "Ifhfm jt b rvbouvn dbu!"]]
      get_achievement("mystery")
    else
      p[[
      Обрывок листка с инструкцией сообщал:
      "... Для обработки катушечной пленки и кинопленки применяются специальные
      светонепроницаемые проявочные бачки, обычно изготовляемые из пластмассы.
      Преимущество таких бачков состоит в том, что в них можно проводить весь процесс
      обработки пленки (кроме зарядки бачка) на свету, при этом отпадает надобность
      в фотолаборатории. В каждом доме найдется темное помещение, где можно зарядить
      бачок пленкой. Закрыв бачок крышкой, выносят его на свет (конечно, не слишком
      яркий). Все дальнейшие операции, т.е. наполнение бачка проявителем,
      а затем фиксажем, производят на свету."
      ]]
    end
  end;
}

handler_photo_shwabra = function(s,t)
  if (t^"Швабра" or t^"Фотоаппарат") then
    if have "Изолента" then
      p"Не долго думая, Валерка достал изоленту и примотал ей фотоаппарат к швабре. Получилось неплохо.";
      take("Фотошвабра")
      purge("Швабра")
      purge("Фотоаппарат")
    else
      p"Чем бы прикрепить фотоаппарат к швабре?";
    end
  end
end;

obj {
  nam = "Фотоаппарат";
  dsc = [[На краю стола сиротливо лежал {фотоаппарат} "Смена-8".]];
  inv = [[Фотоаппарат "Смена-8".]];
  tak = "Повертев фотоаппарат в руках, Валерка гордо повесил его себе на шею.";
  used = handler_photo_shwabra;
};

function get_achievement(t)
  local achievements = prefs.photo
  if not achievements[t] then
    achievements[t] = true
    achievements.total = achievements.total + 1
    p("^^" .. fmt.u(fmt.nb("Получено достижение: " .. achievement_names[t])))
    prefs:store()
  end
end

obj {
  nam = "Швабра";
  dsc = "В углу стоит {швабра}.";
  inv = "Обычная деревянная швабра.";
  tak = function()
    if _("Пётр").should_use_camera then
      p "Валерка прихватил швабру с собой. Пригодится."
    else
      p "Так и не придумав, зачем ему нужна швабра, Валерка оставил её в покое."
      return false
    end
  end;
  used = handler_photo_shwabra;
};

obj {
  photo_done = false;
  nam = "Фотошвабра";
  inv = function(s)
    if _("Кассета с пленкой").photo_taken then
      p"Валерка извлек из фотоаппарата черную кассету с фотопленкой."
      take "Кассета с пленкой"
      purge "Фотошвабра"
    else
      p"Швабра с примотанным фотоаппаратом. Мощное орудие научного познания."
    end
  end
};

obj {
  nam = "Кассета с пленкой";
  photo_taken = false;
  is_processed = false;
  inv = "Кассета с непроявленной фотопленкой.";
  used = function (s,w)
    if w^"Бачок для проявки" then
      if here().is_darkness then
        p"Наощупь Валерка вытащил пленку из кассеты и заправил её в бачок."
        drop(s);
        w.ready_to_process = true;
      else
        p"В одном Валерка был уверен на все сто - здесь неподходящее место для этого. Пленку нельзя было засветить ни в коем случае."
      end
    end
  end
}

obj {
  nam = "Пленка";
  inv = function(s,w)
    if here().darkness then
      p"Темно и ничего не видно."
    else
      p"Кажется, получилось! Нужно скорее показать пленку Петру."
    end
  end;
}

obj {
  nam = "Бачок для проявки";
  ready_to_process = false;
  process_stage = 0;
  disp = function(s)
    if s.ready_to_process then
      p"Бачок с пленкой";
    else
      p"Бачок для проявки"
    end
  end;
  dsc = [[Там же стоял и {бачок для проявки пленки}.]];
  tak = "Валерка взял с собой проявочный бачок.";
  inv = function(s)
    if s.ready_to_process then
      if s.process_stage == 2 then
        p"Наконец-то все было готово! Валерка с нетерпением вытащил пленку из бачка.";
        s.ready_to_process = false
        take "Пленка"
        if pf then
          get_achievement("profi")
        end
      else
        p"Бачок для проявки фотопленки с заправленной пленкой. Открывать не стоит!";
      end
    else
      p"Бачок для проявки фотопленки."
    end
  end;
  used = function (s,w)
    if w^"Кассета с пленкой" then
      if here().is_darkness then
        p"Наощупь Валерка вытащил пленку из кассеты и заправил её в бачок."
        drop(w);
        s.ready_to_process = true;
      else
        p"В одном Валерка был уверен на все сто - здесь неподходящее место для этого. Пленку нельзя было засветить ни в коем случае."
      end
    elseif w^"Проявитель" or w^"Фиксаж" then
      p"Валерка решил придерживаться инструкции и не сыпать реактивы прямо в бачок."
      pf = false
    elseif w^"Колба" then
      if w.with_water then
        p"В бачок нужно заливать совсем не воду, вспомнил Валерка."
        pf = false
      end
    end
  end
}

-- ROOMS

room {
  nam = "main";
  noinv = true;
  disp = "Фотоохота";
  dsc = [[Портал открылся мгновенно и практически беззвучно. Пространство в проволочной рамке искривилось и потемнело, а сама рамка начала светиться слабым синеватым светом.^
  Валерка шагнул к порталу, но Пётр успел схватить его за руку: ^
  -- Куда это ты собрался? ^
  Валерка смущенно склонил голову.^
  -- Ну... это... посмотреть, что там.^
  -- Никакого представления о технике безопасности! - горестно вздохнул Пётр и покачал головой. - Сколько лет тебя учу, и все зря!^
  -- Так а как же исследовать-то?^
  -- Фотографировать. Принеси, пожалуйста, фотоаппарат из моего кабинета.]];
  decor = fmt.c("{#начало|Начать игру}");
}: with{
  obj {
    nam = "#начало",
    act = function()
      _("Пётр").should_get_camera = true
      walk "lab"
    end
  }
};

room {
  nam = "lab";
  disp = "Лаборатория";
  decor = "Проволочная рамка {#портал|портала} слегка светилась, отбрасывая слабые тени на оборудование вокруг. {Пётр|Пётр} сосредоточенно наблюдал за показаниями приборов.";
  way = { "corridor" };
}:with {
  obj {
    is_photo_used = false;
    is_shwabra_used = false;
    nam = "#портал";
    act = "Кто знает, что ждет нас внутри?";
    used = function(s, t)
      if t^"Фотоаппарат" then
        if s.is_photo_used then
          pn "-- Ну я же сказал - сам в портал не лезь! -- устало повторил Пётр."
        else 
          pn [[Валерка собрался просунуть фотоаппарат в портал.^
          -- Ты что, с ума сошел? -- остановил его Пётр. -- Зачем снова в портал полез? Нет, так дело не пойдет. Нужно найти безопасный способ сделать снимок.]]
          _("Пётр").should_get_camera = false
          _("Пётр").should_use_camera = true
          s.is_photo_used = true
        end
      elseif t^"Фотошвабра" then
        if s.is_shwabra_used then
          pn "-- Думаю, на сегодня фотографий достаточно, -- напомнил Пётр."
        else
          p[[Выставив автоспуск на пять секунд, Валерка осторожно просунул фотошвабру в портал. Для верности Валерка повторил эту процедуру несколько раз - хотя бы один кадр должен был выйти удачным. ^
          Эксперимент пришлось прекратить, когда во время очередной съёмки в швабру вцепилось что-то с другой стороны. К счастью, благодаря героическим усилиям Валерки, фотоаппарат удалось спасти. ^
          -- Отлично, просто отлично! -- Пётр сиял от восторга. -- Скорей бы посмотреть, что там получилось на фото! Займись-ка этим вопросом, а я продолжу наблюдения.]]
          s.is_shwabra_used = true
          _("Пётр").should_get_camera = false
          _("Пётр").should_use_camera = false
          _("Пётр").should_get_photos = true
          _("Кассета с пленкой").photo_taken = true
        end
      else
        p"-- Ты что собрался в портал запихнуть??? -- возмущенно воскликнул Пётр. -- Прекращай-ка эту самодеятельность."
      end
    end;
  };
  obj {
    nam = "Пётр";
    should_get_camera = false;
    should_give_key = false;
    should_use_camera = false;
    should_get_photos = false;
    act = function(s,w)
      if have "Пленка" then
        walk "finalscene"
        return
      end
      if s.should_get_camera then
        if have "Фотоаппарат" or have "Фотошвабра" then
          pn "-- О, ты нашел фотоаппарат! Прекрасно.";
        else
          pn "-- Ну что, принес фотоаппарат?";
          if s.should_give_key then
            pn"-- Вы мне, кажется, ключ от кабинета дать забыли..."
            pn"-- Ах да, конечно. Вот, держи!";
            take("Ключ")
            s.should_give_key = false;
          end
        end
      elseif s.should_use_camera then
        pn"-- Ну как, придумал как фото сделать?";
        pn"-- Нет еще... Но я близок к решению!";
      elseif s.should_get_photos then
        pn"-- Как там продвигается дело с проявкой пленки?";
        pn"-- В процессе! Осталось совсем недолго."; 
      end
    end;
    used = function(s, t)
      if t^"Фотоаппарат" then
        pn "Пётр замахал руками:^-- Нет-нет, меня фотографировать не надо!"
      elseif t^"Фотошвабра" then
        if _("Кассета с пленкой").photo_taken then
          pn "-- Доставай уже плёнку, не тяни! -- поторопил Пётр."
        else
          pn "-- Прямо-таки чудо инженерной мысли, -- похвалил Пётр. -- Ну что, приступим к опыту?" 
        end
      elseif t^"Кассета с пленкой" then
        pn "-- Но она же не проявлена! -- заметил Пётр. -- Я же попросил - прояви, пожалуйста."
      elseif t^"Пленка" then
        walk "finalscene"
      else
        pn("-- " .. t.nam .. ". -- произнёс Пётр. -- Прекрасно. Но зачем мне это?")
      end
    end;
  }
}

room {
  nam = "corridor";
  disp = "Коридор";
  title = "Коридор";
  dsc = "Коридор, выкрашенный зеленой краской до середины, казался бесконечным.";
  decor = function(s)
    if visits() == 2 then
      pn("Из-за угла появился институтский {#кот|кот} Гегель, несущий в зубах кусок колбасы.")
    end
    if visits() == 3 then
      pn("{#кот|Кот} сидел посреди коридора и с упоением грыз колбасу.")
    end
    if visits() == 4 then
      pn("Кот куда-то делся. Похоже, его кто-то спугнул - недогрызенный кусок колбасы остался лежать посреди коридора.")
    end
    if visits() == 5 or visits() == 6 then
      pn("Посреди коридора валяется кусок колбасы, недоеденной котом.")
    end
    if visits() == 7 then
      pn("Кусок колбасы пропал. Видимо, Гегель вернулся за своей добычей.")
    end
  end;
  way = { "lab", "kitchen", "cabinet", "toilet", "storage" };
}:with {
  obj {
    nam = "#кот";
    act = function(s)
      p("Кот лениво посмотрел на Валерку. Увидев, что у Валерки нет ничего вкусненького, он потерял к нему интерес.")
    end;
    used = function (s,t)
      if t^"Фотоаппарат" then
        p[[Осторожно, стараясь не спугнуть кота, Валерка навел камеру и нажал спуск. Должно получиться отличное фото!]]
        get_achievement('cat');
      else
        p"Кот никак не отреагировал на продемонстрированный ему предмет."
      end
    end;
  };
}

room {
  nam = "kitchen";
  disp = "Кухня";
  decor = [[У окна стоял большой обеденный {#стол|стол}. Справа - несколько шкафов с посудой. В углу белела {#мойка|мойка}.]];
  way = { "corridor" };
}:with {
  obj {
    nam = "#мойка";
    act = [[Это была обыкновенная кухонная мойка. Из крана лениво капала вода.]];
    used = function (s,w)
      if w^"Колба" then
        p"Валерка подставил колбу под кран и покрутил вентиль. Бесполезно - вода и не собиралась течь. Раздосадованный, Валерка отошел от мойки."
      elseif w^"Проявитель" or w^"Фиксаж" then
        p"Высыпать реактивы прямо в раковину казалось многобещающей идеей. Но, поразмыслив, Валерка решил отказаться от этой затеи."
      else
        p"В эту мойку посуду складывают. Лучше не экспериментировать с ней."
      end
    end,
  };
  obj {
    nam = "#стол";
    act = function(s)
      p"Стол был заставлен посудой. "
      if s:closed() then
        p"Кроме всего прочего, на столе стояла пустая химическая колба."
        open(s)
      end
    end;
    used = function (s,w)
      p"На этом столе лучше ничего не оставлять. Правда, не стоит. Не надо."
    end;
  }:with{"Колба"}:close();
}

room {
  is_darkness = true;
  nam = "toilet";
  disp = "Туалет";
  decor = function()
    if here().is_darkness then
      p"В туалете было темно. Где-то возле входа точно был {#выключатель|выключатель}."
    else
      p"Убранство туалета было более чем спартанским: {#раковина|раковина} для мытья рук, {#зеркало|зеркало} и, конечно же, {#унитаз|унитаз}.^На стене возле входа - {#выключатель|выключатель}."
    end
  end;
  way = { "corridor" };
}:with {
  obj {
    nam = "#раковина";
    act = "Раковина была именно такой, какую ожидаешь увидеть в туалете. Кран закрывался неплотно, и из него капала вода.";
    used = function (s,w)
      if w^"Колба" then
        if w.with_water then
          p"Подумав, Валерка вылил воду из колбы."
          w.with_water = false
        elseif w.is_broken then
          p"Валерка попытался набрать в колбу воды, но быстро обнаружил, что колба протекает. Через несколько секунд колба вновь оказалась пустой."
        else
          p"Валерка набрал в колбу воды из-под крана."
          w.with_water = true
        end
      elseif w^"Проявитель" or w^"Фиксаж" then
        p"Высыпать реактивы прямо в раковину казалось многобещающей идеей. Но, поразмыслив, Валерка решил отказаться от этой затеи."
      else 
        p"Раковину лучше оставить в покое."
      end
    end,
  };
  obj {
    nam = "#зеркало";
    act = "Зеркало было старым, с треснувшим уголком и в потеках.";
    used = function(s,t)
      if (t^"Фотоаппарат" and not here().is_darkness) then
        p[[Валерка поправил прическу, навел фотоаппарат в зеркало и осторожно нажал на спуск. Автопортрет должен выйти на славу.]]
        get_achievement('selfie');
      else
        p[["Предметы, отраженные в зеркале, ближе, чем кажутся" -- ни к селу ни к городу вспомнил Валерка.]]
      end
    end
  };
  obj {
    nam = "#унитаз";
    act = "Венец сантехнической мысли - фаянсовый трон.";
    used = function (s,w)
      if w^"Колба" then
        if w.with_water then
          p"Подумав, Валерка вылил воду из колбы."
          w.with_water = false
        else
          p"Набрать воды из унитаза у Валерки не вышло - колба не подошла по габаритам."
        end
      elseif w^"Проявитель" or w^"Фиксаж" then
        p"Высыпать реактивы прямо в унитаз казалось многобещающей идеей. Но Валерка, подумав немного, решил отказаться от этой затеи."
      else
        p[["Нет, не стоит бездумно совать вещи в унитаз." -- спохватился Валерка.]]
      end
    end;
  };
  obj {
    nam = "#выключатель",
    act = function(s)
      if here().is_darkness then
        p"Валерка включил свет. Некоторое время он привыкал к нему, прищурив глаза."
        here().is_darkness = false
        s:open()
      else
        p"Валерка щелкнул выключателем, и свет погас."
        here().is_darkness = true
        s:close()
      end
    end;
    used = function (s,w)
      p"Выключатель никак не реагировал на продемонстрированный ему предмет."
    end;
    obj = { "Швабра" };
  }:close()
}

room {
  nam = "achievements";
  noinv = true;
  disp = "Достижения";
  dsc = function()
    local achievements = prefs.photo
    if (achievements.cat) then pn("^1. " .. fmt.u(achievement_names["cat"]) .. "^ --  cделал котофото. Или фотокото.") else pn "^1. ???" end
    if (achievements.selfie) then pn("^2. " .. fmt.u(achievement_names["selfie"]) .. "^ -- cделал селфи в туалете, опередив моду на два десятилетия.") else pn "^2. ???" end
    if (achievements.profi) then pn("^3. " .. fmt.u(achievement_names["profi"]) .. "^ -- проявил пленку, не допустив ни одной ошибки.") else pn "^3. ???" end
    if (achievements.reader) then pn("^4. " .. fmt.u(achievement_names["reader"]) .. "^ -- пролистал все книги в кабинете Петра.") else pn "^4. ???" end
    if (achievements.mystery) then pn("^5. " .. fmt.u(achievement_names["mystery"]) .. "^ -- нашел загадочную записку.") else pn "^5. ???" end
    pn ()
    pn (("{@restart|Вернуться к журналу}"))
  end
}

room {
  nam = "storage";
  disp = "Кладовая";
  decor = [[Среди гор пыльного хлама гордо возвышался {#шкаф|деревянный шкаф}. Рядом с ним - {#ящик|ящик с инструментами}.]];
  way = { "corridor" };
}:with {
  obj {
    nam = "#шкаф";
    act = function(s)
      if _("Кассета с пленкой").photo_taken and s:closed() then
        p"Порывшись в шкафу, Валерка нашел несколько реактивов для обработки фотопленки."
        open(s)
      else
        p"Шкаф был заполнен разнообразными химикатами: в пакетиках, банках и коробках."
      end
    end;
    used = function (s,w)
      p"Шкаф был забит химикатами буквально под завязку."
    end;
  }:with{"Фиксаж","Проявитель"}:close();
  obj {
    nam = "#ящик";
    act = function(s)
      if s:closed() then
        p"Порывшись в ящике, Валерка обнаружил моток изоленты. Синей, конечно же."
        open(s)
      else
        p"Повторный осмотр ящика не дал никаких результатов."
      end
    end;
    used = function (s,w)
      p"Сама мысль о том, чтобы положить что-нибудь в этот грязный и пыльный ящик, приводила в ужас."
    end;
  }:with{"Изолента"}:close();
};

room {
  nam = "cabinet";
  disp = "Кабинет Петра";
  decor = "Сквозь неплотно прикрытые шторы пробивался свет, освещая рабочий стол Петра, расположенный прямо у окна. Вдоль стен были расставлены {#шкаф|шкафы} с книгами и документами. В углу разместился {#фотостол|стол} с фотографическими принадлежностями.";
  way = { "corridor" };
  obj = { "Фотоаппарат" };
  is_closed = true;
  onenter = function(s, t)
    if have "Ключ" then
      p"Повозившись пару минут с заедающим замком, Валерка все же попал в кабинет."
      s.is_closed = false;
    end
    if s.is_closed then
      p"Валерка подергал ручку двери, но безрезультатно. Кабинет был заперт."
      _("Пётр").should_give_key = true
      return false
    end
  end;
}:with{
  obj {
    nam = "#шкаф";
    act = function(s)
      p"Валерка наугад вытащил книгу из шкафа. "
      local current_book = table.remove(book, 1)
      p(current_book)
      table.insert(book, current_book)
      p"Пролистав книгу, Валерка поставил ее на место."
      if paperf then
        p"^Из книги выпал какой-то обрывок бумаги."
        place("Инструкция")
        paperf = false
      end
      bk = bk + 1
      if bk == 5 then
        get_achievement("reader")
      end
    end;
    used = function (s,w)
      p"В книжном шкафу должны быть только книги. В крайнем случае - журналы."
    end;
  };
  obj {
    nam = "#фотостол";
    act = function(s)
      p"На столе вперемешку лежали кюветы, валики, какие-то банки и прочий хлам. "
      if _("Кассета с пленкой").photo_taken and s:closed() then
        p"Порывшись в завалах на столе, Валерка извлек две стеклянные банки и поставил их на расчищенное от хлама место. Там же нашелся и проявочный бачок для фотопленки."
        open(s)
      end
    end;
    used = function (s,w)
      p"Оставив что-нибудь на этом столе, Валерка вряд ли смог бы это потом найти."
    end;
  }:with{"Банка1", "Банка2", "Бачок для проявки"}:close()    
}

room {
  nam = "finalscene";
  noinv = true;
  disp = "...";
  dsc = [[
  Пётр нетерпеливо выхватил пленку: ^
  -- Сейчас, сейчас мы наконец узнаем, что по ту сторону портала!^
  Но по мере просмотра пленки лицо Петра принимало все более хмурое выражение. Отложив пленку, он взял фотошвабру. Осмотрев её, Пётр повернулся к Валерке и саркастически произнес:^
  -- А скажите-ка мне, младший лаборант Валерий, ...^
  Такое вступление не предвещало ничего хорошего.^
  -- ...знакомы ли вы с основами фотографии?]];
  decor = "{#конец|-- Конечно, знаком. Я еще со школы...}";
}: with{
  obj {
    nam = "#конец";
    act = function()
      walk("gameover")
    end
  }
};

room {
  nam = "gameover";
  noinv = true;
  disp = "...";
  dsc = function()
  pn[[
  -- Конечно, знаком. Я еще со школы...^
  -- Это понятно, что со школы. Как я мог сомневаться?^
  Пётр ткнул Валерке под нос швабру. Объектив примотанного к ней фотоаппарата был надежно закрыт крышкой.^
  -- И что же, скажите на милость, вы могли ВОТ ЭТИМ сфотографировать? Неужели в Вашу голову даже не пришла мысль...^
  Не дожидаясь окончания фразы, Валерка выскочил за дверь. Пётр, несмотря на вспыльчивый характер, был отходчивым. Главное - переждать где-нибудь эти пять минут...
  ]]
  pn(fmt.c("^КОНЕЦ"))
  p(fmt.em([[^^
  Автор: Сергей Можайский (techniX)^
  Графика: https://ru.wikipedia.org/wiki/Смена-8
  ]]))
  end;
  decor = function()
    local achievements = prefs.photo
    pn("{#достижения|Достижения} (открыто " .. tostring(achievements.total) .. " из 5)");
  end
}:with{
  obj {
    nam = "#достижения";
    act = function()
      walk("achievements")
    end
  }
}
