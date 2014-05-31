-- Maze generator for LOST IN MAZE

require("tile")
require("node")

Maze = {}
Maze.__index = Maze

seed = 0

Maze.tileset = love.graphics.newImage("assets/sprite/tiles.png")

Maze.tileset:setFilter("nearest","nearest")

function Maze.generate(size, exit_wall)
	math.randomseed(os.time() + seed)
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
	-- maze:generatRandomly()
	
	-- Prim-based generation: a lot cleaner, at least
	if not maze:generatePrim({math.ceil(size/2),size}) then
		maze:print()
		seed = seed + 1
		maze = Maze.generate(size)
	end
	
	-- Add exit
	if exit_wall == "up" then
		maze.end_x = math.random(size)*2
		maze.end_y = 1
		maze:updateNode(maze.end_x/2,1,exit_wall,true)
	elseif exit_wall == "down" then
		maze.end_x = math.random(size)*2
		maze.end_y = size*2+1
		maze:updateNode(maze.end_x/2,size,exit_wall,true)
	elseif exit_wall == "left" then
		maze.end_y = math.random(size)*2
		maze.end_x = 1
		maze:updateNode(1,maze.end_y/2,exit_wall,true)
	elseif exit_wall == "right" then
		maze.end_y = math.random(size)*2
		maze.end_x = size*2+1
		maze:updateNode(size,maze.end_y/2,exit_wall,true)
	end
	maze:setTile(maze.end_x, maze.end_y, " ")
	
	-- Colorization; to add some orientation
	-- First select our "quadrants"
	local Q = {}
	local colors = {
		{0xff, 0x80, 0x00, 0xff},{0xff, 0xff, 0x00, 0xff},{0x00, 0xff, 0x00, 0xff},
		{0xff, 0x00, 0x00, 0xff},{0xff, 0xff, 0xff, 0xff},{0x00, 0xff, 0xff, 0xff},
		{0xff, 0x00, 0x80, 0xff},{0x80, 0x00, 0xff, 0xff},{0x00, 0x00, 0xff, 0xff}
	}
	local sect = 3
	local sect_size = math.ceil(board_size/sect)
	for i = 1,sect^2 do
		local h,k = (i-1) % sect + 1, math.ceil(i/sect)
		local _x = math.random(sect_size) + sect_size * (h-1)
		local _y = math.random(sect_size) + sect_size * (k-1)
		
		table.insert(Q, {x = _x, y = _y, color = colors[i]})
		print(unpack({h, k, _x, _y, unpack(colors[i])}))
	end
	-- Now, colorize everything in terms of what's close, blending color
	for X = 1,board_size do
		for Y = 1,board_size do
			local T = maze:getTile(X,Y)
			local q = math.floor(Y / sect_size) * 3 + math.ceil(X / sect/size)
			local _Q = Q[q]
			-- for j,C in ipairs(_Q.color) do T.color[j] = C end
			T.color = {128,128,128,255}
			for i,_Q in ipairs(Q) do
				local d = math.sqrt((X - _Q.x)^2 + (Y - _Q.y)^2) + 1 -- we don't want zero distance here
				local alpha = 1/d
				for j,C in ipairs(_Q.color) do
					T.color[j] = (1-alpha)*T.color[j] + alpha*C
				end
			end
			--print(unpack(T.color))
			--T.color[4] = 255
		end
	end
	
	-- Terminal nodes and crossroads will contain events(hazards, messages, stuff like that)
	local T = {}
	local C = {}
	for X = 1,size do
		for Y = 1,size do
			if not (X*2 == player_x and Y*2 == player_y) then
				local N = maze:getNode(X,Y)
				local exits = N:getExits()
				if exits == 1 then
					table.insert(T, N)
				elseif exits == 4 then
					table.insert(C, N)
				end
			end
		end
	end
		
	for _,term in ipairs(T) do
		local deadends = {
			{{255,0,0}, "deadend", "comfort"},
			{{255,128,0}, "setback", "setback"}
		}
		local ev = deadends[math.random(#deadends)]
		term.event = {color = ev[1], name = ev[3], kind = ev[2], card = ev[4]}
	end
	
	for _,cross in ipairs(C) do
		if math.random(2) == 1 then
			local crossroads = {
				{{255,192,0}, "crossroads", "crossroads"},
				{{0,192,255}, "leap", "quantumleap"},
				{{192,192,192}, "leap", "shortcut"},
			}
			local ev = crossroads[math.random(#crossroads)]
			cross.event = {color = ev[1], name = ev[3], kind = ev[2]}
		end
	end
	
	return maze
end

function Maze:generateRandomly()
	-- Generate maze totally randomly setting up the exits on each node
	for x = 1,self.size do
		for y = 1,self.size do
			self:updateNode(x,y,"left", math.random(2) == 1)
			self:updateNode(x,y,"right", math.random(2) == 1)
			self:updateNode(x,y,"up", math.random(2) == 1)
			self:updateNode(x,y,"down", math.random(2) == 1)
		end
	end
end

function Maze:generatePrim(start_node)
	-- Use modified Prim's Algorithm to create the maze
	-- Not sure if this will work as I intended, but will probably be good enough for now
	local N = self:getNode(unpack(start_node))
	N.visited = true
	N.cost = 0
	
	local V = {N} -- list of visited nodes
	
	local direction = {"left", "up", "right", "down"}
	local delta = {left = {-1,0}, up = {0,-1}, right = {1,0}, down = {0,1}}
	while #V < self.size^2 do -- When all size^2 are visited, stop
		N = V[math.random(#V)]
		local dir = direction[math.random(4)]
		local _N = self:getNode(N.x + delta[dir][1], N.y + delta[dir][2])
		
		if _N ~= nil and not _N.visited then
			self:updateNode(N.x, N.y, dir, true)
			_N.visited = true
			_N.cost = N.cost + 1
			table.insert(V, _N)
			-- self:print()
			-- love.timer.sleep(0.5)
		end
	end
	
	return true
end

function Maze:generateWindingPath(start_node, end_node)
	-- In this method we generate a winding path from one end to the other of the maze
	-- The "winding path" is defined as a path that is deliberately suboptimal(not the quickest to the end) and does not cross itself(no shortcuts)]]
	local direction = {"left", "up", "right", "down"}
	local turn = {left = {"up","down"}, up = {"left","right"}, right = {"down","up"}, down = {"right","left"}}
	local delta = {left = {-1,0}, up = {0,-1}, right = {1,0}, down = {0,1}}
	local Sx,Sy = unpack(start_node)
	local S = self:getNode(Sx, Sy)
	local Ex,Ey = unpack(end_node)
	local E = self:getNode(Ex, Ey)
	
	-- With the winding path created, now we connect every other 
	return true
end

function Maze:getTile(x,y)
	if x < 1 or x > self.board_size or y < 1 or y > self.board_size then
		return nil
	else
		return self.tiles[y][x]
	end
end

function Maze:setTile(x,y,tile)
	if x >= 1 and x <= self.board_size and y >= 1 and y <= self.board_size then
		self.tiles[y][x].content = tile
	end
end

function Maze:getNode(x,y)
	if x < 1 or x > self.size or y < 1 or y > self.size then
		return nil
	else
		return self.nodes[y][x]
	end
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
			if x == player_x and y == player_y then
				line = line .. "o"
			elseif x % 2 == 0 and y % 2 == 0 then
				line = line .. tostring(self:getNode(x/2,y/2))
			else
				line = line .. tostring(self:getTile(x,y))
			end
		end
		print(line)
	end
	io.stdout:flush()
end