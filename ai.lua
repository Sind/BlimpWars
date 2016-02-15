-- AI module, hooks into a dummyInput.
ai = class()

function ai:init(playerObject, inputObject)
   self.timer = 0
   self.shotTimer = 0
   self.player = playerObject
   self.input = inputObject
end

function ai:update(dt)
   self.timer = self.timer + dt
   self.shotTimer = self.shotTimer + dt
   if self.timer > 0.5 then
      self.timer = 0
      self.input.movementDirections.up = util.randomBool(0.85)
      self.input.movementDirections.left = util.randomBool(0.5)
      self.input.movementDirections.right = util.randomBool(0.5)
      ---self.input.firing = util.randomBool(0.3)
   end
   self.input.firing = true
   if self.shotTimer > 1.3 then
      self.shotTimer = 0
      self.input.firing = false
   end
   local targetedPlayerDistance = 1/0
   local targetedPlayerPosition = nil;
   for i, p in ipairs(playermanager.players) do
      if p.active and not p.dead and p.pos.dist(p.pos, self.player.pos) < targetedPlayerDistance and p ~= self.player then
	 targetedPlayerDistance = p.pos.dist(p.pos, self.player.pos)
	 targetedPlayerPosition = p.pos:clone()
      end
   end
   if targetedPlayerPosition then
      local heightCorrectionFactor = math.max(0.6*targetedPlayerDistance, 50)
      targetedPlayerPosition.y = targetedPlayerPosition.y - heightCorrectionFactor
      self.input.aimDirection = targetedPlayerPosition - self.player.pos
      self.input.aimDirection.y = -self.input.aimDirection.y
      -- always try to fall at least 6 pixels below the player we're targetting.
      if targetedPlayerPosition.y > self.player.pos.y + 6 then
	 self.input.movementDirections.up = false
      end
      -- when shooting straight up, simply doge to the right.
      if math.abs(self.input.aimDirection.x) < 0.01 then
	 self.input.movementDirections.right = true
      end
   else
      print("found no player to target")
   end
   
end
