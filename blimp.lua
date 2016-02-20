blimp = {}
require "colorscheme"

function blimp.load()
	local cannonImageData = love.image.newImageData(10, 2)
	-- wtf is this even doing, kek
	for i = 0,9 do for j = 0,1 do cannonImageData:setPixel(i,j,128,128,128) end end
	blimp.cannonImage = love.graphics.newImage(cannonImageData)
end

function blimp.draw(pos, cannonRotation, mainColor, active)
	local darken = 1.0
	if not active then darken = 0.2 end
	-- love.graphics.circle("line", self.pos.x, self.pos.y, 7)
	love.graphics.setColor(255*darken,255*darken,255*darken)
	love.graphics.draw(blimp.cannonImage, pos.x, pos.y, cannonRotation, 1, 1, 1, 1)
	love.graphics.setColor(darken*colors.BLIMP_COLOR_SUB[1], darken*colors.BLIMP_COLOR_SUB[2], darken*colors.BLIMP_COLOR_SUB[3])
	love.graphics.rectangle("fill", pos.x-2, pos.y, 4, 3)
	love.graphics.rectangle("fill", pos.x-1, pos.y, 2, 4)
	love.graphics.push()
	local blimpXloc = (pos.x/192-0.5)*2 -- TODO: magic number
	local blimpYloc = (pos.y/108-0.5)*2 -- TODO: magic number
	love.graphics.scale(1, 0.6)
	-- love.graphics.setColor(BLIMP_COLOR_MAIN[1]+SUN_COLOR[1]/4,BLIMP_COLOR_MAIN[2]+SUN_COLOR[2]/4,BLIMP_COLOR_MAIN[3]+SUN_COLOR[3]/4)
	love.graphics.setColor(mainColor[1]+60, mainColor[2]+50, mainColor[3]+10)
	love.graphics.circle("fill", pos.x, (pos.y-2)/0.6, 7)
	love.graphics.setColor(darken*mainColor[1], darken*mainColor[2], darken*mainColor[3])
	love.graphics.circle("fill", pos.x+blimpXloc, (pos.y-2+blimpYloc)/0.6, 7)
	love.graphics.pop()
	love.graphics.setColor(255, 255, 255)
end
