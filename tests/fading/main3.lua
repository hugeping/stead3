loadmod 'fading'
obj {
	nam = 'бомба';
	dsc = [[На полу лежит {бомба}.]];
	act = function(s)
		p [[БАХ!!!]];
		remove(s)
	end;
}

room {
	nam = 'main';
	dsc = [[Комната.]];
	obj = { 'бомба' };
	way = { 'main2' };
}

room {
	nam = 'main2';
	dsc = [[Комната 2.]];
	way = { 'main' };
}
