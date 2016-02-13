FRAME_SPEED = 1/60

WHITE = {255,255,255,255}
BLACK = {0,0,0}
BACKGROUND_COLOR = {82, 12, 4}
SUN_COLOR = {254, 150, 15}
WATER_COLOR = {0, 5, 50, 50}
BLIMP_COLOR_MAIN = {128, 0, 0}
BLIMP_COLOR_SUB = {128, 128, 128}
BULLET_COLOR = {255,255,255}

BLIMP_COLORS = {
	{128, 0, 0},
	{85, 29, 0},
	{105, 22, 0},
	{95, 0, 33},
	{141, 63, 7},
	{141, 94, 7}
}
function love.load()
	if jit ~= nil then
		print("Running under luajit...")
		status = jit.status()
		if status then
			print("JIT is enabled...")
		else
			print("JIT is disabled...")
		end
	end
	love.mouse.setVisible(false)
	love.graphics.setDefaultFilter("nearest","nearest")
	love.window.setMode(1920,1080,{fullscreen = true})
	-- love.graphics.setBackgroundColor(WHITE)

	canvas = love.graphics.newCanvas(192, 108)
	backgroundCanvas = love.graphics.newCanvas(192,108)
	circleCanvas = love.graphics.newCanvas(192,80)
	vignetteCanvas = love.graphics.newCanvas(192,108)

	canvas:setWrap("clamp","clamp")
	backgroundCanvas:setWrap("clamp","clamp")
	vec2 = require "vector"
	require "class"
	require "blimp"
	require "bullet"
	screenshake = require "screenshake"
	-- assert(#joysticks >= 2,"not enough joysticks")
	local cannonImageData = love.image.newImageData(10, 2)
	for i = 0,9 do for j = 0,1 do cannonImageData:setPixel(i,j,128,128,128) end end
	cannonImage = love.graphics.newImage(cannonImageData)

	joysticks = love.joystick.getJoysticks()
	players = {}
	print()
	for i = 1,#joysticks do
		local lin = (i-1)/math.max(1,#joysticks-1)
		local pos = lin*(192-50)
		local angle = -lin*math.pi/2 - math.pi/4
		local p = blimp:new(25+pos,50,joysticks[i],angle,BLIMP_COLORS[i])
		-- players = {blimp:new(50,50,joysticks[1],-math.pi/4), blimp:new(192-50,50,joysticks[2],-3*math.pi/4)}
		table.insert(players,p)
	end
	accumulator = 0
	bullets = {}
	keypressed = {}
	sunTimer = 0
	sunDistortVector = love.image.newImageData(108, 1)
	sunDistortVectorImg = love.graphics.newImage(sunDistortVector)
	for x = 0,107 do
		sunDistortVector:setPixel(x, 0, 127, 0, 0, 0)
	end
	circleCanvasOnce = false
end

framecount = 0
function love.update(dt)
	framecount = framecount + 1
	if framecount % 300 == 0 then
		print("FPS: " .. tostring(love.timer.getFPS()))
	end
	accumulator = accumulator + dt
	screenshake:update(dt)
	sunTimer = sunTimer - dt

	if sunTimer < 0 then
		for x = 80,107 do
			local value = math.random(0, 255)
			sunDistortVector:setPixel(x, 0, value, 0, 0, 0)
		end
		sunTimer = sunTimer + 0.1
	end
	while accumulator > FRAME_SPEED do
		accumulator = accumulator - FRAME_SPEED
		for i,v in ipairs(players) do v:update(FRAME_SPEED) end
		tick("updating all bullets")
		if #bullets ~= 0 then
			for i = #bullets,1,-1 do
				--for i = 1,#bullets do
				local b = bullets[i]
				if b:update(FRAME_SPEED) then table.remove(bullets,i) end
			end
		end
		tock("updating all bullets", 2)
		keypressed = {}
	end
end

function love.draw()
	if not circleCanvasOnce then
		circleCanvasOnce = true
		love.graphics.setCanvas(vignetteCanvas)
		for i = 200,60,-1 do
			local gs = 255-(255*(i-60)/(200-60))
			gs = math.floor(gs/20)*20
			love.graphics.setColor(gs,gs,gs)
			love.graphics.circle("fill", 192/2, 80, i)
		end

		love.graphics.setCanvas(circleCanvas)
		love.graphics.setColor(BACKGROUND_COLOR)
		love.graphics.rectangle("fill", 0, 0, 192, 108)

		love.graphics.setColor(WHITE)
		love.graphics.setBlendMode("multiply")
		love.graphics.draw(vignetteCanvas)
		love.graphics.setBlendMode("alpha")
		love.graphics.setColor(SUN_COLOR)
		love.graphics.circle("fill", 192/2, 80, 60)
		love.graphics.setColor(WHITE)
		love.graphics.setCanvas(backgroundCanvas)
		love.graphics.draw(circleCanvas)
		love.graphics.draw(circleCanvas, 0, 80, 0, 1, -0.35,0,80)
		love.graphics.setColor(WATER_COLOR)
		love.graphics.rectangle("fill", 0, 80, 192, 108-80)
	end

	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	love.graphics.setColor(255, 255, 255)
	sunDistortVectorImg:refresh()
	distortShader:send('distortVec', sunDistortVectorImg)
	love.graphics.setColor(WHITE)
	love.graphics.setShader(distortShader)
	love.graphics.draw(backgroundCanvas)
	love.graphics.setShader()

	for i,v in ipairs(bullets) do v:draw() end
	for i,v in ipairs(players) do v:draw() end

	love.graphics.setCanvas()
	screenshake:start()
	love.graphics.draw(canvas, 0, 0, 0, 10, 10)
	screenshake:stop()
end

function love.keypressed(key)
	keypressed[key] = true
	if key == "escape" then love.event.push("quit") end
	if key == "6" then love.load() end
end

function love.joystickpressed(js,key)
	if key == 8 then love.load() end
end

function isColliding(a,b)
	local dist = (a.pos - b.pos):len()
	return a.radius + b.radius > dist
end

distortShader = love.graphics.newShader([[
	extern Image distortVec;
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords){
		number distort = (Texel(distortVec, vec2(texture_coords.y, 0.0)).r - 0.5)/45.0;
		return vec4(Texel(texture, vec2(texture_coords.x + distort, texture_coords.y)).rgb, 1.0);
	}
]])
