-- LOST IN MAZE

require("maze")

function love.load()
	player_x, player_y = 16,30
	_maze = Maze.generate(15,"up")
	_maze:print()
	scale = love.window.getWidth()/32
	print(string.format("%dX", scale))
end

function love.keypressed(key, isrepeat)
	if key == "up" or key == "down" or key == "left" or key == "right" then
		local delta = {up = {0,-1}, down = {0,1}, left = {-1,0}, right = {1,0}}
		local _x = player_x + delta[key][1]
		local _y = player_y + delta[key][2]
		local T = _maze:getTile(_x,_y)
		if T.content ~= "#" then
			player_x = _x
			player_y = _y
		end
	end
end

function love.update(dt)
end

function love.draw()
	love.graphics.setColor(255,255,255,255)
	love.graphics.scale(scale,scale)
	
	-- Do NOT use love.graphics.line, since LÖVE seems to draw scaled lines centered on the end points
	love.graphics.rectangle("fill",10,0,1,32)
	love.graphics.rectangle("fill",21,0,1,32)
	love.graphics.rectangle("fill",0,10,32,1)
	love.graphics.rectangle("fill",0,21,32,1)

	for x = -1,1 do
		for y = -1,1 do
			local _x = player_x + x
			local _y = player_y + y
			love.graphics.push()
			love.graphics.translate((x+1)*11, (y+1)*11)
			if x == 0 and y == 0 then
				love.graphics.setColor(255,255,255,255)
				love.graphics.rectangle("fill", 3, 1, 4, 8)
				love.graphics.rectangle("fill", 2, 2, 6, 6)
				love.graphics.setColor(0,0,0,255)
				love.graphics.rectangle("fill", 3, 4, 1, 1)
				love.graphics.rectangle("fill", 6, 4, 1, 1)
				love.graphics.rectangle("fill", 3, 6, 4, 1)
			elseif _x % 2 == 0 and _y % 2 == 0 then
				local node = _maze:getNode(_x/2, _y/2)
				if node ~= nil then
					node:draw()
				end
			else
				local tile = _maze:getTile(_x, _y)
				if tile ~= nil then
					tile:draw()
				end
			end
			love.graphics.pop()
		end
	end
end

function love.quit()
end