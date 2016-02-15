game = {
   simulationtime = 0,
   accumulator = 0
}

function game.load()

end

function game.update(dt)
   game.simulationtime = game.simulationtime + dt
   game.accumulator = game.accumulator + dt
   screenshake:update(dt)
   
   while game.accumulator > FRAME_SPEED do
      game.accumulator = game.accumulator - FRAME_SPEED
      playermanager.updatePlayers(FRAME_SPEED)
      tick("updating all bullets")
      if #bullets ~= 0 then -- put this into a bulletmanager or sth
	 for i = #bullets,1,-1 do
	    local b = bullets[i]
	    if b:update(FRAME_SPEED) then table.remove(bullets,i) end
	 end
      end
      tock("updating all bullets", 2)
      keypressed = {}
   end
   playermanager.update(dt) -- TODO: disable updating inactive players?
end

function game.draw()
   for i,v in ipairs(bullets) do v:draw() end
   playermanager.drawPlayers(false)
end

return game
