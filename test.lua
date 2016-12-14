require 'stead3'
room = stead.room
obj = stead.obj
pl = stead.player

pl {
	nam = 'игрок';
}

a = room {
	nam = 'главная';
	{
		dsc = 'Проверка';
	};
	obj = {
		obj {
			nam = 'нож';
			dsc = "Тут лежит {нож}";
		};
	};
}
b = stead.new ( 'obj', {  })
--stead.delete(b)
stead 'player'.where = 'главная';
--a.obj:add('игрок')
a.x = true
a:disable()
--a.z = { [1] = { a }}
stead.ini()
stead.save(io.stdout)
--print(stead 'игрок':look())
iface.cmd 'look'
