playermanager = {}
tween = require "tween"
require "util"
require "blimp"
require "colorscheme"
require "player"

playermanager.ongoingTweens = {}

-- the home positions each blimp starts out with and will return to when deactivated.
playermanager.homePositions = nil;
-- list of possible starting positions for 1, 2, 3 and 4 players.
playermanager.statePositions = nil;
-- player data
playermanager.players = nil;

function playermanager.initializePositions(windowWidth, windowHeight, joysticks)
   local maxWidth = windowWidth*0.8
   local widthOffset = (windowWidth - maxWidth)/2.0
   local bottomOffset = windowHeight - windowHeight*0.1
   playermanager.homePositions = {
      vec2(widthOffset, bottomOffset),
      vec2(widthOffset + maxWidth/3, bottomOffset),
      vec2(widthOffset + 2*maxWidth/3, bottomOffset),
      vec2(windowWidth - widthOffset, bottomOffset)
   }
   playermanager.players = {}
   
   -- we always generate a full set of four players at the bottom, even if fewer gamepads are connected.
   for i = 1, 4 do
      playermanager.players[i] = player:new(playermanager.homePositions[i]:clone(), joysticks[i], math.pi, colors.BLIMP_COLORS[i])
      playermanager.active = false
   end

   local cX = windowWidth/2
   local cY = windowHeight/2
   local rX = windowHeight*0.6
   local rY = windowHeight*0.4
   local circle = function(radians) return vec2(cX + rX*math.cos(radians), (cY*0.5 - 1.5*rY*math.sin(radians))) end
   playermanager.statePositions = {
      {vec2(windowWidth/2, windowHeight/2 - rY)},
      {vec2(cX + rX*math.cos(math.pi), cY - 1.5*rY*math.sin(math.pi)), vec2(cX + rX*math.cos(0), cY - rY*math.sin(0))},
      {circle(0), circle(-math.pi/2), circle(2*math.pi/2)},
      {vec2(cX + rX, cY + rY), vec2(cX - rX, cY + rY), vec2(cX - rX, cY - rY), vec2(cX + rX, cY - rY)}
   }
end

function playermanager.drawPlayers(drawInactives)
   for k, v in ipairs(playermanager.players) do
      if v.active or drawInactives then
	 v:draw()
      end
   end
end

function playermanager.updatePlayers(dt)
   for i,v in ipairs(playermanager.players) do v:update(dt) end
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
   playermanager._move(0.5, playermanager.players[player].pos, playermanager.homePositions[player]:clone(), "outCirc")

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
      playermanager._move(0.5, playermanager.players[playerId].pos, possiblePositions[best[i]], "outCirc")
   end
end

function playermanager._move(duration, subject, target, easing)
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

function playermanager.findBestAssignment(currentObjectPositions, slotPositions)
   local dist = function(a, b) return math.sqrt((a.x - b.x)^2 + (a.y - b.y)^2) end -- TODO: does vec already do this for us?
   local scoreAssignment = function(assignment)
      local acc = 0
      for i = 1,#slotPositions do
   	 acc = acc + dist(currentObjectPositions[i], slotPositions[assignment[i]])
      end
      return acc
   end
   local allPermutations = util.enumeratePermutationVectors(#slotPositions)

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
