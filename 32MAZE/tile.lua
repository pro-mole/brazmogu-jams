-- Tile class definitions
-- Tile: the actual thing that is in the "game board"
Tile = {
	x = 0,
	y = 0,
	content = "#"
}
Tile.__index = Tile

function Tile:__tostring()
	return self.content
end

function Tile.new(x,y,tile)
	return setmetatable({x = x, y = y, content = tile, color = {255,255,255,255}}, Tile)
end

function Tile:draw()
	if self.content == "#" then
		love.graphics.setColor(unpack(self.color))
		love.graphics.rectangle("fill", 1, 1, 8, 8)
		
		local T_up = _maze:getTile(self.x, self.y-1)
		if T_up and T_up.content == "#" then love.graphics.rectangle("fill", 1, 0, 8, 1) end
		
		local T_down = _maze:getTile(self.x, self.y+1)
		if T_down and T_down.content == "#" then love.graphics.rectangle("fill", 1, 9, 8, 1) end
		
		local T_left = _maze:getTile(self.x-1, self.y)
		if T_left and T_left.content == "#" then love.graphics.rectangle("fill", 0, 1, 1, 8) end
		
		local T_right = _maze:getTile(self.x+1, self.y)
		if T_right and T_right.content == "#" then love.graphics.rectangle("fill", 9, 1, 1, 8) end
	end
end