local inp = {}
local guard = nil
for value in io.lines() do
  local i = value:find("^", 1, true)
  if i ~= nil then
    guard = { x = i, y = #inp + 1 }
    value = value:sub(1, i - 1) .. "." .. value:sub(i + 1, #value)
  end
  table.insert(inp, value)
end
local function inbounds(x, y)
  return x > 0 and y > 0 and x <= #inp[1] and y <= #inp
end

local dirs = { { x = 0, y = -1 }, { x = 1, y = 0 }, { x = 0, y = 1 }, { x = -1, y = 0 } }
local function walk(inp, gx, gy)
  local dir = 1
  local path = { { x = gx, y = gy } }
  while inbounds(gx + dirs[dir].x, gy + dirs[dir].y) do
    if inp[gy + dirs[dir].y]:byte(gx + dirs[dir].x) == string.byte("#") then
      if dir == 4 then
        dir = 1
      else
        dir = dir + 1
      end
    else
      gx = gx + dirs[dir].x
      gy = gy + dirs[dir].y
      table.insert(path, { x = gx, y = gy })
    end
    if #path > #inp * #inp then
      return nil
    end
  end
  return path
end

local path = walk(inp, guard.x, guard.y)
local unique = {}
local n = 0
for _, value in ipairs(path) do
  if not unique[value.y] then
    unique[value.y] = {}
  end
  if not unique[value.y][value.x] then
    unique[value.y][value.x] = true
    n = n + 1
  end
end
print("Part 1:", n)

local n2 = 0
local unique2 = {}
for i, value in ipairs(path) do
  if i ~= 1 then
    local ninp = {}
    for y, line in ipairs(inp) do
      if y == value.y then
        line = line:sub(1, value.x - 1) .. "#" .. line:sub(value.x + 1, #line)
      end
      table.insert(ninp, line)
    end
    if walk(ninp, guard.x, guard.y) == nil
    then
      if not unique2[value.y] then
        unique2[value.y] = {}
      end
      if not unique2[value.y][value.x] then
        unique2[value.y][value.x] = true
        n2 = n2 + 1
      end
    end
  end
end
print("Part 2:", n2)
