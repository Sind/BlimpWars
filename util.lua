util = {}
-- some utilities. Most are taken from the lume library.

-- deep-copies a table
function util.deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[util.deepcopy(orig_key)] = util.deepcopy(orig_value)
		end
		setmetatable(copy, util.deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

-- enumerates all ordered permutation vectors for a given length, e.g.
-- 1 => {{1}}
-- 2 => {{1, 2}, {2, 1}}
-- 3 => {{1, 2, 3}, {2, 3, 1}, {3, 2, 1}, {1, 3, 2}, {2, 1, 3}, {3, 1, 2}}
-- etc.
function util.enumeratePermutationVectors(a)
	local permutations = {}
	local b = a
	if a==0 then return end
	local taken = {} local slots = {}
	for i=1,a do slots[i]=0 end
	for i=1,b do taken[i]=false end
	local index = 1
	while index > 0 do repeat
			repeat slots[index] = slots[index] + 1
			until slots[index] > b or not taken[slots[index]]
			if slots[index] > b then
				slots[index] = 0
				index = index - 1
				if index > 0 then
					taken[slots[index]] = false
				end
				break
			else
				taken[slots[index]] = true
			end
			if index == a then
				local newPermutation = {}
				for i=1,a do newPermutation[i] = slots[i] end
				table.insert(permutations, newPermutation)
				taken[slots[index]] = false
				break
			end
			index = index + 1
					   until true end
	return permutations
end

function util.angle(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1)
end

function util.roundAngleToNearestValid(angle)
	local validAngle = angle
	if angle > 0 then
		if angle > 0.5*math.pi then
			validAngle = math.pi
		else
			validAngle = 0
		end
	end
	return validAngle
end

function util.randomBool(chanceOfTrue)
	return love.math.random(0, 1) < chanceOfTrue
end

local noop = function()
end

local identity = function(x)
	return x
end

local iscallable = function(x)
	if type(x) == "function" then return true end
	local mt = getmetatable(x)
	return mt and mt.__call ~= nil
end

local isarray = function(x)
	return (type(x) == "table" and x[1] ~= nil) and true or false
end

local getiter = function(x)
	if isarray(x) then
		return ipairs
	elseif type(x) == "table" then
		return pairs
	end
	error("expected table", 3)
end

local iteratee = function(x)
	if x == nil then return identity end
	if iscallable(x) then return x end
	if type(x) == "table" then
		return function(z)
			for k, v in pairs(x) do
				if z[k] ~= v then return false end
			end
			return true
		end
	end
	return function(z) return z[x] end
end

function util.map(t, fn)
	fn = iteratee(fn)
	local iter = getiter(t)
	local rtn = {}
	for k, v in iter(t) do rtn[k] = fn(v) end
	return rtn
end

function util.reduce(t, fn, first)
	local acc = first
	local started = first and true or false
	local iter = getiter(t)
	for _, v in iter(t) do
		if started then
			acc = fn(acc, v)
		else
			acc = v
			started = true
		end
	end
	assert(started, "reduce of an empty table with no first value")
	return acc
end

function util.find(t, value)
  local iter = getiter(t)
  for k, v in iter(t) do
    if v == value then return k end
  end
  return nil
end

return util
