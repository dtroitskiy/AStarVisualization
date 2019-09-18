Tile = {}
Tile.__index = Tile

function Tile:new()
	local tile = { isBlocking = false }
	setmetatable(tile, self)
	return tile
end

Map = {}

function Map:new(width, height)
	local map = { tiles = {}, width = width, height = height }
	setmetatable(map, self)
	self.__index = self
	
	map.tilesCount = width * height
	
	for i = 1, map.tilesCount do
		map.tiles[i] = Tile:new()
	end
	
	return map
end

function Map:getTileIndex(x, y)
	return (y - 1) * self.width + x
end

function Map:getTile(x, y)
	if x < 1 or x > self.width or y < 1 or y > self.height then
		return nil
	end
	local i = self:getTileIndex(x, y)
	if i >= 1 and i <= self.tilesCount then
		return self.tiles[i]
	end
	return nil
end
