--these are the variables for the window height and width
WINDOW_WIDTH=1280
WINDOW_HEIGHT=720

PADDLE_SPEED = 200

ball = {}

--this function runs once at startup
function love.load()
	--this creates a random seed for later use
	math.randomseed(os.time())

	--this sets the title of the window that pops up
	love.window.setTitle('PONG!')

	--this makes a window that has a defined width and height, is not fullscreen,
	--is not resizable, and is synced with the monitors refresh rate
	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen=false,
		resizable=false,
		vsync=true
	})

	--makes the images on screen crisper
	love.graphics.setDefaultFilter("nearest", "nearest")

	--this creates a font variable
	smallFont = love.graphics.newFont('font.ttf', 25)

	--this is the score font
	scoreFont = love.graphics.newFont('font.ttf', 100)

	--these are the variables for the paddles and ball
	player1 = {}
	player1.x = 10
	player1.y = 10
	player1.width = 20
	player1.height = 90
	player1.score = 0

	player2 = {}
	player2.x = WINDOW_WIDTH - 30
	player2.y = WINDOW_HEIGHT - 100
	player2.width = 20
	player2.height = 90
	player2.score = 0

	ball.x = WINDOW_WIDTH / 2 - 2
	ball.y = WINDOW_HEIGHT / 2 - 2
	ball.width = 4
	ball.height = 4
	ball.dx = math.random(2) == 1 and 100 or -100 --These vars are where the ball gets its 2d velocity/trajectory
	ball.dy = math.random(-50, 50) * 1.5

	--this is a variable to store the game's state
	gameState = 'start'

	--this variable is for the serving player
	servingPlayer = 0
end

--this function repetitively runs
function love.update(dt)
	if gameState == 'serve' then
		ball.dy = math.random(-50, 50)
		ball:reset()
		if servingPlayer == 1 then
			ball.dx = math.random(140, 200)
		else
			ball.dx = -math.random(140, 200)
		end

	elseif gameState == 'play' then
		--[[THIS CODE DEALS WITH PLAYER MOVEMENT]]
		--this section of the code deals with the player 1 movement
		--if the 'w' key is down then move the player up
		if love.keyboard.isDown('w') then
			player1.y = player1.y + -PADDLE_SPEED * dt
		end
		--if the 's' key is pressed, move the player down
		if love.keyboard.isDown('s') then
			player1.y = player1.y + PADDLE_SPEED * dt
		end
		--this section deals with the player 2 movement
		--if the up key is being pressed then move the player up
		if love.keyboard.isDown('up') then
			player2.y = player2.y + -PADDLE_SPEED * dt
		end
		--if the down key is being pressed then move the player down
		if love.keyboard.isDown('down') then
			player2.y = player2.y + PADDLE_SPEED * dt
		end



		--[[COLLISION DETECTION]]
		--for player 1
		if player1.y <= 0 then
			player1.y = 0
		end
		if (player1.y + player1.height) >= WINDOW_HEIGHT then
			player1.y = WINDOW_HEIGHT - player1.height
		end

		--for player 2
		if player2.y <= 0 then
			player2.y = 0
		end
		if (player2.y + player2.height) >= WINDOW_HEIGHT then
			player2.y = WINDOW_HEIGHT - player2.height
		end

		ball.x = ball.x + ball.dx * dt
		ball.y = ball.y + ball.dy * dt

		--for the ball and paddles
		if ball:collides(player1) then
			ball.dx = -ball.dx * 1.03
			ball.x = player1.x + 20

			--increment the score
			player1.score = player1.score + 1

			--keep the velocity going the same direction but randomize it
			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end
		end

		if ball:collides(player2) then
			ball.dx = -ball.dx * 1.03
			ball.x = player2.x - ball.width

			--increment the score
			player2.score = player2.score + 1	

			--keep the velocity going the same direction but randomize it
			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end
		end

		--for the ball and the end of the screen (bottom and up)
		if ball.y <= 0 then
			ball.y = 0
			ball.dy = -ball.dy
		end

		if ball.y >= WINDOW_HEIGHT - ball.height then
			ball.y = WINDOW_HEIGHT - ball.height
			ball.dy = -ball.dy
		end

		--for when the ball reaches the sides of the screen
		if ball.x <= 0 then
			servingPlayer = 1
			player2.score = player2.score + 1
			ball:reset()
			gameState = 'serve'
		end

		if (ball.x + ball.width) >= WINDOW_WIDTH then
			servingPlayer = 2
			player1.score = player1.score + 1
			ball:reset()
			gameState = 'serve'
		end
	end
end

function ball:collides(paddle)
	if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
		return false
	end

	if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
		return false
	end

	return true
end

function ball:reset()
	ball.x = WINDOW_WIDTH / 2 - 2
	ball.y = WINDOW_HEIGHT / 2 - 2
	ball.dx = math.random(2) == 1 and 100 or -100
	ball.dy = math.random(-50, 50) * 1.5
end


--this function checks for key presses repeatedly
function love.keypressed(key)
	--for exiting the program
	if key == 'escape' then
		love.event.quit()
	end
	--for switching between game states with the 'enter' or 'return' button
	if key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'play'
		elseif gameState == 'serve' then
			gameState = 'play'
		else
			gameState = 'start'

			--resets the ball's position and velocities
			ball:reset()
		end
	end
end


--this function draws everything onto the screen each frame
function love.draw()
	--[[SETTING THE BACKGROUND COLOR]]
	love.graphics.clear(40/255, 45/255, 52/255, 1)

	--[[DIFFERENT MESSAGES FOR DIFFERENT GAME STATES]]
	--draws a welcome message if the game state is at 'start'
	if gameState == 'start' then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(smallFont)
		love.graphics.printf("Press ENTER to play!", 0, 20, WINDOW_WIDTH, "center")
	--draws 'PONG!' if the game state is 'play'
	elseif gameState == 'play' then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(smallFont)
		love.graphics.printf("PONG!", 0, 20, WINDOW_WIDTH, "center")
	elseif gameState == 'serve' then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setFont(smallFont)
		love.graphics.printf("Player " .. tostring(servingPlayer) .. " Serve!", 0, 20, WINDOW_WIDTH, "center")
	end

	--[[DISPLAYING THE SCORES OF BOTH PLAYERS]]
	love.graphics.setFont(scoreFont)
	love.graphics.print(tostring(player1.score), WINDOW_WIDTH / 2 - 150, WINDOW_HEIGHT / 3)
	love.graphics.print(tostring(player2.score), WINDOW_WIDTH / 2 + 100, WINDOW_HEIGHT / 3)


	--[[DRAWING THE KEY ELEMENTS]]
	--draws the first paddle with the params being (fill, x, y, width, height) and being on the left side of the screen
	love.graphics.rectangle("fill", player1.x, player1.y, player1.width, player1.height)
	--draws the ball in the center
	love.graphics.rectangle("fill", ball.x, ball.y, 20, 20)
	--draws the second paddle (right hand side)
	love.graphics.rectangle("fill", player2.x, player2.y, player2.width, player2.height)


	--[[MONITORING THE FPS]]
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0, 1, 0, 1)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end
