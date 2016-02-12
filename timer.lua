__ltg = love.timer.getTime
__global_timers = {}

function tick(name)
	__global_timers[name] = __ltg()
end

function tock(name, pain_threshold_ms)
	local endtimer = __ltg()
	local ms = 1000*(endtimer - __global_timers[name])
	if ms >= pain_threshold_ms then
	   print(string.format("[TIMER]: '" .. name .. "' took %.3fms", ms))
	end
end
