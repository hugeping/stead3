-- Copyright 2016 Yat Hin Wong

local maze = {}

local N, S, E, W = "north", "south", "east", "west"
local DX = {[E] = 1, [W] = -1, [N] = 0, [S] = 0}
local DY = {[E] = 0, [W] = 0, [N] = -1, [S] = 1}
local OPPOSITE = {[E] = W, [W] = E, [N] = S, [S] = N}

local function shuffle(t)
	local j
	for i = #t, 2, -1 do
		j = math.random(i)
		t[i], t[j] = t[j], t[i]
	end
end

-- recursive function used to dig passages in the maze
local function carve(cx, cy, grid)
	local directions = {N, S, E, W}
	local nx, ny
	
	-- randomizes dig directions
	shuffle(directions)
	
	for _,dir in ipairs(directions) do
		nx, ny = cx + DX[dir], cy + DY[dir]
		
		if nx >= 1 and nx <= #grid and ny >= 1 and ny <= #grid and not grid[ny][nx].visited then
			grid[cy][cx][dir] = true
			grid[cy][cx].visited = true
			grid[ny][nx][OPPOSITE[dir]] = true -- two-way passage
			grid[ny][nx].visited = true
			carve(nx, ny, grid)
		end
	end
end

-- converts the maze representation to one suitable for the raycaster engine
local function convert(a)
	local b = {}
	for i = 1, #a*2+1 do
		b[i] = {}
		for j = 1, #a*2+1 do
			b[i][j] = 1
		end
	end
	
	for i,v in ipairs(a) do
		for j,u in ipairs(v) do
			b[2*i][2*j] = 0
			if u[S] then
				b[2*i+1][2*j] = 0
			end
			if u[E] then
				b[2*i][2*j+1] = 0
			end
		end
	end
	return b
end

function maze.create(size)
	local grid = {}
	for i = 1, size do
		grid[i] = {}
		for j = 1, size do
			grid[i][j] = {[N] = false, [S] = false, [E] = false, [W] = false, visited = false}
		end
	end

	math.randomseed(os.time())
	carve(1, 1, grid)

	return convert(grid)
end
	
return maze
