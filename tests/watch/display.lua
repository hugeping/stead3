std.scene_delim = "^"
game.display = function(s, state)
	local div = fmt.c(fmt.img 'gfx/div.png')
	if not D'snow' then
		div = fmt.c(fmt.img 'gfx/div2.png')
	end
	local l, av, pv
	local reaction = s:reaction() or nil
	if state then
		av, pv = s:events()
		av = iface:em(av)
		pv = iface:em(pv)
		reaction = iface:em(reaction)
		l = s.player:look() -- objects [and scene]
		l = std.par(std.scene_delim, av or false, l or false, pv or false)
	end
	if player_moved() then
	    l = std.par(std.scene_delim, reaction or false, l)
	    reaction = false
	end
	l = std.par("^"..div.."^", l or false, reaction or false) or ''
	return l
end;
