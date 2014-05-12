-- LOST IN MAZE

require("maze")

function love.load()
	player_x, player_y = 16,30
	_maze = Maze.generate(15)
	_maze:print()
	scale = love.window.getWidth()/32
	print(string.format("%dX", scale))
end

function love.keypressed(key, isrepeat)
	if key == "up" or key == "down" or key == "left" or key == "right" then
		local delta = {up = {0,-1}, down = {0,1}, left = {-1,0}, right = {1,0}}
		player_x = player_x + delta[key][1]
		player_y = player_y + delta[key][2]
	end
end

function love.update(dt)
end

function love.draw()
	love.graphics.scale(scale,scale)
	
	love.graphics.line(10,0,10,31)
	love.graphics.line(21,0,21,31)
	love.graphics.line(0,10,31,10)
	love.graphics.line(0,21,31,21)

	for x = -1,1 do
		for y = -1,1 do
			love.graphics.push()
			love.graphics.translate((x+1)*11, (y+1)*11)
			local tile = _maze:getTile(player_x + x, player_y + y)
			if x == 0 and y == 0 then
				love.graphics.rectangle("fill", 2, 1, 5, 7)
				love.graphics.rectangle("fill", 1, 2, 7, 5)
			end

			if tile.content == "#" then
				love.graphics.rectangle("fill", 1, 1, 7, 7)
			end
			love.graphics.pop()
		end
	end
end

function love.quit()
end