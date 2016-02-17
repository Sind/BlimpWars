-- AI module, hooks into a dummyInput.
ai = class()

function ai:init(playerObject, inputObject)
	self.timer = 0
	self.shotTimer = 0
	self.player = playerObject
	self.input = inputObject
	self.dodgequeue = {}
	--playermanager.wantsJoin(self)
end

-- target coordinates. self must already be at (0, 0).
function ai.targetCoordinates(x, y)
	local GRAVITY = 100
	local v = 1.2
	return math.atan(v^2 + math.sqrt(v^4 - GRAVITY*(GRAVITY*x^2 + 2*y*v^2))/(GRAVITY*x))
end

function ai:update(dt)
	self.timer = self.timer + dt
	self.shotTimer = self.shotTimer + dt
	if self.timer > 1.0 then
		self.timer = 0
		self.input.movementDirections.up = util.randomBool(0.85)
		self.input.movementDirections.left = util.randomBool(0.5)
		self.input.movementDirections.right = util.randomBool(0.5)
		---self.input.firing = util.randomBool(0.3)
	end
	self.input.firing = true
	if self.shotTimer > 1.0 then
		self.shotTimer = 0
		self.input.firing = false
		if math.abs(self.input.aimDirection.x) < 0.1 then
			--print("initiating emergency dodge!")
			for i = 1,120 do -- dodge for N frames
				if self.player.pos.x < 192/2 then
					table.insert(self.dodgequeue, 1)
				else
					table.insert(self.dodgequeue, 2)
				end
			end
		end
	end
	local targetedPlayerDistance = 1/0
	local targetedPlayerPosition = nil;
	for i, p in ipairs(playermanager.players) do
		if p.active and not p.dead and p ~= self.player then
			if not p.ai then
				targetedPlayerDistance = p.pos.dist(p.pos, self.player.pos)
				targetedPlayerPosition = p.pos:clone()
				break
			end
			if p.pos.dist(p.pos, self.player.pos) < targetedPlayerDistance and p ~= self.player then
				targetedPlayerDistance = p.pos.dist(p.pos, self.player.pos)
				targetedPlayerPosition = p.pos:clone()
			end
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
	else
		--print("found no player to target")
	end
	--local angle = ai.targetCoordinates(192/2 - self.player.pos.x, 108/2 + self.player.pos.y)
	--self.input.aimDirection = vec2(math.cos(angle), math.sin(angle))
	for i, b in ipairs(game.bullets) do
		local bulletToSelfVector = (b.pos - self.player.pos):normalized()
		local dotProd = bulletToSelfVector*b.vel:normalized()
		if math.abs(dotProd - 1) < 0.1 then
			for i = 1,5 do
				table.insert(self.dodgequeue, 2)
				--print("bullet dodge")
			end
		end
	end
	-- perform an emergency dodge
	if #self.dodgequeue ~= 0 then
		local action = table.remove(self.dodgequeue, 1)
		if action == 1 then
			self.input.movementDirections.right = true
		elseif action == 2 then
			self.input.movementDirections.left = true
		else
			self.input.movementDirections.up = true
		end
	end
end
