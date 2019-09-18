require 'widget'

Button = Widget:new()
Button.__index = Button

function Button:new(label)
	local button = {
		label = label,
		font = nil,
		color = { 1, 1, 1, 1 },
		pressedColor = { 1, 1, 1, 1 },
		roundness = 0,
		roundnessRadius = 0,
		labelY = 0,
		isPressed = false,
		onPressedHanders = {},
		onReleasedHanders = {}
	}
	setmetatable(button, self)
	return button
end

function Button:setLabel(label)
	self.label = label
end

function Button:setFont(font)
	self.font = font
end

function Button:setColor(color)
	self.color = color
end

function Button:setPressedColor(color)
	self.pressedColor = color
end

function Button:setRoundness(roundness)
	if roundness < 0 then roundness = 0 end
	if roundness > 1 then roundness = 1 end
	self.roundness = roundness
end

function Button:onMousePressed(x, y)
	if not Widget.onMousePressed(self, x, y) then return end
	self.isPressed = love.mouse.isDown(1)
	if self.isPressed then
		for k, v in pairs(self.onPressedHanders) do
			v()
		end
	end
end

function Button:onMouseReleased(x, y)
	self.isPressed = false
	if not Widget.onMousePressed(self, x, y) then return end
	for k, v in pairs(self.onReleasedHanders) do
		v()
	end
end

function Button:addOnPressedHandler(handler)
	self.onPressedHanders[handler] = handler
end

function Button:removedOnPressedHandler(handler)
	self.onPressedHanders[handler] = nil
end

function Button:addOnReleasedHandler(handler)
	self.onReleasedHanders[handler] = handler
end

function Button:removedOnReleasedHandler(handler)
	self.onReleasedHanders[handler] = nil
end

function Button:setSize(size)
	Widget.setSize(self, size)
	self.roundnessRadius = size.height * 0.5 * self.roundness
	self.labelY = (size.height - self.font:getHeight()) / 2
end

function Button:draw()
	love.graphics.setColor(self.isPressed and self.pressedColor or self.color)
	if self.roundness == 0 then
		love.graphics.rectangle('line', self.position.x, self.position.y, self.size.width, self.size.height)
	else
		love.graphics.arc('line', 'open', self.position.x + self.roundnessRadius, self.position.y + self.roundnessRadius,
		                  self.roundnessRadius, -math.pi, -math.pi / 2, 8)
		love.graphics.arc('line', 'open', self.position.x + self.size.width - self.roundnessRadius, self.position.y + self.roundnessRadius,
											self.roundnessRadius, -math.pi / 2, 0, 8)
		love.graphics.arc('line', 'open', self.position.x + self.size.width - self.roundnessRadius, self.position.y + self.size.height - self.roundnessRadius,
		                  self.roundnessRadius, 0, math.pi / 2, 8)
		love.graphics.arc('line', 'open', self.position.x + self.roundnessRadius, self.position.y + self.size.height - self.roundnessRadius,
		                  self.roundnessRadius, math.pi / 2, math.pi, 8)
		love.graphics.line(self.position.x + self.roundnessRadius, self.position.y, self.position.x + self.size.width - self.roundnessRadius, self.position.y)
		love.graphics.line(self.position.x + self.roundnessRadius, self.position.y + self.size.height,
		                   self.position.x + self.size.width - self.roundnessRadius, self.position.y + self.size.height)
		love.graphics.line(self.position.x, self.position.y + self.roundnessRadius, self.position.x, self.position.y + self.size.height - self.roundnessRadius)
		love.graphics.line(self.position.x + self.size.width, self.position.y + self.roundnessRadius,
		                   self.position.x + self.size.width, self.position.y + self.size.height - self.roundnessRadius)
	end
	love.graphics.setFont(self.font)
	love.graphics.printf(self.label, self.position.x, self.position.y + self.labelY, self.size.width, 'center')
end
