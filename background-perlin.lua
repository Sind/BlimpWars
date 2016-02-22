background = {
	sunTimer = 0
}

function background.load(renderWidth, renderHeight)
	print("using perlin noise shader")
	background.circleCanvas = love.graphics.newCanvas(renderWidth, 80)
	background.vignetteCanvas = love.graphics.newCanvas(renderWidth, renderHeight)
	background.backgroundCanvas = love.graphics.newCanvas(renderWidth, renderHeight)
	background.backgroundCanvas:setWrap("clamp","clamp")
	background.distortShader = resourcemanager.loadShader("perlin-wave-shader.fsh")
	background.distortShader:send("waterColor", colors.WATER_COLOR)
	background.drawOnce()
end

function background.update(dt)
	background.sunTimer = background.sunTimer - dt
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
	love.graphics.setCanvas()
end

function background.draw()
	love.graphics.setColor(colors.WHITE)
	-- TODO: there is some overdraw here we could optimize away, since the background on the lower part
	-- TODO: of the screen is going to get re-drawn with the wave-shader anyway.
	love.graphics.draw(background.backgroundCanvas)
	love.graphics.setShader(background.distortShader)
	background.distortShader:send("t", background.sunTimer)
	background.distortShader:send("background", background.backgroundCanvas)
	love.graphics.rectangle("fill", 0, 80, 192, 108-80)
	love.graphics.setShader()
end

return background
