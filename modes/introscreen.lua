introscreen = {
   simulationtime = 0
}

function introscreen.load()
   introscreen.logo = love.graphics.newImage("blimpwars-logo.png")
   introscreen.buttontext = love.graphics.newImage("join-start-text.png")
end

function introscreen.update(dt)
   introscreen.simulationtime = introscreen.simulationtime + dt
   playermanager.update(dt)
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
   if key == "enter" then
      -- progress into gamemode here somehow
   end
end

return introscreen
