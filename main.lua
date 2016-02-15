FRAME_SPEED = 1/60

FAKE_JOYSTICKS = 4 -- set to > 0 to fake that number of gamepads being connected.

modes = {}
currentMode = nil

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
	require "modes/introscreen"
	require "modes/game"

	modes["introscreen"] = introscreen
	modes["game"] = game

	-- mode the game boots into
	currentMode = "introscreen"

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

	--[[for i = 1,#joysticks do
		local lin = (i-1)/math.max(1,#joysticks-1)
		local pos = lin*(192-50)
		local angle = -lin*math.pi/2 - math.pi/4
		local p = blimp:new(25+pos,50,joysticks[i],angle,colors.BLIMP_COLORS[i])
		-- players = {blimp:new(50,50,joysticks[1],-math.pi/4), blimp:new(192-50,50,joysticks[2],-3*math.pi/4)}
		table.insert(players,p)
	   end]]--
	bullets = {}
	keypressed = {}

	background.load(192, 108)
	modes[currentMode].load()

end

framecount = 0
function love.update(dt)
	framecount = framecount + 1
	if framecount % 300 == 0 then
		print("FPS: " .. tostring(love.timer.getFPS()))
	end
	background.update(dt)
	modes[currentMode].update(dt)
end

function love.draw()

	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	love.graphics.setColor(255, 255, 255)
	background.draw()

	modes[currentMode].draw()

	love.graphics.setCanvas()
	screenshake:start()
	love.graphics.draw(canvas, 0, 0, 0, 10, 10)
	screenshake:stop()

end

function love.keypressed(key)
	keypressed[key] = true
	if key == "escape" then love.event.push("quit") end
	if key == "6" then love.load() end
	modes[currentMode].keypressed(key)
end

function love.joystickpressed(js,key)
	if key == 8 then love.load() end
end
