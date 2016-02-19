require "strict"
require "class"
require "blimp"
require "bullet"
require "playermanager"
require "background"
require "colorscheme"
require "input"
require "ai"
require "modes/introscreen"
require "modes/game"
require "modes/credits"
screenshake = require "screenshake"
vec2 = require "vector"

ADD_AI_OPPONENTS = true -- when set to true, the game will be filled up with AI opponents.
IDLE_TIMEOUT_SECONDS = 45

-- TODO: mode transitions should really be managed by some sort of
-- TODO: state-manager so that we can have automatic mode:onEnter(),
-- TODO: mode:onLeave(), mode:load(), mode:unload() callbacks etc.
-- TODO: that way e.g. the credits screen can unload its textures
-- TODO: when leaving it, and reload them on enter. We can also get
-- TODO: automatic GC when moving between modes.
modes = {}
currentMode = nil
mainCanvas = nil
scaleFactor = 1
connectedInputs = {}

lastInputReceivedTimestamp = -2
lastIdleReset = -1

function love.load(args)
	love.mouse.setVisible(false) -- TODO: try calling this outside love.load as well, to get it in as early as possible
	love.graphics.setDefaultFilter("nearest","nearest")
	love.window.setMode(1920, 1080, {fullscreen = true})
	--love.window.setMode(3200, 1800, {fullscreen = true})
	scaleFactor = love.graphics.getWidth()/192

	if (#args) > 1 then
		currentMode = args[2]
	end

	lastIdleReset = love.timer.getTime()
	lastInputReceivedTimestamp = love.timer.getTime() - 1

	-- Most of the love.load is factored into the initialize()
	-- function, so that we can call initialize() to restart
	-- the game, but not have love flicker the window.
	initialize()
end

function initialize()
	-- everything will be rendered to this canvas, which is then rendered upscaled to the screen.
	connectedInputs = {}

	mainCanvas = love.graphics.newCanvas(192, 108)
	mainCanvas:setWrap("clamp","clamp")

	-- TODO: check what happens with #connectedInputs < 4
	local joysticks = love.joystick.getJoysticks()
	for i = 1, math.min(#joysticks, 4) do
		print("Inserted player")
		table.insert(connectedInputs, inputGamepad:new(joysticks[i]))
	end
	if ADD_AI_OPPONENTS then
		local opponentsToAdd = 4 - math.min(#joysticks, 4)
		print("Adding " .. tostring(opponentsToAdd) .. " AI opponents.")
		for i = 1,opponentsToAdd do
			table.insert(connectedInputs, inputDummy:new())
		end
	else
		-- construct actual inputs from available gamepads and keyboard here
	end

	-- playermanager keeps track of players and automatically updates all players each frame etc.
	-- put all players into their initial positions at the bottom
	-- TODO: should playermanager know about joysticks? probably not!
	playermanager.initializePositions(192, 108, connectedInputs)

	-- load the background. Note that modes do not draw or update the background themselves.
	background.load(192, 108)
	-- initialize the gamemodes
	introscreen.load()
	game.load()
	credits.load()
	-- blimp module needs to pregenerate a tiny image, so let it do that
	blimp.load()
	modes["introscreen"] = introscreen
	modes["game"] = game
	modes["credits"] = credits
	-- mode the game boots into by default, overridden by commandline
	if not currentMode then currentMode = "introscreen" end
	collectgarbage()
end

framecount = 0
function love.update(dt)
	framecount = framecount + 1
	if framecount % 300 == 0 then
		print("FPS: " .. tostring(love.timer.getFPS()))
	end
	background.update(dt)
	modes[currentMode].update(dt)
	for _, input in ipairs(connectedInputs) do
		input:update(dt)
	end
	local now = love.timer.getTime()
	if (now > lastInputReceivedTimestamp + IDLE_TIMEOUT_SECONDS) and (lastIdleReset < lastInputReceivedTimestamp) and not ADD_AI_OPPONENTS then
		lastIdleReset = love.timer.getTime()
		print(lastInputReceivedTimestamp)
		currentMode = "introscreen"
		initialize()
	end
end

function love.draw()
	love.graphics.setCanvas(mainCanvas)
	love.graphics.clear()
	love.graphics.setColor(255, 255, 255)
	background.draw()

	modes[currentMode].draw()

	love.graphics.setCanvas()
	screenshake:start()
	love.graphics.draw(mainCanvas, 0, 0, 0, scaleFactor, scaleFactor)
	screenshake:stop()
end

function love.keypressed(key)
	-- TODO review keybinds before deployment
	if key == "escape" then love.event.push("quit")
	elseif key == "6" then
		currentMode = "introscreen"
		initialize()
	else
		modes[currentMode].keypressed(key)
	end
	lastInputReceivedTimestamp = love.timer.getTime()
end

function love.joystickpressed(js, key)
	lastInputReceivedTimestamp = love.timer.getTime()
	-- TODO: should this be mapped to the user?
	if key == 9 then
		currentMode = "introscreen"
		initialize()
	end
	if key == 8 then
		-- TODO: this is ugly. Should probably be refactored so that
		-- TODO: gamemodes receive semantic information rather than raw
		-- TODO: unmapped keypresses etc.
		modes[currentMode].keypressed("return")
	end

	-- TODO: this is badly decoupled. main.lua should not ever
	-- TODO: call playermanager.wantsJoin(p), instead the event
	-- TODO: should just be passed on to the active game mode,
	-- TODO: which can then decide what to do with it.
	if key == 1 and currentMode == "introscreen" then
		-- a player wants to join; look up which player it is
		for i, p in ipairs(playermanager.players) do
			if p.input.joystick == js then
				playermanager.wantsJoin(p)
			end
		end
	end
	if (key == 2 or key == 3) and currentMode == "introscreen" then
		-- a player wants to join; look up which player it is
		for i, p in ipairs(playermanager.players) do
			if p.input.joystick == js then
				playermanager.wantsLeave(p)
			end
		end
	end
	print(key)
end
