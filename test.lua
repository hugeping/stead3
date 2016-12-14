require 'stead3'
room = stead.room
obj = stead.obj
pl = stead.player

pl {
	nam = 'игрок';
}

a = room {
	nam = 'главная';
	dsc = 'Проверка';
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
a.obj:add('игрок')
a.x = true
a:disable()
--a.z = { [1] = { a }}
stead.ini()
stead.save(io.stdout)
--print(stead 'игрок':look())
iface.cmd 'look'
print( (stead 'нож':where()).nam)
print (stead 'игрок':where().nam)