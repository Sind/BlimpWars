require "timer"
bullet = class()
GRAVITY = 100
function bullet:init(start, velocity, isConfetti, color)
	self.pos = start:clone()
	self.vel = velocity
	self.time = 0
	self.radius = 1
	self.confetti = isConfetti
	self.color = color or (isConfetti and BLIMP_COLOR_MAIN or colors.BULLET_COLOR)
end

function bullet:update(dt)
	tick("bullet update")
	self.time = self.time + dt
	self.vel.y = self.vel.y + GRAVITY*dt
	self.pos = self.pos + self.vel *dt
	if self.pos.y > 110 then return true end
	if self.confetti then return false end
	if self.time > 0.15 then
		-- TODO: should this be more decoupled so that collisions are checked in playermanager or so?
		for i,v in ipairs(playermanager.players) do
			if not v.dead and isColliding(v,self) then
				v:hit(self,dt)
				screenshake(25,0.7)
				return true
			end
		end
	end
	tock("bullet update", 0.5)
end

function bullet:draw()
	love.graphics.setColor(self.color)
	love.graphics.circle("fill", self.pos.x, self.pos.y, 1)
	love.graphics.setColor(colors.WHITE)
end

function isColliding(a,b)
	local dist = (a.pos - b.pos):len()
	return a.radius + b.radius > dist
end
