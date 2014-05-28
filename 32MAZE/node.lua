-- Node class definition
-- Node: an abstract representation of key crossing points that we use to generate the maze
Node = {
	x = 0,
	y = 0,
	visited = false,
	cost = 0,
	event = nil,
	paths = {left = false, up = false, down = false, right = false}
}
Node.__index = Node
	
Node.tiles = {
	crossroads = love.graphics.newQuad(0,0,10,10,60,60),
	retrace = love.graphics.newQuad(10,0,10,10,60,60),
	pitfall = love.graphics.newQuad(20,0,10,10,60,60),
	question = love.graphics.newQuad(30,0,10,10,60,60)
}

function Node.new(x,y)
	return setmetatable({x = x, y = y, cost = 0, paths = {left = false, up = false, down = false, right = false}}, Node)
end

function Node:__tostring()
	if self.cost < 10 then
		return self.cost
	else
		local alpha = "abcdefghijklmnopqrstuvwxyz"
		return alpha:sub(self.cost-9, self.cost-9)
	end
end

function Node:getExits()
	local exits = 0
	
	if self.paths.up then exits = exits + 1 end
	if self.paths.down then exits = exits + 1 end
	if self.paths.left then exits = exits + 1 end
	if self.paths.right then exits = exits + 1 end
	
	return exits
end

function Node:draw()
	if self.event then
		love.graphics.setColor(unpack(self.event.color))
		love.graphics.draw(Maze.tileset, Node.tiles["crossroads"],0,0)
		--love.graphics.rectangle("fill", 4, 1, 2, 8)
		--love.graphics.rectangle("fill", 3, 3, 4, 4)
		--love.graphics.rectangle("fill", 1, 4, 8, 2)
	end
end