require "fonts"
local fnt = _'$fnt'
fnt:face ('sans', 'sans.ttf', 33)
room {
	nam = 'main';
	dsc = '{$fnt sans}';
}:with {
	obj {
		dsc = 'Тут лежит {{$fnt sans|ЧТО\\|ТО}}';
		act = '{$fnt sans|есссс}';
	};
	obj {
		nam = 'test';
		act = 'test!';
	};

}