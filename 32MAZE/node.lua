-- Node class definition
-- Node: an abstract representation of key crossing points that we use to generate the maze
Node = {
	x = 0,
	y = 0,
	visited = false,
	paths = {left = false, up = false, down = false, right = false}
}
Node.__index = Node
	
function Node.new(x,y)
	return setmetatable({x = x, y = y, paths = {left = false, up = false, down = false, right = false}}, Node)
end