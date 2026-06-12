--==========================================================================================
-- Weight Related
-- Weight gain script by SyntaxScales
-- Edited by Mizi! (referenced Jams code a bit!)
--==========================================================================================
--Version
local we_ = {}
we_.version_ = "1.0.4"
we_.size_ = 1

--Config
local modelConfig_ = require("config")
local lizard_ = modelConfig_.lizard
local lizardFullbody_ = modelConfig_.lizardFullbody
local lizardBody_ = modelConfig_.lizardBody
local lizardLegs_ = modelConfig_.lizardLegs
local lizardTail_ = modelConfig_.lizardTail
local lizardHead_ = modelConfig_.lizardHead

-- Helpers
local h_ = require("scripts.api.helper")

-- Chat
local ch_ = require("scripts.chat")

--Weight Vars
--------------
local syncPingTimer = 0   -- Used to sync the weight variables with players that joined a server and haven't gotten pinged yet

-- Weight variables
local weight_ = 0          -- Weight is stored as a float from 0 to 1. 0 is minimum weight, while 1 is maximum
local weightVariant_ = {level = 0, minWeight = 0}  -- Determines which set of manually-designed fat parts get toggled
local macro = false       -- Fun feature
local preGUIScale = nil

-- Eating variables
local prevFood = 0
local prevSaturation = 0

local weightPerHungerPoint = 0.002 -- Modify this if you want to increase/decrease the amount gained by eating, currently sat to 0, so it's disabled. Use your emote wheel in figura to gain for now.

-- Effect variables
local cameraShakeDuration = 0
local cameraShakeMaxDuration = 0
local cameraShakeIntensity = 0
local cameraShakeUpdateTicker = 0 -- Used by receivers to detect updates to screen shake

local cameraShakeReceiverTable = {}

local timeNotGrounded = 0 -- Used to shake grouond after certain number of ticks
local stepTime = 0
local wasSleeping = false

-- Mitsi note: I haven't messed with sounds yet, although I'm 100% sure Soft will want to have everyone hear their gurgly gut :RivOwO:
-- Sound variables
local gurgleSoundTimer = 0
local sloshSoundTimer = 0
local prevYaw = 0
local hungrySoundTimer = 0
local attenuationModifier = 1 -- Modifies distance from which all sounds can be heard

--The different weights and how much food needs to be eaten for each
local weightVariants_ = 
{
  {level = 0, minWeight = 0, heightScale = 1.1},
  {level = 1, minWeight = 0.14, heightScale = 1.2},
  {level = 2, minWeight = 0.28, heightScale = 1.3},
  {level = 3, minWeight = 0.42, heightScale = 1.4},
  {level = 4, minWeight = 0.56, heightScale = 1.5},
}


--Removes the warning from sound attenuationtion
---@diagnostic disable: undefined-field


--==========================================================================================
-- Retriever Functions
--==========================================================================================

local function receiverUpdate()
  -- First, iterate through every player in the world, stored in the variable v
  for k, v in pairs(world:getPlayers()) do
    -- Then, check to ensure the user is not receiving their own camera shake. This is only really necessary if this function is in the WG script
    if (not (v:getUUID() == avatar:getUUID())) then
      -- Get camera shake information from the avatar's stored variables
      local shakeDuration = v:getVariable("cameraShakeDuration")
      local shakeMaxDuration = v:getVariable("cameraShakeMaxDuration")
      local shakeIntensity = v:getVariable("cameraShakeIntensity")

      --[[
      The shake intensity or shake duration is not updated every frame. Therefore,
      a separate variable is needed to detect when a change to the camera shake state has occured.
      This value is compared with the value stored in the cameraShakeReceiverTable using the player's UUID.
      If the values don't match, that means a new camera shake occured.
      Then, after that is checked, it updates the table to contain the new value
      --]]
      local shakeUpdateTicker = v:getVariable("cameraShakeUpdateTicker")

      -- Make sure that the camera shake information was actually found. If not, the user is not wearing a WG avatar
      if (not (shakeDuration == nil or shakeMaxDuration == nil or shakeIntensity == nil or shakeUpdateTicker == nil)) then
        -- If the viewer is too far away, don't shake
        if ((player:getPos() - v:getPos()):length() <= shakeIntensity * 1200) then
          -- If there has been an update (meaning a new screen shake was sent)
          if (not (cameraShakeReceiverTable[v:getUUID()] == nil or shakeUpdateTicker == cameraShakeReceiverTable[v:getUUID()])) then
            cameraShakeDuration = shakeDuration
            cameraShakeMaxDuration = shakeMaxDuration
            cameraShakeIntensity = shakeIntensity
          end
        end

        cameraShakeReceiverTable[v:getUUID()] = shakeUpdateTicker
      end
    end
  end
end







--==========================================================================================
--Regular Functions
--==========================================================================================

-- Toggles model parts for manually created stages of model weight gain
local function setWeightVariant(variant)
  if (weightVariant_ == variant) then
    return
  end
  weightVariant_ = variant

  if weight_ < weightVariant_.minWeight then
    weight_ = weightVariant_.minWeight
  end

  if true then return end -- didn't weight for models aren't made yet

  --Toggle body parts
  local activation = (variant == 0)
  models.model.BodyW0:setVisible(activation)
  models.model.TailW0:setVisible(activation)
  models.model.LeftArmW0:setVisible(activation)
  models.model.RightArmW0:setVisible(activation)
  models.model.LeftLegW0:setVisible(activation)
  models.model.RightLegW0:setVisible(activation)
  activation = (variant == 1)
  models.model.BodyW1:setVisible(activation)
  models.model.TailW1:setVisible(activation)
  models.model.LeftArmW0:setVisible(activation)
  models.model.RightArmW0:setVisible(activation)
  models.model.LeftLegW1:setVisible(activation)
  models.model.RightLegW1:setVisible(activation)
  activation = (variant == 2)
  models.model.BodyW2:setVisible(activation)
  models.model.TailW1:setVisible(activation)
  models.model.LeftArmW2:setVisible(activation)
  models.model.RightArmW2:setVisible(activation)
  models.model.LeftLegW2:setVisible(activation)
  models.model.RightLegW2:setVisible(activation)
  activation = (variant == 3)
  models.model.HeadW3:setVisible(activation)
  models.model.BodyW3:setVisible(activation)
  models.model.TailW3:setVisible(activation)
  models.model.LeftArmW3:setVisible(activation)
  models.model.RightArmW3:setVisible(activation)
  models.model.LeftLegW3:setVisible(activation)
  models.model.RightLegW3:setVisible(activation)
  activation = (variant == 4)
  models.model.HeadW3:setVisible(activation)
  models.model.BodyW4:setVisible(activation)
  models.model.TailW4:setVisible(activation)
  models.model.LeftArmW4:setVisible(activation)
  models.model.RightArmW4:setVisible(activation)
  models.model.LeftLegW4:setVisible(activation)
  models.model.RightLegW4:setVisible(activation)
end

-- I'll modify the "weight" value in the future to go higher then one for funsies sakes :RivOwO:
local function setWeight(amount)
    weight_ = amount
    weight_ = math.clamp(weight_,0,1)
    local newWR = GetWeightVariantFromWeight(weight_)
    setWeightVariant(newWR)
    UpdateModelScales()
end

function GetWeightVariantFromWeight(weight)
  for i = #weightVariants_, 1, -1 do
    if weight > weightVariants_[i].minWeight then
      return weightVariants_[i]
    end
  end
  return weightVariants_[1]
end


function UpdateModelScales()
  local finalScale = 1

  for _, variant in ipairs(weightVariants_) do
    if variant.level < weightVariant_.level then
      finalScale = finalScale * variant.heightScale
    else
      break
    end
  end

  local nextLimit = 1
  if weightVariant_.level + 1 ~= #weightVariants_ then
    nextLimit = weightVariants_[weightVariant_.level + 2].minWeight
  end

  local scaleAmount = h_.InverseLerp(weightVariant_.minWeight, nextLimit, weight_)

  --print("scale amount:" .. scaleAmount .. "weightVariant_:" .. weightVariant_.minWeight .. " nextLimit:" .. nextLimit .. " weight_:" .. weight_)

  scaleAmount = math.lerp(1, weightVariant_.heightScale, scaleAmount)
  --print("scaling by " .. scaleAmount)
  finalScale = finalScale * scaleAmount

  --[[ Scales the stomach based on weight
  if weightVariant_.level == 0 then
    --models.model.Body.Stomach:setScale(scaleAmount) 
  elseif weightVariant_.level == 1 then
    --models.model.Body2.Stomach:setScale(scaleAmount) 
  elseif weightVariant_.level == 2 then
    --models.model.BodyW2.BellyW2:setScale(scaleAmount) 
  elseif weightVariant_.level == 3 then
    --models.model.BodyW3.BellyW3:setScale(scaleAmount) 
  else
      --none
  end
  ]]

  local reducedScale = math.min(1, 1 / (finalScale * 0.75) )

  if (macro) then
    finalScale = finalScale * 2
    reducedScale = math.min(1, 1 / (finalScale * 0.75) )
  end

  pings.SetAdditionalScale(finalScale)

  
  -- De-scale the head and hands (since the head shouldn't grow larger. Only fatter)
  lizardHead_:setScale(reducedScale)

  --adjust head if need be
  if (macro) then
      lizardHead_:setPos(0, (finalScale - 1) * 0.06, 0)
  else
     lizardHead_:setPos(0, (finalScale - 1) * 0.1, 0)
  end
  --models.model.HeadW3:setScale(models.model.Head:getScale()) -------------------------------- MODIFY HERE TO ADJUST HEAD/ARM DE-SCALING AT HUGE SIZES (Mitsi note:This is for your fat face cheeks, so they dont scale to hard while you get massive.
  --  models.model.HeadW3:setPos(models.model.Head:getPos())
  --  models.model.LeftArmW4.LeftHandW4:setScale(1 / scale * reducedScale)
  --  models.model.RightArmW4.RightHandW4:setScale(1 / scale * reducedScale) -- We shouldnt need these yet, so I disabled them for you guys for now - Mitsi
end

-- Make big \\\\ not needed for now -Mitsi
local function setMacro(value)
  if (macro == value) then
    return
  end
  macro = value

  if (macro) then
    attenuationModifier = 16
    gurgleSoundTimer = 0
  else
    attenuationModifier = 1
  end
end





function shakeCamera(duration, intensity)
  if (macro) then
    cameraShakeDuration = duration * 6
    cameraShakeMaxDuration = duration * 6
    cameraShakeIntensity = intensity * 8
  else
    cameraShakeDuration = duration
    cameraShakeMaxDuration = duration
    cameraShakeIntensity = intensity
  end

  -- Store so receivers can have their screen shaken
  avatar:store("cameraShakeDuration", cameraShakeDuration)
  avatar:store("cameraShakeMaxDuration", cameraShakeMaxDuration)
  avatar:store("cameraShakeIntensity", cameraShakeIntensity)
  cameraShakeUpdateTicker = cameraShakeUpdateTicker + 1
  avatar:store("cameraShakeUpdateTicker", cameraShakeUpdateTicker)
end

-- Sound for stepping while extremely large
local function stepEffects()
    sounds:playSound("block.stone.hit", player:getPos(), 0.5, 0.3 - math.random() * 0.1, false)
    :setAttenuation(4 * attenuationModifier)
    if (macro) then
      sound = sounds:playSound("entity.zombie.attack_wooden_door", player:getPos(), 0.1, 0.3, false)
      sound:setAttenuation(6 * attenuationModifier)
    end
    
    if (cameraShakeDuration <= 4 or cameraShakeIntensity <= 0.05) then
      shakeCamera(16, 0.05)
    end
end

-- Sound for landing after a jump while extremely large
local function jumpEffects()
    sounds:playSound("entity.generic.small_fall", player:getPos(), 0.4, 0.15, false)
    :setAttenuation(4 * attenuationModifier)
    if (weight_ >= 0.9) then
        sounds:playSound("entity.zombie.attack_wooden_door", player:getPos(), 0.15, 0.4, false)
        :setAttenuation(4 * attenuationModifier)
    end
    if (macro) then
        sounds:playSound("entity.zombie.break_wooden_door", player:getPos(), 0.15, 0.15, false)
        :setAttenuation(8 * attenuationModifier)
    end

    shakeCamera(16, weight_ * 0.3)
end

-- Ground slam for landing while extremely large
local function groundSlamEffects()
    sounds:playSound("entity.generic.small_fall", player:getPos(), 1, 0.15, false)
    :setAttenuation(6 * attenuationModifier)
    if (weight_ >= 0.9) then
        sounds:playSound("entity.zombie.break_wooden_door", player:getPos(), 0.5, 0.3, false)
        :setAttenuation(8 * attenuationModifier)
        sounds:playSound("entity.generic.explode", player:getPos(), 0.4, 0.35, false)
        :setAttenuation(8 * attenuationModifier)
    else
        sounds:playSound("entity.zombie.break_wooden_door", player:getPos(), 0.25, 0.5, false):setAttenuation(6 * attenuationModifier)
    end
    if (macro) then
        sounds:playSound("entity.zombie.break_wooden_door", player:getPos(), 0.25, 0.05, false):setAttenuation(8 * attenuationModifier)
    end

    

     -- Create ground particles
    for i=0,255 do
        local pos = player:getPos()
        pos = vec(pos.x + (math.random() - 0.5) * weight_ * 12, pos.y + 0.25, pos.z + (math.random() - 0.5) * weight_ * 12)
        particles:newParticle("minecraft:block minecraft:stone", pos, vec(0, 1, 0))
    end

    shakeCamera(35 + weight_ * 40, weight_ * 0.6)
end

-- Splash effects for landing in water while extremely large
local function waterSlamEffects()
    if (weight_ >= 0.9) then
        sounds:playSound("entity.player.splash.high_speed", player:getPos(), 0.5, 0.4, false)
        :setAttenuation(8 * attenuationModifier)
        sounds:playSound("entity.generic.explode", player:getPos(), 0.4, 0.35, false)
        :setAttenuation(8 * attenuationModifier)
    else
        sounds:playSound("entity.player.splash.high_speed", player:getPos(), 0.5, 0.75, false)
        :setAttenuation(6 * attenuationModifier)
    end

    -- Create water particles
    local pos
    for i=0,127 do
        pos = player:getPos()
        pos = vec(pos.x + (math.random() - 0.5) * weight_ * 12, pos.y + 0.25, pos.z + (math.random() - 0.5) * weight_ * 12)
        if (math.random(0, 1) <= 0) then
            particles:newParticle("minecraft:block minecraft:water", pos, vec(0, 1, 0))
        else
            particles:newParticle("cloud", pos, vec(0, 0, 0))
        end
    end

    shakeCamera(35 + weight_ * 40, weight_ * 0.6)
end




--==========================================================================================
--Sound Functions
--==========================================================================================

-- Plays sound effects where appropriate
local function updateSounds()
  -- Gurgle sounds
  if (weightVariant_.level >= 3) then
    gurgleSoundTimer = gurgleSoundTimer - 1
    if (gurgleSoundTimer <= 0) then
      gurgleSoundTimer = math.random(1100, 1300) - (weightVariant_.level - 3) * 800
      if (macro) then
         gurgleSoundTimer = 160
      end
      playGurgleSound()
    end
  end

  -- Slosh sounds
  local minYaw = 48
  if (macro) then
     minYaw = 12
  end
  if (weightVariant_.level >= 2) then
    sloshSoundTimer = sloshSoundTimer - 1
    if (sloshSoundTimer <= 0 and math.abs(player:getBodyYaw() - prevYaw) > minYaw) then
      sloshSoundTimer = 6
      playSloshSound()
    end
  end
  prevYaw = player:getBodyYaw()

  -- Hungry sounds (occur more frequently the bigger the weight)
  if (prevFood <= (6 + weightVariant_.level) and not (player:getGamemode() == "CREATIVE")) then
    hungrySoundTimer = hungrySoundTimer - 1
    if (hungrySoundTimer <= 0) then
      hungrySoundTimer = math.random(150, 300)
      playHungrySound()
    end
  else
     hungrySoundTimer = 0
  end
end

function playGurgleSound()
  if (macro) then
    sounds:playSound("sounds.gurgle_" .. math.random(0, 1), player:getPos(), 0.5, 0.5 - math.random() * 0.1, false):setAttenuation((4 + weightVariant_.level) * attenuationModifier)

    if (cameraShakeDuration <= 4 or cameraShakeIntensity <= 0.05) then
      shakeCamera(320, 0.01)
    end
  else
    sounds:playSound("sounds.gurgle_" .. math.random(0, 1), player:getPos(), 0.5, 1 - math.random() * 0.2, false):setAttenuation((4 + weightVariant_.level) * attenuationModifier)

    if (weight_ >= 0.9) then
      shakeCamera(160, weight_ * 0.06)
    end
  end
end

function playSloshSound()
    if (macro) then
        sounds:playSound("entity.zombie.break_wooden_door", player:getPos(), 0.15, 0.05, false):setAttenuation(8 * attenuationModifier)
    end
    sounds:playSound("slosh_" .. math.random(0, 1), player:getPos(), (0.1 + weight_ * 0.4), (1.0 - weight_ * 0.5) - math.random() * 0.15, false):setAttenuation((4 + weightVariant_.level) * attenuationModifier)

    if (weight_ >= 0.9) then
        shakeCamera(80, weight_ * 0.1)
    end
end

function playHungrySound()
    sounds:playSound("sounds.hungry_" .. math.random(0, 0), player:getPos(), 0.65, 1 - math.random() * 0.25, false)
end

function playBurpSound()
    if (macro) then
        sounds:playSound("sounds.burp_" .. math.random(0, 1), player:getPos(), 0.9, 0.5 - math.random() * 0.15, false):setAttenuation(8 * attenuationModifier)
    else
        sounds:playSound("sounds.burp_" .. math.random(0, 1), player:getPos(), 0.7, (1 - weight_ * 0.25) - math.random() * 0.15, false):setAttenuation((6 + weightVariant_.level * 2) * attenuationModifier)
    end

    if (weight_ >= 0.9) then
        shakeCamera(160, weight_ * 0.1)
    end
end


--==========================================================================================
--Pings
--==========================================================================================

function pings.SyncPing(amount, value)
  setWeight(amount)
  setMacro(value)
end

function pings.setWeight(amount)
  setWeight(amount)
end

function pings.setMacro(value)
  setMacro(value)
  sounds:playSound("minecraft:entity.squid.ambient", player:getPos(), 1.5, 0.85)
  :setAttenuation(6 * attenuationModifier)
  --sounds:playSound("entity.player.burp", player:getPos(), 1, 1, false)
  shakeCamera(0, 0)

  UpdateModelScales()

  log(value and "[Macro] On" or "[Macro] Off")
end

function pings.burp()
    playBurpSound()
end

function pings.ShakeCamera(duration, intensity)
  shakeCamera(duration, intensity)
end

function pings.ChangeWeight(val)
  setWeight(weight_ + 0.05 * val)
  if val > 0 then
    sounds:playSound("minecraft:entity.panda.eat", player:getPos(), 2, 1, false)
    :setAttenuation(6 * attenuationModifier)
  else
    sounds:playSound("minecraft:entity.boat.paddle_water", player:getPos(), 2, 1, false)
    :setAttenuation(6 * attenuationModifier)
  end

  log("Weight is now " .. weight_)
end

function pings.ResetWeight()
  setWeight(0)
  sounds:playSound("minecraft:entity.skeleton.ambient", player:getPos(), 2, 2, false)
  :setAttenuation(6 * attenuationModifier)
  shakeCamera(0, 0)
  log("Weight reset to 0")
end

function pings.MaxWeight()
  setWeight(1)
  sounds:playSound("entity.player.burp", player:getPos(), 0.75, 1, false)
  shakeCamera(0, 0)
  log("Weight set to 1")
end

function pings.PlayGurgleSound()
  playGurgleSound()
end

--==========================================================================================
--Main Functions
--==========================================================================================


function we_.Init()



  -- Initialize default eating values
  prevFood = player:getFood()
  prevSaturation = player:getSaturation()

  -- Initialize sound update values
  prevYaw = player:getBodyYaw()

  -- Initialize default weight
  setWeightVariant(weightVariants_[1])
end

function we_.tick() 
  syncPingTimer = syncPingTimer + 1
  if (syncPingTimer >= 80) then
      pings.SyncPing(weight_, macro)
      syncPingTimer = 0
  end


  -- Adjust tail position when crouching
  if (player:isCrouching()) then 
  --    models.model.Tail:setPos(0, 2, 3)
  --    models.model.TailW1:setPos(0, 0, 3)
  --    models.model.TailW3:setPos(0, 2, 6)
  ---    models.model.TailW4:setPos(0, 2, 6)
  else
  --    models.model.Tail:setPos(0, 0, 0)
  --     models.model.TailW1:setPos(0, 0, 0)
  --      models.model.TailW3:setPos(0, 0, 0)
  --   models.model.TailW4:setPos(0, 0, 0)
  end

  -- Gain weight through food consumption (I might modify some of this later to make absorption hearts a bit silly, no clue how we'll update the scripts yet tho. -Mitsi)
  if (player:getFood() > prevFood or player:getSaturation() > prevSaturation) then
    local amount = player:getFood() - prevFood + player:getSaturation() - prevSaturation -- Get number of points increased
    if (host:isHost()) then
       setWeight(weight_ + amount * weightPerHungerPoint) -- Weight gain speed per hunger notch
    end
    if (player:getFood() >= 20 and weightVariant_.level >= 1) then
      playBurpSound() -- Burp after topping off hunger
    end
  end
  prevFood = player:getFood()
  prevSaturation = player:getSaturation()

  -- Cancel the fall time and play a water splash if landing in water Mitsinote: I might switch "weightVariant" to just your weight value, just for funsies
  if (player:isInWater()) then
    if (timeNotGrounded > 10 and weightVariant_.level >= 3) then
      waterSlamEffects()
    end
    timeNotGrounded = 0
  end

  -- Play jump/ground slam effect if not grounded after a moment (Mitsi note: this one literally uses weight instead of stages...)
  if (not player:isOnGround()) then
     timeNotGrounded = timeNotGrounded + 1
  else
    if (timeNotGrounded > 20 and weight_ >= 0.65) then
      groundSlamEffects()
    elseif (timeNotGrounded > 9 and weight_ >= 0.65) then
       jumpEffects()
    end
    timeNotGrounded = 0
  end

  -- Use a timer to determine step sound times
  if (player:isOnGround()) then
      stepTime = stepTime + player:getVelocity():length()
  end
  if (stepTime >= 1.625) then
      stepTime = stepTime % 1.625
      if (weight_ >= 0.65) then
          stepEffects()
      end
  end

  -- Play bed creak sound
  if ((player:getPose() == "SLEEPING" and not wasSleeping) and weightVariant_.level >= 4) then
    sounds:playSound("block.stem.place", player:getPos(), 1, 0.3, false)
    sounds:playSound("block.stem.fall", player:getPos(), 1, 0.2, false)
  end
  wasSleeping = player:getPose() == "SLEEPING"

  updateSounds()

  receiverUpdate()
end


function we_.render(delta, context)
  -- Reduce arm movement strength while fat. Makes the arms feel weightier
  local rot = vanilla_model.LEFT_ARM:getOriginRot()
  --   models.model.LeftArmW3:setOffsetRot(-rot * 0.25) -------------------------------- MODIFY HERE TO REDUCE THE MAGNITUDE OF ARM SWING MOVEMENT WHILE FAT (same part rules apply)  --------------------------------
  --   models.model.LeftArmW4:setOffsetRot(-rot * 0.5)

  rot = vanilla_model.RIGHT_ARM:getOriginRot()
  --  models.model.RightArmW3:setOffsetRot(-rot * 0.25)
  -- models.model.RightArmW4:setOffsetRot(-rot * 0.5)

  -- Reduce leg movement strength while fat. Makes the legs clip less and feel weightier
  rot = vanilla_model.LEFT_LEG:getOriginRot() -------------------------------- MODIFY HERE TO REDUCE THE MAGNITUDE OF LEG SWING MOVEMENT WHILE FAT (same part rules apply) --------------------------------
  --models.model.LeftLeg:setOffsetRot(-rot * 0.4) 
  --  models.model.LeftLegW1:setOffsetRot(-rot * 0.4)
  -- models.model.LeftLegW2:setOffsetRot(-rot * 0.7)
  --  models.model.LeftLegW3:setOffsetRot(-rot * 0.9)
  --  models.model.LeftLegW4:setOffsetRot(-rot * 0.9)

  rot = vanilla_model.RIGHT_LEG:getOriginRot()
  --models.model.RightLeg:setOffsetRot(-rot * 0.4)
  --  models.model.RightLegW1:setOffsetRot(-rot * 0.4)
  --  models.model.RightLegW2:setOffsetRot(-rot * 0.7)
  --  models.model.RightLegW3:setOffsetRot(-rot * 0.9)
  --   models.model.RightLegW4:setOffsetRot(-rot * 0.9)

  -- Shake the camera (Mitsi note: I'll look into this later)
  if (cameraShakeDuration > 0) then
    cameraShakeDuration = cameraShakeDuration - delta
    if (cameraShakeDuration < 0) then
        cameraShakeDuration = 0
    end
    local percent = cameraShakeDuration / cameraShakeMaxDuration
    renderer:setOffsetCameraPivot(math.random() * cameraShakeIntensity * percent, math.random() * cameraShakeIntensity * percent, math.random() * cameraShakeIntensity * percent)
  else
    renderer:setOffsetCameraPivot(0, 0, 0) -- Reset the camera when not shaking any more
  end

  -- Zoom camera out at larger sizes
  if (not renderer:isFirstPerson()) then
    renderer:setCameraPos(0, 0, (lizard_:getScale().y - 1) * 2.5)
  else
    renderer:setCameraPos(0, 0, 0)
  end

  -- Render inventory GUI model smaller to fit
  if (context == "MINECRAFT_GUI") then
    preGUIScale = lizard_:getScale()
    if (weightVariant_.level == 3) then
      lizard_:setScale(0.75 * 4)
    elseif (weightVariant_.level == 4) then
      lizard_:setScale(0.5 * 4)
    end
  end
end

function we_.post_render(delta, context)
  -- Reset model size after GUI scaling
  if (context == "MINECRAFT_GUI") then
    lizard_:setScale(preGUIScale)
  end
end


return we_