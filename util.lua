util = {}

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

return util
