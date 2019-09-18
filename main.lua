require 'map'
require 'obstacles'
require 'pathfinder'
require 'creature'
require 'slider'
require 'button'

local MAP_SIZE = { width = 50, height = 50 }
local FREE_TILE_COLOR = { 0, 1, 0, 1 }
local BLOCKED_TILE_COLOR = { 1, 0, 0, 1 }
local PATHFINDING_OPENED_COLOR = { 1, 1, 0, 1 }
local PATHFINDING_CLOSED_COLOR = { 1, 0, 1, 1 }
local PATHFINDING_ACTIVE_COLOR = { 1, 0.5, 0, 1 }
local PATHFINDING_VALUES_COLOR = { 0, 0, 0, 1 }
local PATHFINDING_DEFAULT_SPEED = 0.9
local PATHFINDING_MIN_SPEED = 0
local PATHFINDING_MAX_SPEED = 1
local PATHFINDING_FONT_SIZE_FACTOR = 0.375
local CREATURE_START_POS = { x = 25, y = 25 }
local CREATURE_COLOR = { 0, 0, 1, 1 }
local CREATURE_DEFAULT_SPEED = 5
local CREATURE_MIN_SPEED = 1
local CREATURE_MAX_SPEED = 50
local CREATURE_SIZE_FACTOR = 0.47
local OBSTACLE_DRAW_MODE_NONE, OBSTACLE_DRAW_MODE_DRAW, OBSTACLE_DRAW_MODE_ERASE = 0, 1, 2
local INSTRUCTIONS_LABEL_POS_FACTOR = { x = 0.02, y = 0.05 }
local SLIDER_SIZE_FACTORS = { width = 0.18, height = 0.02 }
local SLIDER_LINE_COLOR = { 0, 0.5, 0.5, 1 }
local SLIDER_SLID_COLOR = { 0, 0.75, 0.75, 1 }
local CREATURE_SPEED_SLIDER_POS_FACTORS = { x = 0.02, y = 0.2 }
local PATHFINDING_SPEED_SLIDER_POS_FACTORS = { x = 0.02, y = 0.3 }
local BUTTON_SIZE_FACTORS = { width = 0.085, height = 0.04 }
local BUTTON_COLOR = { 0, 0.5, 0.5, 1 }
local BUTTON_PRESSED_COLOR = { 0, 0.75, 0.75, 1 }
local BUTTON_ROUNDNESS = 0.3
local CLEAR_OBSTACLES_BUTTON_POS_FACTORS = { x = 0.02, y = 0.4 }
local RESET_OBSTACLES_BUTTON_POS_FACTORS = { x = 0.115, y = 0.4 }
local MOUSE_CURSOR_LABEL_POS_FACTORS = { x = 0.02, y = 0.5 }
local STATS_POS_FACTORS = { x = 0.02, y = 0.58 }
local UI_FONT_SIZE_FACTOR = 0.017
local UI_FONT_COLOR = { 0, 0.75, 0.75, 1 }
local UI_LABEL_Y_OFFSET_FACTOR = 0.02

local map = nil
local pathfinder = nil
local pathfindingInProgress = false
local pathfindingAsyncPauseTime, pathfindingAsyncPauseTimeLeft = 0, 0
local pathfindingSearchData = nil
local creature = nil
local creatureSpeedSlider, pathfindingSpeedSlider = nil, nil
local clearObstaclesButton, resetObstaclesButton = nil, nil
local widgets = {}

local tileSize = 0
local mapDrawX, mapDrawY = 0, 0
local pathfindingFont = nil
local uiFont = nil
local instructionsLabelPos = { x = 0, y = 0 }
local creatureSpeedLabelPos, creatureSpeedValuesPos = { x = 0, y = 0 }, { x = 0, y = 0 }
local pathfindingSpeedLabelPos, pathfindingSpeedValuesPos = { x = 0, y = 0 }, { x = 0, y = 0 }
local pathfindingSpeedValue = 0
local mouseCursorLabelPos = { x = 0, y = 0 }
local mouseCursorTilePos = { x = 0, y = 0 }
local statsPos = { x = 0, y = 0 }
local statsIterations, statsOpenedNodesThisIter, statsOpenedNodesTotal, statsClosedNodesTotal, statsDuplicateNodesTotal, statsAllNodesTotal = 0, 0, 0, 0, 0, 0
local obstacleDrawMode = OBSTACLE_DRAW_MODE_NONE

function love.load()
	-- needed to enabled debugging in ZeroBrane
	if arg[#arg] == '-debug' then
		local mobdebug = require('mobdebug')
		mobdebug.coro()
		mobdebug.start()
	end
	
	love.window.setMode(0, 0, { fullscreen = false })

	map = Map:new(MAP_SIZE.width, MAP_SIZE.height)
	setMapObstacles(map)

	pathfinder = Pathfinder:new(map)
	
	creature = Creature:new(CREATURE_START_POS.x, CREATURE_START_POS.y, CREATURE_DEFAULT_SPEED)
	
	creatureSpeedSlider = Slider:new()
	creatureSpeedSlider:setLineColor(SLIDER_LINE_COLOR)
	creatureSpeedSlider:setSlidColor(SLIDER_SLID_COLOR)
	creatureSpeedSlider:addOnChangedHandler(onCreatureSpeedSliderChanged)
	creatureSpeedSlider:setPercentage((CREATURE_DEFAULT_SPEED - CREATURE_MIN_SPEED) / (CREATURE_MAX_SPEED  - CREATURE_MIN_SPEED))
	table.insert(widgets, creatureSpeedSlider)
	
	pathfindingSpeedSlider = Slider:new()
	pathfindingSpeedSlider:setLineColor(SLIDER_LINE_COLOR)
	pathfindingSpeedSlider:setSlidColor(SLIDER_SLID_COLOR)
	pathfindingSpeedSlider:addOnChangedHandler(onPathfindingSpeedSliderChanged)
	pathfindingSpeedSlider:setPercentage((PATHFINDING_DEFAULT_SPEED - PATHFINDING_MIN_SPEED) / (PATHFINDING_MAX_SPEED  - PATHFINDING_MIN_SPEED))
	table.insert(widgets, pathfindingSpeedSlider)
	
	clearObstaclesButton = Button:new('Clear obstacles')
	clearObstaclesButton:setColor(BUTTON_COLOR)
	clearObstaclesButton:setPressedColor(BUTTON_PRESSED_COLOR)
	clearObstaclesButton:setRoundness(BUTTON_ROUNDNESS)
	clearObstaclesButton:addOnReleasedHandler(onClearObstaclesButtonClicked)
	table.insert(widgets, clearObstaclesButton)
	
	resetObstaclesButton = Button:new('Reset obstacles')
	resetObstaclesButton:setColor(BUTTON_COLOR)
	resetObstaclesButton:setPressedColor(BUTTON_PRESSED_COLOR)
	resetObstaclesButton:setRoundness(BUTTON_ROUNDNESS)
	resetObstaclesButton:addOnReleasedHandler(onResetObstaclesButtonClicked)
	table.insert(widgets, resetObstaclesButton)
	
	onResize()
end

function love.mousepressed(x, y, button)
	for i, widget in ipairs(widgets) do
		widget:onMousePressed(x, y)
	end
	
	if button == 2 and mouseCursorTilePos.x > 0 and mouseCursorTilePos.y > 0 then
		local tile = map:getTile(mouseCursorTilePos.x, mouseCursorTilePos.y)
		if tile then
			obstacleDrawMode = tile.isBlocking and OBSTACLE_DRAW_MODE_ERASE or OBSTACLE_DRAW_MODE_DRAW
		end
	end
end

function love.mousemoved(x, y)
	for i, widget in ipairs(widgets) do
		widget:onMouseMoved(x, y)
	end
	
	local tileX, tileY = math.floor((x - mapDrawX) / tileSize) + 1, math.floor((y - mapDrawY) / tileSize) + 1
	if tileX >= 1 and tileX <= map.width and tileY >= 1 and tileY <= map.height then
		mouseCursorTilePos.x, mouseCursorTilePos.y = tileX, tileY
	else
		mouseCursorTilePos.x, mouseCursorTilePos.y = 0, 0
	end
	
	if obstacleDrawMode ~= OBSTACLE_DRAW_MODE_NONE then
		local tile = map:getTile(mouseCursorTilePos.x, mouseCursorTilePos.y)
		if tile then
			tile.isBlocking = obstacleDrawMode == OBSTACLE_DRAW_MODE_DRAW
		end
	end
end

function love.mousereleased(x, y, button)
	for i, widget in ipairs(widgets) do
		widget:onMouseReleased(x, y)
	end
	
	if button == 1 and mouseCursorTilePos.x > 0 and mouseCursorTilePos.y > 0 then
		local creatureX, creatureY = math.floor(creature.pos.x), math.floor(creature.pos.y)
		creature:setPosition(creatureX, creatureY)
		pathfinder:findPath({ x = creatureX, y = creatureY }, { x = mouseCursorTilePos.x, y = mouseCursorTilePos.y }, true)
		pathfindingInProgress = true
	end
	
	obstacleDrawMode = OBSTACLE_DRAW_MODE_NONE
end

function love.update(dt)
	if pathfindingInProgress then
		pathfindingAsyncPauseTimeLeft = pathfindingAsyncPauseTimeLeft - dt
		
		if pathfindingAsyncPauseTimeLeft <= 0 then
			local result = pathfinder:process()
			if result.openedList then -- intermediate search data
				pathfindingSearchData = result
				
				-- recording stats
				statsIterations = result.iterations
				statsOpenedNodesThisIter = result.openedNodesThisIter
				statsOpenedNodesTotal = result.openedNodesTotal
				statsClosedNodesTotal= result.closedNodesTotal
				statsDuplicateNodesTotal = result.duplicateNodesTotal
				statsAllNodesTotal = result.allNodesTotal
				
				pathfindingAsyncPauseTimeLeft = pathfindingAsyncPauseTime
			else -- path found
				pathfindingSearchData = nil
				pathfindingInProgress = false
				creature:setPath(result)
			end
		end
	else
		creature:update(dt)
	end
end

function love.draw()
	drawMap()
	drawPathfinding()
	drawCreature()
	drawUI()
end

function onResize()
	local screenWidth, screenHeight = love.graphics.getDimensions()
	local minScreenSideSize = math.min(screenWidth, screenHeight)
	local maxMapSideSize = math.max(map.width, map.height)
	
	tileSize = minScreenSideSize / maxMapSideSize
	
	mapDrawX = (screenWidth - map.width * tileSize) / 2
	mapDrawY = (screenHeight - map.height * tileSize) / 2
	
	pathfindingFont = love.graphics.newFont(tileSize * PATHFINDING_FONT_SIZE_FACTOR)
	uiFont = love.graphics.newFont(screenHeight * UI_FONT_SIZE_FACTOR)
	
	instructionsLabelPos.x = math.floor(screenWidth * INSTRUCTIONS_LABEL_POS_FACTOR.x);
	instructionsLabelPos.y = math.floor(screenHeight * INSTRUCTIONS_LABEL_POS_FACTOR.y);
	
	creatureSpeedSlider:setSize({ width = screenWidth * SLIDER_SIZE_FACTORS.width, height = screenHeight * SLIDER_SIZE_FACTORS.height })
	creatureSpeedSlider:setPosition({ x = math.floor(screenWidth * CREATURE_SPEED_SLIDER_POS_FACTORS.x), y = math.floor(screenHeight * CREATURE_SPEED_SLIDER_POS_FACTORS.y) })
	
	creatureSpeedLabelPos.x = creatureSpeedSlider.position.x
	creatureSpeedLabelPos.y = creatureSpeedSlider.position.y - screenHeight * UI_LABEL_Y_OFFSET_FACTOR
	creatureSpeedValuesPos.x = creatureSpeedSlider.position.x
	creatureSpeedValuesPos.y = creatureSpeedSlider.position.y + screenHeight * UI_LABEL_Y_OFFSET_FACTOR
		
	pathfindingSpeedSlider:setSize({ width = screenWidth * SLIDER_SIZE_FACTORS.width, height = screenHeight * SLIDER_SIZE_FACTORS.height })
	pathfindingSpeedSlider:setPosition({ x = math.floor(screenWidth * PATHFINDING_SPEED_SLIDER_POS_FACTORS.x), y = math.floor(screenHeight * PATHFINDING_SPEED_SLIDER_POS_FACTORS.y) })
	
	pathfindingSpeedLabelPos.x = pathfindingSpeedSlider.position.x
	pathfindingSpeedLabelPos.y = pathfindingSpeedSlider.position.y - screenHeight * UI_LABEL_Y_OFFSET_FACTOR
	pathfindingSpeedValuesPos.x = pathfindingSpeedSlider.position.x
	pathfindingSpeedValuesPos.y = pathfindingSpeedSlider.position.y + screenHeight * UI_LABEL_Y_OFFSET_FACTOR
	
	clearObstaclesButton:setFont(uiFont)
	clearObstaclesButton:setSize({ width = screenWidth * BUTTON_SIZE_FACTORS.width, height = screenHeight * BUTTON_SIZE_FACTORS.height })
	clearObstaclesButton:setPosition({ x = math.floor(screenWidth * CLEAR_OBSTACLES_BUTTON_POS_FACTORS.x), y = math.floor(screenHeight * CLEAR_OBSTACLES_BUTTON_POS_FACTORS.y) })
	
	resetObstaclesButton:setFont(uiFont)
	resetObstaclesButton:setSize({ width = screenWidth * BUTTON_SIZE_FACTORS.width, height = screenHeight * BUTTON_SIZE_FACTORS.height })
	resetObstaclesButton:setPosition({ x = math.floor(screenWidth * RESET_OBSTACLES_BUTTON_POS_FACTORS.x), y = math.floor(screenHeight * RESET_OBSTACLES_BUTTON_POS_FACTORS.y) })
	
	mouseCursorLabelPos.x = math.floor(screenWidth * MOUSE_CURSOR_LABEL_POS_FACTORS.x);
	mouseCursorLabelPos.y = math.floor(screenHeight * MOUSE_CURSOR_LABEL_POS_FACTORS.y);
	
	statsPos.x = math.floor(screenWidth * STATS_POS_FACTORS.x);
	statsPos.y = math.floor(screenHeight * STATS_POS_FACTORS.y);
end

function onCreatureSpeedSliderChanged(percentage)
	creature:setSpeed(CREATURE_MIN_SPEED + (CREATURE_MAX_SPEED - CREATURE_MIN_SPEED) * percentage)
end

function onPathfindingSpeedSliderChanged(percentage)
	pathfindingSpeedValue = (PATHFINDING_MIN_SPEED + (PATHFINDING_MAX_SPEED - PATHFINDING_MIN_SPEED) * percentage)
	pathfindingAsyncPauseTime = PATHFINDING_MAX_SPEED - pathfindingSpeedValue
end

function onClearObstaclesButtonClicked()
	for x = 1, map.width do
		for y = 1, map.height do
			local tile = map:getTile(x, y)
			if tile then
				tile.isBlocking = false
			end
		end
	end
end

function onResetObstaclesButtonClicked()
	onClearObstaclesButtonClicked()
	setMapObstacles(map)
end

function drawMap()
	for x = 1, map.width do
		for y = 1, map.height do
			local tile = map:getTile(x, y)
			love.graphics.setColor(tile.isBlocking and BLOCKED_TILE_COLOR or FREE_TILE_COLOR)
			local rx, ry = mapDrawX + (x - 1) * tileSize + 1, mapDrawY + (y - 1) * tileSize + 1 -- offsets to have
			love.graphics.rectangle('fill', rx, ry, tileSize - 2, tileSize - 2)                 -- grid lines between tiles
		end
	end
end

function drawPathfinding()
	if not pathfindingInProgress then return end
	
	local drawNode = function(node, color)
		love.graphics.setColor(color)
		local rx, ry = mapDrawX + (node.x - 1) * tileSize + 1, mapDrawY + (node.y - 1) * tileSize + 1
		love.graphics.rectangle('fill', rx, ry, tileSize - 2, tileSize - 2)
		love.graphics.setColor(PATHFINDING_VALUES_COLOR)
		local tx, ty = math.floor(rx), math.floor(ry + pathfindingFont:getHeight() / 2)
		love.graphics.setFont(pathfindingFont)
		love.graphics.printf(string.format('%.1f', node.g), tx, ty, tileSize - 2, 'center')
	end
	
	for i, node in ipairs(pathfindingSearchData.openedList) do
		drawNode(node, PATHFINDING_OPENED_COLOR)
	end
	
	for index, node in pairs(pathfindingSearchData.closedMap) do
		drawNode(node, PATHFINDING_CLOSED_COLOR)
	end
	
	drawNode(pathfindingSearchData.activeNode, PATHFINDING_ACTIVE_COLOR)
end

function drawCreature()
	love.graphics.setColor(CREATURE_COLOR)
	local cx, cy = mapDrawX + (creature.pos.x + 0.5 - 1) * tileSize, mapDrawY + (creature.pos.y + 0.5 - 1) * tileSize
	love.graphics.circle('fill', cx, cy, tileSize * CREATURE_SIZE_FACTOR)
end

function drawUI()
	for i, widget in ipairs(widgets) do
		widget:draw()
	end
	
	love.graphics.setFont(uiFont)
	love.graphics.setColor(UI_FONT_COLOR)
	
	love.graphics.print('A* pathfinding demo with visualization.\nv1.0.0\n\n' ..
	                    'Left click to build path and follow it.\n' ..
	                    'Right click to draw & erase obstacles.', instructionsLabelPos.x, instructionsLabelPos.y)
	
	love.graphics.print('Creature speed', creatureSpeedLabelPos.x, creatureSpeedLabelPos.y)
	
	love.graphics.printf(tostring(CREATURE_MIN_SPEED), creatureSpeedValuesPos.x, creatureSpeedValuesPos.y, creatureSpeedSlider.size.width, 'left')
	love.graphics.printf(tostring(CREATURE_MAX_SPEED), creatureSpeedValuesPos.x, creatureSpeedValuesPos.y, creatureSpeedSlider.size.width, 'right')
	love.graphics.printf(tostring(math.floor(creature.speed)), creatureSpeedValuesPos.x, creatureSpeedValuesPos.y, creatureSpeedSlider.size.width, 'center')
	
	love.graphics.print('Pathfinding speed', pathfindingSpeedLabelPos.x, pathfindingSpeedLabelPos.y)
	
	love.graphics.printf(tostring(PATHFINDING_MIN_SPEED), pathfindingSpeedValuesPos.x, pathfindingSpeedValuesPos.y, pathfindingSpeedSlider.size.width, 'left')
	love.graphics.printf(tostring(PATHFINDING_MAX_SPEED), pathfindingSpeedValuesPos.x, pathfindingSpeedValuesPos.y, pathfindingSpeedSlider.size.width, 'right')
	love.graphics.printf(string.format('%.2f', pathfindingSpeedValue), pathfindingSpeedValuesPos.x, pathfindingSpeedValuesPos.y, pathfindingSpeedSlider.size.width, 'center')
	
	love.graphics.print(string.format('Mouse cursor pos: (%i, %i)', mouseCursorTilePos.x, mouseCursorTilePos.y), mouseCursorLabelPos.x, mouseCursorLabelPos.y)
	
	local stats = string.format('Stats\n===\nIterations: %i\nOpened nodes this iteration: %i\nOpened nodes total: %i\n' ..
															'Closed nodes total: %i\nDuplicate nodes total: %i\nAll nodes total: %i',
	                            statsIterations, statsOpenedNodesThisIter, statsOpenedNodesTotal, statsClosedNodesTotal, statsDuplicateNodesTotal, statsAllNodesTotal)
	love.graphics.print(stats, statsPos.x, statsPos.y)
end
