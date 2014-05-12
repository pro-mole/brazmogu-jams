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
	return setmetatable({x = x, y = y, content = tile}, Tile)
end