introscreen = {
	simulationtime = 0,
	transitionAnimations = {},
	isTransitioning = false,
	bannerOffset = 0,
	notificationAnimation = nil,
	notificationImage = nil,
	notificationOffset = -10,
}

function introscreen.load()
	introscreen.simulationtime = 0
	introscreen.transitionAnimations = {}
	introscreen.isTransitioning = false
	introscreen.bannerOffset = 0
	introscreen.notificationAnimation = nil
	introscreen.logo = love.graphics.newImage("blimpwars-logo.png")
	introscreen.buttontext = love.graphics.newImage("join-start-text.png")
	introscreen.notificationImage = love.graphics.newImage("need-more-players.png")
	introscreen.notificationOffset = -10

	if roundStates.actives then
		for i, p in ipairs(roundStates.actives) do
			print("setting player", p, "auto-active, since player participated in last round.")
			playermanager.wantsJoinId(p)
		end
	end
	collectgarbage()
end

function introscreen.update(dt)
	introscreen.simulationtime = introscreen.simulationtime + dt
	playermanager.update(dt, true)
	if introscreen.isTransitioning then
		for i = #introscreen.transitionAnimations,1,-1 do
			local res = introscreen.transitionAnimations[i]:update(dt)
			if res then
				table.remove(introscreen.transitionAnimations, i)
			end
		end
		if #introscreen.transitionAnimations == 0 then
			introscreen.isTransitioning = false
			introscreen.bannerOffset = 0
			introscreen._transitionToGameMode()
		end
	end
	if introscreen.notificationAnimation then
		local done = introscreen.notificationAnimation:update(dt)
		if done then
			introscreen.notificationOffset = -10
			introscreen.notificationAnimation = nil
		end
	end
end

function introscreen.draw()
	playermanager.drawPlayers(true)
	love.graphics.draw(introscreen.logo, 192/2 - introscreen.logo:getWidth()/2,
					   108/2 - introscreen.logo:getHeight()/2 - 8 + 4.8*math.sin(introscreen.simulationtime/2) + introscreen.bannerOffset)
	love.graphics.draw(introscreen.buttontext, 192/2 - introscreen.buttontext:getWidth()/2,
					   108/2 - introscreen.buttontext:getHeight()/2
						   + 13 + math.min(4.8*math.sin(introscreen.simulationtime/2 + 0.8), 3) + introscreen.bannerOffset)
	if introscreen.notificationAnimation then
		love.graphics.draw(introscreen.notificationImage,
						   192/2 - introscreen.notificationImage:getWidth()/2,
						   introscreen.notificationOffset - introscreen.notificationImage:getHeight()/2)
	end
end

function introscreen.keypressed(key)
	if key == "1" or key == "2" or key == "3" or key == "4" then
		if love.keyboard.isDown("lshift") then
			-- TODO: once gamepads and players are associated, probably don't use byId here?
			playermanager.wantsLeaveId(tonumber(key))
		else
			playermanager.wantsJoinId(tonumber(key))
		end
	end
	if key == "return" and not introscreen.isTransitioning then
		-- NOTE: read the warning about the special semantics of the
		-- NOTE: roundStates variable in main.lua!
		local actives = {}
		for i, p in ipairs(playermanager.players) do
			if p.active then
				table.insert(actives, i)
			end
		end
		roundStates["actives"] = actives

		if playermanager.getNumActivePlayers() < 2 then
			print("too few active players: ", playermanager.getNumActivePlayers())
			if not introscreen.notificationAnimation then
				introscreen.notificationAnimation = tween.new(1.5, introscreen, {notificationOffset = 108 + 80}, "outInExpo")
			end
			return
		end
		introscreen.isTransitioning = true
		playermanager.movePlayersToAssignedPositions()
		table.insert(introscreen.transitionAnimations, tween.new(1, introscreen, {bannerOffset = -100}, "inOutBack"))
		for i, p in ipairs(playermanager.players) do
			if not p.active then
				local newPos = p.pos:clone()
				newPos.y = newPos.y + 40
				table.insert(introscreen.transitionAnimations, tween.new(1, p.pos, newPos, "inOutQuint"))
			end
		end
	end
	if key == "backspace" then
		introscreen._transitionToCredits()
	end
end

function introscreen._transitionToGameMode()
	for i, p in ipairs(playermanager.players) do
		p.wobble = false
		p.autoAim = false
	end
	currentMode = "game"
	game.enter()
end

function introscreen._transitionToCredits()
	currentMode = "credits"
end

return introscreen
