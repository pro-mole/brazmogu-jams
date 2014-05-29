-- LOST IN MAZE

require("maze")

sound_step = love.audio.newSource("assets/sound/step.wav")

game_stack = {"title"}

function loadCard(name)
	local I = love.graphics.newImage("assets/cards/"..name..".png")
	I:setFilter("nearest","nearest")
	return I
end

function love.load()
	title_card = loadCard("title")
	good_end = loadCard("end")
	bad_end = loadCard("badend")

	scale = love.window.getWidth()/32
	print(string.format("%dX", scale))
end

function love.keypressed(key, isrepeat)
	local top = game_stack[#game_stack]
	
	if top == "title" then
		if key == "escape" then love.event.quit() end
		if key == " " then
			player_x, player_y = 16,30
			_maze = Maze.generate(15,"up")
			_maze:print()
			table.insert(game_stack,"maze")
			print (game_stack[#game_stack])
		end
	elseif top == "maze" then
		if key == "up" or key == "down" or key == "left" or key == "right" then
			local delta = {up = {0,-1}, down = {0,1}, left = {-1,0}, right = {1,0}}
			local _x = player_x + delta[key][1]
			local _y = player_y + delta[key][2]
			if _x < 1 or _x > _maze.board_size or _y < 1 or _y > _maze.board_size then
				table.insert(game_stack,"end")
			else
				local T = _maze:getTile(_x,_y)
				if T.content ~= "#" and not sound_step:isPlaying() then
					player_x = _x
					player_y = _y
					sound_step:play()
				end
			end
		end
		
		if key == "escape" then
			table.remove(game_stack)
		end
	elseif top == "end" or top == "badend" then
		if key == "escape" then love.event.quit() end
		if key == " " then
			repeat
				table.remove(game_stack)
			until #game_stack == 1
		end
	end
end

function love.update(dt)
end

function love.draw()
	local top = game_stack[#game_stack]
	love.graphics.setColor(255,255,255,255)
	love.graphics.scale(scale,scale)
	
	if top == "title" then -- Draw Title Screen
		love.graphics.draw(title_card, 0, 0)
	elseif top == "maze" then -- Draw Game Maze
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
				
				local tile = _maze:getTile(_x, _y)
				if tile ~= nil then
					tile:draw()
				end
				
				if _x % 2 == 0 and _y % 2 == 0 then
					local node = _maze:getNode(_x/2, _y/2)
					if node ~= nil then
						node:draw()
					end
				end
				
				if x == 0 and y == 0 then
					love.graphics.setColor(255,255,255,255)
					love.graphics.rectangle("fill", 3, 1, 4, 8)
					love.graphics.rectangle("fill", 2, 2, 6, 6)
					love.graphics.setColor(0,0,0,255)
					love.graphics.rectangle("fill", 3, 4, 1, 1)
					love.graphics.rectangle("fill", 6, 4, 1, 1)
					love.graphics.rectangle("fill", 3, 6, 4, 1)	
				end
				love.graphics.pop()
			end
		end
	else -- Draw Event Card
		if top == "end" then
			love.graphics.draw(good_end, 0, 0)
		end
	end
end

function love.quit()
end