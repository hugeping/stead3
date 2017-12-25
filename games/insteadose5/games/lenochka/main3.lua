--$Name: Леночка$
--$Version: 3$
--$Author: MAlischka$
--$Info: Инстедоз: 5 измерение \n$


dofile "games/lenochka/reception.lua"
dofile "games/lenochka/toilet.lua"
dofile "games/lenochka/kitchen.lua"
dofile "games/lenochka/5-floor.lua"
dofile "games/lenochka/couloir.lua"

game.pic = "gfx/lenochka1.png"

require "fmt"
fmt.para = true

require "snd"

require "prefs"

prefs.lena = {}
prefs.lena.friend = false
prefs.lena.funny1 = false
prefs.lena.bisquit1 = false
prefs.lena.futurama1 = false
prefs.lena.points = 0

prefs:load()

global 'futurama' (0)

std.strip_call = false

game.use = function(s)
    local msg= {
        "Не работает.",
        "Зачем мне это?",
        "Может не надо?!",
    }
    p(msg[rnd(#msg)])
end;

game.act= function(s)
    local msg= {
        "Не работает.",
        "Зачем мне это?",
        "Может не надо?!",
        "Я не ослик, чтобы всё катать на себе!",
    }
    p(msg[rnd(#msg)])
end;

game.inv = [[По моему, тут и так всё ясно.]];

room {
    nam = "ende";
    disp = "Конец";
    dsc=function(s,w)
        p[[По коже пробежали мурашки, секретарша как будто вышла из транса и помахала солдату,
который уже пару минут наблюдал за задумавшийся перед окном девушкой.^
Чтобы прогнать воспоминания она вернулась за стол и погрузилась в работу с головой.
^^
Автор: MAlischka^
Специально для  "Инстедоз: 5 измерениее".^^
P. S.:^
Благодарность и медаль на всё "пузо":^
Огромное спасибо "солнышку", за терпение и попытки объяснить мне "куда-тыкать-что-бы-работало"  до конца.^
Спасибо "рыбке", за исправление ошибок и коробку запятых.^
Не могу не поблагодарить "циферки", за тщательное тестирование игры.^^

{@restart|Вернуться к журналу}
]];
    end;

    way= {"progress"};
};

room {
    nam = "main";
    enter = function()
        snd.music ("mus/lenochka.ogg");
    end;

    disp = "Приемная";
    dsc =[[Начальство рано изволило уйти, и Лена спокойно могла поработать.]];
    decor=[[{#В_приёмной|В приёмной} слышались только тихое, равномерное,
почти гипнотическое тиканье настенных {#часы|часов},
и щелчки кнопок от быстрого галопа пальцев по клавишам.^
Внезапно они оборвались.]];
}: with {
    obj{
        nam="#В_приёмной";
        act= function(s)
            walkin ("reception");
        end;
    };
    obj{
        nam="#часы";
        act=[[Тик-так...^
Тик-так...^
Веки становятся тяжелее...^
Стоп, конечно мне нужно отдохнуть, но не настолько ведь?!]];
    }
        };

room {
    nam = "progress";
    disp = "Достижения";
    dsc=function(s)
        return "Вы открыли " .. prefs.lena.points .. " достижений из возможных 4."
    end;

    way= {"ende"};

    obj={

        obj{
            nam="cat";
            dsc=function(s)
                if prefs.lena.friend then p[[^1)"Пушистый друг"-Покормить кота колбаской.]];
                else p[[^1) ***]]
                end;
            end;
        };

        obj{
            nam="fun";
            dsc=function(s)
                if prefs.lena.funny1 then p[[^2)"Петросян"-Шуточки, как (плоские) досочки.]];
                else p[[^2) ***]];
                end;
            end;
        };

        obj{
            nam="delft";
            dsc=function(s)
                if prefs.lena.bisquit1 then p[[^3)"Фаянс"-Проведено тщательное исследование "уборной".]];
                else p[[^3) ***]];
                end;
            end;
        };

        obj{
            nam="future1";
            dsc=function(s)
                if prefs.lena.futurama1 then p[[^4)"Любопытство"-Не пропущено не детали при осмотре лаборатории из будущего.]];
                else p[[^4) ***]];
                end;
            end;
        };

    };

};
