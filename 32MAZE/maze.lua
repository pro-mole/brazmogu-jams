-- Maze generator for LOST IN MAZE

require("tile")
require("node")

Maze = {}
Maze.__index = Maze

function Maze.generate(size)
	math.randomseed(os.time())
	local direction = {"left", "up", "right", "down"}
	local board_size = size*2+1
	local maze = setmetatable({size = size, board_size = board_size, tiles = {}, nodes = {}}, Maze)
	
	for Y = 1, board_size do
		table.insert(maze.tiles, {})
		if Y % 2 == 0 then table.insert(maze.nodes, {}) end
		for X = 1,board_size do
			if X % 2 == 0 and Y % 2 == 0 then
				table.insert(maze.tiles[Y],Tile.new(X,Y," "))
				table.insert(maze.nodes[Y/2],Node.new(X/2, Y/2))
			else
				table.insert(maze.tiles[Y],Tile.new(X,Y,"#"))
			end
		end
	end	
	
	-- Total randomness test!
	for x = 1,size do
		for y = 1,size do
			maze:updateNode(x,y,"left", math.random(2) == 1)
			maze:updateNode(x,y,"right", math.random(2) == 1)
			maze:updateNode(x,y,"up", math.random(2) == 1)
			maze:updateNode(x,y,"down", math.random(2) == 1)
		end
	end
	
	return maze
end

function Maze:getTile(x,y)
	return self.tiles[y][x]
end

function Maze:getNode(x,y)
	return self.nodes[y][x]
end

-- When changing the paths of nodes, make sure the connections are 2-way
function Maze:updateNode(x,y,dir,state)
	local main = self:getNode(x,y)
	main.paths[dir] = state
	
	local content
	if state then
		content = " "
	else
		content = "#"
	end
	
	if dir == "left" then		
		self:getTile(x*2 - 1, y*2).content = content
	elseif dir == "right" then		
		self:getTile(x*2 + 1, y*2).content = content
	elseif dir == "up" then		
		self:getTile(x*2, y*2 - 1).content = content
	elseif dir == "down" then		
		self:getTile(x*2, y*2 + 1).content = content
	end
	
	if dir == "left" and x > 1 then
		self:getNode(x-1,y).paths["right"] = state
	end
	
	if dir == "right" and x < self.size then
		self:getNode(x+1,y).paths["left"] = state
	end
	
	if dir == "up" and y > 1 then
		self:getNode(x,y-1).paths["down"] = state
	end
	
	if dir == "down" and y < self.size then
		self:getNode(x,y+1).paths["up"] = state
	end
end

function Maze:print()
	for y = 1,self.board_size do
		local row = self.tiles[y]
		local line = ""
		for x = 1,self.board_size do
			line = line .. tostring(self.tiles[y][x])
		end
		print(line)
	end
end

M = Maze.generate(16)
M:print()