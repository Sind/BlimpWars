resourcemanager = {}

resourcemanager.loadImage = util.memoize(love.graphics.newImage)
resourcemanager.loadShader = util.memoize(love.graphics.newShader)

return resourcemanager
