blimp = {}
require "colorscheme"

function blimp.init()
	local cannonImageData = love.image.newImageData(10, 2)
	-- wtf is this even doing, kek
	for i = 0,9 do for j = 0,1 do cannonImageData:setPixel(i,j,128,128,128) end end
	blimp.cannonImage = love.graphics.newImage(cannonImageData)
end

function blimp.draw(pos, cannonRotation, mainColor)
	-- love.graphics.circle("line", self.pos.x, self.pos.y, 7)
	love.graphics.setColor(255,255,255)
	love.graphics.draw(blimp.cannonImage, pos.x, pos.y, cannonRotation, 1, 1, 1, 1)
	love.graphics.setColor(colors.BLIMP_COLOR_SUB)
	love.graphics.rectangle("fill", pos.x-2, pos.y, 4, 3)
	love.graphics.rectangle("fill", pos.x-1, pos.y, 2, 4)
	love.graphics.push()
	local blimpXloc = (pos.x/192-0.5)*2 -- TODO: magic number
	local blimpYloc = (pos.y/108-0.5)*2 -- TODO: magic number
	love.graphics.scale(1, 0.6)
	-- love.graphics.setColor(BLIMP_COLOR_MAIN[1]+SUN_COLOR[1]/4,BLIMP_COLOR_MAIN[2]+SUN_COLOR[2]/4,BLIMP_COLOR_MAIN[3]+SUN_COLOR[3]/4)
	love.graphics.setColor(mainColor[1]+40, mainColor[2]+50, mainColor[3]+5)
	love.graphics.circle("fill", pos.x, (pos.y-2)/0.6, 7)
	love.graphics.setColor(mainColor)
	love.graphics.circle("fill", pos.x+blimpXloc, (pos.y-2+blimpYloc)/0.6, 7)
	love.graphics.pop()
	love.graphics.setColor(255, 255, 255)
end

