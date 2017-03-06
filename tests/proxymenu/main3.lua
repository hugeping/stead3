loadmod 'proxymenu'
game.exam = "default exam"
obj {
	nam = 'яблоко';
	dsc = [[Тут есть {яблоко}.]];
	act = [[act яблока.]];
	useit = [[inv яблока.]];
--	used = [[used яблока.]];
	exam = [[Осмотреть]];
}

obj {
	nam = 'груша';
	dsc = [[Тут есть {груша}.]];
	act = [[act груши.]];
	useit = [[inv груши.]];
	used = [[used груша]];
	use = function(s, w)
		p ("Поюзал:", w)
	end;
	take = function(s)
		p [[Взял грушу.]]
	end
}

game.after_take = function(s, o)
	take(o)
end

game.walk = function(s, w)
	walk(w)
end

function init()
	game.player = std.menu_player {}

	instead.noways = true

	place( proxy_menu { 
		disp = 'ОСМОТРЕТЬ';
		acts = { inv = 'exam' };
		sources = { scene = true, inv = true };
	}, me())

	place( proxy_menu { 
		disp = 'ВЗЯТЬ';
		acts = { inv = 'take' };
		sources = { scene = true };
	}, me())

	place( proxy_menu { 
		disp = 'ИСПОЛЬЗОВАТЬ';
		use_mode = true;
		acts = { use = 'use', inv = 'useit' };
		sources = { inv = true, scene = true };
	}, me())

	place( proxy_menu { 
		disp = 'ИДТИ';
		acts = { inv = 'walk' };
		sources = { ways = true };
	}, me())

end

room {
	nam = 'main';
	dsc = [[Описатель]];
	way = { 'room2' };
	obj = { 'яблоко', 'груша' };
}

room {
	nam = 'room2';
	disp = 'комната 2';
	dsc = [[Описатель 2]];
	way = { 'main' };
}
