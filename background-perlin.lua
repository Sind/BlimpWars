background = {}

background.shaderSrc = [[
float rand(vec2 n) {
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}
float noise(vec2 p){
	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u*u*(3.0-2.0*u);
	float res = mix(
		mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
		mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
	return res*res;
}

uniform float t;
uniform Image background;
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords){
	if(screen_coords.y >= 80){
		vec2 coords = screen_coords + vec2(0, -60);
		float n2 = noise(coords/vec2(5.0, 1 - coords.y/800) - vec2(t - 7, t));
		float n3 = noise(coords/vec2(5.0, 1 - coords.y/800) - vec2(t - 1, t + 3));
		vec4 col = Texel(texture, texture_coords - vec2(0, n2*n3*0.16 - 0.008));
		return col;
	}
	else {
		return Texel(background, texture_coords);
	}
}]]

function background.load(renderWidth, renderHeight)
	print("using perlin noise shader")
	background.circleCanvas = love.graphics.newCanvas(renderWidth, 80)
	background.vignetteCanvas = love.graphics.newCanvas(renderWidth, renderHeight)
	background.backgroundCanvas = love.graphics.newCanvas(renderWidth, renderHeight)
	background.backgroundCanvas:setWrap("clamp","clamp")
	background.sunTimer = 0
	background.distortShader = love.graphics.newShader(background.shaderSrc)
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
	background.distortShader:send("t", background.sunTimer)
	love.graphics.setColor(colors.WHITE)
	love.graphics.setShader(background.distortShader)
	love.graphics.draw(background.backgroundCanvas)
	love.graphics.setShader()
	love.graphics.setColor(colors.WATER_COLOR)
	love.graphics.rectangle("fill", 0, 80, 192, 108-80)
end

return background
