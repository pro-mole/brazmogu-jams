-- Maze generator for LOST IN MAZE

Maze = {}
Maze.__index = Maze

function Maze.generate(size)
	local maze = setmetatable({size = size, grid = {}}, Maze)
	
	for y = 1,size do
		table.insert(maze.grid, {})
		for x = 1,size do
			table.insert(maze.grid[y],'#')
		end
	end
	
	local m_start = maze:getRandomWallPoint()
	maze.grid[m_start[2]][m_start[1]] = " "
	
	local turns = math.random(5) + 3
	local prev_turnpoint = m_start
	repeat
		local turnpoint
		repeat
			turnpoint = { math.random(size), math.random(size) }
		until prev_turnpoint[1] == turnpoint[1] or prev_turnpoint[2] == turnpoint[2]
		
		if prev_turnpoint[1] == turnpoint[1] then
			if prev_turnpoint[2] > turnpoint[2] then
				for y = turnpoint[2],prev_turnpoint[2] do
					maze.grid[y][turnpoint[1]] = " "
				end
			elseif prev_turnpoint[2] < turnpoint[2] then
				for y = prev_turnpoint[2],turnpoint[2] do
					maze.grid[y][turnpoint[1]] = " "
				end
			end
		elseif prev_turnpoint[2] == turnpoint[2] then
			if prev_turnpoint[1] > turnpoint[1] then
				for x = turnpoint[1],prev_turnpoint[1] do
					maze.grid[turnpoint[2]][x] = " "
				end
			elseif prev_turnpoint[1] < turnpoint[1] then
				for x = prev_turnpoint[1],turnpoint[1] do
					maze.grid[turnpoint[2]][x] = " "
				end
			end
		end
		
		prev_turnpoint = turnpoint
		
		turns = turns - 1
	until turns == 0
	
	return maze
end

function Maze:getRandomWallPoint()
	math.randomseed(os.time())
	local side = math.random(4)
	
	if side == 1 then -- LEFT
		return { 1, math.random(self.size) }
	elseif side == 2 then -- TOP
		return { math.random(self.size), 1 }
	elseif side == 3 then -- RIGHT
		return { self.size, math.random(self.size) }
	elseif side == 4 then -- BOTTOM
		return { math.random(self.size), self.size }
	end
	
	return nil
end

function Maze:print()
	for y = 1,self.size do
		local row = self.grid[y]
		local line = ""
		for x = 1,self.size do
			line = line..self.grid[y][x]
		end
		print(line)
	end
end

M = Maze.generate(32)
M:print()