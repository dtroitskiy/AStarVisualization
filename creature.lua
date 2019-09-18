require 'vector2'

Creature = {}
Creature.__index = Creature

function Creature:new(x, y, speed)
	local creature = {
		pos = Vector2:new(x, y),
		dir = nil,
		speed = speed,
		path = nil,
		stepIndex = nil,
		excessiveMovement = 0
	}
	setmetatable(creature, self)
	return creature
end

function Creature:setPosition(x, y)
	self.pos = Vector2:new(x, y)
end

function Creature:setSpeed(speed)
	self.speed = speed
end

function Creature:setPath(path)
	if #path > 0 then
		self.path = path
		self.stepIndex = 1
	end
end

function Creature:update(dt)
	
	if self.path then
		-- initializing dir when needed (needs to renewed on each step)
		local step = self.path[self.stepIndex]
		local toTarget = Vector2:new(step.x - self.pos.x, step.y - self.pos.y)
		if not self.dir then
			self.dir = toTarget:copy()
			self.dir:normalize()
			-- adding excessive movement left from previous step (if any)
			self.pos.x = self.pos.x + self.dir.x * self.excessiveMovement
			self.pos.y = self.pos.y + self.dir.y * self.excessiveMovement
		end
		
		-- movement
		self.pos.x = self.pos.x + self.dir.x * self.speed * dt
		self.pos.y = self.pos.y + self.dir.y * self.speed * dt
		
		-- checking that path step is reached
		if self.dir:dot(toTarget) <= 0 then
			self.pos.x = step.x
			self.pos.y = step.y
			if self.stepIndex < #self.path then
				self.stepIndex = self.stepIndex + 1 -- switching to next step
				self.excessiveMovement = toTarget:length()
				self.dir = nil
				self:update(0)
			else
				self.path = nil -- traversed full path till the end
			end
		end
	end

end
