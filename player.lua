player = class()

function player:init(pos, joystick, angle, color)
	print("player made: " .. pos.x .. " " .. pos.y)
	self.pos = pos
	self.joystick = joystick
	self.cannon = angle
	self.bulletReset = false
	self.radius = 7
	self.hitTimer = 0
	self.charge = 0
	self.mainColor = color
	self.wobble = true
	self.wobbleX = love.math.random(100)
	self.wobbleY = love.math.random(100)
	self.autoAim = true
end

function player:update(dt)
	self.hitTimer = self.hitTimer - dt
	if self.hitTimer < 0 then self.joystick:setVibration(0,0) end
	if self.dead then return true end
	local anglevec = vec2(self.joystick:getAxis(4),-self.joystick:getAxis(5))
	local angle = vec2(0,0):angleTo(anglevec)
	if angle > math.pi/2 then angle = -math.pi
	elseif angle > 0 then angle = 0 end
	if anglevec:len() > 0.4 then self.cannon = angle end

	self.pos.y = self.pos.y + 25*dt

	-- if self.joystick:getAxis(2) > JOYSTICK_CUTOFF then
	-- 	self.pos.y = self.pos.y + dt*50
	-- end

	if self.joystick:getAxis(2) < - JOYSTICK_CUTOFF then
		self.pos.y = self.pos.y - dt*66
	end
	if self.joystick:getAxis(1) < - JOYSTICK_CUTOFF then
		self.pos.x = self.pos.x - dt*50 * (1.0 - self.charge*0.5)
	end
	if self.joystick:getAxis(1) > JOYSTICK_CUTOFF then
		self.pos.x = self.pos.x + dt*50 * (1.0 - self.charge*0.5)
	end
	self.pos.x = math.min(192,math.max(0,self.pos.x))
	self.pos.y = math.min(108,math.max(0,self.pos.y))
	-- if self.joystick:getAxis(6) < JOYSTICK_CUTOFF then
	-- 	if self.bulletReset == true then
	-- 		self.bulletReset = false
	-- 	end
	-- end
	if    self.joystick:getAxis(6) > JOYSTICK_CUTOFF
	   -- or self.joystick:getAxis(6) < -JOYSTICK_CUTOFF
	   or self.joystick:isDown(5,6) then
	   -- print("charging")
	   self.charge = math.min(1.2,self.charge + dt)
	else
		if self.charge > 0.25 then
			local pos = self.pos + vec2(9,0):rotated(self.cannon)
			local b = bullet:new(pos,vec2(self.charge*BULLET_FORCE*math.cos(self.cannon),self.charge*BULLET_FORCE*math.sin(self.cannon)))
			table.insert(bullets,b)
		end
		self.charge = 0
	end
	--    and not self.bulletReset then
	-- -- if self.joystick:getAxis(6) > JOYSTICK_CUTOFF then
	-- 	self.bulletReset = true
	-- 	local b = bullet:new(self.pos,vec2(BULLET_FORCE*math.cos(self.cannon),BULLET_FORCE*math.sin(self.cannon)))
	-- 	table.insert(bullets,b)
	-- end
end

function player:draw()
	if self.dead then return end
	local position = self.pos
	if self.wobble then
		local time = love.timer.getTime()
		position.x = 0.03*math.cos(time + self.wobbleX) + position.x
		position.y = 0.03*math.sin(time + self.wobbleY) + position.y
	end
	local rotation = self.cannon
	if self.autoAim then
		rotation = util.roundAngleToNearestValid(util.angle(position.x, position.y, 192/2, 108/2)) -- TODO: magic values
	end
	blimp.draw(self.pos, rotation, self.mainColor, self.active)
end
function player:hit(bullet,dt)
	self.joystick:setVibration(0.5,0.5)
	self.pos = self.pos + 4*bullet.vel*dt
	-- local pieces = math.random(2,5)
	-- for i = 1,pieces do
	-- 	local rotate = math.random(-30,30)/180*math.pi
	-- 	local v = (bullet.vel):rotated(rotate)/2
	-- 	local c = bullet:new(bullet.pos,v,true)
	-- 	table.insert(bullets,c)
	-- end
	self.hitTimer = 1
	self.dead = true
	local deadvec = {3,5,6,7,7,6,5,3,2,2,1}
	for i = 1,#deadvec do
		for j = 1,deadvec[i] do
			local color = (i > 8 and PLAYER_COLOR_SUB or self.mainColor)
			local y = self.pos.y-8+i
			local x = self.pos.x-(j-1)
			local x2 = self.pos.x+j-1

			local rotate = math.random(-30,30)/180*math.pi
			local v = (bullet.vel):rotated(rotate)/2
			local c = bullet:new(vec2(x,y),v,true,color)

			local rotate = math.random(-30,30)/180*math.pi
			local v = (bullet.vel):rotated(rotate)/2
			local d = bullet:new(vec2(x2,y),v,true,color)
			table.insert(bullets,c)
			table.insert(bullets,d)
		end
	end
end
