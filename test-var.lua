require 'stead'
stead:init()

room = stead.room
obj = stead.obj
pl = stead.player
p = stead.p
main = stead.ref 'main'
game = stead.ref 'game'
declare {
	func = function()
		print "Hello world!"
	end
}
global {
	a = { 1 };
}

global {
	b = {1, 2};
}

global {
	c = { 1, 2, 3};
}
global {
	d = { a },
	zzz = true;
}

global {
	zlist = stead.list {
		obj {
			nam = 'нож';
			dsc = "Тут лежит {нож}";
		};
	};
}
cv = function() end

game:ini()
func()
zzz = func;
print('--------')
stead:save(io.stdout)
print('--------')
b = a
stead:save(io.stdout)
print('--------')
a[1] = c;
stead:save(io.stdout)
d[1] = a
stead:done()
