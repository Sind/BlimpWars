background = {
	sunTimer = 0
}

function background.load(renderWidth, renderHeight)
	print("using random noise shader")
	--background.canvas = love.graphics.newCanvas(renderWidth, renderHeight)
	background.circleCanvas = love.graphics.newCanvas(renderWidth, 80)
	background.vignetteCanvas = love.graphics.newCanvas(renderWidth, renderHeight)
	background.backgroundCanvas = love.graphics.newCanvas(renderWidth, renderHeight)
	background.backgroundCanvas:setWrap("clamp","clamp")
	background.sunDistortVector = love.image.newImageData(renderHeight, 1)
	background.sunDistortVectorImg = love.graphics.newImage(background.sunDistortVector)
	for x = 0,107 do -- TODO: magic number
		background.sunDistortVector:setPixel(x, 0, 127, 0, 0, 0)
	end
	background.distortShader = love.graphics.newShader([[
	extern Image distortVec;
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords){
		number distort = (Texel(distortVec, vec2(texture_coords.y, 0.0)).r - 0.5)/45.0;
		return vec4(Texel(texture, vec2(texture_coords.x + distort, texture_coords.y)).rgb, 1.0);
	}
]])
	background.drawOnce()
end

function background.update(dt)
	background.sunTimer = background.sunTimer - dt
	if background.sunTimer < 0 then
		for x = 80, 107 do -- TODO: magic number
			local value = math.random(0, 255)
			background.sunDistortVector:setPixel(x, 0, value, 0, 0, 0)
		end
		background.sunTimer = background.sunTimer + 0.15
	end
end

function background.drawOnce()
	-- TODO: reduce # of used canvases here if at all possible.
	-- TODO: if this code had better performance, we could probably
	-- TODO: update it every frame for a dynamically changing back-
	-- TODO: ground on the rpi.
	love.graphics.setCanvas(background.vignetteCanvas)
	for i = 200,60,-1 do
		local gs = 255-(255*(i-60)/(200-60))
		gs = math.floor(gs/20)*20
		love.graphics.setColor(gs,gs,gs)
		love.graphics.circle("fill", 192/2, 80, i)
	end

	love.graphics.setCanvas(background.circleCanvas)
	love.graphics.setColor(colors.BACKGROUND_COLOR)
	love.graphics.rectangle("fill", 0, 0, 192, 108)

	love.graphics.setColor(colors.WHITE)
	love.graphics.setBlendMode("multiply")
	love.graphics.draw(background.vignetteCanvas)
	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(colors.SUN_COLOR)
	love.graphics.circle("fill", 192/2, 80, 60)
	love.graphics.setColor(colors.WHITE)
	love.graphics.setCanvas(background.backgroundCanvas)
	love.graphics.draw(background.circleCanvas)
	love.graphics.draw(background.circleCanvas, 0, 80, 0, 1, -0.35, 0, 80)
	love.graphics.setColor(colors.WATER_COLOR)
	love.graphics.rectangle("fill", 0, 80, 192, 108-80)
	love.graphics.setCanvas()
end

function background.draw()
	background.sunDistortVectorImg:refresh()
	background.distortShader:send('distortVec', background.sunDistortVectorImg)
	love.graphics.setColor(colors.WHITE)
	love.graphics.setShader(background.distortShader)
	love.graphics.draw(background.backgroundCanvas)
	love.graphics.setShader()
end

return background
