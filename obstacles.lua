function setMapObstacles(map)
	local x, y = 0, 0
	
	for x = 10, 14 do
		map:getTile(x, 10).isBlocking = true
	end
	
	for x = 29, 33 do
		for y = 23, 27 do
			map:getTile(x, y).isBlocking = true
		end
	end
	
	for y = 15, 22 do
		map:getTile(20, y).isBlocking = true
	end
	
	for x = 32, 38 do
		map:getTile(x, 12).isBlocking = true
	end
	
	for y = 13, 19 do
		map:getTile(32, y).isBlocking = true
	end
	
	for y = 13, 19 do
		map:getTile(38, y).isBlocking = true
	end
	
	x, y = 15, 35
	while x <= 20 and y >= 30 do
		map:getTile(x, y).isBlocking = true
		x = x + 1
		y = y - 1
	end
	
	x, y = 14, 35
	while x <= 20 and y >= 30 do
		map:getTile(x, y).isBlocking = true
		x = x + 1
		y = y - 1
	end
	
	for x = 23, 31 do
		map:getTile(x, 38).isBlocking = true
	end
	
	for y = 33, 38 do
		map:getTile(31, y).isBlocking = true
	end
	
	for x = 31, 39 do
		map:getTile(x, 32).isBlocking = true
	end
	
	for x = 23, 29 do
		map:getTile(x, 8).isBlocking = true
	end
	
	for y = 5, 11 do
		map:getTile(26, y).isBlocking = true
	end
	
	for x = 15, 17 do
		map:getTile(x, 24).isBlocking = true
	end
	
	for x = 4, 17 do
		map:getTile(x, 26).isBlocking = true
	end
	
	for y = 15, 23 do
		map:getTile(15, y).isBlocking = true
	end
	
	for x = 6, 14 do
		map:getTile(x, 15).isBlocking = true
	end
	
	for y = 13, 25 do
		map:getTile(4, y).isBlocking = true
	end
	
	map:getTile(6, 13).isBlocking = true
	map:getTile(6, 14).isBlocking = true
	
	for x = 5, 15 do
		map:getTile(x, 38).isBlocking = true
	end
	
	for y = 39, 48 do
		map:getTile(15, y).isBlocking = true
	end
	
	for x = 5, 14 do
		map:getTile(x, 48).isBlocking = true
	end
	
	for y = 40, 47 do
		map:getTile(5, y).isBlocking = true
	end
	
	for x = 6, 13 do
		map:getTile(x, 40).isBlocking = true
	end
	
	for y = 41, 46 do
		map:getTile(13, y).isBlocking = true
	end
	
	for x = 7, 12 do
		map:getTile(x, 46).isBlocking = true
	end
	
	for y = 42, 45 do
		map:getTile(7, y).isBlocking = true
	end
	
	for x = 8, 11 do
		map:getTile(x, 42).isBlocking = true
	end
	
	for y = 43, 44 do
		map:getTile(11, y).isBlocking = true
	end
	
	for x = 9, 10 do
		map:getTile(x, 44).isBlocking = true
	end
	
	for x = 26, 34 do
		map:getTile(x, 43).isBlocking = true
	end
	
	for x = 26, 34 do
		map:getTile(x, 45).isBlocking = true
	end
	
	for y = 39, 42 do
		map:getTile(34, y).isBlocking = true
	end
	
	for y = 46, 49 do
		map:getTile(34, y).isBlocking = true
	end
	
	for y = 39, 49 do
		map:getTile(36, y).isBlocking = true
	end
	
	for x = 37, 49 do
		map:getTile(x, 39).isBlocking = true
	end
	
	for x = 37, 49 do
		map:getTile(x, 49).isBlocking = true
	end
	
	for y = 40, 48 do
		map:getTile(49, y).isBlocking = true
	end
	
	map:getTile(43, 39).isBlocking = false
	map:getTile(43, 49).isBlocking = false
	map:getTile(49, 44).isBlocking = false
	
	for x = 39, 46 do
		map:getTile(x, 42).isBlocking = true
	end

	for x = 39, 46 do
		map:getTile(x, 46).isBlocking = true
	end
end
