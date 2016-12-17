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

const {
	global_const = true;
}

global {
	global_table = { a = 1 };
}
global {
	global_var = global_table;
}
declare {
	zlist = stead.list {
		obj {
			nam = 'нож';
			dsc = "Тут лежит {нож}";
		};
	};
}
a = room {
	nam = 'главная';
	dsc = 'Проверка';
	onenter = "a onenter";
	enter = "a enter";
	obj = zlist;
	table =  { };
--	obj = {
--		obj {
--			nam = 'нож';
--			dsc = "Тут лежит {нож}";
--		};
--	};
}
a.xm = { 1, 2, 3 }
a.dsc = 'Проверка';
b = stead.new ( 'obj', {  })
c = stead.new ( 'obj', { x = 'c = ' })
stead.delete(b)
stead 'player'.room = 'главная';
stead.init()
a.zx = { azx = 1 } --global_table;
global_table = 1
-- global_table = a.zx
global_var = b
print(global_var, global_table)
--global_var = global_table
a.obj:add('игрок')
a.x = true
a:disable()
--a.z = { [1] = { a }}
--print(stead 'игрок':look())
print( (stead 'нож':where()))
print (stead 'нож':where())
print(stead 'нож':where().obj:del 'нож')
print (stead 'нож':where())
print(stead 'игрок':walk(a))
print(iface.cmd 'look')
a.table.z = 1
stead.save(io.stdout)
-- global_const = 2
stead.done()
