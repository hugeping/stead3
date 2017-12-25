room {
    nam = "couloir1";
    disp = "Коридор";
    dsc=[[Куда теперь?]];
    onenter = function()
        if not have ("Лейка") and not have ("Лейка с водой") then
            walkin ("couloir2");
            return false
        end;
    end;
    decor=function(s,w)
        if have "Бутерброд" then
            p[[{#кот|Гегель} сидел посреди коридора и молча смотрел на бутерброд в руках девушки.]];
        end
    end;
    way= {"reception","toilet","kitchen","counting","conference","5-floor"};
}:with
{
    obj{
        nam="#кот";
        act=[[-- Кыс-кыс-кыс, иди сюда поглажу, -- поманила девушка кота к себе.]];

        used=function(s,w)
            if w^"Бутерброд" then
                p[[-- Тоже кушать хочешь? -- сняв колбаску с бутерброда и положив её перед котом, девушка решила поделиться с пушистым обжорой.]];
                remove(w);
                if not prefs.lena.friend then
                    prefs.lena.friend = true;
                    prefs.lena.points = prefs.lena.points+1;
                    prefs:store()
                end
            else
                return false
            end;
        end;
    };
};

room {
    nam = "couloir2";
    disp = "Коридор";
    dsc=[[Куда теперь?]];
    way= {"reception2","toilet","kitchen2","counting","conference","5-floor"};
};

room {
    nam = "counting";
    disp = "Бухгалтерия";
    onenter = function(s)
        p[[Заперто.^
Наверное все уже ушли.]];
        return false
    end;
};

room {
    nam = "conference";
    disp = "Ком. для совещаний.";
    onenter = function(s)
        p[[Заперто.]];
        return false
    end;
};
