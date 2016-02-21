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
uniform vec4 waterColor;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords){
	vec2 coords = screen_coords + vec2(0.0, -60.0);
	float n2 = noise(coords/vec2(5.0, 1.0 - coords.y/800.0) - vec2(t - 7.0, t));
	float n3 = noise(coords/vec2(5.0, 1.0 - coords.y/800.0) - vec2(t - 1.0, t + 3.0));
	vec4 col = Texel(background, screen_coords/vec2(192.0, 108.0) - vec2(0.0, n2*n3*0.16 - 0.008));
	return col*waterColor;
}
