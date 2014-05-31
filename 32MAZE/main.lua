-- LOST IN MAZE

require("maze")

sound_step = love.sound.newSoundData("assets/sound/step.wav")
steps = {}
stepwait = 0

function step()
	if #steps >= 10 then
		local old_step = steps[1]
		if old_step:isPlaying() then old_step:stop() end
		table.remove(steps, 1)
	end
	
	local new_step = love.audio.newSource(sound_step)
	new_step:play()
	table.insert(steps, new_step)
end

game_stack = {"title"}
function game_stack:rewind()
	repeat
		table.remove(self)
	until #self == 1
end

event = {}

cards = {}

function loadCard(name)
	local I = love.graphics.newImage("assets/cards/"..name..".png")
	I:setFilter("nearest","nearest")
	return I
end

function love.load()
	title_card = loadCard("title")
	cards["end_good"] = {loadCard("ending1"), loadCard("ending2"), loadCard("end"), loadCard("credits")}
	
	cards["end_bad"] = {loadCard("badend"), loadCard("tryagain")}

	cards["comfort"] = {loadCard("comfort1"), loadCard("comfort2")}
	
	cards["setback"] = {loadCard("setback1"), loadCard("setback2")}

	cards["crossroads"] = {loadCard("crossroads1"), loadCard("crossroads2")}

	cards["quantumleap"] = {loadCard("quantumleap1"), loadCard("quantumleap2")}

	cards["shortcut"] = {loadCard("shortcut1"), loadCard("shortcut2")}

	scale = love.window.getWidth()/32
	print(string.format("%dX", scale))
end

function love.resize(w, h)
	if w < h then
		scale = love.window.getWidth()/32
	else
		scale = love.window.getHeight()/32
	end
end

function love.keypressed(key, isrepeat)
	local top = game_stack[#game_stack]
	
	if top == "title" then
		if key == "escape" then love.event.quit() end
		if key == " " then
			local maze_size = 25
			player_memory = {maze_size+1,maze_size*2} -- Record our initial position for setbacks
			player_x, player_y = unpack(player_memory)

			_maze = Maze.generate(maze_size,"up")
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
				table.insert(game_stack,"event")
				event = {kind = "end", name = "end_good", page = 1}
			else
				local T = _maze:getTile(_x,_y)
				if T.content ~= "#" and stepwait == 0 then
					stepwait = 1/4
					player_x = _x
					player_y = _y
					step()
				end
				
				if _x % 2 == 0 and _y % 2 == 0 then
					local N = _maze:getNode(_x/2, _y/2)
					if N.event then
						table.insert(game_stack,"event")
						event = {kind = N.event.kind, name = N.event.name, page = 1}
						N.event = nil
						for k,v in pairs(event) do
							print(k,v)
						end
					end
				end
			end
		end
		
		if key == "escape" then
			table.remove(game_stack)
		end
	elseif top == "event" then
		if event.page == #cards[event.name] then
			if key == " " then
				local kind = event.kind
				event = {}
				if kind == "end" then
					game_stack:rewind()
				elseif kind == "deadend" then
					event = {kind = "end", name = "end_bad", page = 0}
				elseif kind == "setback" then
					player_x, player_y = unpack(player_memory)
					table.remove(game_stack)
				elseif kind == "crossroads" then
					player_memory = {player_x, player_y}
					table.remove(game_stack)
				elseif kind == "leap" then
					repeat
						player_x, player_y = math.random(_maze.board_size), math.random(_maze.board_size)
						local _T = _maze:getTile(player_x, player_y)
					until _T.content == " " and (player_x % 2 == 1 or player_y %2 == 1)
					table.remove(game_stack)
				else
					table.remove(game_stack)
				end
			end
		end
		
		if event.page then
			if event.page > 1 then
				if key == "left" then
					event.page = event.page - 1
				end
			end
			if event.page < #cards[event.name] then
				if key == " " or key == "right" then
					event.page = event.page + 1
				end
			end
			
			if key == "escape" then
				event = {}
				game_stack:rewind()
			end
		end
	end
end

function love.update(dt)
	if stepwait > 0 then
		stepwait = stepwait - dt
		if stepwait < 0 then stepwait = 0 end
	end
end

function love.draw()
	local top = game_stack[#game_stack]
	love.graphics.setColor(255,255,255,255)
	love.graphics.scale(scale,scale)
	
	if top == "title" then -- Draw Title Screen
		love.graphics.draw(title_card, 0, 0)
	elseif top == "maze" then -- Draw Game Maze
		-- Do NOT use love.graphics.line, since LÖVE seems to draw scaled lines centered on the end points
		love.graphics.setColor(255,255,255,128)
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
		love.graphics.draw(cards[event.name][event.page], 0, 0)
	end
end

function love.quit()
end