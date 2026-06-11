--==========================================================================================
-- This purely holds helper functions
--==========================================================================================

local function ClampVector(vect, low, high)
      local clampedVector = vect:copy()
      clampedVector.x = math.clamp(clampedVector.x, low.x, high.x)
      clampedVector.y = math.clamp(clampedVector.y, low.y, high.y)
      clampedVector.z = math.clamp(clampedVector.z, low.z, high.z)  
      return clampedVector
end

local function RandomFloat(min, max)
  return min + math.random() * (max - min)
end

-- Recursive function to grab all folders and groups
local function GetModelFoldersRecursively(container, part)
  -- Check if this part has children (meaning it's a folder/group, not a single cube)
  if container ~= nil and part ~= nil and part:getChildren() ~= nil and #part:getChildren() > 0 then
    table.insert(container, part)
        
    -- Loop through all children and search inside them
    for _, child in ipairs(part:getChildren()) do
       GetModelFoldersRecursively(container,child)
    end
  end
  return container
end

local function TableContains(tbl, x)
  for _, value in ipairs(tbl) do
    if value == x then
      return true
    end
  end
  return false
end

local function InverseLerp(min, max, value)
  if min == max then
      return 0 -- Prevent division by zero
  end
  return (value - min) / (max - min)
end

local function check_brackets(s)
  if #s < 2 then -- String must have at least two characters
    return false
  end
  local first_char = string.sub(s, 1, 1)
  local last_char = string.sub(s, -1, -1)
  return first_char == "{" and last_char == "}"
end

local function VectorRound(vect, place)
  if not vect then return vec(0, 0, 0) end

  local newVec = vect:copy()

  local placeScaler = 1

  if place < 0 then
    placeScaler = 10 ^ (-place)
    newVec = vec(
        math.floor(vect.x * placeScaler + 0.5) / placeScaler,
        math.floor(vect.y * placeScaler + 0.5) / placeScaler,
        math.floor(vect.z * placeScaler + 0.5) / placeScaler
    )
  elseif place > 0 then
    placeScaler = 10 ^ (place - 1)
    newVec = vec(
        math.floor(vect.x / placeScaler + 0.5) * placeScaler,
        math.floor(vect.y / placeScaler + 0.5) * placeScaler,
        math.floor(vect.z / placeScaler + 0.5) * placeScaler  
    )
  end

  return newVec
end

local function FloatRound(value, place)
  if place == 0 then return value end

  if place < 0 then
    local multiplier = 10 ^ (-place)
    return math.floor(value * multiplier + 0.5) / multiplier
  elseif place > 0 then
    local multiplier = 10 ^ (place - 1)
    return math.floor(value / multiplier + 0.5) * multiplier
  end
end

local function GetForwardDirOfModel(model)
  local getRotation = model:getRot()

  -- Assume these are your model's current rotations in degrees
  local modelPitch = getRotation.x or 0 -- X rotation (Up/Down)
  local modelYaw   = getRotation.y or 0   -- Y rotation (Left/Right)

  -- 1. CONVERT TO RADIANS: Lua math functions require radians instead of degrees
  local radPitch = math.rad(modelPitch)
  local radYaw   = math.rad(modelYaw)

  -- 2. CALCULATE THE 3D VECTOR COMPONENT PARTS:
  -- Pitch controls the vertical height (Y). 
  -- Cosine of Pitch scales the flat horizontal plane (X and Z).
  local x = -math.sin(radYaw) * math.cos(radPitch)
  local y =  math.sin(radPitch)
  local z =  math.cos(radYaw) * math.cos(radPitch)

  -- 3. COMBINE AND NORMALIZE: 
  -- Creates a clean arrow vector with an exact length of 1 block
  local forwardDir = vec(x, y, z):normalize()
  return forwardDir
end

--Makes all angles between -180 and 180
local function NormalizeAngle(angle)
  return (angle + 180) % 360 - 180
end

-- 2. The custom yaw clamp function
local function ClampAngle(currentAngle, centerAngle, limit)
    -- Find the shortest angular distance between current and center
    local diff = NormalizeAngle(currentAngle - centerAngle)
    
    -- Clamp the distance between negative limit and positive limit
    local clampedDiff = math.clamp(diff, -limit, limit)

    -- Add the safe distance back to the center angle
    return NormalizeAngle(centerAngle + clampedDiff)
end

local helperFunctions =
{
  ClampVector = ClampVector,
  RandomFloat = RandomFloat,
  GetModelFoldersRecursively = GetModelFoldersRecursively,
  TableContains = TableContains,
  check_brackets = check_brackets,
  InverseLerp = InverseLerp,
  GetForwardDirOfModel = GetForwardDirOfModel,
  NormalizeAngle = NormalizeAngle,
  VectorRound = VectorRound,
  FloatRound = FloatRound,
  ClampAngle = ClampAngle
}

return helperFunctions