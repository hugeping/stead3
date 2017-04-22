--$Name: Структура$
--$Version: 0.9$
--$Author: Андрей Лобанов$
--$Info: Специально для\nINSTEADOSE V: Пятое измерение$

require 'fmt'
require 'noinv'
require 'snd'

game.act = 'Не работает.'
game.use = 'Это не поможет.'
game.inv = 'Странная штука.'
game.pic = 'gfx/struct.png'

-- Объект для подстановки. Нужен для принудительных переводов строк в dsc-объектов.
obj {
   nam = '$',
   act = function(s, w)
      return w
   end,
}

declare {
   titles = '',
}

global {
   minutes = 23,
   plants_act = 'Растения выглядят довольно интересно. Толстые зелёные стволы, напоминающие стебли какой-нибудь земной травы, увеличенные в несколько десятков раз, с многочисленными зелёными же ветвями, усеянными листьями неожиданно похожими на берёзовые. Растения эти, извиваясь, как будто пытаются занять весь объем оранжереи.',
   password_photo = false,
   plant_photo = false,
   record = false,
   record2_photo = false,
   sky_photo = false,
   stable_portal = false,
   e = -1,
}

function init()
   minutes = 23
   room.interface = false
   take 'computer'
   password_photo = false
   plant_photo = false
   record = false
   record2_photo = false
   sky_photo = false
   stable_portal = false
   e = -1
   titles = '^^' .. fmt.b 'Автор игры' .. ': Андрей Лобанов^' .. fmt.b 'Автор INSTEAD' .. ': Пётр Косых^' .. fmt.b 'Музыка' .. ': Mellow-D -- Appelsap track 1^' .. fmt.b 'Тестирование' .. ': Пётр Косых, Сергей Можайский, Kerbal.'
end

function time()
   local h = math.floor(minutes / 60)
   local m = minutes - h * 60
   h = tostring(h)
   m = tostring(m)
   if string.len(h) < 2 then
      h = "0" .. h
   end
   if string.len(m) < 2 then
      m = "0" .. m
   end
   return h .. ":" .. m
end

function mdec(t)
   if minutes > 0 then
      minutes = minutes - t
   end
end

obj {
   nam = 'computer',
   recorded = 0,
   disp = 'компьютер',
   inv = function()
      walk 'computer_interface'
   end,
   use = function(s, w)
      if w ^ 'inscription' then
	 if not password_photo then
	    _'computer_interface'.files = true
	    place('word', 'computer_interface')
	    password_photo = true
	    mdec(1)
	    return 'Без особой надежды я навёл камеру компьютера на надпись и попробовал запустить переводчик. Без сетевых ресурсов попытка перевода заняла некоторое время. Результат оказался печальным и предсказуемым: "Невозможно определить язык".'
	 else
	    return 'Фотография надписи у меня уже есть.'
	 end
      elseif w ^ 'record' then
	 return 'Мой компьютер ничем не поможет с этой пластинкой.'
      elseif w ^ 'plants' then
	 if not plant_photo then
	    _'computer_interface'.files = true
	    plant_photo = true
	    place('plant_photo', 'computer_interface')
	    mdec(2)
	    return 'Я сфотографировал растения. Любая новая информация пойдёт на благо.'
	 else
	    return 'Я уже сфотографировал растения.'
	 end
      elseif w ^ 'keyboard' then
	 if password_photo then
	    if not _'hall_door'.opened then
	       _'hall_door'.opened = true
	       enable '#central'
	       mdec(1)
	       return 'Символы на клавиатуре такие же, как на стене в жилом комплексе. Я попробовал ввести надпись с фотографии и дверь открылась. Довольно странно.'
	    else
	       return 'Дверь уже открыта.'
	    end
	 else
	    return 'Вряд ли я смогу чего-то добиться таким образом.'
	 end
      elseif w ^ 'reader2' and where 'record2' ^ 'read_device' then
	 if not record2_photo then
	    record2_photo = true
	    place('table', 'computer_interface')
	    mdec(1)
	    return 'Я заснял на камеру эту таблицу. Лишней для лингвистов эта информация не будет.'
	 else
	    return 'Я уже заснял таблицу.'
	 end
      elseif w ^ 'sky' then
	 if not sky_photo then
	    sky_photo = true
	    place('sky_photo', 'computer_interface')
	    mdec(1)
	    return 'Я поднял объектив встроенной в компьютер камеры так, чтобы в кадр попали и небо и часть структуры. Это будет отличным доказательством того, что структура не покрывает всю поверхность планеты.'
	 else
	    return 'У меня уже есть фотография неба.'
	 end
      else
	 return 'Мой компьютер тут бесполезен.'
      end
   end,
   life = function(s)
      if s.recorded < 5 then
	 mdec(1)
	 s.recorded = s.recorded + 1
      end
      if s.recorded == 5 then
	 s.recorded = 6
	 _'computer_interface'.files = true
	 place('translate1', 'computer_interface')
	 record = true
	 p 'Компьютер пропищал, сигнализируя о завершении перевода.'
	 lifeoff(s)
      end
   end,
}

-- Объекты, формирующие список файлов
obj {
   nam = 'plant_photo',
   dsc = '• {Фотография растений}{$|^}',
   act = function()
      walk 'plant_photo_file'
   end,
}

obj {
   nam = 'word',
   dsc = '• {Фото надписи из жилого комплекса}{$|^}',
   act = function()
      walk 'word_file'
   end,
}

obj {
   nam = 'translate1',
   dsc = '• {Перевод видеозаписи}{$|^}',
   act = function()
      walk 'translate1_file'
   end,
}

obj {
   nam = 'table',
   dsc = '• {Таблица}{$|^}',
   act = function()
      walk 'table_file'
   end,
}

obj {
   nam = 'sky_photo',
   dsc = '• {фотография неба}{$|^}',
   act = function()
      walk 'sky_photo_file'
   end,
}

-- Интерфейс компьютера
room {
   nam = 'computer_interface',
   noinv = true,
   interface = true,
   files = false,
   f = '',
   disp = 'компьютер',
   decor = function(s)
      local v =  'В правом верхнем углу экрана виден таймер, отсчитывающий время до закрытия портала: ' .. time() .. '.'
      if s.files then
	 v = v .. '^^Ниже расположен список доступных файлов:'
      end
      return v
   end,
   onenter = function(s, f)
      if not f.interface then
	 s.f = f
      end
   end,
   obj = {
      obj {
	 nam = 'close_computer',
	 pri = 1,
	 dsc = '{$|^}{Закрыть}.',
	 act = function()
	    walk(here().f)
	 end,
      },
   },
}

-- Объект для возвращения на основной экран компьютера.
obj {
   nam = 'back',
   dsc = '{Назад}',
   act = function()
      walkout()
   end,
}

-- Содержимое файлов
room {
   nam = 'word_file',
   noinv = true,
   interface = true,
   disp = 'фото',
   dsc = 'На фотографии изображена надпись со стены жилого комплекса. Надпись сделана очень давно, но краска до сих пор выглядит достаточно яркой. Даже под слоем пыли, которая осела везде, где только можно. Содержимое же этой надписи неясно: используется неизвестный алфавит, больше всего похожий на смесь клинописи с геометрическими примитивами.',
   obj = { 'back' },
}

room {
   nam = 'translate1_file',
   noinv = true,
   seen = false,
   interface = true,
   disp = 'перевод видеозаписи',
   dsc = function(s)
      local v = '"Отмена больший промежуток времени [ПРОПУЩЕННАЯ ЧАСТЬ ПЕРЕВОД НЕВОЗМОЖЕН] Увеличение число элементы следствие нуль [ПРОПУЩЕННАЯ ЧАСТЬ ПЕРЕВОД НЕВОЗМОЖЕН] Исход туннели множества отключение закрытых. Пустота через искажение тридцать четыре больше нуля отклик. Цикл пустота через искажение тридцать четыре [ПРОПУЩЕННАЯ ЧАСТЬ ПЕРЕВОД НЕВОЗМОЖЕН] поиск дверь."'
      if not s.seen then
	 s.seen = true
	 v = v .. '^^Не так уж и плохо для фонетического анализа незнакомого языка. Надо будет провести анализ записи в институте, если я смогу вернуться.'
      end
      return v
   end,
   obj = { 'back' },
}

room {
   nam = 'plant_photo_file',
   noinv = true,
   interface = true,
   disp = 'фото растений',
   dsc = function()
      return 'Фотография сделана в оранжерее возле жилого комплекса.^^' .. plants_act
   end,
   obj = { 'back' },
}

room {
   nam = 'table_file',
   noinv = true,
   interface = true,
   disp = 'фотография таблицы',
   dsc = 'На фотографии изображена таблица на экране прибора, похожего на компьютер. Таблица заполнена разнообразными значками, как и встреченные мной ранее надписи, напоминающими смесь клинописи и геометрических примитивов.',
   obj = { 'back' },
}

room {
   nam = 'sky_photo_file',
   noinv = true,
   interface = true,
   disp = 'фотография неба',
   dsc = 'На фотографии видно синее небо без единого облачка. С боку нависает часть структуры, закрывающей небо рваным краем из балок и арматуры.',
   obj = { 'back' },
}

-- Мир игры
room {
   seen = false,
   nam = 'main',
   disp = 'генераторная',
   dsc = function(s)
      local v = ''
      if not s.seen then
	 s.seen = true
	 v =  'Чёрт. Голова просто раскалывается. Что же со мной было?.. Не помню. Кажется, мы с Сергеичем шли в структуру. Но я не помню, как мы возвращались...^^В голове начало проясняться. Время! Сколько времени я лежу здесь? Сколько осталось до закрытия портала? Я поднялся на ноги. Стоять пока тяжеловато, но в целом состояние сносное.^^'
      end
      v = v .. 'Я нахожусь в генераторной.'
      return v
   end,
   exit = function(s, w)
      if not _'artefact'.fixed and where 'artefact' ^ 'screw' then
	 place('artefact', s)
      end
   end,
   obj = {
      obj {
	 seen = false,
	 dsc = 'Посреди помещения стоит пилон {генератора}.',
	 act = function(s)
	    if not s.seen then
	       s.seen = true
	       place('hatch', s)
	       return 'Судя по форме, это генератор родом из ранней истории структуры. Во фронтальной панели есть небольшой лючок.'
	    else
	       return 'Древний генератор. Явно нерабочий.'
	    end
	 end,
      },
      obj {
	 nam = 'screw',
	 disp = 'винт',
	 dsc = function(s)
	    if where(s) ^ 'terminals' then
	       return 'В клеммах зажат {винт}.'
	    else
	       return 'На полу лежит {винт}.'
	    end
	 end,
	 tak = function(s)
	    if where(s) ^ 'terminals' then
	       p 'Я попробовал вытащить винт из щитка, но он сильно нагрелся.'
	       return false
	    else
	       return 'Я взял винт.'
	    end
	 end,
	 inv = 'Металлический винт примерно пяти сантиметров в длину.',
	 use = function(s, w)
	    if w ^ 'terminals' then
	       place(s, w)
	       _'door'.op = true
	       mdec(1)
	       return 'Я вставил на место предохранителя винт. Надеюсь, я не устрою пожар в запертой комнате.'
	    else
	       return 'Винт не поможет в этой ситуации.'
	    end
	 end,
      }:disable(),
      obj {
	 nam = 'door',
	 op = false,
	 dsc = function(s)
	    if s.op then
	       return 'Входная {дверь} открыта.'
	    else
	       return 'Входная {дверь} закрыта.'
	    end
	 end,
	 act = function(s)
	    if s.op then
	       if disabled 'hall' then
		  enable 'hall'
		  return 'Я открыл дверь. Хорошо, что дверь запитана не от этого генератора.'
	       else
		  return 'Обычная дверь.'
	       end
	    else
	       return 'Я попытался сдвинуть дверь, но она не поддалась ни на миллиметр.'
	    end
	 end,
      },
      obj {
	 nam = 'portal2',
	 dsc = 'В проёме двери находится {портал}.',
	 act = function()
	    e = 1
	    walk 'end1'
	 end,
      }:disable(),
      obj {
	 seen = false,
	 nam = 'switchboard',
	 dsc = function()
	    if disabled 'door' then
	       return 'Рядом с порталом находится распределительный {щиток}'
	    else
	       return 'Рядом с дверью находится распределительный {щиток}.'
	    end
	 end,
	 act = function(s)
	    local v = ''
	    if s:closed() then
	       s:open()
	       if not s.seen then
		  s.seen = true
		  v = v ..  'Щиток закрывается удобной защёлкой. '
	       end
	       v = v .. 'Я открыл щиток.'
	    else
	       s:close()
	       v = v .. 'Я закрыл щиток.'
	    end
	    return v
	 end,
	 obj = {
	    obj {
	       nam = 'fuse',
	       disp = 'предохранитель',
	       dsc = 'В щитке установлен {предохранитель}.',
	       tak = function()
		  place('terminals', 'switchboard')
		  return 'Я с трудом вынул предохранитель.'
	       end,
	       inv = 'Предохранитель явно сгорел. Представляет он собой трубку, сантиметров пять в диаметре.',
	       use = 'Сгоревший предохранитель бесполезен.',
	    },
	 },
      }:close(),
   },
   way = { 'operator_room', 'hall' },
}

obj {
   opened = false,
   nam = 'hatch',
   dsc = 'В его фронтальной панели есть небольшой {лючок}.',
   act = function(s)
      if not s.opened then
	 return 'Лючок крепко удерживается на месте винтом.'
      else
	 return 'Управляющая схема явно вышла из строя. Мне её не починить.'
      end
   end,
}

obj {
   nam = 'terminals',
   dsc = 'В щитке видны {клеммы}.',
   act = 'Клеммы-зажимы для предохранителя.',
}

room {
   nam = 'operator_room',
   disp = 'операторская',
   dsc = 'Тесная комната, рассчитанная на двух человек.',
   obj = {
      obj {
	 dsc = 'Вдоль смежной с генераторной стены тянется {пульт} управления.',
	 act = 'От пульта осталось только шасси. Все приборы и органы управления с него сняты.',
      },
      obj {
	 taken = false,
	 dsc = 'Прозрачная перегородка, отделяющая операторскую от генераторной, разбита. Пол устилают многочисленные {осколки}.',
	 act = function(s)
	    if not s.taken then
	       s.taken = true
	       take 'glass_piece'
	       return 'Я взял осколок покрупнее.'
	    else
	       return 'Материал похож на стекло, но гораздо крепче. Его уже исследовали сотрудники нашего института, но ничего конкретного про него рассказать не смогли. Кроме того, что он очень крепкий. Так что что бы ни разбило эту перегородку, оно было очень сильным. Оптимизма это знание мне особо не прибавляет.'
	    end
	 end,
      },
      obj {
	 seen = false,
	 nam = 'unit',
	 dsc = 'В углу стоит {агрегат} неизвестного назначения.',
	 act = function(s)
	    if not s.seen then
	       s.seen = true
	       return 'В корпусе есть небольшой лючок, держащийся на защёлке.'
	    elseif s:closed() then
	       s:open()
	       return 'Я открыл лючок.'
	    else
	       return 'Невозможно определить назначение большего числа устройств, встречающихся в структуре. Например, этого агрегата.'
	    end
	 end,
	 obj = {
	    obj {
	       taked = false,
	       nam = 'wires',
	       dsc = 'Внутри его находятся многочисленные электронные схемы. Поверх них идёт пучок разноцветных {проводов}.',
	       act = 'Я попытался вырвать один провод, но мне не хватает на это силы.',
	    },
	 },
      }:close(),
   },
   way = { 'main' },
}

obj {
   nam = 'glass_piece',
   disp = 'осколок',
   inv = 'Осколок прозрачного материала похожего на стекло.',
   use = function(s, w)
      if w ^ 'hatch' and disabled 'screw' then
	 w.opened = true
	 enable 'screw'
	 mdec(3)
	 return 'Ровной кромкой осколка мне удалось открутить крышку.'
      elseif w ^ 'wires' and not w.taked then
	 w.taked = true
	 take 'wire'
	 mdec(2)
	 return 'Острой кромкой осколка я смог разрезать изоляцию одного провода, а потом и перепилить жилы.'
      elseif w ^ 'plants' and not have 'piece_of_plant' then
	 take 'piece_of_plant'
	 mdec(1)
	 return 'Я несколько опрометчиво отрезал несколько листков с растений. Надеюсь, они не ядовиты.'
      else	    
	 return 'Осколок мне тут не поможет.'
      end
   end,
}

obj {
   nam = 'wire',
   disp = 'провод',
   inv = 'Кусок провода из неизвестного сплава.',
   use = function(s, w)
      if w ^ 'artefact' and where 'artefact' ^ 'screw' then
	 w.fixed = true
	 disable(s)
	 disable 'door'
	 disable 'hall'
	 enable 'portal2'
	 return 'Я крепко примотал проводом артефакт к винту. Спустя некоторое время артефакт поменял свой цвет на бледно-зелёный и в проёме двери открылся портал в неизвестный мир.'
      elseif w ^ 'screw' and where 'screw' ^ 'terminals' then
	 return 'Это может быть опасно. Цепь под напряжением.'
      else
	 return 'Провод тут бесполезен.'
      end
   end,	 
}

room {
   seen = false,
   nam = 'hall',
   disp = 'зал',
   dsc = function(s)
      if not s.seen then
	 s.seen = true
	 return 'За дверью оказался просторный зал с высоким потолком, теряющимся в темноте. Для чего был создан этот большой пустой зал -- загадка. До сих пор таких помещений не встречалось и для связки помещений использовались широкие, но всё таки коридоры.'
      else
	 return 'Я нахожусь в просторном зале. Потолок теряется в тёмной вышине.'
      end
   end,
   onenter = function()
      snd.music('mus/appelsap_track_1.ogg')
   end,
   obj = {
      obj {
	 seen = false,
	 opened = false,
	 nam = 'hall_door',
	 dsc = 'В холле есть две арки, ведущие в другие помещения и {дверь}.',
	 act = function(s)
	    local v
	    if not s.opened then
	       v = 'Дверь заперта.'
	       if not s.seen then
		  s.seen = true
		  enable 'keyboard'
		  v = v .. ' Рядом с дверью есть небольшая клавиатура с экраном.'
	       end
	       return v
	    else
	       return 'Дверь открыта.'
	    end
	 end,
      },
      obj {
	 nam = 'keyboard',
	 dsc = 'Рядом с дверью на расположена небольшая {клавиатура}.',
	 act = 'Похоже на кодовый замок. Символы на клавишах напоминают смесь клинописи и геометрических примитивов.',
      }:disable(),
   },
   way = {
      'main',
      path { 'дверь слева', after='завод', 'factory' },
      path { 'дверь справа', after='оранжерея', 'greenhouse' },
      path { '#central', 'центральная дверь', after='лаборатория', 'laboratory' }:disable(),
   },
}:disable()

room {
   seen = false,
   nam = 'factory',
   disp = '"завод"',
   dsc = function(s)
      if not s.seen then
	 s.seen = true
	 return 'За проёмом оказалось помещение типа "завод". Доподлинно неизвестно назначение этих сооружений, но они попадаются исследователям то и дело. Это гигантское помещение, уходящее на многие сотни метров во все стороны. Вдоль него тянется мост без перил, на котором я и стою.'
      else
	 return 'Я нахожусь на "заводе".'
      end
   end,
   obj = {
      obj {
	 nam = 'bridge',
	 seen = false,
	 dsc = '{Мост} пересекает весь завод.',
	 act = function(s)
	    local v = 'Широкий мост, по которому тем не менее страшновато ходить, так как у него нет перил.'
	    if not s.seen then
	       s.seen = true
	       enable 'f_ladder'
	       v = v .. '^^Осмотрев внимательно мост, я заметил у входа лестницу, ведущую вниз.'
	    end
	    return v
	 end,
      },
      obj {
	 nam = 'f_ladder',
	 seen = false,
	 dsc = 'Возле входа с моста вниз уходит маленькая {лестница}.',
	 act = function(s)
	    if not s.seen then
	       s.seen = true
	       enable '#вниз'
	    end
	    return 'Металлическая лестница. Спускаться по ней может быть опасно.'
	 end,
      }:disable(),
   },
   way = {
      'hall',
      'control_room',
      path{ '#вниз', 'вниз', 'd_factory' }:disable(),
   },
}

room {
   seen = false,
   nam = 'control_room',
   disp = 'комната контроля',
   dsc = function(s)
      if not s.seen then
	 s.seen = true
	 return 'Дверь на другой стороне моста привела меня в небольшую комнату с большим количеством разнообразных приборов и органов управления. Судя по всему, это комната управления заводом.'
      else
	 return 'Я нахожусь в небольшой комнате контроля.'
      end
   end,
   obj = {
      obj {
	 nam = 'devices',
	 dsc = 'Почти всё пространство комнаты занимают разнообразные {приборы}.',
	 act = function(s)
	    if not have 'record' and not have 'record2' and not seen('reader', s) then
	       return 'Так странно, что в операторской генератора, которая находится неподалёку, сняли всё, что только могли, а это помещение выглядит нетронутым.'
	    else
	       enable 'reader'
	       return 'Среди многочисленных приборов я заметил щель, подходящую по размеру, оптическому носителю, найденному в жилом блоке.'
	    end
	 end,
      },
      obj {
	 seen = false,
	 nam = 'reader',
	 dsc = function(s)
	    if not s.seen then
	       s.seen = true
	       return 'Среди них видна {щель}, похожая на приёмник оптических носителей навроде того, что у меня.'
	    else
	       return 'Среди них видна {щель} считывателя.'
	    end
	 end,
	 act = function(s)
	    if not where 'record' ^ 'reader' and not where 'record2' ^ 'reader' then
	       return 'Щель пуста.'
	    else
	       return 'Из щели торчит краешек пластинки.'
	    end
	 end,
      }:disable(),
      obj {
	 pressed = false,
	 nam = 'button',
	 dsc = 'Рядом с щелью мигает зелёным цветом небольшая {кнопка}.',
	 act = function(s)
	    if where 'record' and where 'record' ^ 'reader' then
	       if not s.pressed then
		  s.pressed = true
		  lifeon 'computer'
		  mdec(5)
		  return 'Я нажал на кнопку. Над пультом появилось трёхмерное изображение. Оно подёргивалось и немного расплывалось, но не распознать в нём человека было нельзя. Он стоял, отвернувшись куда-то в сторону. Я как можно скорее навёл камеру компьютера на картинку и начал съёмку. Фигура повернулась ко мне лицом и из динамиков раздался голос. Говорил он на незнакомом языке, в котором смутно угадывалось схожее с испанским произношение. Я не понял ни слова, но продолжал запись до тех пор, пока человек не закончил говорить, тяжело вздохнул и выключил записывающее устройство.^^Я остановил запись. Особенно ни на что не надеясь, я запустил переводчик с фонетическим анализатором для обработки этого видеофайла.'
	       else
		  return 'Я нажал на кнопку, но ничего не произошло.'
	       end
	    elseif where 'record2' ^ 'reader' then
	       return 'Я нажал на кнопку, но ничего не произошло.'
	    end
	 end,
      }:disable(),
   },
   way = {
      'factory',
      path { 'дверь', after='открытое пространство', 'side' }
   },
}

room {
   nam = 'd_factory',
   seen = false,
   entered = false,
   disp = '"завод"',
   dsc = function(s)
      if from() ^ 'factory' and not s.entered then
	 s.entered = true
	 local v =  'Осторожно перебирая лестничные перекладины, я спустился.'
	 if not s.seen then
	    s.seen = true
	    v = v .. ' Снизу от вида завода захватывает дух ещё сильнее.'
	 end
	 return v
      else
	 return 'Я нахожусь в сердце "завода".'
      end
   end,
   onenter = function(s, f)
      if f ^ 'factory' then
	 s.entered = false
      end
   end,
   obj = {
      obj {
	 nam = 'machines',
	 dsc = 'Меня окружают исполинские {машины} неизвестного назначения.',
	 act = 'Есть в них что-то, вызывающее трепет. Невольно преисполняешься уважением к их создателям. Что интересно, сама структура, имея явно искусственное происхождение, таких чувств не вызывает, наоборот заставляет чувствовать себя неуютно.',
      },
   },
   way = {
      path{ 'наверх', 'factory' },
      path{ 'вглубь "завода"', 'in_factory' },
   },
}

room {
   nam = 'in_factory',
   disp = '"завод"',
   iter = 0,
   enter = function(s, f)
      if f ^ 'd_factory' then
	 disable 'd_factory'
	 enable '#inside'
	 s.iter = 0
      else
	 s.iter = s.iter + 1
	 if s.iter == 3 then
	    if disabled 'artefact' then
	       enable 'artefact'
	    end
	    enable 'd_factory'
	    disable '#inside'
	 end
      end
   end,
   obj = {
      'machines',
      obj {
	 fixed = false,
	 nam = 'artefact',
	 disp = 'артефакт',
	 dsc = function(s)
	    if where(s) ^ 'd_factory' then
	       return 'Возле очередного исполина лежит какой-то {предмет}.'
	    elseif where(s) ^ 'screw' then
	       if not s.wixed then
		  return 'Рядом с винтом расположен {артефакт}. Того и гляди он упадёт на пол.'
	       else
		  return 'К винту крепко привязан {артефакт}.'
	       end
	    elseif where(s) ^ 'main' then
	       return 'На полу рядом со щитком лежит {артефакт}.'
	    else
	       return 'Рядом с порталом лежит {артефакт}.'
	    end
	 end,
	 tak = function(s)
	    if not stable_portal then
	       if where(s) ^ 'd_factory' then
		  return 'Это оказался артефакт. В точности такой же, какой на Земле используется для открытия порталов.'
	       else
		  if not s.fixed then
		     return 'Я взял артефакт.'
		  else
		     p 'Артефакт крепко привязан и я не могу его взять.'
		  end
	       end
	    else
	       p 'Артефакт как будто прирос к полу. Мне не удаётся его хоть не много сдвинуть, не то что взять в руки.'
	       return false
	    end
	 end,
	 inv = 'Артефакт! В точности такой же, как и тот, что на Земле!',
	 use = function(s, w)
	    if w ^ 'portal' and minutes > 0 then
	       stable_portal = true
	       place(s)
	       return 'Я поднёс артефакт к порталу. Диск поменял цвет на бирюзовый. Точно такой же, как в лаборатории при открытии портала в структуру.^^Невидимой силой артефакт вырвало из моих рук и опустило рядом с порталом.'
	    elseif w ^ 'screw' then
	       place(s, w)
	       dprint(where(s).nam)
	       return 'Я пристроил артефакт к винту. Но его надо бы чем-то зафиксировать.'
	    else
	       return false
	    end
	 end,
      }:disable(),
   },
   way = {
      path{ '#inside', 'вглубь', 'in_factory' },
      path{ 'вглубь', 'd_factory' },
   },
}

room {
   seen = false,
   nam = 'side',
   disp = 'открытое пространство',
   dsc = function(s)
      if not s.seen then
	 s.seen = true
	 return 'За дверью оказалось то, чего меньше всего я ожидал увидеть в структуре: открытое пространство. Доказательство того, что структура всё таки покрывает не всю планету. Правда, заодно это подтверждает, что я нахожусь далеко от точки входа и шансы вернуться домой стремятся к нулю.'
      else
	 return 'Я нахожусь над открытым пространством.'
      end
   end,
   obj = {
      obj {
	 nam = 'beam',
	 dsc = 'Прямо передо мной из стены выпирает толстая металлическая {балка}.',
	 act = 'Выглядит крепкой.',
      },
      obj {
	 seen = false,
	 nam = 'surface_obj',
	 dsc = 'Далеко внизу видна {поверхность} этого странного мира.',
	 act = function(s)
	    local v = 'Совершенно голая земля без намёка на растительность. Достаточно удручающее зрелище.'
	    if not s.seen then
	       s.seen = true
	       enable 'trash'
	       v = v .. ' На некотором удалении от края структуры видна гора разного хлама.'
	    end
	    return v
	 end,
      },
      obj {
	 nam = 'trash',
	 dsc = 'Поодаль виднеется гора {хлама}, но подробности не удаётся рассмотреть невооружённым глазом.',
	 act = 'Сколько бы я не напрягал глаза, всё равно выглядит это как наваленные в кучу металлические конструкции неизвестного назначения. Детали же на таком расстоянии рассмотреть не удаётся.',
      }:disable(),
      obj {
	 nam = 'sky',
	 dsc = 'Надо мной раскинулось пронзительно синее {небо}.',
	 act = 'Совсем как на Земле в ясный солнечный день.',
      },
   },
   way = {
      'control_room',
      path { '#down', 'вниз', 'surface' }:disable(),
   },
}

room {
   nam = 'surface',
   seen = false,
   disp = 'поверхность',
   dsc = function(s)
      if not s.seen then
	 s.seen = true
	 return 'Аккуратно, чтобы не обжечь руки и не свалиться, я спустился по верёвке на поверхность. Можно сказать, что это исторический момент -- первый человек ступил на землю этого мира.'
      else
	 return 'Я нахожусь на поверхности.'
      end
   end,
   obj = {
      obj {
	 nam = 'down_trash',
	 dsc = 'В отдалении лежит {гора} хлама.',
	 act = function()
	    local v = 'Просто набор покорёженных и тронутых коррозией металлических конструкций.'
	    if not _'robot'.talked and not _'robot'.talked then
	       enable 'robot'
	       v = v .. 'Из-за этой горы хлама вышла антропоморфная фигура и направилась в мою сторону. От неожиданности я застыл на месте не в силах сдвинуться.'
	    end
	    return v
	 end,
      },
      obj {
	 nam = 'robot',
	 talked = false,
	 dsc = 'Рядом со мной стоит {робот}.',
	 act = function(s)
	    mdec(2)
	    s.talked = true
	    walk 'dialog'
	 end,
      }:disable(),
   },
   way = {
      path { 'наверх', 'side' },
      path { 'за кучу хлама', after = 'ко входу', 'corridor' },
   },
}


dlg {
   nam = 'dialog',
   disp = 'разговор с роботом',
   noinv = true,
   onenter = 'Я подошёл к роботу, тот наклонил голову, следя за моими движениями.',
   phr = {
      { 'Ты кто?', 'Робот ответил на незнакомом языке, напоминающего на слух испанский. К сожалению, я не понял ни слова.',
	{ 'Ты видел где-нибудь поблизости портал?', 'На этот раз робот ограничился короткой фразой, но смысл её я также не уловил.',
	  { 'Это ты меня так по голове приложил?', 'Очередная тирада на испаноподобном языке.',
	    { 'Тебе что-нибудь от меня нужно?', function() p 'Робот ответил что-то на своём тарабарском языке и показал рукой куда-то за кучу хлама, после чего проворно скрылся в структуре.'; enable 'corridor'; disable 'robot'; end }
	  }
	}
      },
   },
}

room {
   nam = 'corridor',
   disp = 'коридор',
   dsc = 'Я нахожусь в коротком коридоре.',
   obj = {
      obj {
	 nam = 'grid',
	 seen = false,
	 dsc = 'Вместо пола здесь используется металлическая {решётка}.',
	 act = function(s)
	    local v = ''
	    if not s.seen then
	       s.seen = true
	       v = v .. 'В отличии от металлоконструкций снаружи, решётка совершенно не разрушена и даже выглядит новой. Такое ощущение, что эта часть структуры появилась значительно позже той, где я очнулся. '
	    end
	    v = v .. 'Сквозь решётку видны какие-то коммуникации: трубы малого диаметра, металлорукава, кабели в мягкой оболочке.'
	    return v
	 end,
      },
      obj {
	 nam = 'walls',
	 seen = false,
	 dsc = 'Стены представляют собой металлические же {панели}.',
	 act = function(s)
	    if not s.seen then
	       s.seen = true
	       enable 'panels'
	    end
	    return 'Совершенно ровные панели кое где имеют какие-то панели управления и небольшие дисплеи.'
	 end,
      },
      obj {
	 nam = 'panels',
	 seen = false,
	 dsc = 'Тут и там имеются какие-то {элементы} управления.',
	 act = function(s)
	    if not s.seen then
	       s.seen = true
	       return 'Я подошёл к одному из этих пультов, но органы управления не обозначены никак. Лучше их не трогать.'
	    else
	       return 'Панели управления неизвестного назначения.'
	    end
	 end,
      }:disable(),
      obj {
	 nam = 'lift_button',
	 seen = false,
	 dsc = 'В стене видна {кнопка}.',
	 act = function(s)
	    if not s.seen then
	       s.seen = true
	       enable 'lift'
	       return 'Я нажал на кнопку. Спустя некоторое время одна из панелей стены отъехала в сторону и передо мной открылся вход в кабину лифта.'
	    else
	       return 'Лифт уже передо мной.'
	    end
	 end,
      },
   },
   way = { 'surface', 'lift' },
}:disable()

room {
   nam = 'lift',
   disp = 'лифт',
   seen = false,
   dsc = function(s)
      if not s.seen then
	 s.seen = true
	 return 'Я зашёл в просторную кабину лифта. Ничем не примечательная металлическая коробка. С потолка, представляющего собой цельную световую панель, льётся мягкий свет.'
      else
	 return 'Я нахожусь в кабине лифта.'
      end
   end,
   obj = {
      obj {
	 nam = 'button_up',
	 dsc = 'Рядом со входом находятся две кнопки: {вверх} и',
	 act = function()
	    if disabled 'corridor' then
	       disable 'level_17'
	       enable 'corridor'
	       return 'Я нажал кнопку и лифт поехал вверх. Через некоторое время двери открылись и я увидел знакомый уже коридор.'
	    else
	       return 'Я нажал на кнопку, но ничего не произошло.'
	    end
	 end,
      },
      obj {
	 nam = 'button_down',
	 seen = false,
	 dsc = '{вниз}.',
	 act = function(s)
	    if disabled 'level_17' then
	       disable 'corridor'
	       enable 'level_17'
	       local v = 'Я нажал на кнопку и лифт поехал вниз. Через некоторое время двери лифта открылись и я увидел '
	       if not s.seen then
		  s.seen = true
		  v = v .. ' обнадёживающую надпись "Уровень 17", сделанную ещё на заре изучения структуры для облегчения ориентирования исследователей. Значит я рядом с точкой входа.'
	       else
		  v = v .. ' надпись "Уровень 17".'
	       end
	       return v
	    else
	       return 'Я нажал на кнопку, но ничего не произошло.'
	    end
	 end,
      },
   },
   way = { 'corridor', 'level_17' },
}:disable()

room {
   nam = 'level_17',
   seen = false,
   disp = 'уровень 17',
   dsc = function(s)
      local v = 'Я нахожусь на семнадцатом уровне.'
      if not s.seen then
	 s.seen = true
	 v = v .. ' Значит я недалеко от портала.'
      end
      return v
   end,
   obj = {
      obj {
	 nam = 'l17',
	 dsc = 'На стене видна {надпись}.',
	 act = 'Надпись гласит "Уровень 17". Уровни нумеровали снизу вверх. Но никому и в голову не приходило, что структура находится под землёй.',
      },
   },
   way = { 'lift', 'enter' },
}:disable()

room {
   nam = 'enter',
   seen = false,
   disp = 'возле портала',
   dsc = function()
      local v = 'Я нахожусь возле портала.'
      if minutes > 0 then
	 v = v .. ' Мне повезло, что я успел до его закрытия. Скорее домой -- делиться увиденным с коллегами.'
      else
	 v = v .. ' Время вышло. Портал уже закрылся и мне уже вряд ли когда-нибудь удастся вернуться домой.'
      end
      return v
   end,
   obj = {
      obj {
	 nam = 'portal',
	 seen = false,
	 dsc = function()
	    if minutes > 0 then
	       return 'Рядом со мной находится арка, в которой мерцает {портал}, ведущий домой.'
	    else
	       return 'В {арке}, через которую всегда открывался портал в структуру, ничего нет.'
	    end
	 end,
	 act = function(s)
	    if minutes > 0 then
	       e = 0
	       walk 'end0'
	    else
	       local v = 'Я опоздал. Теперь мне не вернуться на родную Землю.'
	       if not s.seen then
		  s.seen = true
		  v = v .. ' Как же так?'
	       end
	       return v
	    end
	 end,
      },
   },
   way = { 'level_17' },
}

room {
   seen = false,
   nam = 'greenhouse',
   disp = 'оранжерея',
   dsc = function(s)
      if not s.seen then
	 s.seen = true
	 return 'За дверью меня ждал сюрприз. Во всяком случае, я никак не ожидал увидеть в структуре такое помещение. Оранжерея, заброшенная много лет назад, с одичавшими растениями и густым запахом прелых растений. Похоже, здесь установилась своя экосистема.'
      else
	 return 'Я нахожусь в оранжерее.'
      end
   end,
   obj = {
      obj {
	 nam = 'plants',
	 dsc = 'Всё пространство оранжереи занимают одичавшие и разросшиеся {растения} неизвестных видов.',
	 act = plants_act,
      },
      obj {
	 nam = 'greenhouse_stuff',
	 seen = false,
	 dsc = function(s)
	    if not s.seen then
	       return 'В углу лежат какие-то {обломки}.'
	    else
	       return 'В углу лежат {обломки} инструментов.'
	    end
	 end,
	 act = function(s)
	    if not s.seen then
	       s.seen = true
	       return 'Я осмотрел обломки внимательней. Похоже, когда-то это были инструменты для работы в оранжерее, но по тому, что от них осталось, трудно сказать наверняка.'
	    else
	       return 'Груда изъеденных временем инструментов.'
	    end
	 end,
      },
   },
   way = { 'hall', 'residential_complex' },
}

obj {
   nam = 'piece_of_plant',
   disp = 'листья',
   inv = 'Листья растений, срезанные мной в оранжерее. Возможно, биологам будет интересно на них взглянуть.',
   use = 'Что я могу здесь сделать с помощью этих листьев?',
}

room {
   seen = false,
   nam = 'residential_complex',
   disp = 'жилой комплекс',
   dsc = function(s)
      if not s.seen then
	 s.seen = true
	 return 'Такой тип помещений уже был обнаружен. Существует несколько гипотез о его назначении, но ни одну невозможно ни подтвердить ни опровергнуть. Мне нравится думать, что это жилые комплексы. Правда разумная жизнь в структуре обнаружена не была, но кто-то ведь построил её.'
      else
	 return 'Я нахожусь в жилом комплексе.'
      end
   end,
   obj = {
      obj {
	 nam = 'ladder',
	 dsc = 'Комплекс поделён на две части: первая представляет собой открытое пространство, второе — два этажа небольших помещений. На второй этаж ведёт {лестница}.',
	 act = 'Обычная бетонная лестница.',
      },
      obj {
	 seen = false,
	 nam = 'gallery',
	 dsc = 'Входы второго этажа расположены на своеобразной {галерее}.',
	 act = function(s)
	    if not s.seen then
	       s.seen = true
	       open 'living_room'
	       return 'Одна из дверей второго этажа оказалась открыта.'
	    else
	       return 'Довольно странно выглядит, так как вся ранее известная структура была сугубо практична и не имела ненужных элементов, вроде этой галереи. По всей логике этого мира, тут должно было быть два коридора и лестница. Где же я нахожусь?'
	    end
	 end,
      },
      obj {
	 nam = 'inscription',
	 dsc = 'На стене видна {надпись}, сделанная крупными буквами.',
	 act = 'Надпись была сделана очень давно, но краска до сих пор выглядит достаточно яркой. Даже под слоем пыли, которая осела везде, где только можно. Содержимое же этой надписи неясно: используется неизвестный алфавит, больше всего похожий на смесь клинописи с геометрическими примитивами.',
      },
   },
   way = { 'greenhouse', 'living_room' },
}

room {
   seen = false,
   nam = 'living_room',
   disp = 'жилой блок',
   dsc = function(s)
      if not s.seen then
	 s.seen = true
	 return 'Продолжая аналогию с жилыми комплексами, выходит, что это помещение является жилым блоком.'
      else
	 return 'Я нахожусь в жилом блоке.'
      end
   end,
   obj = {
      obj {
	 nam = 'mess',
	 dsc = 'В комнате царит бардак. Множество {предметов} самой разной формы и неизвестного назначения валяются то тут, то там.',
	 act = function(s)
	    if not have 'record' then
	       take 'record'
	       mdec(2)
	       return 'Среди разнообразных предметов неизвестного назначения я нашёл некий предмет, похожий на оптический накопитель.'
	    else
	       return 'Я внимательно осмотрел этот хлам, но не нашёл ничего полезного.'
	    end
	 end,
      },
   },
   way = { 'residential_complex' },
}:close()

obj {
   nam = 'record',
   disp = 'носитель',
   dsc = 'Из щели считывателя торчит краешек {пластинки}.',
   inv = 'Квадратная прозрачная пластинка, переливающаяся всеми цветами радуги.',
   tak = function(s)
      disable 'button'
      return 'Я вытащил пластинку из щели считывателя.'
   end,
   use = function(s, w)
      if w ^ 'computer' then
	 return 'Мой компьютер несовместим с иномирными накопителями. О чём я вообще думаю?'
      elseif w ^ 'reader' then
	 if where 'record2' ^ 'reader' then
	    return 'В считыватели уже вставлен другой носитель.'
	 else
	    place(s, w)
	    enable 'button'
	    return 'Я вставил пластинку в щель считывателя.'
	 end
      elseif w ^ 'read_device' then
	 if where 'record2' ^ 'read_device' then
	    return 'В считыватели уже вставлен другой носитель.'
	 else
	    place(s, w)
	    return 'Я вставил пластинку в щель считывателя, но ничего не произошло.'
	 end
      else
	 return 'Пластинка носителя здесь бесполезна.'
      end
   end,
}

room {
   seen = false,
   nam = 'laboratory',
   disp = 'лаборатория',
   dsc = function(s)
      if not s.seen then
	 s.seen = true
	 return 'Просторное помещение заполнено странными конструкциями и приборами. Очень похоже на некую футуристическую лабораторию. К сожалению, я совершенно не представляю её предназначения и у меня нет времени для её детального изучения.'
      else
	 return 'Я нахожусь в лаборатории.'
      end
   end,
   obj = {
      obj {
	 seen = false,
	 nam = 'оборудование',
	 dsc = 'Лаборатория просто ломится от разнообразного {оборудования}.',
	 act = function(s)
	    if not s.seen then
	       s.seen = true
	       enable 'record2'
	       return 'Среди разнообразных электронных приборов и разнокалиберных пробирок и колб я заметил ещё одну пластинку оптического носителя.'
	    else
	       return 'Оборудование здесь сохранилось лучше всего, что я до сих пор встречал.'
	    end
	 end,
	 obj = {
	    obj {
	       nam = 'record2',
	       disp = 'носитель из лаборатории',
	       dsc = function(s)
		  if where(s) ^ 'reader' then
		     return 'Из щели торчит краешек {пластинки}.'
		  elseif where(s) ^ 'read_device' then
		     return 'Из щели считывателя торчит краешек {пластинки}.'
		  else
		     return 'Среди оборудования лежит пластинка {носителя}.'
		  end
	       end,
	       tak = function(s)
		  if where(s) ^ 'reader' then
		     disable 'button'
		  end
		  return 'Я взял носитель.'
	       end,
	       inv = 'Квадратная прозрачная пластинка, переливающаяся всеми цветами радуги.',
	       use = function(s, w)
		  if w ^ 'computer' then
		     return 'Мой компьютер несовместим с иномирными накопителями. О чём я вообще думаю?'
		  elseif w ^ 'reader' then
		     if where 'record' ^ 'reader' then
			return 'В считыватели уже вставлен другой носитель.'
		     else
			place(s, w)
			enable 'button'
			return 'Я вставил пластинку в щель считывателя.'
		     end
		  elseif w ^ 'read_device' then
		     if where 'record' and where 'record' ^ 'read_device' then
			return 'В считыватели уже вставлен другой носитель.'
		     else
			place(s, w)
			return 'Я вставил носитель в считыватель. На экране появилась таблица с непонятными символами, похожими на те, что я видел на стене.'
		     end
		  else
		     return 'Пластинка носителя здесь бесполезна.'
		  end
	       end
	    }:disable(),
	 },
      },
      obj {
	 seen = false,
	 on = false,
	 nam = 'reader2',
	 dsc = 'В углу стоит {прибор} похожий на земной компьютер.',
	 act = function(s)
	    if not s.seen then
	       s.seen = true
	       enable 'read_device'
	       return 'В этом "компьютере" есть считыватель для этих квадратных носителей.'
	    else
	       if not s.on then
		  s.on = true
		  return 'Я включил прибор.'
	       else
		  s.on = false
		  return 'Я выключил прибор.'
	       end
	    end
	 end,
	 obj = {
	    obj {
	       nam = 'read_device',
	       dsc = 'В нём есть {считыватель}.',
	       act = 'Узкая щель, подходящая размером под найденные мной носители.',
	    },
	 },
      },
      obj {
	 nam = 'rope',
	 disp = 'верёвка',
	 dsc = function(s)
	    if where(s) ^ 'laboratory' then
	       return 'На стене висит {моток} верёвки.'
	    else
	       return 'К ней привязана {верёвка}.'
	    end
	 end,
	 tak = function(s)
	    if where(s) ^ 'laboratory' then
	       return 'Я взял верёвку.'
	    else
	       p 'Я так старательно привязывал верёвку не для того, чтобы сейчас её отвязывать.'
	       return false
	    end
	 end,
	 inv = 'Верёвка из какого-то синтетического волокна. Крепкая, не взирая на то, что лежала в лаборатории неизвестно сколько лет.',
	 use = function(s, w)
	    if w ^ 'beam' then
	       place(s, w)
	       enable '#down'
	       mdec(5)
	       return 'Я крепко привязал верёвку к балке.'
	    else
	       return false
	    end
	 end,
      },
   },
   way = { 'hall' },
}

obj {
   nam = 'to_achievements',
   dsc = '{Достижения}',
   act = function()
      walk 'achievements'
   end,
}

room {
   nam = 'end0',
   disp = 'конец',
   noinv = true,
   dsc = function()
      local v = 'Я подошёл к порталу. Этот провал между мирами видится человеком как мерцающая и подрагивающая поверхность. Тихое гудение, разносящееся по помещению, сейчас пришлось мне лучше любого успокаивающего. Мысленно подгоняя себя, я вошёл в портал и через сладостный миг перехода оказался в родной лаборатории'
      if stable_portal then
	 v = v .. '.^^После моего возвращения портал не закрылся, а продолжал поддерживать сам себя. Последующие исследования показали, что два артефакта сделали этот связь между мирами постоянной. Было много горячих споров на предмет такого поведения артефактов, выдвинута не одна гипотеза, но наибольшую поддержку получила идея, что артефакты служили для построения транспортной сети между мирами.^^Почему же Земля была исключена из этой сети и будут ли какие-либо последствия в связи с тем, что я нечаянно включил её в эту сеть обратно, покажет только время.'
      else
	 v = v .. '…'
      end
      v = v .. titles
      return v
   end,
   obj = { 'to_achievements' },
}

room {
   nam = 'end1',
   disp = 'конец',
   noinv = true,
   dsc = function()
      if minutes <= 0 then
	 return 'Домой я уже не попаду, но и бездействовать мне претит. Бродить бесцельно по структуре пока я не умру от истощения — не тот конец, который я бы хотел себе. Поэтому я сделал свой выбор и, затаив дыхание в преддверии неизвестности, шагнул в портал. В неизвестное…' .. titles
      else
	 return 'Портал перекрыл мне путь наружу. Теперь уже нет смысла ждать пока выход из генераторной откроется. Дороги домой к тому моменту уже не будет. Оставаться в структуре тоже нет смысла, ведь здесь я вряд ли найду еду или воду. Так что остаётся только идти в неизведанное с призрачной надеждой выжить.^^Я закрыл глаза, задержал дыхание и шагнул в мерцающий гул портала в неизвестное…'
      end
   end,
   obj = { 'to_achievements' },
}

room {
   nam = 'achievements',
   noinv = true,
   disp = 'достижения',
   decor = function()
      if password_photo then
	 pn '1. Фотография надписи'
      else
	 pn '1. Достижение закрыто'
      end
      
      if plant_photo then
	 pn '2. Фотография растений'
      else
	 pn '2. Достижение закрыто'
      end

      if record then
	 pn '3. Видеозапись частично дешифрована'
      else
	 pn '3. Достижение закрыто'
      end

      if record2_photo then
	 pn '4. Таблица сфотографирована'
      else
	 pn '4. Достижение закрыто'
      end

      if sky_photo then
	 pn '5. Небо сфотографировано'
      else
	 pn '5. Достижение закрыто'
      end

      if have 'piece_of_plant' then
	 pn '6. Образец растения взят'
      else
	 pn '6. Достижение закрыто'
      end

      if have 'artefact' then
	 pn '7. Второй артефакт найден'
      else
	 pn '7. Достижение закрыто'
      end

      if stable_portal then
	 pn '8. Портал стабилизирован'
      else
	 pn '8. Достижение закрыто'
      end

      if e == 0 then
	 pn '9. Вернулся домой'
	 pn '10. Достижение закрыто'
      elseif e == 1 then
	 pn '9. Достижение закрыто'
	 pn '10. Ушёл в другие миры'
      end
      pn '^{@restart|ВЕРНУТЬСЯ К ЖУРНАЛУ}'
   end,
}

