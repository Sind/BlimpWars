game = {
   simulationtime = 0,
   accumulator = 0,
   bullets = {},
   keypressed = {}
}

FRAME_SPEED = 1/60

function game.load()

end

function game.update(dt)
   game.simulationtime = game.simulationtime + dt
   game.accumulator = game.accumulator + dt
   screenshake:update(dt)

   while game.accumulator > FRAME_SPEED do
      game.accumulator = game.accumulator - FRAME_SPEED
      playermanager.updatePlayers(FRAME_SPEED)
      tick("updating all game.bullets")
      if #game.bullets ~= 0 then -- put this into a bulletmanager or sth
	 for i = #game.bullets,1,-1 do
	    local b = game.bullets[i]
	    if b:update(FRAME_SPEED) then table.remove(game.bullets,i) end
	 end
      end
      tock("updating all game.bullets", 2)
   end
   playermanager.update(dt, false)
end

function game.draw()
   for i,v in ipairs(game.bullets) do v:draw() end
   playermanager.drawPlayers(false)
end

function game.keypressed(key)

end

return game
