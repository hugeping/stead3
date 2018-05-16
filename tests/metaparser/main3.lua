require "mp"

obj {
	nam = 'яблоко';
	word = -"яблоко,яблочко,красное яблоко";
}: dict {
--	['яблоко/дт,мн'] = 'xxx';
}

function start()
	print(_'яблоко':noun('дт,мн'))
end
