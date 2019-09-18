require 'widget'

Slider = Widget:new()
Slider.__index = Slider

function Slider:new()
	local slider = {
		percentage = 0,
		lineWidth = 0,
		slidRadius = 0,
		lineY = 0,
		slidX = 0,
		lineColor = { 1, 1, 1, 1 },
		slidColor = { 1, 1, 1, 1 },
		onChangeHanders = {}
	}
	setmetatable(slider, self)
	return slider
end

function Slider:setPercentage(percentage)
	self.percentage = percentage
	self.slidX = self.size.width * percentage
	for k, v in pairs(self.onChangeHanders) do
		v(percentage)
	end
end

function Slider:setLineColor(color)
	self.lineColor = color
end

function Slider:setSlidColor(color)
	self.slidColor = color
end

function Slider:onMousePressed(x, y)
	if not Widget.onMousePressed(self, x, y) then return end
	if not love.mouse.isDown(1) then return end
	self:setPercentage((x - self.position.x) / self.lineWidth)
end

function Slider:onMouseMoved(x, y)
	if not Widget.onMouseMoved(self, x, y) then return end
	if not love.mouse.isDown(1) then return end
	self:setPercentage((x - self.position.x) / self.lineWidth)
end

function Slider:addOnChangedHandler(handler)
	self.onChangeHanders[handler] = handler
end

function Slider:removeOnChangedHandler(handler)
	self.onChangeHanders[handler] = nil
end

function Slider:setSize(size)
	Widget.setSize(self, size)
	self.lineWidth = size.width
	self.lineY = size.height / 2
	self.slidRadius = size.height / 2
	self.slidX = self.size.width * self.percentage
end

function Slider:draw()
	local y = self.position.y + self.lineY
	love.graphics.setColor(self.lineColor)
	love.graphics.line(self.position.x, y, self.position.x + self.lineWidth, y)
	love.graphics.setColor(self.slidColor)
	love.graphics.circle('fill', self.position.x + self.slidX, y, self.slidRadius)
end
