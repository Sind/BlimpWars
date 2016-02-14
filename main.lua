FRAME_SPEED = 1/60

FAKE_JOYSTICKS = 4 -- set to > 0 to fake that number of gamepads being connected.

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
	love.mouse.setVisible(false) -- TODO: try calling this outside love.load as well, to get it in as early as possible
	love.graphics.setDefaultFilter("nearest","nearest")
	love.window.setMode(1920,1080, {fullscreen = true})

	canvas = love.graphics.newCanvas(192, 108)

	canvas:setWrap("clamp","clamp")

	vec2 = require "vector"
	require "class"
	require "blimp"
	require "bullet"
	require "playermanager"
	background = require "background"
	screenshake = require "screenshake"
	require "colorscheme"
	blimp.init()


	-- assert(#joysticks >= 2,"not enough joysticks")
	--local cannonImageData = love.image.newImageData(10, 2)
	--for i = 0,9 do for j = 0,1 do cannonImageData:setPixel(i,j,128,128,128) end end
	--cannonImage = love.graphics.newImage(cannonImageData)

	joysticks = love.joystick.getJoysticks()
	if FAKE_JOYSTICKS > 0 then
	   joysticks = {}
	   for i = 1,FAKE_JOYSTICKS do
	      table.insert(joysticks, false) -- TODO: replace here with some sort of fake joystick object or so
	   end
	end

	playermanager.initializePositions(192, 108, joysticks)

	players = {}
	print()
	--[[for i = 1,#joysticks do
		local lin = (i-1)/math.max(1,#joysticks-1)
		local pos = lin*(192-50)
		local angle = -lin*math.pi/2 - math.pi/4
		local p = blimp:new(25+pos,50,joysticks[i],angle,colors.BLIMP_COLORS[i])
		-- players = {blimp:new(50,50,joysticks[1],-math.pi/4), blimp:new(192-50,50,joysticks[2],-3*math.pi/4)}
		table.insert(players,p)
	   end]]--
	accumulator = 0
	bullets = {}
	keypressed = {}

	logo = love.graphics.newImage("blimpwars-logo.png")
	background.load(192, 108)
end

framecount = 0
simulationtime = 0
function love.update(dt)
	framecount = framecount + 1
	if framecount % 300 == 0 then
		print("FPS: " .. tostring(love.timer.getFPS()))
	end
	simulationtime = simulationtime + dt
	accumulator = accumulator + dt
	screenshake:update(dt)

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
	playermanager.update(dt)
	background.update(dt)
end

function love.draw()

	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	love.graphics.setColor(255, 255, 255)
	background.draw()

	for i,v in ipairs(bullets) do v:draw() end
	--for i,v in ipairs(players) do v:draw() end
	playermanager.drawPlayers()

	love.graphics.draw(logo, 192/2 - logo:getWidth()/2, 108/2 - logo:getHeight()/2 + 5*math.sin(simulationtime/2))

	love.graphics.setCanvas()
	screenshake:start()
	love.graphics.draw(canvas, 0, 0, 0, 10, 10)
	screenshake:stop()
	
end

function love.keypressed(key)
	keypressed[key] = true
	if key == "escape" then love.event.push("quit") end
	if key == "6" then love.load() end
	if key == "1" or key == "2" or key == "3" or key == "4" then
		if love.keyboard.isDown("lshift") then
			playermanager.wantsLeave(tonumber(key))
		else
			playermanager.wantsJoin(tonumber(key))
		end
	end
end

function love.joystickpressed(js,key)
	if key == 8 then love.load() end
end

function isColliding(a,b)
	local dist = (a.pos - b.pos):len()
	return a.radius + b.radius > dist
end
