require "mp"

obj {
	nam = 'яблоко';
	disp = -"яблоко,яблочко,красное яблоко";
}: dict {
	['яблоко/дт,мн'] = 'xxx';
}

function start()
	print(_'яблоко':word('дт,мн'))
end
