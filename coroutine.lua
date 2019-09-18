function printResult(a)
	for i = 1, #a do
		io.write(a[i], ' ')
	end
	io.write('\n')
end

function permgen(a, n)
	n = n or #a --default for 'n' is size of 'a'
	if n <= 1 then --nothing to change?
		coroutine.yield(a)
	else
		for i = 1, n do
			--put i-th element as the last one
			a[n], a[i] = a[i], a[n]
			--generate all permutations of the other elements
			permgen(a, n - 1)
			--restore i-th element
			a[n], a[i] = a[i], a[n]
		end
	end
end

function combgen(a, b, c)
	local nc = {}
	if c then
		for k, v in pairs(c) do
			nc[k] = v
		end
	end
	local n = #a
	if b <= 0 or n <= 0 then
		coroutine.yield(nc)
	else
		for i = 1, n do
			table.insert(nc, table.remove(a, i))
			combgen(a, b - 1, nc)
			table.insert(a, i, table.remove(nc, #nc))
		end
	end
end

function permutations(a)
	return coroutine.wrap(function () permgen(a) end)
end

function combinations(a, b)
	return coroutine.wrap(function () combgen(a, b) end)
end

for p in combinations({ 'a', 'b', 'c', 'd', 'e' }, 3) do
	printResult(p)
end
