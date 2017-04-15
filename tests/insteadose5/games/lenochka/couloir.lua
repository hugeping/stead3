room {
    nam = "couloir1";
    disp = "Коридор";
    dsc=[[Куда теперь?]];
    decor=function(s,w)
        if have "Лейка" and not have "Бутерброд" then
            p(false);
        elseif  have "Лейка с водой" and not have "Бутерброд" then
            p(false);
        elseif have "Бутерброд" then
            p[[{#кот|Гегель} сидел посреди коридора и молча смотрел на бутерброд в руках девушки.]];

        elseif not have ("Лейка" and "Лейка с водой")then
            walkin ("couloir2");
        end;
    end;

    way= {"reception","toilet","kitchen","counting","conference","5-floor"};
}:with
{
    obj{
        nam="#кот";
        act=[["Кыс-кыс-кыс, иди сюда поглажу."- Поманила девушка кота к себе.]];

        used=function(s,w)
            if w^"Бутерброд" then
                p[["Тоже кушать хочешь?"- сняв колбаску с бутерброда и положив её перед котом, девушка решила поделиться с пушистым обжорой.]];
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
    dsc=function(s,w)
        p[[Заперто.^
Наверное все уже ушли.]];
        walkin ("couloir1");
    end;
};

room {
    nam = "conference";
    disp = "Ком. для совещаний.";
    dsc=function(s,w)
        p[[Заперто.]];
        walkin ("couloir1");
    end;
};
