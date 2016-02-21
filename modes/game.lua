game = {
	simulationtime = 0,
	accumulator = 0,
	bullets = {},
	gameOver = nil,
	gameOverTimeout = 0,
	trueGameOver = nil,
	winnerTextOffset = 0,
	gameOverAnimation = nil,
	winner = nil,
	playAgainImage = nil
}

FRAME_SPEED = 1/60

function game.load()
	game.simulationtime = 0
	game.accumulator = 0
	game.bullets = {}
	game.gameOver = false
	game.trueGameOver = false
	game.gameOverTimeout = 0
	game.winnerTextOffset = -10
	game.winner = nil
	game.playAgainImage = love.graphics.newImage("restart.png")
	collectgarbage()
end

function game.enter()
	game.bullets = {}
end

function game.update(dt)
	game.simulationtime = game.simulationtime + dt
	game.accumulator = game.accumulator + dt
	screenshake:update(dt)

	while game.accumulator > FRAME_SPEED do
		game.accumulator = game.accumulator - FRAME_SPEED
		playermanager.updatePlayers(FRAME_SPEED, false)
		--tick("updating all game.bullets")
		for i = #game.bullets,1,-1 do
			local b = game.bullets[i]
			if b:update(FRAME_SPEED) then table.remove(game.bullets,i) end
		end
		--tock("updating all game.bullets", 2)192
	end
	local numAlive = 0
	for i, player in ipairs(playermanager.players) do
		if (not player.dead) and player.active then
			numAlive = numAlive + 1
		end
	end
	if (not game.gameOver) and (numAlive <= 1) then
		game.gameOver = true
		game.gameOverTimeout = game.simulationtime
	end
	if (game.gameOverTimeout + 1.5 < game.simulationtime) and not game.trueGameOver and game.gameOver then
		game.trueGameOver = true
		game._determineWinner()
		game.gameOverAnimation = tween.new(0.5, game, {winnerTextOffset = 108.0/2}, "outBounce")
	end
	if game.trueGameOver then
		game.gameOverAnimation:update(dt)
	end
end

function game._determineWinner()
	local winner = 5
	local winnerImages = {"player-1-wins.png", "player-2-wins.png", "player-3-wins.png", "player-4-wins.png", "draw.png"}
	for i, p in ipairs(playermanager.players) do
		if not p.dead then
			winner = i
		end
	end
	game.winner = love.graphics.newImage(winnerImages[winner])
end

function game.draw()
	for i,v in ipairs(game.bullets) do v:draw() end
	playermanager.drawPlayers(false)
	if game.trueGameOver then
		love.graphics.draw(game.winner, 192/2 - game.winner:getWidth()/2 - 0.5, game.winnerTextOffset - game.winner:getHeight()/2 - 5)
		love.graphics.draw(game.playAgainImage, 192/2 - game.playAgainImage:getWidth()/2 - 0.5, game.winnerTextOffset - game.playAgainImage:getHeight()/2 + 35)
	end
end

function game.keypressed(key)
	if key == "return" and game.trueGameOver then
		currentMode = "introscreen"
		initialize()
	end
end

return game
