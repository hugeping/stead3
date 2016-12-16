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
game.onwalk = function() p 'game onwalk'; end
a = room {
	nam = 'главная';
	dsc = 'Проверка';
	onenter = "a onenter";
	enter = "a enter";
	obj = {
		obj {
			nam = 'нож';
			dsc = "Тут лежит {нож}";
		};
	};
}
a.xm = { 1, 2, 3 }
a.dsc = 'Проверка';
b = stead.new ( 'obj', {  })
c = stead.new ( 'obj', { x = 'c = ' })
stead.delete(b)
stead 'player'.room = 'главная';
stead.init()
a.obj:add('игрок')
a.x = true
a:disable()
--a.z = { [1] = { a }}
--print(stead 'игрок':look())
iface.cmd 'look'
print( (stead 'нож':where()))
print (stead 'нож':where())
print(stead 'нож':where().obj:del 'нож')
print (stead 'нож':where())
print(stead 'игрок':walk(a))
stead.save(io.stdout)
stead.done()
