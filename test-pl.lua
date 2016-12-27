require 'stead3'
room = stead.room
obj = stead.obj
pl = stead.player
p = stead.p
main = stead.ref 'main'
game = stead.ref 'game'

pl {
	nam = 'игрок';
}
x = room {
	nam = 'x';
	xtable = { 1, 2, 3 };
}

a = room {
	nam = 'главная';
	dsc = 'Проверка';
	onenter = "a onenter";
	enter = "a enter";
	obj = { 'яблоко'};
	way = { 'x' };
}
apple = obj {
	nam = 'яблоко';
	tak = function(s) p 'взял яблоко'; return; end;
	act = function()
		p "действие"
	end;
	inv = "использовал";
	dsc = '{яблоко}';
}
stead 'player'.room = 'главная';
stead.init()
print(stead 'главная':lookup('яблоко'))
print(stead 'главная':seen('x'))
print(stead 'game':cmd({'act', 'яблоко'}))
print(stead 'game':cmd({'use', 'яблоко'}))
print(stead 'player':take 'яблоко')
stead.save(io.stdout)
stead.done()
