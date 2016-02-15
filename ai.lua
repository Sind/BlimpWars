-- This family of classes provides semantically mapped access to an
-- input device such as a joystick, keyboard or a dummy input generator.
ai = class()

function ai:init(playerObject, inputObject)
   self.timer = 0
   self.player = playerObject
   self.input = inputObject
end

function ai:update(dt)
   self.timer = self.timer + dt
   if self.timer > 1 then
      print("rerolling inputs")
      self.timer = 0
      self.input.movementDirections.up = util.randomBool(0.8)
      self.input.movementDirections.left = util.randomBool(0.5)
      self.input.movementDirections.right = util.randomBool(0.5)
      self.input.firing = util.randomBool(0.3)
   end
   local targetedPlayerDistance = 1/0
   local targetedPlayerPosition = nil;
   for i, p in ipairs(playermanager.players) do
      if p.active and p.pos.dist(p.pos, self.player.pos) < targetedPlayerDistance then
	 targetedPlayerDistance = p.pos.dist(p.pos, self.player.pos)
	 targetedPlayerPosition = p.pos
      end
   end
   if targetedPlayerPosition then
      self.input.aimDirection = targetedPlayerPosition
   end
   
end
