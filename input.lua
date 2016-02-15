-- This family of classes provides semantically mapped access to an
-- input device such as a joystick, keyboard or a dummy input generator.
inputDummy = class()

function inputDummy:init()
   self.timer = 0
   self.movementDirections = {up=false, left=false, right=false}
   self.aimDirection = vec2(0, 1)
   self.firing = false
end

function inputDummy:update(dt)
   self.timer = self.timer + dt
   if self.timer > 1 then
      print("rerolling inputs")
      self.timer = 0
      self.movementDirections.up = util.randomBool(0.8)
      self.movementDirections.left = util.randomBool(0.5)
      self.movementDirections.right = util.randomBool(0.5)
   end
end

function inputDummy:getMovementDirections()
   return self.movementDirections
end

function inputDummy:getAimDirection()
   return self.aimDirection
end

function inputDummy:getFire()
   return self.firing
end

function inputDummy:vibrate(boolean) end
