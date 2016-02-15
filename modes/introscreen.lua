introscreen = {
   simulationtime = 0
}

function introscreen.load()
   introscreen.logo = love.graphics.newImage("blimpwars-logo.png")
   introscreen.buttontext = love.graphics.newImage("join-start-text.png")
end

function introscreen.update(dt)
   introscreen.simulationtime = introscreen.simulationtime + dt
   playermanager.update(dt, true)
end

function introscreen.draw()
   playermanager.drawPlayers(true)
   love.graphics.draw(introscreen.logo, 192/2 - introscreen.logo:getWidth()/2, 108/2 - introscreen.logo:getHeight()/2 - 8 + 4.8*math.sin(introscreen.simulationtime/2))
   love.graphics.draw(introscreen.buttontext, 192/2 - introscreen.buttontext:getWidth()/2, 108/2 - introscreen.buttontext:getHeight()/2 + 13 + 4.8*math.sin(introscreen.simulationtime/2 + 0.8))
end

function introscreen.keypressed(key)
   if key == "1" or key == "2" or key == "3" or key == "4" then
      if love.keyboard.isDown("lshift") then
	 playermanager.wantsLeave(tonumber(key))
      else
	 playermanager.wantsJoin(tonumber(key))
      end
   end
   if key == "return" then
      introscreen._transitionToGameMode()
   end
   if key == "backspace" then
      introscreen._transitionToCredits()
   end
end

function introscreen._transitionToGameMode()
   -- TODO: needs mechanism for delayed transition. E.g. when transitioning
   -- TODO: to gamemode, we need to fade out the logo etc. Might also want
   -- TODO: to move the players into position first when the game starts.
   if playermanager.getNumActivePlayers() < 2 then
      print("too few active players: ", playermanager.getNumActivePlayers())
      -- TODO: indicate to the user somehow
      return
   end
   for i, p in ipairs(playermanager.players) do
      p.wobble = false
      p.autoAim = false
   end
   currentMode = "game"
end

function introscreen._transitionToCredits()
   currentMode = "credits"
end

return introscreen
