--Removes the warning from sound attenuationtion
---@diagnostic disable: undefined-field
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
local modelConfig_ = require("scripts.config")
local lizard_ = modelConfig_.lizard
local lizardFullbody_ = modelConfig_.lizardFullbody
local lizardBody_ = modelConfig_.lizardBody
local lizardLegs_ = modelConfig_.lizardLegs
local lizardTail_ = modelConfig_.lizardTail
local lizardHead_ = modelConfig_.lizardHead

-- Helpers
local h_ = require("scripts.api.helper")

--Weight Vars
--------------
local syncPingTimer_ = 0   -- Used to sync the weight variables with players that joined a server and haven't gotten pinged yet

-- Weight variables
local weight_ = 0          -- Weight is stored as a float from 0 to 1. 0 is minimum weight, while 1 is maximum
local maxWeight_ = 1100
local weightVariant_ = {level = 0, minWeight = 0, heightScale = 1.0}  -- Determines which set of manually-designed fat parts get toggled
local macro_ = false       -- Fun feature
local preGUIScale_ = nil
local preGUIRotation_ = nil
local weightLossRatio_ = 0.5 -- How much weight is lost in relation to weight gained

-- Eating variables
local prevFood_ = 0
local prevSaturation_ = 0

local weightPerHungerPoint_ = 1 -- Modify this if you want to increase/decrease the amount gained by eating

-- Effect variables
local weightEffect_ = 0
local cameraShakeDuration_ = 0
local cameraShakeMaxDuration_ = 0
local cameraShakeIntensity_ = 0
local cameraShakeUpdateTicker_ = 0 -- Used by receivers to detect updates to screen shake

local cameraShakeReceiverTable_ = {}

local timeNotGrounded_ = 0 -- Used to shake grouond after certain number of ticks
local stepTime_ = 0
local wasSleeping_ = false

-- Mitsi note: I haven't messed with sounds yet, although I'm 100% sure Soft will want to have everyone hear their gurgly gut :RivOwO:
-- Sound variables
local gurgleSoundTimer_ = 0
local sloshSoundTimer_ = 0
local prevYaw_ = 0
local hungrySoundTimer_ = 0
local attenuationModifier_ = 1 -- Modifies distance from which all sounds can be heard

--The different weights and how much food needs to be eaten for each
local weightVariants_ = 
{
  {level = 0, minWeight = 0, heightScale = 1.1},
  {level = 1, minWeight = 70, heightScale = 1.2},
  {level = 2, minWeight = 140, heightScale = 1.3},
  {level = 3, minWeight = 210, heightScale = 1.4},
  {level = 4, minWeight = 280, heightScale = 1.5},
  {level = 5, minWeight = 1000, heightScale = 1}
}

--Rotund
---------------------------------------------------------------------------
local pehkui_ = require('scripts.api.Pehkui')

-- ((CONFIGURE)) --
local crouchSqzEnabled_ = true --SET THIS TO "false" IF YOU DON'T WANT THE CROUCH-SQUEEZING FEATURE
local baseHeight_ = 1 --THIS IS FOR SLUGCAT HEIGHT. SET TO "1" FOR DEFAULT PLAYER HITBOX HEIGHT
local squeezeLoop_ = sounds["sounds.squeezesLOOP1"]:loop(true) --THIS IS THE SQUEEZE SFX FILE NAME. YOU CAN REPLACE IT WITH YOUR OWN .OGG FILE IF YOU WANT. IF IT'S TOO BIG YOU MIGHT NEED TO COMPRESS IT


-- ((OK DON'T CONFIGURE THE REST OF THESE))
local myWidthMult_ = 1
local jumpMod_ = 1 --THIS ONES EITHER 1 OR 0 DEPENDING ON IF STUCK 
local lastJumpMod_ = 1
local moveMod_ = 1 --SAME, 0 OR 1 (why didn't I just make these booleans)
local lastMoveMod_ = 1
local squeezeVal_ --DISTANCE BETWEEN OUR HIPS AND THE WALLS. SMALLER NUM MEANS TIGHTER SQUEEZE. 
local isNarrowSqueezed_ = false
local lastSqueezed_ = false
local lastWeightStage_ = -1 --TO FORCE A WEIGHT CHANGE ON LOAD
local struggleFlag_ = false --DELAYED START TO STRUGGLE WHILE STUCK
local struggleTimer_ = 0 --HOW MANY FRAMES TO STRUGGLE
local myFoodPoints_ = 0
local lateUpdateFlag_ = false
local crouchSqzTick_ = 0
local crouchSqz_ = false
local lastCrouchSqz_ = false
local lastInWater_ = false
local mainWidth_ = 0.6 --TRACK HITBOX WIDTH EXCLUDING CROUCHSEQUEEZE
local lastBoundingX_ = 0.6
local featherFall_ = true

local playSqueezeSfx_ = false
local lastPlaySqueezeSfx_ = false

--KEYBINDS
local struggleKey_ = keybinds:newKeybind("Struggle", keybinds:getVanillaKey("key.jump"))

--==========================================================================================
-- Retriever Functions
--==========================================================================================

--Gets the screen shake sent from others to be applied to player but gradually reduces it the further from the source it is
local function ReceiverUpdateTick()
  local selfUUUID = avatar:getUUID()

  -- First, iterate through every player in the world, stored in the variable v
  for k, v in pairs(world:getPlayers()) do
    local playerUUID = v:getUUID()

    -- Do not grab own camera shake info
    if (not (playerUUID == selfUUUID)) then
      -- Get camera shake information from the avatar's stored variables
      local shakeDuration = v:getVariable("cameraShakeDuration")
      local shakeMaxDuration = v:getVariable("cameraShakeMaxDuration")
      local shakeIntensity = v:getVariable("cameraShakeIntensity")

      --[[
      The shake intensity or shake duration is not updated every frame. Therefore,
      a separate variable is needed to detect when a change to the camera shake state has occured.
      This value is compared with the value stored in the cameraShakeReceiverTable_ using the player's UUID.
      If the values don't match, that means a new camera shake occured.
      Then, after that is checked, it updates the table to contain the new value
      --]]
      local shakeUpdateTicker = v:getVariable("cameraShakeUpdateTicker")

      -- Make sure that the camera shake information was actually found. If not, the user is not wearing a WG avatar
      if (not (shakeDuration == nil or shakeMaxDuration == nil or shakeIntensity == nil or shakeUpdateTicker == nil)) then
        -- If the viewer is too far away, don't shake
        local distance = (player:getPos() - v:getPos()):length()
        local maxRange = shakeIntensity * 1200
        if (distance <= maxRange) then

          -- If there has been an update (meaning a new screen shake was sent)
          if (not (cameraShakeReceiverTable_[v:getUUID()] == nil or shakeUpdateTicker == cameraShakeReceiverTable_[v:getUUID()])) then
            cameraShakeDuration_ = shakeDuration
            cameraShakeMaxDuration_ = shakeMaxDuration

            --scale the intensity based on distance
            local normalizedDistance = math.clamp(distance / maxRange, 0, 1)
            local exponent = 1.5 -- Tweak this value to change the curve's sharpness
            local curve = 1 - math.pow(normalizedDistance, exponent)
            cameraShakeIntensity_ = shakeIntensity * curve
          end
        end

        cameraShakeReceiverTable_[v:getUUID()] = shakeUpdateTicker
      end
    end
  end
end



--==========================================================================================
--Getters Functions
--==========================================================================================

--Get the largest weight varient that the weight falls in
local function GetWeightVariantFromWeight(weight)
  for i = #weightVariants_, 1, -1 do
    if weight >= weightVariants_[i].minWeight then
      return weightVariants_[i]
    end
  end
  return weightVariants_[1]
end

--Whether the player is moving at all
local function isKindaMoving()
	return player:getVelocity():length() >= 0.005  --player:isMoving()
end

--Grants movement brefly if stuck
local function struggleCheck()
	if isNarrowSqueezed_ then
		if isKindaMoving() == false then 
			struggleTimer_ = 3 --MODIFY THIS VALUE TO DETERMINE HOW LONG YOUR STRUGGLE BOOSTS LAST
			moveMod_ = 1
			struggleFlag_ = true --WE NEED TO DELAY THIS A TICK OTHERWISE WE'LL JUMP
			pehkui_.setScale("pehkui:jump_height", 0.01,false)
		end
	end
end

--CHECK IF A PHYSICAL BLOCK COLLISION EXISTS AT A SPECIFIC COORDINATE
local function checkColRaycast(x, y, z)
	
	local startPos = player:getPos()
	local endPos = startPos + vec(x, y, z)
    local hit, rayendpos, side = raycast:block(startPos, endPos)
	
	return rayendpos
end


--DETECT IF THERE ARE BLOCKS AT BOTH SIDES OF EITHER AXIS
local function updateNarrowSqueezed()
	
	--WAIT WHAT IF I MEASURED THE DISTANCE INSTEAD......
	local distCheck = 2 + mainWidth_ --KIND OF ARBITRARY BUT LONG ENOUGH TO NOT BE AN ISSUE AND SHORT ENOUGH TO REDUCE COST
	local yCheck = player:getEyeHeight() * 0.5 --PROBABLY A GOOD INDICATOR OF WHERE THEIR HIPS ARE
	
	local xPass = (checkColRaycast(distCheck, yCheck, 0).x - checkColRaycast(-distCheck, yCheck, 0).x) - mainWidth_
	local zPass = (checkColRaycast(0, yCheck, distCheck).z - checkColRaycast(0, yCheck, -distCheck).z) - mainWidth_
	local yPass = 2
	
	--BONUS CHECK IF WE'RE CRAWLING, CHECK FOR ROOM ABOVE US
	if player:getPose() == "SWIMMING" then
		distCheck = player:getBoundingBox().y + 2
		yPass = checkColRaycast(0, distCheck, 0).y - checkColRaycast(0, -distCheck, 0).y - player:getBoundingBox().y
	end
	
	squeezeVal_ = math.min(xPass, zPass, yPass) --TAKE WHICHEVER IS LOWER
	-- print ("GAP " .. squeezeVal_)
	
	return (squeezeVal_ < 0.2)
end

--DETECT IF THERE'S A BLOCK DIRECTLY ABOVE OUR HEAD.
local function canUncrouch()
	local distCheck = 0.65 * myWidthMult_
	return world.getBlockState(player:getPos():add(distCheck, 1.1, distCheck)):isSolidBlock() == false
		and world.getBlockState(player:getPos():add(-distCheck, 1.1, distCheck)):isSolidBlock() == false
		and world.getBlockState(player:getPos():add(distCheck, 1.1, -distCheck)):isSolidBlock() == false
		and world.getBlockState(player:getPos():add(-distCheck, 1.1, -distCheck)):isSolidBlock() == false
		and squeezeVal_ > 0
end


--==========================================================================================
--Setter Functions
--==========================================================================================

--Additional Scaling of the player model based on weight
local function UpdateModelScales()
  local finalScale = 1

  --Scale model based on the scales from all the previous weight variants
  for _, variant in ipairs(weightVariants_) do
    if variant.level < weightVariant_.level then
      finalScale = finalScale * variant.heightScale
    else
      break
    end
  end

  --Last limit is always maxWeight_ 
  local nextLimit = maxWeight_
  if weightVariant_.level + 1 ~= #weightVariants_ then
    nextLimit = weightVariants_[weightVariant_.level + 2].minWeight
  end

  --Scale player's current progression towards the next limit
  local scaleAmount = h_.InverseLerp(weightVariant_.minWeight, nextLimit, weight_)
  scaleAmount = math.lerp(1, weightVariant_.heightScale, scaleAmount)
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

  if (macro_) then
    finalScale = finalScale * 2
  end

  local reducedScale = math.min(1, 1 / (finalScale * 0.75) )

  pings.SetAdditionalScale(finalScale)
  
  -- De-scale the head and hands (since the head shouldn't grow larger. Only fatter)
  lizardHead_:setScale(reducedScale)

  --adjust head if need be
  if (macro_) then
      lizardHead_:setPos(0, (finalScale - 1) * 0.06, 0)
  else
     lizardHead_:setPos(0, (finalScale - 1) * 0.1, 0)
  end
end

-- Sets the weight variant and Toggles model parts for manually created stages of model weight gain
local function setWeightVariant(variant)
  --Change nothing if same variant or variant is nil
  if (weightVariant_ == variant) or variant == nil then
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

-- Sets the weight. Lowest is 0, highest is maxWeight_
local function setWeight(amount)
  weight_ = amount
  weight_ = math.clamp(weight_,0,maxWeight_)
  weightEffect_ =  h_.InverseLerp(0, maxWeight_, weight_)
end

--Sets the weight, handles the weight variant, updates scale, and update weight stats
local function setWeightExtended(amount, squeezed,mm,jm,crouchsqz,wet)
  setWeight(amount)

  local newWR = GetWeightVariantFromWeight(weight_)
  setWeightVariant(newWR)
  UpdateModelScales()

  
	updateWeightStats(newWR.level, squeezed, mm, jm, crouchsqz, wet)

	isNarrowSqueezed_ = squeezed --UPDATE FOR OTHER CLIENTS (I don't think it worked)
end


--Enables Macro
local function setMacro(value)
  if (macro_ == value) then
    return
  end
  macro_ = value

  if (macro_) then
    attenuationModifier_ = 16
    gurgleSoundTimer_ = 0
  else
    attenuationModifier_ = 1
  end
end

--Resets food and weight to spawn default
local function ResetFood()
	prevFood_ = 20
	prevSaturation_ = 5
	weight_ = 0
end



--==========================================================================================
--Effects Functions
--==========================================================================================

--Sets how much camera shake there should be
local function shakeCamera(duration, intensity)
  if (macro_) then
    cameraShakeDuration_ = duration * 6
    cameraShakeMaxDuration_ = duration * 6
    cameraShakeIntensity_ = intensity * 8
  else
    cameraShakeDuration_ = duration
    cameraShakeMaxDuration_ = duration
    cameraShakeIntensity_ = intensity
  end

  cameraShakeUpdateTicker_ = cameraShakeUpdateTicker_ + 1

  -- Store so receivers can have their screen shaken
  avatar:store("cameraShakeDuration", cameraShakeDuration_)
  avatar:store("cameraShakeMaxDuration", cameraShakeMaxDuration_)
  avatar:store("cameraShakeIntensity", cameraShakeIntensity_)
  avatar:store("cameraShakeUpdateTicker", cameraShakeUpdateTicker_)
end

-- Sound for stepping while extremely large
local function stepEffects()
  sounds:playSound("block.stone.hit", player:getPos(), 0.5, 0.3 - math.random() * 0.1, false)
  :setAttenuation(4 * attenuationModifier_)
  if (macro_) then
    sound = sounds:playSound("entity.zombie.attack_wooden_door", player:getPos(), 0.1, 0.3, false)
    sound:setAttenuation(6 * attenuationModifier_)
  end
  
  if (cameraShakeDuration_ <= 4 or cameraShakeIntensity_ <= 0.05) then
    shakeCamera(16, 0.05)
  end
end

-- Sound for landing after a jump while extremely large
local function jumpEffects()
  sounds:playSound("entity.generic.small_fall", player:getPos(), 0.4, 0.15, false)
  :setAttenuation(4 * attenuationModifier_)
  if (weight_ >= 500) then
    sounds:playSound("entity.zombie.attack_wooden_door", player:getPos(), 0.15, 0.4, false)
    :setAttenuation(4 * attenuationModifier_)
  end
  if (macro_) then
    sounds:playSound("entity.zombie.break_wooden_door", player:getPos(), 0.15, 0.15, false)
    :setAttenuation(8 * attenuationModifier_)
  end

  shakeCamera(16, weightEffect_ * 0.3)
end

-- Ground slam for landing while extremely large
local function groundSlamEffects()
  sounds:playSound("entity.generic.small_fall", player:getPos(), 1, 0.15, false)
  :setAttenuation(6 * attenuationModifier_)
  if (weight_ >= 500) then
    sounds:playSound("entity.zombie.break_wooden_door", player:getPos(), 0.5, 0.3, false)
    :setAttenuation(8 * attenuationModifier_)
    sounds:playSound("entity.generic.explode", player:getPos(), 0.4, 0.35, false)
    :setAttenuation(8 * attenuationModifier_)
  else
    sounds:playSound("entity.zombie.break_wooden_door", player:getPos(), 0.25, 0.5, false):setAttenuation(6 * attenuationModifier_)
  end
  if (macro_) then
    sounds:playSound("entity.zombie.break_wooden_door", player:getPos(), 0.25, 0.05, false):setAttenuation(8 * attenuationModifier_)
  end

  

  -- Create ground particles
  for i=0,255 do
    local pos = player:getPos()
    pos = vec(pos.x + (math.random() - 0.5) * weightEffect_ * 12 , pos.y + 0.25, pos.z + (math.random() - 0.5) * weightEffect_ * 12 )
    particles:newParticle("minecraft:block minecraft:stone", pos, vec(0, 1, 0))
  end

  shakeCamera(35 + weightEffect_ * 40 , weightEffect_ * 0.6 )
end

-- Splash effects for landing in water while extremely large
local function waterSlamEffects()
  if (weight_ >= 500) then
    sounds:playSound("entity.player.splash.high_speed", player:getPos(), 0.5, 0.4, false)
    :setAttenuation(8 * attenuationModifier_)
    sounds:playSound("entity.generic.explode", player:getPos(), 0.4, 0.35, false)
    :setAttenuation(8 * attenuationModifier_)
  else
    sounds:playSound("entity.player.splash.high_speed", player:getPos(), 0.5, 0.75, false)
    :setAttenuation(6 * attenuationModifier_)
  end

  -- Create water particles
  local pos
  for i=0,127 do
    pos = player:getPos()
    pos = vec(pos.x + (math.random() - 0.5) * weightEffect_ * 12 , pos.y + 0.25, pos.z + (math.random() - 0.5) * weightEffect_ * 12 )
    if (math.random(0, 1) <= 0) then
      particles:newParticle("minecraft:block minecraft:water", pos, vec(0, 1, 0))
    else
      particles:newParticle("cloud", pos, vec(0, 0, 0))
    end
  end

  shakeCamera(35 + weightEffect_ * 40 , weightEffect_ * 0.6 )
end


--==========================================================================================
--Sound Functions
--==========================================================================================


--Plays altered Vanilla Sound
local function playGurgleSound()
 
 --local sound = "sounds.gurgle_" .. math.random(0, 1)
  local sound = "minecraft:entity.drowned.ambient"
  
  local pitch = 0.5 - weightEffect_ * 0.2  - math.random() * 0.2

  if macro_ then
    pitch = 0.5 - math.random() * 0.1
    if (cameraShakeDuration_ <= 4 or cameraShakeIntensity_ <= 0.05) then
      shakeCamera(320, 0.01)
    end
  elseif (weight_ >= 0.9) then
    shakeCamera(160, weightEffect_ * 0.06)
  end

  sounds:playSound(sound, player:getPos(), 0.5, pitch, false)
    :setAttenuation((8 + weightVariant_.level) * attenuationModifier_)
end

--Plays altered Vanilla Sound
local function playSloshSound()

  if (macro_) then
    sounds:playSound("entity.zombie.break_wooden_door", player:getPos(), 0.15, 0.05, false)
    :setAttenuation(8 * attenuationModifier_)
  end
  local sound = "minecraft:entity.dolphin.swim" --"minecraft:entity.squid.ambient"
  sounds:playSound(sound, player:getPos(), (1), (0.6 - weightEffect_ * 0.2 ) - math.random() * 0.15, false)
  :setAttenuation((1 + weightVariant_.level) * attenuationModifier_)

  if (weight_ >= 500) then
    shakeCamera(80, weightEffect_ * 0.1 )
  end
end

--Plays altered Vanilla Sound
local function playHungrySound()
  
  local sound = "minecraft:entity.ravager.stunned"

  sounds:playSound(sound, player:getPos(), 0.65, 1 - math.random() * 0.25, false)
  :setAttenuation((16 + weightVariant_.level) * attenuationModifier_)
end

--Plays NOTHING
local function playBurpSound()
  if (macro_) then
      sounds:playSound("sounds.burp_" .. math.random(0, 1), player:getPos(), 0.9, 0.5 - math.random() * 0.15, false)
      :setAttenuation(8 * attenuationModifier_)
  else
      sounds:playSound("sounds.burp_" .. math.random(0, 1), player:getPos(), 0.7, (1 - weightEffect_ * 0.25) - math.random() * 0.15, false)
      :setAttenuation((6 + weightVariant_.level * 2) * attenuationModifier_)
  end

  if (weight_ >= 500) then
      shakeCamera(160, weightEffect_ * 0.1 )
  end
end


--==========================================================================================
--Pings
--==========================================================================================

--Syncs variables for all players
function pings.SyncPing(amount, value)
  setWeightExtended(amount,isNarrowSqueezed_, moveMod_, jumpMod_, crouchSqz_, player:isInWater())
  setMacro(value)
end

function pings.setWeight(amount)
  setWeight(amount)
end

function pings.setMacro(value)
  setMacro(value)
  sounds:playSound("minecraft:entity.squid.ambient", player:getPos(), 1.5, 0.85)
  :setAttenuation(6 * attenuationModifier_)
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
  setWeight(weight_ + 5 * val)
  if val > 0 then
    sounds:playSound("minecraft:entity.panda.eat", player:getPos(), 2, 1, false)
    :setAttenuation(6 * attenuationModifier_)
  else
    sounds:playSound("minecraft:entity.boat.paddle_water", player:getPos(), 2, 1, false)
    :setAttenuation(6 * attenuationModifier_)
  end

  log("Weight is now " .. weight_)
end

function pings.ResetWeight()
  setWeight(0)
  sounds:playSound("minecraft:entity.skeleton.ambient", player:getPos(), 2, 2, false)
  :setAttenuation(6 * attenuationModifier_)
  shakeCamera(0, 0)
  log("Weight reset to 0")
end

function pings.MaxWeight()
  setWeight(maxWeight_)
  sounds:playSound("entity.player.burp", player:getPos(), 0.75, 1, false)
  shakeCamera(0, 0)
  log("Weight set to 1")
end

function pings.PlayGurgleSound()
  playGurgleSound()
  print("Played gurgle sound")
end

function pings.PlaySloshSound()
  playSloshSound()
  print("Played slosh sound")
end

function pings.PlayHungrySound()
  playHungrySound()
  print("Played hungry sound")
end

function pings.squeezeSfxPing(command)
	playSqueezeSfx_ = command
end

function pings.setWeightExtended(amount, squeezed,mm,jm,crouchsqz,wet)
  setWeightExtended(amount, squeezed,mm,jm,crouchsqz,wet)
end

--==========================================================================================
--Tick Functions
--==========================================================================================
--Determines how weight is gained or lost by food and saturation
local function UpdateFoodAndWeightTick()
  -- Gain weight through food consumption
  if (player:getFood() > prevFood_ or player:getSaturation() > prevSaturation_) then
    local amount = player:getFood() - prevFood_ + player:getSaturation() - prevSaturation_ -- Get number of points increased
    setWeight(weight_ + amount * weightPerHungerPoint_) -- Weight gain speed per hunger notch
  --MODIFIED TO ACCOUNT FOR WEIGHT LOSS TOO
  elseif ((player:getFood() < prevFood_ and player:getFood() < 20) or (player:getSaturation() < prevSaturation_ and player:getSaturation() < 20)) then 
    local amount = player:getFood() - prevFood_ + player:getSaturation() - prevSaturation_ -- Get number of points decreased
    setWeight(weight_ + amount * weightPerHungerPoint_ * weightLossRatio_) -- Weight loss speed per hunger notch
  end
  prevFood_ = player:getFood()
  prevSaturation_ = player:getSaturation()
end

--Manages the timers and stuff for effects
local function UpdateEffectsTick()
  
  -- Cancel the fall time and play a water splash if landing in water Mitsinote: I might switch "weightVariant" to just your weight value, just for funsies
  if (player:isInWater()) then
    if (timeNotGrounded_ > 10 and weightVariant_.level >= 3) then
      waterSlamEffects()
    end
    timeNotGrounded_ = 0
  end

  -- Play jump/ground slam effect if not grounded after a moment (Mitsi note: this one literally uses weight instead of stages...)
  if (not player:isOnGround()) then
     timeNotGrounded_ = timeNotGrounded_ + 1
  else
    if (timeNotGrounded_ > 20 and weightEffect_ >= 0.65) then
      groundSlamEffects()
    elseif (timeNotGrounded_ > 9 and weightEffect_ >= 0.65) then
       jumpEffects()
    end
    timeNotGrounded_ = 0
  end

  -- Use a timer to determine step sound times
  if (player:isOnGround()) then
      stepTime_ = stepTime_ + player:getVelocity():length()
  end
  if (stepTime_ >= 1.625) then
      stepTime_ = stepTime_ % 1.625
      if (weightEffect_ >= 0.65) then
          stepEffects()
      end
  end

  -- Play bed creak sound
  if ((player:getPose() == "SLEEPING" and not wasSleeping_) and weightVariant_.level >= 4) then
    sounds:playSound("block.stem.place", player:getPos(), 1, 0.3, false)
    sounds:playSound("block.stem.fall", player:getPos(), 1, 0.2, false)
  end
  wasSleeping_ = player:getPose() == "SLEEPING"
end

-- Plays sound effects where appropriate
local function UpdateSoundsTick()
  -- Gurgle sounds
  if (weightVariant_.level >= 3) then
    gurgleSoundTimer_ = gurgleSoundTimer_ - 1
    if (gurgleSoundTimer_ <= 0) then
      gurgleSoundTimer_ = math.random(1000, 1200) - (weightVariant_.level / #weightVariants_) * 600
      if (macro_) then
        gurgleSoundTimer_ = 160
      end
      playGurgleSound()
    end
  end

  -- Slosh sounds
  local minYaw = 10
  if (macro_) then
    minYaw = 12
  end
  if (weightVariant_.level >= 2) then
    sloshSoundTimer_ = sloshSoundTimer_ - 1
    if (sloshSoundTimer_ <= 0 and math.abs(player:getBodyYaw() - prevYaw_) > minYaw) then
      sloshSoundTimer_ = 100 - math.lerp(20, 80, weightEffect_)
      playSloshSound()
    end
  end
  prevYaw_ = player:getBodyYaw()

  -- Hungry sounds (occur more frequently the bigger the weight)
  if (prevFood_ <= (6 + weightVariant_.level) and not (player:getGamemode() == "CREATIVE")) then
    hungrySoundTimer_ = hungrySoundTimer_ - 1
    if (hungrySoundTimer_ <= 0) then
      hungrySoundTimer_ = math.random(150, 300)
      playHungrySound()
    end
  else
    hungrySoundTimer_ = 0
  end
end

local function RotundHostTick()
  -- KEEP TRACK OF OUR MODEL'S CANON WIDTH. THE SIZING PROCESS TWEENS SO WE HAVE TO CHECK THIS EVERY TICK :/
  if crouchSqz_ == false and player:getBoundingBox().x == lastBoundingX_ then --DON'T RUN IF THE VALUE IS CHANGING. WAIT UNTIL THE TWEEN IS DONE
    mainWidth_ = player:getBoundingBox().x
  elseif crouchSqz_ == true then
    lastBoundingX_ = mainWidth_
  else
    lastBoundingX_ = player:getBoundingBox().x
  end
  
  
  if lastSqueezed_ ~= isNarrowSqueezed_ then
    lateUpdateFlag_ = true --OKAY THIS WAS GONNA BOTHER ME. AVOID RUNNING THE UPDATE 2 TICKS IN A ROW WHEN CHANGING SQUEEZE STATES
  end
  
  if lastWeightStage_ ~= weightVariant_.level or lastJumpMod_ ~= jumpMod_ or lastMoveMod_ ~= moveMod_ or lastCrouchSqz_ ~= crouchSqz_ or lastInWater_ ~= player:isInWater() then
    setWeightExtended(weight_,isNarrowSqueezed_, moveMod_, jumpMod_, crouchSqz_, player:isInWater())
  end
  
  
  if isNarrowSqueezed_ then
    
    --ONLY PLAY THE SQUEEZE SOUND WHILE MOVING
    if isKindaMoving() then
      playSqueezeSfx_ = true
    else
      playSqueezeSfx_ = false
    end
    
    --IF ONLY LIGHTLY SQUEEZED, WE DON'T COME TO A HALT
    if squeezeVal_ <= 0.14 and struggleTimer_ <= 0 then --STUCK. UNTIL THE TIMER RESETS WHEN WE AREN'T SQUEEZED
      moveMod_ = 0
      if isKindaMoving() == false and struggleTimer_ <= -10 then
        jumpMod_ = 0 --STOP JUMPING UNTIL WE SQUEEZE FREE
      end
    end
    
  else
    moveMod_ = 1
    jumpMod_ = 1
    playSqueezeSfx_ = false
  end
  
  
  --OKAY NOW RUN A SQUEEZE RELATED WEIGHT UPDATE, IF WE DIDN'T ALREADY
  if lateUpdateFlag_ then
    setWeightExtended(weight_,isNarrowSqueezed_, moveMod_, jumpMod_, crouchSqz_, player:isInWater())
  end
  
  
  if struggleFlag_ then
    if struggleFlag_ and player:getPose() ~= "SWIMMING" then
      jumpMod_ = 1
    end
    struggleFlag_ = false
  end
  
  --ONLY PING THE SQUEEZE SFX IF IT CHANGED
  if lastPlaySqueezeSfx_ ~= playSqueezeSfx_ then
    pings.squeezeSfxPing(playSqueezeSfx_)
    lastPlaySqueezeSfx_ = playSqueezeSfx_
  end
end

local function RotundAllTick()
    --OKAY FINE RUN IT EVERY TICK THEN. FUCK YOU
	if playSqueezeSfx_ then
		squeezeLoop_:play()
		squeezeLoop_:setPos(player:getPos())
		--ADJUST PITCH AND VOLUME BASED ON TIGHTNESS
		if squeezeVal_ <= 0.08 then
			squeezeLoop_:setVolume(1)
			squeezeLoop_:setPitch(0.7)
		elseif squeezeVal_ <= 0.14 then
			squeezeLoop_:setVolume(1)
			squeezeLoop_:setPitch(0.85)
		else
			squeezeLoop_:setVolume(0.6)
			squeezeLoop_:setPitch(1)
		end
	else
		squeezeLoop_:pause()
	end
	
	--I THINK WE CAN SAFELY REACH SPEED 0 IN THE AIR SINCE THERE'S NO FOOTSTEPS
	if moveMod_ == 0 and player:isMoving() and isKindaMoving() == false and player:getVelocity().y < 0 and (player:isOnGround() or player:isClimbing()) == false then 
		pehkui_.setScale("pehkui:motion", 0, false)
		pehkui_.setScale("pehkui:motion", 0, false)
	end
	
	if moveMod_ == 0 and not isKindaMoving() then
		-- pehkui.setScale("pehkui:view_bobbing", 0)
		-- pehkui.setScale("pehkui:view_bobbing", 0)
		-- print("vb")
		-- animations:stopAll()
		--WAIT WOULD THIS WORK...
		if host:isHost() then
			-- pehkui.setScale("pehkui:motion", 0)
			-- pehkui.setScale("pehkui:motion", 0)
		end
	else
		-- pehkui.setScale("pehkui:view_bobbing", 1)
	end
	
	--MODIFIED FROM THE WG_TEMPLATE. RECREATE OUR FOOTSTEPS BECAUSE WE DISABLED THE VANILLA ONES BECAUSE THEY BROKE
	-- Use a timer to determine step sound times
  if (player:isOnGround()) then
    stepTime_ = stepTime_ + player:getVelocity():length()
	elseif player:isClimbing() then
		stepTime_ = stepTime_ + player:getVelocity():length() * 1.5
  end
  if (stepTime_ >= 1.625) then
    stepTime_ = stepTime_ % 1.625
    -- PlayFootstep() --MAYBE LATER WE'LL BRING THIS BACK BUT RIGHT NOW OTHER PLAYERS CAN'T EVEN HEAR IT
  end
end


local function UpdateSqueezeGraphics(stage)
  --pehkui_.setScale("pehkui:model_width", 1, false) --A QUICK LAZY WAY TO CHANGE THE WIDTH OF YOUR WHOLE MODEL. WORKS ON ANY MODEL
	
	--EVERYTHING ELSE IS SLUGCAT SPECIFIC
	--SHOW THE > < EYES WHEN SQUEEZED 
	--models.models.slugcat.FullBody.UpperBody.head.Main.Eyes.Base:setVisible(lastSqueezed_ == false)
	--models.models.slugcat.FullBody.UpperBody.head.Main.Eyes.Squint:setVisible(lastSqueezed_) 
	--models.models.slugcat.FullBody.UpperBody.Body.Main.Gourmand:setVisible(true) --ASSUME THIS IS TRUE UNLESS TOLD OTHERWISE
	
	
	--if stage <= 1 then
	--	pehkui_.setScale("pehkui:model_width", 1.25, false)
	--end
end

function updateWeightStats(stage, squeezed, mm, jm, crouchSqz, wet) --OKAY WE NEED TO TAKE OUR SQUEEZED BOOL INTO ACCOUNT AND 'ONLY' RUN MOVEMENT SCALING IN HERE TO AVOID SPEED DESYNCS AND SERVER FALL DAMAGE
	-- print("UPDATE WS " .. tostring(stage))
	local mySpeedMult = 1
	
	--SOME NOTABLE WIDTH VALUES:
	--1.0  default
	--1.08 slightly squeezes in open doorways (slowed, but not stuck)
	--1.14 tight squeezes in open doorways (slowed and stuck)
	--1.28 barely fits through open doorways (slowed more and stuck quicker)
	--1.37 slightly squeezes in 1 block wide gaps (does not fit open doorways)
	--1.45 tight squeezes in 1 block wide gaps
	--1.60 barely fits through 1 block wide gaps
	--(THEN YOU WON'T GET STUCK IN MUCH UNTIL YOU'RE BIG ENOUGH TO GET STUCK IN 2 BLOCK GAPS)
	--2.40 slightly squeezes in open double-doorways
	--2.50 tight squeezes in open double-doorways
	--2.60 barely fits through open double-doorways
	--(ETC.. JUST KEEP INCREASING THE NUMBER)
	
	--WHEN CROUCH-SQUEEZING, TIGHTNESS IS CALCULATED USING YOUR UN-CROUCH-SQUEEZED WEIGHT. SO IF YOU HAVE TO CROUCH-SQUEEZE TO ENTER A GAP IT WILL ALWAYS BE VERY TIGHT
	
	
	-- ((CONFIGURE)) -- WEIGHT STAGES; MODIFY YOUR STATS BELOW TO DETERMINE WHAT YOU GET AT EACH WEIGHT STAGE
	if stage <= 0 then
		mySpeedMult = 1
		myWidthMult_ = (1)
	elseif stage == 1 then
		mySpeedMult = 0.9
		myWidthMult_ = ((crouchSqz and 1.0) or 1.14) --THE FIRST NUMBER IS FOR WHEN YOURE CROUCH-SQUEEZING. THE SECOND NUMBER IS FOR EVERYTHING ELSE
	elseif stage == 2 then
		mySpeedMult = 0.85
		myWidthMult_ = ((crouchSqz and 1.0) or 1.28)
	elseif stage == 3 then
		mySpeedMult = 0.8
		myWidthMult_ = ((crouchSqz and 1.1) or 1.45) 
	elseif stage == 4 then
		mySpeedMult = 0.75
		myWidthMult_ = ((crouchSqz and 1.28) or 1.60)
	elseif stage == 5 then
		mySpeedMult = 0.5
		myWidthMult_ = ((crouchSqz and 2) or 2.5)
	end
	--FEEL FREE TO ADD OR REMOVE WEIGHT STAGES HOWEVER YOU'D LIKE. DON'T FORGET TO MAKE THOSE SAME CHANGES TO THE "weightStage()" FUNCTION BELOW
	--THERE ARE OTHER STATS YOU MIGHT CONSIDER ADDING INTO WEIGHT STAGES TOO...
	-- pehkui_.setScale("pehkui:defense", 1)
	-- pehkui_.setScale("pehkui:knockback", 1)
	
	
	-- ((CONFIGURE)) -- GET SLIGHTLY SHORTER FOR CROUCHSQUEEZE
	pehkui_.setScale("pehkui:hitbox_height", (crouchSqz_ and 0.5) or baseHeight_, false)
	pehkui_.setScale("pehkui:eye_height", (crouchSqz_ and 0.5) or baseHeight_, false)
	--I MADE THESE THE SAME IN EACH WEIGHT STAGE BUT YOU COULD MOVE THESE INTO EACH WEIGHT STAGE TO CHANGE THEM
	
	--REDUCE SPEED VALUES WHEN SQUEEZED
	if squeezed then
		mySpeedMult = mySpeedMult * 0.4
	end
	
	--REDUCED FRICTION WHEN IN WATER.
	if wet and mm == 0 then
		mySpeedMult = mySpeedMult / 2
		mm = 1
	end
	
	--SQUEEZE TO A MORE SUDDEN HALT FOR TIGHTER SQUEEZES.
	if mm == 0 and isKindaMoving() then 
		if squeezeVal_ < 0.08 then --TIGHT SQUEEZE 
			pehkui_.setScale("pehkui:motion", 0.2, false)
			pehkui_.setScale("pehkui:motion", 0.2, false)--YES WE HAVE TO RUN THIS TWICE TO SKIP THE TWEEN
		else --MEDIUM SQUEEZE 
			pehkui_.setScale("pehkui:motion", 0.4, false)
			pehkui_.setScale("pehkui:motion", 0.4, false)
		end
		--LIGHT SQUEEZES WON'T RUN THIS
	end
	
	--THANKS TO A PEHKUI BUG, WE CAN'T EVER LET MOTION BE 0 OR WE COULD TRIGGER THE THOUSAND FOOTSTEPS BUG
	pehkui_.setScale("pehkui:motion", mySpeedMult * (((mm == 0) and 0.01) or mm), false)
	pehkui_.setScale("pehkui:hitbox_width", myWidthMult_, false)
	
	
	--WTF IS IT DOING TO OUR GRAVITY?? FIX THAT
	local speedlerp = (math.lerp(mySpeedMult, 1, 0.3))
	local myJumpMult = (1/speedlerp)
	pehkui_.setScale("pehkui:jump_height", myJumpMult * jm, false)
	pehkui_.setScale("pehkui:jump_height", myJumpMult * jm, false)
	pehkui_.setScale("pehkui:step_height", 1/mySpeedMult, false)
	pehkui_.setScale("pehkui:step_height", 1/mySpeedMult, false)
	pehkui_.setScale("pehkui:falling", (squeezed and 0) or mySpeedMult * mm, false) --DON'T BREAK OUR ANKLES WHEN SQUEEZING PLEASE
	
	UpdateSqueezeGraphics(stage)
	
	lastWeightStage_ = stage
	lastSqueezed_ = squeezed
	lastJumpMod_ = jm
	lastMoveMod_ = mm
	lateUpdateFlag_ = false
	lastInWater_ = wet
end


--==========================================================================================
--Render Functions
--==========================================================================================
--Reduces limb rotation based on weight variant
local function AlterLimbRotationRender(delta, context)
  -- Reduce arm movement strength while fat. Makes the arms feel weightier
  local rot = vanilla_model.LEFT_ARM:getOriginRot()
  -------------------------------- MODIFY HERE TO REDUCE THE MAGNITUDE OF ARM SWING MOVEMENT WHILE FAT (same part rules apply)  --------------------------------
  --   models.model.LeftArmW3:setOffsetRot(-rot * 0.25) 
  --   models.model.LeftArmW4:setOffsetRot(-rot * 0.5)

  rot = vanilla_model.RIGHT_ARM:getOriginRot()
  --  models.model.RightArmW3:setOffsetRot(-rot * 0.25)
  -- models.model.RightArmW4:setOffsetRot(-rot * 0.5)

  -- Reduce leg movement strength while fat. Makes the legs clip less and feel weightier
  rot = vanilla_model.LEFT_LEG:getOriginRot() 
  -------------------------------- MODIFY HERE TO REDUCE THE MAGNITUDE OF LEG SWING MOVEMENT WHILE FAT (same part rules apply) --------------------------------
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
end

--Actually shakes the camera for the player
local function ShakeCameraRender(delta, context)
  -- Shake the camera (Mitsi note: I'll look into this later)
  if (cameraShakeDuration_ > 0) then
    cameraShakeDuration_ = cameraShakeDuration_ - delta
    if (cameraShakeDuration_ < 0) then
        cameraShakeDuration_ = 0
    end
    local percent = cameraShakeDuration_ / cameraShakeMaxDuration_
    renderer:setOffsetCameraPivot(math.random() * cameraShakeIntensity_ * percent, math.random() * cameraShakeIntensity_ * percent, math.random() * cameraShakeIntensity_ * percent)
  else
    renderer:setOffsetCameraPivot(0, 0, 0) -- Reset the camera when not shaking any more
  end
end

--Adjusts the third person camera based on player scale
local function AdjustThirdPersonCameraRender(delta, context)
  -- Zoom camera out at larger sizes
  if (not renderer:isFirstPerson()) then
    renderer:setCameraPos(0, 0, (lizard_:getScale().y - 1) * 2.5)
  else
    renderer:setCameraPos(0, 0, 0)
  end
end

--Resizes model and rotation while in GUI
local function ResizeGUIRender(delta,context)
  -- Render inventory GUI model smaller to fit
  if (context == "MINECRAFT_GUI") then
    preGUIScale_ = lizard_:getScale()
    preGUIRotation_ = lizard_:getRot()

    lizard_:setRot(vec(0,0,0))

    if (weightVariant_.level > 0) then
      local newScale = 1 + weightVariant_.level / #weightVariants_
      lizard_:setScale(newScale)
    end
  end
end

-- Reset model size after GUI scaling
local function ReturnGUITONormalPostRender(delta, context)
  if (context == "MINECRAFT_GUI") then
    lizard_:setScale(preGUIScale_)
    lizard_:setRot(preGUIRotation_)
  end
end


--==========================================================================================
-- Keybinds
--==========================================================================================

function struggleKey_.press()
  struggleCheck()
end




--==========================================================================================
--Main Functions
--==========================================================================================



function we_.Init(scale)
  -- Initialize default eating values
  prevFood_ = 20
  prevSaturation_ = 5

  -- Initialize sound update values
  prevYaw_ = player:getBodyYaw()

  --Make sure the maximum weight is greater than the last weight variant tier
  local maxVar = weightVariants_[#weightVariants_]
  if maxVar and maxWeight_ < maxVar.minWeight then
    maxWeight_ = maxVar.minWeight + 100
  end

  -- Initialize default weight
  pings.setWeightExtended(0,isNarrowSqueezed_, moveMod_, jumpMod_, crouchSqz_, player:isInWater())
	
	-- SLUGCAT SPECIFIC THINGS
	pehkui_.setScale("pehkui:hitbox_height", scale, false)
	pehkui_.setScale("pehkui:eye_height", scale, false)
end

--Happens 20 times per second
function we_.Tick() 
  isNarrowSqueezed_ = updateNarrowSqueezed() --OKAY WE SHOULD ONLY BE RUNNING THIS ONCE A TICK NOW IT'S SO EXPENSIVE

  --OK FR, THIS ONLY NEEDS TO BE RUN BY THE HOST
	if host:isHost() then
    --RESET OUR FOOD AND WEIGHT LEVELS ON DEATH
		if player:isAlive() == false then
			--ResetFood()
			return 
		end --AND THEN SKIP EVERYTHING UNDER THIS

    if struggleTimer_ > -10 then --GIVE US A CHANCE TO JUMP AFTER STRUGGLING WHILE STANDING STILL
			struggleTimer_ = struggleTimer_ - 1
		end
		
		--ALLOW US TO SHRINK OUR HITBOX SLIGHTLY IF WE CROUCH LONG ENOUGH.
		lastCrouchSqz_ = crouchSqz_
		if player:getPose() == "CROUCHING" and crouchSqzEnabled_ then
			crouchSqzTick_ = crouchSqzTick_ + 1
			if crouchSqzTick_ >= 20 then
				crouchSqz_ = true
			end
		elseif crouchSqz_ and canUncrouch() then
			crouchSqz_ = false
			crouchSqzTick_ = 0
		end

    syncPingTimer_ = syncPingTimer_ + 1
    if (syncPingTimer_ >= 80 and isNarrowSqueezed_ == false) then
      pings.SyncPing(weight_, macro_)
      syncPingTimer_ = 0
    end

    UpdateFoodAndWeightTick()

    RotundHostTick()
  end

  -- THE REST OF THIS RUNS FOR ALL PLAYERS --
  RotundAllTick()
  
  UpdateEffectsTick()
  UpdateSoundsTick()
  ReceiverUpdateTick()
end


function we_.render(delta, context)
  AlterLimbRotationRender(delta, context)
  ShakeCameraRender(delta, context)
  AdjustThirdPersonCameraRender(delta, context)
  ResizeGUIRender(delta, context)
end

function we_.post_render(delta, context)
  ReturnGUITONormalPostRender(delta, context)
end


return we_