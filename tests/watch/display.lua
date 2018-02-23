std.scene_delim = "^"
game.display = function(s, state)
	local l, av, pv
	local reaction = s:reaction() or nil
	if state then
		av, pv = s:events()
		av = iface:em(av)
		pv = iface:em(pv)
		l = s.player:look() -- objects [and scene]
		l = std.par(std.scene_delim, av or false, l or false, pv or false)
	end
	if not player_moved() then
		l = std.par("^"..(fmt.c(fmt.img 'gfx/div.png')).."^", l or false, reaction or false) or ''
	else
		l = std.par("^"..(fmt.c(fmt.img 'gfx/div.png')).."^", reaction or false, l or false) or ''
	end
	return l
end;
