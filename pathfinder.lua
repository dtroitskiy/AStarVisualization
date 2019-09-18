PathSearchNode = {}
PathSearchNode.__index = PathSearchNode

function PathSearchNode:new(x, y, index, parentIndex)
	parentIndex = parentIndex or 0
	local node = {
		x = x,
		y = y,
		index = index,
		parentIndex = parentIndex,
		g = 0,
		h = 0,
		f = 0
	}
	setmetatable(node, self)
	return node
end

function PathSearchNode:__tostring()
	return '{ x = ' .. self.x .. ', y = ' .. self.y .. ', index = ' .. self.index .. ', parentIndex = ' .. self.parentIndex ..
	       ', g = ' .. self.g .. ', h = ' .. self.h .. ', f = ' .. self.f .. ' }'
end

Pathfinder = {}
Pathfinder.__index = Pathfinder

function Pathfinder:new(map)
	local pathfinder = { map = map }
	pathfinder.straightWeight = 1
	pathfinder.diagonalWeight = math.sqrt(2)
	setmetatable(pathfinder, self)
	return pathfinder
end

function Pathfinder:findPath(from, to, coop)
	if coop then
		self.coroutine = coroutine.create(self.AStar)
		self.lastFrom = from
		self.lastTo = to
	else
		return self:AStar(from, to, false)
	end
end

function Pathfinder:process()
	if self.coroutine then
		local status, result = coroutine.resume(self.coroutine, self, self.lastFrom, self.lastTo, true)
		return result
	end
end

function Pathfinder:AStar(from, to, coop)
	
	if from.x == to.x and from.y == to.y then
		return nil
	end
	local tile = self.map:getTile(from.x, from.y)
	if not tile or tile.isBlocking then
		return nil
	end
	
	local openedList, openedMap, closedMap = {}, {}, {}
	local iterations, openedNodesThisIter, openedNodesTotal, closedNodesTotal, duplicateNodesTotal, allNodesTotal = 0, 0, 0, 0, 0, 0
	
	-- function for adding new child node to parent node
	function addNode(parentNode, xOff, yOff)
		
		local x, y = parentNode.x + xOff, parentNode.y + yOff
		local node = PathSearchNode:new(x, y, self.map:getTileIndex(x, y), parentNode.index)
		
		if closedMap[node.index] then
			return false
		end
		
		local tile = self.map:getTile(node.x, node.y)
		if not tile or tile.isBlocking then
			return false
		end
		
		if node.x == to.x and node.y == to.y then
			closedMap[node.index] = node
			return node.index
		end

		local weight = self.straightWeight
		if xOff ~= 0 and yOff ~= 0 then
			weight = self.diagonalWeight
		end
		node.g = parentNode.g + weight
		node.h = math.abs(to.x - node.x) + math.abs(to.y - node.y)
		node.f = node.g + node.h
		
		local existingOpenedNode = openedMap[node.index]
		if existingOpenedNode and existingOpenedNode.f < node.f then
			return false
		end
		
		table.insert(openedList, node)
		openedMap[node.index] = node
		openedNodesThisIter = openedNodesThisIter + 1
		openedNodesTotal = openedNodesTotal + 1
		if existingOpenedNode then
			duplicateNodesTotal = duplicateNodesTotal + 1
		end
		allNodesTotal = allNodesTotal + 1
		
		return false
		
	end
	
	-- function for composing found path
	function composePath(index)
		
		local path = {}
		
		-- adding steps
		while index > 0 do
			local node = closedMap[index]
			if not node then
				node = openedMap[index]
			end
			table.insert(path, { x = node.x, y = node.y })
			index = node.parentIndex
		end
		
		-- reversing order
		local i, j = 1, #path
		while i < j do
			path[i], path[j] = path[j], path[i]
			i = i + 1
			j = j - 1
		end
		
		return path
		
	end
	
	-- adding from node
	local fromNode = PathSearchNode:new(from.x, from.y, self.map:getTileIndex(from.x, from.y))
	table.insert(openedList, fromNode)
	openedMap[fromNode.index] = fromNode
	openedNodesTotal = openedNodesTotal + 1
	allNodesTotal = allNodesTotal + 1
	
	-- opened list loop
	while #openedList > 0 do
		
		local node = table.remove(openedList, 1)
		node = openedMap[node.index]
		openedNodesTotal = openedNodesTotal - 1
		
		if node then
			openedMap[node.index] = nil
			closedMap[node.index] = node
			closedNodesTotal = closedNodesTotal + 1
			
			openedNodesThisIter = 0
			
			local result = false
			result = addNode(node, -1, -1)
			if result then
				return composePath(result)
			end
			result = addNode(node, 0, -1)
			if result then 
				return composePath(result)
			end
			result = addNode(node, 1, -1)
			if result then
				return composePath(result)
			end
			result = addNode(node, 1, 0)
			if result then
				return composePath(result)
			end
			result = addNode(node, 1, 1)
			if result then
				return composePath(result)
			end
			result = addNode(node, 0, 1)
			if result then
				return composePath(result)
			end
			result = addNode(node, -1, 1)
			if result then
				return composePath(result)
			end
			result = addNode(node, -1, 0)
			if result then
				return composePath(result)
			end
			
			table.sort(openedList, function(a, b) return a.f < b.f end)
		
			iterations = iterations + 1
			
			if coop then
				coroutine.yield({
					openedList = openedList,
					closedMap = closedMap,
					activeNode = node,
					iterations = iterations,
					openedNodesThisIter = openedNodesThisIter,
					openedNodesTotal = openedNodesTotal,
					closedNodesTotal = closedNodesTotal,
					duplicateNodesTotal = duplicateNodesTotal,
					allNodesTotal = allNodesTotal
				})
			end
		end
	
	end
	
end
