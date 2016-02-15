credits = {
   simulationtime = 0
}

function credits.load()
   --credits.gradientMap = love.graphics.newImage("gradient-test.png")
   --credits._compileShader()
end

function credits.update(dt)
   credits.simulationtime = credits.simulationtime + dt
end

function credits.draw()
   love.graphics.clear(0, 0, 0)
   love.graphics.setShader(credits.shader)
   love.graphics.rectangle("fill", 20, 20, 50, 50)
   love.graphics.setShader()
end

function credits.keypressed(key)
   --credits._transitionToCredits()
end

function credits._transitionToIntroScreen()
   currentMode = "introscreen"
end

function credits._compileShader()
   local glsl = [[
             vec4 effect(vec4 global_draw_color, Image texture, vec2 texture_coords, vec2 pixel_coords){
		float val = texture_coords.x/20.0;
                return vec4(val, val, val, 1.0);
             }
       ]]
   credits.shader = love.graphics.newShader(glsl)
   print(credits.shader:getWarnings())
end

return credits
