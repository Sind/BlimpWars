-- This family of classes provides semantically mapped access to an
-- input device such as a joystick, keyboard or a dummy input generator.
inputDummy = class()

function inputDummy:init()
	self.timer = 0
	self.movementDirections = {up=false, left=false, right=false}
	self.aimDirection = vec2(0, 1)
	self.firing = false
	self.isDummyInput = true
end

function inputDummy:update(dt)

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

function inputDummy:vibrate(boolean)

end

inputGamepad = class()

function inputGamepad:init( joystick )
   self.timer = 0
   self.movementDirections = {up=false, left=false, right=false}
   self.aimDirection = vec2(0, 1)
   self.firing = false
   self.isDummyInput = false
   self.joystick = joystick
end

JOYSTICK_CUTOFF = 0.5
function inputGamepad:update(dt)
   local anglevec = vec2(self.joystick:getAxis(4),-self.joystick:getAxis(5))
   self.aimDirection = anglevec

   local firebutton =  self.joystick:getAxis(6) > JOYSTICK_CUTOFF or self.joystick:isDown(5,6)
   self.firing = firebutton

   self.movementDirections.right = self.joystick:getAxis(1) > JOYSTICK_CUTOFF
   self.movementDirections.left = self.joystick:getAxis(1) < - JOYSTICK_CUTOFF
   self.movementDirections.up = self.joystick:getAxis(2)  < -  JOYSTICK_CUTOFF
end

function inputGamepad:getMovementDirections()
   return self.movementDirections
end

function inputGamepad:getAimDirection()
   return self.aimDirection
end

function inputGamepad:getFire()
   return self.firing
end

function inputGamepad:vibrate(boolean)
   if boolean then
      print("vibrate!")
      self.joystick:setVibration(0.5, 0.5)
   else
      self.joystick:setVibration(0, 0)
   end
end
