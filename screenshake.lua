----------- SCREENSHAKE CODE ---------
------ Usage ------
-- In love.load, have 'screenshake = require "screenshake"'
-- In love.update, have 'screenshake:update(dt)'
-- In love.draw, surround what you want to shake with 'screenshake:start()' and 'screenshake:end()'
-- Use 'screenshake(radius,time)' whenever to shake the screen for 'time' seconds, with a max shake of 'radius' pixels


local ss = {radius = 0,angle = 0,time=0,ms = 0}
local ssm = {}
function ssm:__call(radius,time)
	self.radius = radius
	local calls = time/0.015
	self.ms = math.exp(math.log(0.5/radius)/calls)
	self.angle = math.random()*math.pi*2
end


function ss:update(dt)
	self.time = self.time + dt
	while self.time > 0.015 do
		self.time = self.time - 0.015
		self.radius = self.radius*self.ms
		self.angle = self.angle + 2/3*math.pi +  math.random()*2/3*math.pi

		while self.angle > 2*math.pi do self.angle = self.angle - 2* math.pi end
		while self.angle < 0 do self.angle = self.angle + 2* math.pi end
	end
end

function ss:start()
	love.graphics.push()
	local xOffset = math.sin(self.angle) * self.radius
	local yOffset = math.cos(self.angle) * self.radius
	love.graphics.translate(xOffset, yOffset)
end

function ss:stop()
	love.graphics.pop()
end
return setmetatable(ss,ssm)