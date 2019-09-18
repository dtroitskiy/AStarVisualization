Widget = {}
Widget.__index = Widget

function Widget:new()
	local widget = {
		size = { width = 0, height = 0 },
		position = { x = 0, y = 0 }
	}
	setmetatable(widget, self)
	return widget
end

function Widget:setSize(size)
	self.size = size
end

function Widget:setPosition(pos)
	self.position = pos
end

function Widget:onMousePressed(x, y)
	return self:isPositionInBounds({ x = x, y = y })
end

function Widget:onMouseMoved(x, y)
	return self:isPositionInBounds({ x = x, y = y })
end

function Widget:onMouseReleased(x, y)
	return self:isPositionInBounds({ x = x, y = y })
end

function Widget:isPositionInBounds(pos)
	if pos.x >= self.position.x and pos.x <= self.position.x + self.size.width and
	   pos.y >= self.position.y and pos.y <= self.position.y + self.size.height then
		return true
	else
		return false
	end
end
