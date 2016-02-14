playermanager = {}
tween = require "tween"

playermanager.ongoingTweens = {}

playermanager.homePositions = nil;
playermanager.statePositions = nil;
playermanager.players = nil;

function playermanager.initializePositions(windowWidth, windowHeight)
   local maxWidth = windowWidth*0.8
   local widthOffset = (windowWidth - maxWidth)/2.0
   local bottomOffset = windowHeight - windowHeight*0.05
   playermanager.homePositions = {
      {widthOffset, bottomOffset},
      {widthOffset + maxWidth/3, bottomOffset},
      {widthOffset + 2*maxWidth/3, bottomOffset},
      {windowWidth - widthOffset, bottomOffset}
   }
   playermanager.players = {
      {
	 pos = {widthOffset, bottomOffset},
	 active = false
      },
      {
	 pos = {widthOffset + maxWidth/3, bottomOffset},
	 active = false
      },
      {
	 pos = {widthOffset + 2*maxWidth/3, bottomOffset},
	 active = false
      },
      {
	 pos = {windowWidth - widthOffset, bottomOffset},
	 active = false
      }
   }
   local cX = windowWidth/2
   local cY = windowHeight/2
   local rX = windowHeight*0.6
   local rY = windowHeight*0.4
   local circle = function(radians) return {cX + rX*math.cos(radians), (cY*0.5 - 1.5*rY*math.sin(radians))} end
   playermanager.statePositions = {
      {{windowWidth/2, windowHeight/2 - rY}},
      {{cX + rX*math.cos(math.pi), (cY - 1.5*rY*math.sin(math.pi))}, {cX + rX*math.cos(0), cY - rY*math.sin(0)}},
      {circle(0), circle(-math.pi/2), circle(2*math.pi/2)},
      {{cX + rX, cY + rY}, {cX - rX, cY + rY}, {cX - rX, cY - rY}, {cX + rX, cY - rY}}
   }
end

function playermanager.wantsJoin(player)
   if playermanager.players[player].active then print("player " .. tostring(player) .. " already joined."); return end
   playermanager.players[player].active = true

   playermanager._movePlayersToAssignedPositions()
end

function playermanager.wantsLeave(player)
   if not playermanager.players[player].active then print("player " .. tostring(player) .. " already inactive."); return end
   playermanager.players[player].active = false
   
   -- move the player that left to its home-position
   playermanager.new(0.5, playermanager.players[player].pos, playermanager.homePositions[player], "outCirc")

   -- reshuffle the rest of the players accordingly
   playermanager._movePlayersToAssignedPositions()
end

function playermanager._movePlayersToAssignedPositions()
   local numActives = 0
   local activePositions = {}
   for i, v in ipairs(playermanager.players) do
      if v.active then
	 numActives = numActives + 1
	 table.insert(activePositions, v.pos)
      end
   end
   if numActives == 0 then return end
   local possiblePositions = playermanager.statePositions[numActives]
   local best = playermanager.findBestAssignment(activePositions, possiblePositions)

   local lookupNthActivePlayer = function(n)
      local seen = 0
      for i = 1,#playermanager.players do
	 if playermanager.players[i].active then
	    seen = seen + 1
	 end
	 if seen == n then return i end
      end
   end
   for i, v in ipairs(best) do
      local playerId = lookupNthActivePlayer(i)
      playermanager.new(0.5, playermanager.players[playerId].pos, possiblePositions[best[i]], "outCirc")
   end
end

function playermanager.new(duration, subject, target, easing)
   -- check if a given subject already has any ongoing tweens, and if so, delete them.
   for i = #playermanager.ongoingTweens, 1, -1 do
      if playermanager.ongoingTweens[i].subject == subject then
	 table.remove(playermanager.ongoingTweens, i)
      end
   end
   local t = tween.new(duration, subject, target, easing)
   table.insert(playermanager.ongoingTweens, t)
   return t
end

function playermanager.update(dt)
   for i = #playermanager.ongoingTweens, 1, -1 do
      local done = playermanager.ongoingTweens[i]:update(dt)
      if done then
	 table.remove(playermanager.ongoingTweens, i)
      end
   end
end

function playermanager._perms(a)
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

function playermanager.findBestAssignment(currentObjectPositions, slotPositions)
   local dist = function(a, b) return math.sqrt((a[1] - b[1])^2 + (a[2] - b[2])^2) end
   local scoreAssignment = function(assignment)
      local acc = 0
      for i = 1,#slotPositions do
   	 acc = acc + dist(currentObjectPositions[i], slotPositions[assignment[i]])
      end
      return acc
   end
   local allPermutations = playermanager._perms(#slotPositions)

   local bestScoreSoFar = 1/0
   local bestAssignmentSoFar = nil
   for i, v in ipairs(allPermutations) do
      local score = scoreAssignment(v)
      if score < bestScoreSoFar then
	 bestAssignmentSoFar = v
	 bestScoreSoFar = score
      end
   end
   return bestAssignmentSoFar, bestScoreSoFar
end
return playermanager
