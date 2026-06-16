--==========================================================================================
-- THIS IS THE MAIN SCRIPT THAT RUNS THE MAIN FUNCTIONS OF THE MODEL
--==========================================================================================
--Version
local version_ = "1.0.4"
local size_ = 4

--Definitions
local modelName_ = "models.hypno"

--Config
local modelConfig_ = require("scripts.config")
local lizard_ = modelConfig_.lizard
local lizardFullbody_ = modelConfig_.lizardFullbody
local lizardBody_ = modelConfig_.lizardBody
local lizardLegs_ = modelConfig_.lizardLegs
local lizardTail_ = modelConfig_.lizardTail
local lizardHead_ = modelConfig_.lizardHead

-- API (Stuff that has no reason to ever be changed)
----
-- Animation Blending
--local gsAnim_ = require("scripts.api.GSAnimBlend")
-- Other Animation Blenindg
local anims_ = require("scripts.api.JimmyAnims")
-- Squapi
local squapi_ = require("scripts.api.SquAPI")
-- SwingingPhysics
local swingingPhysics_ = require("scripts.api.swinging_physics")
-- Jiggle physics initialization
local tailPhysics_ = require('scripts.api.tail')
-- Helpers
local h_ = require("scripts.api.helper")

-- Functionality
----
-- Chat (Specifically chat commands)
local chat_ = require('scripts.chat')
-- weight
local weight_ = require('scripts.weight')
-- wheel
local wheel_ = require('scripts.wheel')



-- Rest of Vars
----
-- Defines the default scale of the model (it's 4 because I modeled mine tiny </3)
local baseModelScale_ = 4
local playerScale_ = 4
local playerAdditionalScale_ = 1

-- More Defined Bodyparts
local rightFrontLeg_ = lizardLegs_.RightFrontLeg
local leftFrontLeg_ = lizardLegs_.LeftFrontLeg

local rightMidLeg_ = lizardLegs_.RightMidLeg
local leftMidLeg_ = lizardLegs_.LeftMidLeg

local rightHindLeg_ = lizardLegs_.RightHindLeg
local leftHindLeg_ = lizardLegs_.LeftHindLeg

-- Held item Stuff
local rightItemPivot_ = lizardHead_.RightItemPivot
local leftItemPivot_ = lizardHead_.LeftItemPivot
local rightItemID_ = "None"
local leftItemID_ = "None"
local isEating_ = false
local lizardItems_ = lizard_.Items

-- Armor Stuff
local gearToColorTable_ =
{
	leather = vectors.hexToRGB("#8f6f5e"),
	chainmail = vectors.hexToRGB("#dcdcdc"),
	iron = vectors.hexToRGB("#dcdcdc"),
	golden = vectors.hexToRGB("#ffe26d"),
	diamond = vectors.hexToRGB("#77f1e2"),
	netherite = vectors.hexToRGB("#616161"),
	turtle = vectors.hexToRGB("#3ca444")
}

local listOfAllHeads_ =
{
	{"minecraft:player_head",vec(0,0)},
	{"minecraft:creeper_head",vec(9,0)},
	{"minecraft:skeleton_skull",vec(18,0)},
	{"minecraft:wither_skeleton_skull",vec(18,16)},
	{"minecraft:piglin_head",vec(34,0)},
	{"minecraft:zombie_head",nil},
	{"minecraft:dragon_head",nil}
}

local armors_ = {
  helment = {slot = 6, id = nil, enchanted = false, modelPart = lizardHead_.Helmet},
  chestplate = {slot = 5, id = nil, enchanted = false, modelPart = lizardBody_ and {
    Chestplate = lizardBody_.Chestplate,
    TailChestplate = lizardTail_ and lizardTail_.Chestplate or nil,
    TailChestPlate2 = lizardTail_ and lizardTail_.ChestPlate2 or nil
  } or nil},
  leggings = {slot = 4, id = nil, enchanted = false, modelPart = lizardLegs_ and {
    RightFrontLeg = lizardLegs_.RightFrontLeg.RFLLeggings,
    LeftFrontLeg = lizardLegs_.LeftFrontLeg.LFLLeggings,
    RightMidLeg = lizardLegs_.RightMidLeg.RMLLeggings,
    LeftMidLeg = lizardLegs_.LeftMidLeg.LMLLeggings,
    RightHindLeg = lizardLegs_.RightHindLeg.RHLLeggings,
    LeftHindLeg = lizardLegs_.LeftHindLeg.LHLLeggings
  } or nil},
  boots = {slot = 3, id = nil, enchanted = false, modelPart = lizardLegs_ and {
    RightFrontLeg = lizardLegs_.RightFrontLeg.RFLBoots,
    LeftFrontLeg = lizardLegs_.LeftFrontLeg.LFLBoots,
    RightMidLeg = lizardLegs_.RightMidLeg.RMLBoots,
    LeftMidLeg = lizardLegs_.LeftMidLeg.LMLBoots,
    RightHindLeg = lizardLegs_.RightHindLeg.RHLBoots,
    LeftHindLeg = lizardLegs_.LeftHindLeg.LHLBoots
  } or nil}
}

-- Drool stuff
local ravenous_ = false
local hungerStare_ = false
local droolCounter_ = 0
local droolInterval_ = 20

-- Options

local eyeHeight_ = false
local regularEyes_ = false
local emmissiveEyes_ = false
local eyeEffects_ = false
local lizardArmor_ = false
local lizardBag_ = false
local collar_ = false
local altSpear_ = false

-- Related to Animation
local shakeAnim_ = false

-- Related To Chat
local wasChatOpen_=false

-- Keybinds
local biteSoundKeybind_ = keybinds:newKeybind("Plays lizard Bite Sound", "key.keyboard.p")
local chargeSoundKeybind_ = keybinds:newKeybind("Play lizard Charge Sound", "key.keyboard.g")
local checkHeldItemKeybind_ = keybinds:newKeybind("Check Held Item", "key.keyboard.c")

--Manual Rotation... yay...
local currentModelYaw = 0
local currentModelPitch = 0
-- define how far the player can view before the model rotates to look towards it
local minLimitUntilTurn_ = 60
local bodyRotationSpeed_ = 0.03

-- Save the smooth tracking angles across frames
local currentHeadYaw_ = 0
local currentHeadPitch_ = 0
local headRotationLimitYaw_ = 65
local headRotationLimitPitch_ = 30
local headRotationSpeed_ = 0.25

--GUID stuff
local lastScreen_ = nil

--==========================================================================================
-- Other File Stuff
--==========================================================================================

local function SquapiInit()
  --Manages and limits head rotation
  --squapi_.smoothHead:new(
  --  {
  --     lizardHead_ --element(you can have multiple elements in a table)
  --  },
 --   0.7,    --(1) strength(you can make this a table too)
 --   0,    --(0.1) tilt
  --  nil,    --(1) speed
  --  nil     --(true) keepOriginalHeadPos
  --)

  -- squapi_.tails(myTail, 3, 15, 5, 2, 1.2, 0, 0, 1, .0005, .06, nil, nil)
  local myTail = {}
  --require("scripts.helper")
  myTail = h_.GetModelFoldersRecursively(myTail,lizardTail_)

  --replace each nil with the value/parmater you want to use, or leave as nil to use default values :)
  --parenthesis are default values for reference
  squapi_.tail:new(myTail,
      nil,    --(15) idleXMovement
      nil,    --(5) idleYMovement
      nil,    --(1.2) idleXSpeed
      nil,    --(2) idleYSpeed
      0.3,    --(2) bendStrength
      0,    --(0) velocityPush
      nil,    --(0) initialMovementOffset
      1,    --(1) offsetBetweenSegments
      0.05,    --(.005) stiffness
      nil,    --(.9) bounce
      nil,    --(90) flyingOffset
      -45,    --(-90) downLimit
      20     --(45) upLimit
  )
  --in Blockbench, each tail segment would go inside the last. first segment would contain the second, second would contain the third, etc.
  --this list can be as long as you want based on how many segments your tail is, just add more.

  --replace each nil with the value/parmater you want to use, or leave as nil to use default values :)
  --parenthesis are default values for reference
  --[[
  squapi_.eye:new(
      lizardHead_.Eyes,  --the eye element
      0.2,  --(0.25) left distance
      0.3,  --(1.25) right distance
      0.2,  --(0.5) up distance
      0.2   --(0.5) down distance
  )]]

  --replace each nil with the value/parmater you want to use, or leave as nil to use default values :)
  --parenthesis are default values for reference
  squapi_.randimation:new(
      animations[modelName_].blink,    --animation
      100,    --(200) chanceRange
      true     --(false) isBlink
  )

  --replace each nil with the value/parmater you want to use, or leave as nil to use default values :)
  --parenthesis are default values for reference

  squapi_.ear:new(
      lizardHead_.Horns.LeftHorn, --leftEar
      lizardHead_.Horns.RightHorn, --(nil) rightEar
      nil, --(1) rangeMultiplier
      true, --(false) horizontalEars
      0.5, --(2) bendStrength
      nil, --(true) doEarFlick
      nil, --(400) earFlickChance
      0.2, --(0.1) earStiffness
      0.25  --(0.8) earBounce
  )

  --replace each nil with the value/parmater you want to use, or leave as nil to use default values :)
  --parenthesis are default values for reference
  squapi_.bounceWalk:new(
      lizard_,    --model
      0.4     --(1) bounceMultiplier
  )
end

local function SwingingPhysicsInit()
  --Adds swinging physics to a part that is attached to the head
  --@param part ModelPart The model part that should swing
  --@param dir number Angle in degree, where the part is located relative to the center of the head. Imagine a stick pointing out in that direction with the model part hanging from its end. 0 means forward, 45 means diagonally forward and left, 90 means straight left and so on
  --@param limits table|nil Limits the rotation of the part to make it appear like its colliding with something. Format: {xLow, xHigh, yLow, yHigh, zLow, zHigh} (optional)
  --@param root ModelPart|nil Required if it is part of a chain. Note that the first chain element does not need this root parameter, and does also not need the depth parameter. Only following chain links need it.
  --@paramt depth number|nil An integer that should increase by 1 for each consecutive chain link after the root. The root itself doesnt need this parameter. This increases the friction which makes it look more realistic.

  --swingingPhysics_.swingOnHead(slugcatUpperBody.head.Main.Tongue1, 0, {-45,-35, 0,20, -25,25}, nil, nil)
  --swingingPhysics_.swingOnHead(slugcatUpperBody.head.Main.Tongue1.Tongue2, 0, {-35,-25, 0,30, -25,25}, slugcatUpperBody.head.Main.Tongue1, 1)
  --swingingPhysics_.swingOnHead(slugcatUpperBody.head.Main.Tongue1.Tongue2.Tongue3, 0, {-25,-15, 0,40, -25,25}, slugcatUpperBody.head.Main.Tongue1, 2)
  --swingingPhysics_.swingOnHead(slugcatUpperBody.head.Main.Tongue1.Tongue2.Tongue3.Tongue4, 0, {-15,-5, 0,50, -25,25}, slugcatUpperBody.head.Main.Tongue1, 3)

  --local leftHorn = {}
  --leftHorn = getModelFoldersRecursively(leftHorn,lizardHead_.Horns.LeftHorn)
  --for i, item in ipairs(leftHorn) do
   -- swingingPhysics_.swingOnHead(item, 0, {-10 + i * 10, 10 + i * 10, -10 ,20 , -25 ,25 }, leftHorn[i - 1], i - 1)
  --end

  --slugcatUpperBody.head.Masks.ChiefMask.LeftAntler.LeftAntlerChunk1.physBoneLeftAntlerPearl1.Pearl:setSecondaryRenderType("GLINT")
  --slugcatUpperBody.head.Masks.ChiefMask.LeftAntler.LeftAntlerChunk2.physBoneLeftAntlerPearl2.Pearl:setSecondaryRenderType("GLINT")
  --slugcatUpperBody.head.Masks.ChiefMask.LeftAntler.LeftAntlerUpper1.LeftAntlerChunk3.physBoneLeftAntlerPearl3.Pearl:setSecondaryRenderType("GLINT")
  --slugcatUpperBody.head.Masks.ChiefMask.LeftAntler.LeftAntlerUpper1.LeftAntlerUpper2.LeftAntlerChunk4.physBoneLeftAntlerPearl4.Pearl:setSecondaryRenderType("GLINT")
  --slugcatUpperBody.head.Masks.ChiefMask.LeftAntler.LeftAntlerUpper1.LeftAntlerUpper2.LeftAntlerChunk5.physBoneLeftAntlerPearl5.Pearl:setSecondaryRenderType("GLINT")
  --slugcatUpperBody.head.Masks.ChiefMask.RightAntler.RightAntlerChunk1.physBoneRightAntlerPearl1.Pearl:setSecondaryRenderType("GLINT")
  --slugcatUpperBody.head.Masks.ChiefMask.RightAntler.RightAntlerChunk2.physBoneRightAntlerPearl2.Pearl:setSecondaryRenderType("GLINT")
  --slugcatUpperBody.head.Masks.ChiefMask.RightAntler.RightAntlerUpper1.RightAntlerChunk3.physBoneRightAntlerPearl3.Pearl:setSecondaryRenderType("GLINT")
  --slugcatUpperBody.head.Masks.ChiefMask.RightAntler.RightAntlerUpper1.RightAntlerUpper2.RightAntlerChunk4.physBoneRightAntlerPearl4.Pearl:setSecondaryRenderType("GLINT")
  --slugcatUpperBody.head.Masks.ChiefMask.RightAntler.RightAntlerUpper1.RightAntlerUpper2.RightAntlerChunk5.physBoneRightAntlerPearl5.Pearl:setSecondaryRenderType("GLINT")


  swingingPhysics_.swingOnBody(lizard_.Items.ItemSpear.Explosive.Explosive1, 0, {-80,80, -80,80, -25,25}, nil, nil)
  swingingPhysics_.swingOnBody(lizard_.Items.ItemSpear.Explosive.Explosive1.Explosive2, 0, {-85,85, -85,85, -25,25}, lizard_.Items.ItemSpear.Explosive.Explosive1, 1)
  swingingPhysics_.swingOnBody(lizard_.Items.ItemSpear.Explosive.Explosive1.Explosive2.Explosive3, 0, {-90,90, -90,90, -25,25}, lizard_.Items.ItemSpear.Explosive.Explosive1, 2)
  swingingPhysics_.swingOnBody(lizard_.Items.ItemSpear.Explosive.Explosive1.Explosive2.Explosive3.Explosive4, 0, {-95,95, -95,95, -25,25}, lizard_.Items.ItemSpear.Explosive.Explosive1, 3)

  --slugcatUpperBody.Arms.LeftArm.Main.Gourmand.Down.LeftItemPivot:setScale(0.68,0.68,0.68)
  --slugcatUpperBody.Arms.RightArm.Main.Gourmand.Down.RightItemPivot:setScale(0.68,0.68,0.68)
  --slugcatUpperBody.Arms.LeftArm.Main.Spearmaster.Down.LeftItemPivot:setScale(0.68,0.68,0.68)
  --slugcatUpperBody.Arms.RightArm.Main.Spearmaster.Down.RightItemPivot:setScale(0.68,0.68,0.68)
  --slugcatUpperBody.Arms.LeftArm.Main.Base.Down.LeftItemPivot:setScale(0.68,0.68,0.68)
  --slugcatUpperBody.Arms.RightArm.Main.Base.Down.RightItemPivot:setScale(0.68,0.68,0.68)
  --slugcatUpperBody.Body.LeftElytraPivot:setScale(0.5,0.5,0.5)
  --slugcatUpperBody.Body.RightElytraPivot:setScale(0.5,0.5,0.5)
  --slugcat.Items.ItemPearl:setSecondaryRenderType("GLINT")
end

local function JimmyAnimsInit()
  anims_.blendTime = 1
  anims_.itemBlendTime = 0.2
  anims_.autoBlend = true
  anims_(animations[modelName_])
end

local function TailInit()
  --Make Stomach move
  tailPhysics_.new(lizardBody_.StomachE):setConfig { bounce = 0.25, stiff = 0.4, enableWag = {false} }

  --arrow projectile move
  tailPhysics_.new(lizard_.Misc.Arrow):setConfig { bounce = 0.25, stiff = 0.4, enableWag = {false} }
end

local function ChatInit()
  chat_.new("TriggerRavenous", TriggerRavenous, {"ravenous"}, "Does nothing")
  chat_.new("GrowlStomach", pings.PlayGurgleSound, {"hungry"}, "Does nothing")
end

--==========================================================================================
-- Base Model Functions (makes the barebones work)
--==========================================================================================

local function ModelInit()
  -- Hide vanilla parts
  vanilla_model.PLAYER:setVisible(false) --hide vanilla model
  vanilla_model.ARMOR:setVisible(false) --hide vanilla armor model
  vanilla_model.CAPE:setVisible(false) --hide vanilla cape model
  vanilla_model.ELYTRA:setVisible(false) --hide vanilla elytra model
  --vanilla_model.HELMET_ITEM:setVisible(true)  --re-enable the helmet item

  -- Set rendering type for optimized performance. Prevents back faces from rendering
  models:setPrimaryRenderType("CUTOUT_CULL") 

  -- Adjust scale of Model and Items Inversely
  ScaleModel(playerScale_)

  -- Set the model's root rotation to be not allowed. Rotations are now manual
  renderer:setRootRotationAllowed(false)

  nameplate.CHAT:setText('{"text" : "Coo", "color" : "White"}')
  nameplate.ENTITY:setText('{"text" : "Enigma", "color" : "Orange"}')
  nameplate.LIST:setText('{"text" : "Coo", "color" : "White"}')
end

function ScaleModel(newScale)
  local finalScale = newScale * playerAdditionalScale_
  lizard_:setScale(finalScale)
  local inverseScale = 1/finalScale
  local inverseScaleVec = vec(inverseScale, inverseScale, inverseScale)
  lizardHead_.RightItemPivot:setScale(inverseScaleVec)
  lizardHead_.LeftItemPivot:setScale(inverseScaleVec)

  renderer:setShadowRadius(finalScale / 2)
end


function ManualPlayerRotation(delta, context)
  if not player then return end

  local lookVector = player:getLookDir()

  --Convert to Yaw degrees
  local targetYaw = math.atan2(lookVector.x, lookVector.z) * (180 / math.pi) + 180   

  --fix the 360-degree wraparound
  local diff = (targetYaw - currentModelYaw + 180) % 360 - 180

  local minLimit = minLimitUntilTurn_

  --get player velocity
  local velocity = player:getVelocity()
  --This is under the MASSIVE assumption the movement is because of the player's input
  if velocity.xz:length() > 0.01 then
    --get the Y direction of the player's movement
    local walkYaw = math.atan2(velocity.x, velocity.z) * (180 / math.pi) + 180
    --get the difference between the walking direction and the look direction, as well as the opposite
    local diffw = (walkYaw - targetYaw + 180) % 360 - 180
    local oppositeDiff = (walkYaw - (targetYaw - 180) + 180) % 360 - 180
    --if within the min limit, more or less remove the limit to look straight at it
    if math.abs(diffw) < minLimit or math.abs(oppositeDiff) < minLimit then
      minLimit = 2
    end
  end

  --Rotate if further than the minimum limit
  if math.abs(diff) > minLimit then
      --gradually turn towards it
      currentModelYaw = currentModelYaw + (diff * delta * bodyRotationSpeed_)
  end


  -- Target pitch defaults to 0 (perfectly level) on land
  local targetPitch = 0

  --ONLY change pitch during swimming
  if player:isVisuallySwimming() then
      --Convert to Pitch degrees
      targetPitch = math.atan2(lookVector.y, lookVector.xz:length()) * (180 / math.pi)
  end

  --gradually turn towards it
  currentModelPitch = currentModelPitch + (targetPitch - currentModelPitch) * (delta * bodyRotationSpeed_)

  --turn the model towards the target
  if lizard_ then
    lizard_:setRot(currentModelPitch, currentModelYaw, 0)
  end
end

--Limits how far the head can rotate   !!!Handled by squapi so this is unused
function ManualPlayerHeadRotationRender(delta, context)
  if not player then return end

  -- Where the player is looking
  local lookDir = player:getLookDir()

  --Get the Target Yaw
  local targetYaw = math.atan2(lookDir.x, lookDir.z) * (180 / math.pi) + 180
  --Reduce Target by the current model's yaw
  targetYaw = targetYaw - currentModelYaw

  --Get the difference between the target and current yaw
  local diffYaw = (targetYaw - currentHeadYaw_ + 180) % 360 - 180
  --Move towards target
  currentHeadYaw_ = currentHeadYaw_ + (diffYaw * delta * headRotationSpeed_)

  -- Prevent the head from rotating too far
  local finalYaw =  h_.ClampAngle(currentHeadYaw_ , 0, headRotationLimitYaw_) 

  --Get the Target Pitch
  local targetPitch = math.atan2(lookDir.y, lookDir.xz:length()) * (180 / math.pi) 
  --Reduce Target by the current model's pitch
  targetPitch = targetPitch - currentModelPitch

  --Get the difference between the target and current pitch
  local diffPitch = (targetPitch - currentHeadPitch_ + 180) % 360 - 180
  --Move towards target
  currentHeadPitch_ = currentHeadPitch_ + (diffPitch * (delta * headRotationSpeed_))

  -- Prevent the head from rotating too far
  local finalPitch = math.clamp(currentHeadPitch_, -headRotationLimitPitch_, headRotationLimitPitch_)

  --apply to model
  if lizard_ and lizardHead_ then
      lizardHead_:setRot(finalPitch, finalYaw , 0)
  end
end


-- Animates the 6 legs
function RotateLegs(delta, context)
    -- Get the current rotation and offset of the vanilla right leg
    local mainRightLegRot = vanilla_model.RIGHT_LEG:getOriginRot()
    --local mainLegOff = vanilla_model.RIGHT_LEG:getOffset()
    local mainLeftLegRot = vanilla_model.LEFT_LEG:getOriginRot()

    mainRightLegRot = vec(mainRightLegRot.x * 0.80, mainRightLegRot.y * 0.80, mainRightLegRot.z * 0.80)
    mainLeftLegRot = vec(mainLeftLegRot.x * 0.80, mainLeftLegRot.y * 0.80, mainLeftLegRot.z * 0.80)

    -- Apply these transformations to your extra legs
    -- You can add/subtract to the rotation/offset here to offset the legs manually
    rightFrontLeg_:setRot(mainRightLegRot)
    --rightFrontLeg_:setOffset(mainLegOff)
    leftFrontLeg_:setRot(mainLeftLegRot)

    rightMidLeg_:setRot(mainLeftLegRot)
    leftMidLeg_:setRot(mainRightLegRot)

    rightHindLeg_:setRot(mainRightLegRot)
    leftHindLeg_:setRot(mainLeftLegRot)
end



local function ManageCrouchingTick()
  if not player then return end

  if player:isCrouching() then --player:getPose() == "CROUCHING" then
    --log("Player is crouching")
    -- Do something when the player is crouching
    vanilla_model.BODY:setRot(0, 0, 0)
    vanilla_model.HEAD:setRot(0, 0, 0)
    vanilla_model.BODY:setPos(0, 0, 0)
    vanilla_model.HEAD:setPos(0, 0, 0)

    lizardBody_:setPos(0, 3, 0)
    --lizardHead_:setPos(0, 20, 0)
  else
    lizardBody_:setPos(0, 0, 0)
    --lizardHead_:setPos(0, 20, 0)
  end
end


local function WaterRender()
	local pose = player:getPose()
  local inLiquid = player:isInWater() or player:isInLava()
	if pose == "SWIMMING" and inLiquid == false then
		renderer:offsetCameraPivot(vec(0,0,0))
		renderer:setEyeOffset(vec(0,0,0))
	else
		renderer:offsetCameraPivot((eyeHeight_) and vec(0,-0.65,0) or vec(0,0,0))
		renderer:setEyeOffset((eyeHeight_ ) and vec(0,-0.65,0) or vec(0,0,0))
	end
end

--Plays the model's Shake animation when rained on or hungry
function ShakeTick()
  if world.getRainGradient() > 0 then
    if shakeAnim_ == false then
      shakeAnim_ = true
      animations[modelName_].shake:play()
    end
  elseif player:getFood() < 6 then
    if shakeAnim_ == false then
      shakeAnim_ = true
      animations[modelName_].shake:play()
    end
  else
    shakeAnim_ = false
    animations[modelName_].shake:stop()
  end
end





--==========================================================================================
-- Drool
--==========================================================================================

--Makes the model drool when ravenous is true
function DroolTick()
  if ravenous_ then
    -- 2. Add 1 to our counter every tick
    droolCounter_ = droolCounter_ + 1

    -- 3. Check if 20 ticks (1 full second) have passed
    if droolCounter_ >= droolInterval_ then
      local worldMatrix = lizardHead_:partToWorldMatrix()
      local worldPos = worldMatrix:apply()
      local droolAmount = math.random(1,3)

      for i=0,droolAmount do
        worldPos = vec(worldPos.x + (math.random(0,10) -5) / 20 , worldPos.y , worldPos.z + (math.random(0,10) -5) / 20)
        particles:newParticle("minecraft:falling_water", worldPos, vec(0, 1, 0))
      end
        
      -- 4. Reset the counter back to zero to restart the timer
      droolCounter_ = 0
      droolInterval_ = math.random(15,25)
    end
  end
end

--Triggers Ravenous when looking at creatures
function HungerStareTick()
  --Find what the player is staring at
  local target = player:getTargetedEntity(20)

  -- 2. Check if a target entity actually exists
  if target and hungerStare_ then
    --living creatures only
    if target:isLiving() then
      --properties
      local creatureID = target:getType()
      local cleanName = target:getName()
 
      --print("You are looking at a creature: " .. cleanName .. " (" .. creatureID .. ")")
            
      if not ravenous_ then
        ravenous_ = true
      end
    end
  else
      -- Runs when you look away or stare into empty air/blocks
      -- (Optional: Add reset logic here)
  end
end


function TriggerRavenous()
  ravenous_ = not ravenous_

  if ravenous_ then
    print("You are ravenous.")
  else
    print("You are no longer ravenous.")
  end
end

--==========================================================================================
-- Chat and GUI Triggers
--==========================================================================================

--Checks if the Chat is open
function ChatOpenTick()
  local isChatOpen=host:isChatOpen()
  if isChatOpen ~= wasChatOpen_ then
    pings.setChat(isChatOpen)
  end
  wasChatOpen_=isChatOpen
end

function GUIDTick()
	-- Must be loaded
  if not player:isLoaded() then return end

  -- Get GUI name
  local currentScreen = host:getScreen()

  if currentScreen ~= lastScreen_ then
    if lastScreen_ then
      --end the last screen stuff
      --print("You just closed the " .. lastScreen_ .. " screen!")
    end

    lastScreen_ = currentScreen

    --Check if using chat
    if currentScreen and currentScreen:find("ChatScreen")  then
     -- print("You are currently typing in chat!")
        
      -- Example: Make a "thinking" thought-bubble model part visible
      if lizardFullbody_.DialogueBox then
        lizardFullbody_.DialogueBox:setVisible(true)
        animations[modelName_].dialogue:play()
      end

    else
      -- Runs when you close the chat box and return to standard movement
      -- Example: Hide your thinking model part again
        if lizardFullbody_.DialogueBox then
          lizardFullbody_.DialogueBox:setVisible(false)
          animations[modelName_].dialogue:stop()
        end
    end

    --Check if using inventory
    if currentScreen and currentScreen:find("InventoryScreen")  then
      --print("You are currently typing in your inventory!")
        
      -- Example: Make a "thinking" thought-bubble model part visible
      if lizardBag_ and lizardTail_.Tail2.Tail3.Bag then
        --print("setting parent")
        -- Snap the weapon directly to the player's right hand group
        --lizardTail_.Tail2.Tail3.Bag:setParentType("RightItemPivot")
        -- Optional: Reset position offsets to fit the hand perfectly
        --lizardTail_.Tail2.Tail3.Bag:setPos(0, 0, 0)



        -- 1. Get the starting position (the player's feet or head)
        local startPos = player:getPos() -- Use player:getEyePos() if you want it from eye-level

        -- 2. Get the direction vector the player is looking
        local lookDirection = player:getLookDir()

        -- 3. Decide how many blocks in front you want to look (e.g., 3 blocks)
        local distance = 3

        -- 4. Calculate the target position
        local frontPos = startPos + vec(lookDirection.x, 0, lookDirection.z) * distance

        lizardTail_.Tail2.Tail3.Bag:setParentType("World")
        lizardTail_.Tail2.Tail3.Bag:setPos(frontPos * 16)

        lizardTail_.Tail2.Tail3.Bag:setRot(0, 0, 0)
        lizardTail_.Tail2.Tail3.Bag:setScale(playerScale_ * playerAdditionalScale_)
      end

    else
      if lizardBag_ and lizardTail_.Tail2.Tail3.Bag then
        -- Snap the weapon directly to the player's right hand group
        lizardTail_.Tail2.Tail3.Bag:setParentType("MODEL")
        -- Optional: Reset position offsets to fit the hand perfectly
        lizardTail_.Tail2.Tail3.Bag:setPos(0, 0, 0)
        lizardTail_.Tail2.Tail3.Bag:setRot(0, 0, 0)
        lizardTail_.Tail2.Tail3.Bag:setScale(1)
      end
    end
  end
end

--==========================================================================================
-- Items
--==========================================================================================

function ItemTick()
  --vanilla_model.HELD_ITEMS:setVisible(false)
  --ColorByHunger()
  AlterGrip()
  EatingCheck()
  FullEat()
end

--Colors the body based on how much food the player has
function ColorByHunger()
  --if player:getFood() < 6 then
  --   lizard_.FullBody:setColor(vectors.hexToRGB("#aaaaaa"))
  --elseif player:getFood() < 12 then
  --  lizard_.FullBody:setColor(vectors.hexToRGB("#cccccc"))
  --else
  --  lizard_.FullBody:setColor(vectors.hexToRGB("#ffffff"))
  --end
end

--Changes how the model holds items
function AlterGrip()
  local newGrip = GetGripBasedOnHeldItem(false)
  if newGrip then rightItemPivot_:setRot(GripRotationVec(newGrip,false)) end
  newGrip = GetGripBasedOnHeldItem(true)
  if newGrip then leftItemPivot_:setRot(GripRotationVec(newGrip,true)) end
end

function GetGripBasedOnHeldItem(handBool)
  local item = player:getHeldItem(handBool)
  local newGrip = nil
  local oldItemID = handBool and leftItemID_ or rightItemID_

  if item and oldItemID ~= item:getID() then
    local itemVisibility = true

    --Check whether it's a tool
    if item:isDamageable() and item:isArmor() == false then
      --Check whether it's a shield
      if h_.TableContains(item:getTags(), "forge:tools/shields") then
        itemVisibility = false
        newGrip = "Shield"
       else
        newGrip = "Tool"
       end
    else
      newGrip = "Other"
    end

    --Update the currently held item id and make the item visible
    if handBool then 
      leftItemID_ = item:getID()
      vanilla_model.LEFT_ITEM:setVisible(itemVisibility)
    else
      rightItemID_ = item:getID()
      vanilla_model.RIGHT_ITEM:setVisible(itemVisibility)
    end
  end
  return newGrip 
end

--Gets the new rotation based on the hand
function GripRotationVec(string, handBool)
  local gripRotVec = vec(0,0,0)

  if string then
    if string == "Tool" then
      if not handBool then
        gripRotVec = vec(90,0,-90)
      else
        gripRotVec = vec(90,0,90)
      end
    end
  end
  return gripRotVec
end

--And makes eating effect at actual mouth
function EatingCheck()
  local newIsEating = false

  -- Check if the player is using an item
  if player:isUsingItem() then
    local activeItem = player:getActiveItem()

    if activeItem then
      --Check if it's food
      local isFood = activeItem:isFood()
      if isFood then
        newIsEating = true
        local itemID = activeItem:getID()
        local itemCount = activeItem:getCount()
        --make sure it exists
        if itemID ~= nil and itemID ~= "" then
          for i = 1, math.ceil(itemCount / 21) do
            -- Spawns eating particles at the mouth
            particles:newParticle("minecraft:item " .. itemID, lizardHead_:partToWorldMatrix():apply())
           end
        end
      end
    end
  end

  --Change the scale of the item held if it's being eaten
  if isEating_ ~= newIsEating then
    isEating_ = newIsEating
    local scaler = (1/baseModelScale_)
    if isEating_ then
      local activeItem = player:getActiveItem()
      if activeItem then
        local itemCount = activeItem:getCount()
        --Triple item size if a full stack of 64
        scaler = scaler * ( 0.96875 + 0.03125 * itemCount)
      end
    end

    --restore item size or make it bigger based on stacks
    lizardHead_.RightItemPivot:setScale(scaler, scaler, scaler)
  end
end

--Trigger when fully eaten
local function onFoodFullyEaten()
  --print("Yum! The food item was successfully eaten!")
end

--Checks when something is full eaten
function FullEat()
  -- Safety check: Stop running if the player model isn't loaded yet
  if not player:isLoaded() then return end

  -- Check if the player is using an item
  if player:isUsingItem() then
    local activeItem = player:getActiveItem()

    if activeItem then
      --Check if it's food
      local isFood = activeItem:isFood()
      if isFood then
        local useTicks = player:getActiveItemTime()
        if useTicks == activeItem:getUseDuration() then
          local itemID = activeItem:getID()
          local itemCount = activeItem:getCount()
          if itemID ~= nil and itemID ~= "" then
            

            onFoodFullyEaten()
          end
        end
      end
    end
  end
end



local function HeadTableContains(tbl, x)
  for _, value in ipairs(tbl) do
    if value[1] == x then
      return true
    end
  end
  return false
end

local function HeadTableGetUVVec(tbl, x)
	for _, value in ipairs(tbl) do
    if value[1] == x then
      return value[2]
    end
  end
  return nil
end



local function WearMask(armor)
  local mask = h_.TableContains(listOfAllHeads_, armor.id)
  local maskVec = armor.id and HeadTableGetUVVec(listOfAllHeads_, armor.id)
	
	local masksModel = lizardHead_.Masks
	if masksModel then
		masksModel.NotSadMask:setUVPixels(maskVec)
	
		masksModel.NotSadMask.BaseMask:setVisible((mask == true and armor.id ~= "minecraft:zombie_head" and armor.id ~= "minecraft:dragon_head"))
		masksModel.NotSadMask.Horns:setVisible((mask == true and (armor.id == "minecraft:skeleton_skull" or armor.id == "minecraft:wither_skeleton_skull")))
		masksModel.NotSadMask.Spikes:setVisible((mask == true and armor.id == "minecraft:piglin_head"))
		masksModel.SadMask:setVisible((mask == true and armor.id == "minecraft:zombie_head"))
		masksModel.ChiefMask:setVisible((mask == true and armor.id == "minecraft:dragon_head"))
	end
end

local function WearArmor(armor)
  --Get the type for the armor and return color for it if it exists
	local armorType = armor.id and armor.id:lower():match("minecraft:([^_]+)")
	local color = armorType and gearToColorTable_[armorType] or nil
  local vis = (color ~= nil)

  if armor.modelPart then
    if type(armor.modelPart) == "table" then
      for _, part in pairs(armor.modelPart) do
        part:setVisible(vis)
        part:setColor(color)
        part:setSecondaryRenderType((armor.enchanted) and "GLINT" or "NONE")
      end
    else
      armor.modelPart:setVisible(vis)
      armor.modelPart:setColor(color)
      armor.modelPart:setSecondaryRenderType((armor.enchanted) and "GLINT" or "NONE")
    end
	end
end

local function ArmorTick()
  if lizardArmor_ == false then return end

  for i, armor in pairs(armors_) do
    local item = player:getItem(armor.slot)
    local enchantStatus = item.hasGlint and item:hasGlint() or (item.tag and item.tag.Enchantments ~= nil)
    --print(tostring(i) .. tostring(enchantStatus))
    if armor.id == item.id and armor.enchanted == enchantStatus then 
      --this armor piece has not changed since last tick, so do nothing
    else
      armor.id = item.id
      armor.enchanted = enchantStatus

      if armor.slot == 6 then
        WearMask(armor)
      end
      WearArmor(armor)
    end
  end
end


local function CollarTick()
  if lizardHead_.Collar then
		--lizardHead_.Collar:setVisible((collar_ == true and color == nil))
	end
end

local function ItemTridentLogic(item, lefty)
  local enchants = item:hasGlint()
		--print(enchants)
		lizard_.Items.ItemSpear.Explosive.ExplosiveTop:setSecondaryRenderType((enchants) and "GLINT2" or "NONE")
		lizard_.Items.ItemSpear.Explosive.Explosive1:setSecondaryRenderType((enchants) and "GLINT2" or "NONE")
		lizard_.Items.ItemSpear.Explosive.Explosive1.Explosive2:setSecondaryRenderType((enchants) and "GLINT2" or "NONE")
		lizard_.Items.ItemSpear.Explosive.Explosive1.Explosive2.Explosive3:setSecondaryRenderType((enchants) and "GLINT2" or "NONE")
		lizard_.Items.ItemSpear.Explosive.Explosive1.Explosive2.Explosive3.Explosive4:setSecondaryRenderType((enchants) and "GLINT2" or "NONE")

		local red = vectors.hexToRGB("#fe0108")
		local purple = vectors.hexToRGB("#836bcf")

		lizard_.Items.ItemSpear.Explosive.ExplosiveTop:setPrimaryRenderType("SOLID")
		lizard_.Items.ItemSpear.Explosive.Explosive1:setPrimaryRenderType("SOLID")
		lizard_.Items.ItemSpear.Explosive.Explosive1.Explosive2:setPrimaryRenderType("SOLID")
		lizard_.Items.ItemSpear.Explosive.Explosive1.Explosive2.Explosive3:setPrimaryRenderType("SOLID")
		lizard_.Items.ItemSpear.Explosive.Explosive1.Explosive2.Explosive3.Explosive4:setPrimaryRenderType("SOLID")

		lizard_.Items.ItemSpear.Explosive.ExplosiveTop:setColor((enchants) and purple or red)
		lizard_.Items.ItemSpear.Explosive.Explosive1:setColor((enchants) and purple or red)
		lizard_.Items.ItemSpear.Explosive.Explosive1.Explosive2:setColor((enchants) and purple or red)
		lizard_.Items.ItemSpear.Explosive.Explosive1.Explosive2.Explosive3:setColor((enchants) and purple or red)
		lizard_.Items.ItemSpear.Explosive.Explosive1.Explosive2.Explosive3.Explosive4:setColor((enchants) and purple or red)

		
		--print(tostring(lizard_.Items.ItemSpear))

    if lefty then
			return lizard_.Items.ItemSpear:setPos(-0.25,0,0)
		else
			return lizard_.Items.ItemSpear:setPos(0.25,0,0)
		end
end

local function ItemRenderer(item, mode, pos, rot, scale, lefty)
	--Check that items exist
	if lizard_.Items == nil then return end

	if item.id == "minecraft:trident" then
    return ItemTridentLogic(item, lefty)
	end

	--[[
  elseif item.id == "minecraft:egg" then
    if lefty then
			return slugcat.Items.ItemRock:setPos(-0.5,0,0)
		else
			return slugcat.Items.ItemRock:setPos(0.5,0,0)
		end

  elseif item.id == "minecraft:snowball" then
    if lefty then
			return slugcat.Items.ItemBrick:setPos(-0.5,0,0)
		else
			return slugcat.Items.ItemBrick:setPos(0.5,0,0)
		end

  elseif item.id == "minecraft:amethyst_shard" then
    if lefty then
			return slugcat.Items.ItemPearl:setPos(-0.5,0,0)
		else
			return slugcat.Items.ItemPearl:setPos(0.5,0,0)
		end

	elseif item.id == "minecraft:crossbow" and not gunHide then
		if lefty then
			return slugcat.Items.ItemGun:setPos(-0.5,0,0)
		else
			return slugcat.Items.ItemGun:setPos(0.5,0,0)
		end

  elseif item.id == "minecraft:shield" then
		if lefty then
			return slugcat.Items.ItemShield:setRot(0,90,0):setPos(0.25,0,0)
		else
			return slugcat.Items.ItemShield:setRot(0,-90,0):setPos(0.5,0,0)
		end
  end
	]]
end

local function BlockingSoundDamage(amount, source, type)
    -- 1. Check if you are actively using a shield
  local isUsingItem = player:isUsingItem()

  if amount == 0 and isUsingItem then
    local itemM = player:getHeldItem(true)
    local itemO = player:getHeldItem(false)

    local shieldBlock = false

    -- Check Main Hand
    if itemM then
      local id = itemM.id:lower()
      if id:find("shield") or h_.TableContains(itemM:getTags(), "forge:tools/shields") then
        shieldBlock = true
      end
    -- Check Off Hand
    elseif itemO then
      local id = itemO.id:lower()
      if id:find("shield") or h_.TableContains(itemO:getTags(), "forge:tools/shields") then
        shieldBlock = true
      end
    end

    if shieldBlock then
    --if type:find("arrow") or type:find("projectile") then
          
        -- SUCCESS: You just blocked an arrow! Play your custom ogg file
        sounds:playSound("minecraft:item.spear.lunge1", player:getPos(), 1.0, 1.0)
          
      -- end
    end
  end
end

--==========================================================================================
-- Print Functions
--==========================================================================================

--Prints all the properties of the currently held item
function PrintItemDetails()
  -- Get the item in the main hand
  local heldItem = player:getHeldItem(false)
    
  if heldItem then
    local itemID = heldItem:getID()

    print("You are holding: " .. heldItem:getName())
    print("It has a maxStackSize of " .. tostring(heldItem:getMaxCount()))
    print("It has a max Durability of " .. tostring(heldItem:getMaxDamage()))
    print("Is it armor? " .. tostring(heldItem:isArmor()))
    print("It has a use duration of " .. tostring(heldItem:getUseDuration()))
    print("Its use action is " .. tostring(heldItem:getUseAction()))
    print("Is it food? " .. tostring(heldItem:isFood()))
   
    local tagTable = heldItem:getTags()
    if tagTable and #tagTable > 0 then
      print("Tag Counts of " .. #tagTable)
      print("pairs")
      for key, item in pairs(tagTable) do
        print(tostring(key) .. " " .. tostring(item)) 
      end
      print("ipairs")
      for key, item in ipairs(tagTable) do
        print(tostring(key) .. " " .. tostring(item)) 
      end
    else
      print("This item lacks a tag table or has an empty tag table")
    end
  else
    print("Your hand is empty.")
  end
end

--Prints what grip the item should have
function PrintItemRot()
  print("Right Hand Grip is " .. tostring(GetGripBasedOnHeldItem(false)))
  print("Left Hand Grip is " .. tostring(GetGripBasedOnHeldItem(true)))
end

--==========================================================================================
-- Pings
--==========================================================================================

function pings.SetAdditionalScale(value)
  playerAdditionalScale_ = value
  ScaleModel(playerScale_)
end

function pings.ScaleModel(value)
end

--Eye Pings
----
function pings.RegularEyes(enabled)
	--if lizardHead_.Collar then
	--	lizardHead_.Collar:setVisible(enabled)
	--end

	regularEyes_ = enabled
	log(enabled and "[RegularEyes] On" or "[RegularEyes] Off")
end

function pings.EmmissiveEyes(enabled)
	--if lizardHead_.Collar then
	--	lizardHead_.Collar:setVisible(enabled)
	--end
	emmissiveEyes_ = enabled

	if lizardHead_.Eyes then
		lizardHead_.Eyes:setPrimaryRenderType( (enabled) and "EMISSIVE" or "TRANSLUCENT")
	end
	

	log("[EmmissiveEyes]", (enabled and "+" or "-").." EmmissiveEyes")
end

function pings.EffectsEyes(enabled)
	--if lizardHead_.Collar then
	--	lizardHead_.Collar:setVisible(enabled)
	--end
	eyeEffects_ = enabled
	log("[EffectsEyes]", (enabled and "+" or "-").." EffectsEyes")
end

--Scale Pings
----
function pings.ModelScaler(val)
	if val == 0 then
		playerScale_ = baseModelScale_
	else
		playerScale_ = math.clamp(playerScale_ + val, 1, 8)
	end

	ScaleModel(playerScale_)

	log("[Scaler]", playerScale_)
end

function pings.EyeHeight(eye) 
	eyeHeight_ = eye 
	log(eye and "[Size] Off-Set (WARNING)" or "[EyeHeight] Vanilla")
end


--Item pings
----
function pings.spear(spear)
	local LISpear = lizardItems_.ItemSpear

  --Technically this model has ALL the spears so this must be done
  LISpear.Explosive:setVisible(spear)
  LISpear.Base:setVisible(spear)
  LISpear.Spearmaster:setVisible(false)

	altSpear_ = spear
	log(spear and "[Spear] On" or "[Spear] Off")
end


--Armor Pings
----
function pings.LizardArmor(enabled)
	lizardArmor_ = enabled

  sounds:playSound("minecraft:item.armor.equip_generic", player:getPos(), 1.5, 0.85)

  --remove all armor visuals
  if lizardArmor_ == false then
    for _, armor in pairs(armors_) do
      armor.id = nil
      WearArmor(armor)
    end
  end

	log("[LizardArmor]", (enabled and "+" or "-").." LizardArmor")
end

function pings.LizardBag(enabled)
	if lizardTail_.Tail2.Tail3.Bag then
		lizardTail_.Tail2.Tail3.Bag:setVisible(enabled)
	end

	lizardBag_ = enabled
	
	log("[LizardBag]", (enabled and "+" or "-").." LizardBag")
end

function pings.LizardCollar(enabled)
	if lizardHead_.Collar then
		lizardHead_.Collar:setVisible(enabled)
	end

	collar_ = enabled

	log("[LizardCollar]", (enabled and "+" or "-").." Collar")
end

--Other Pings
----

function pings.Ravenous(enabled)
	ravenous_ = enabled

	log("[Ravenous]", (enabled and "+" or "-").." Ravenous")
end

function pings.HungerStare(enabled)
	hungerStare_ = enabled

	log("[HungerStare]", (enabled and "+" or "-").." HungerStare")
end


function pings.Bite()
  -- "sound" refers to your sound.ogg file
  -- player:getPos() makes it play at your current location
  sounds:playSound("sounds.lizBite2B", player:getPos())
end

function pings.Charge()
  -- "sound" refers to your sound.ogg file
  -- player:getPos() makes it play at your current location
  local options = {"sounds.lizCharge1E"}
  local ranOp = math.random(1,#options)
  sounds:playSound(options[ranOp], player:getPos())
end


--Makes an object visible when Chat is open
function pings.setChat(bool)
  --slugcat.FullBody.ComMark:setVisible(bool)
end


--==========================================================================================
-- Keybinds
--==========================================================================================

function biteSoundKeybind_.press()
  pings.Bite()
end

function chargeSoundKeybind_.press()
  pings.Charge()
end

function checkHeldItemKeybind_.press()
  PrintItemDetails()
  PrintItemRot()
end

--==========================================================================================
--Main Functions
--==========================================================================================

--entity init event, used for when the avatar entity is loaded for the first time
function events.entity_init()
  --Randomizer
  math.randomseed(world.getTime())

  --load the required from other scrips
  SquapiInit()
  SwingingPhysicsInit()
  JimmyAnimsInit()
  TailInit()

  --Run this model's init
  ModelInit()

  --Run other function's inits
  weight_.Init()
  wheel_.Init()
  ChatInit()
end

--tick event, called 20 times per second
function events.tick()
  --ChatOpenTick()
  --ShakeTick()
  ItemTick()
  ArmorTick()
  CollarTick()
  DroolTick()
  HungerStareTick()
  ManageCrouchingTick()
  GUIDTick()

  weight_.Tick()
end

--render event, called every time your avatar is rendered
--it have two arguments, "delta" and "context"
--"delta" is the percentage between the last and the next tick (as a decimal value, 0.0 to 1.0)
--"context" is a string that tells from where this render event was called (the paperdoll, gui, player render, first person)
function events.render(delta, context)
  
  RotateLegs(delta,context)
  ManualPlayerRotation(delta, context)
  ManualPlayerHeadRotationRender(delta, context)

  weight_.render(delta, context)
end

function events.post_render(delta, context)
  weight_.post_render(delta, context) 
end


function events.item_render(item, mode, pos, rot, scale, left)
   -- This checks if the player is holding a specific item. Replace 'minecraft:stone_sword' with your desired item.
   --if item.id == "minecraft:stone_sword" then
   --return scale(0.25, 0.25, 0.25)
   -- end

   local newItem= ItemRenderer(item, mode, pos, rot, scale, left)
   if newItem then
    
    return newItem
   end
end



function events.ON_PLAY_SOUND(id, pos, vol, pitch, loop, category, path)
    if not path then return end -- don't trigger if the sound was played by figura (prevent infinite loop)
    if not player:isLoaded() then return end -- don't trigger if the player isn't loaded
    local nearest, uuid = math.huge,nil -- we will find the nearest player to the sound location
    for _, plr in pairs(world.getPlayers()) do
        local dist = (plr:getPos() - pos):length()
        if dist < nearest then nearest,uuid = dist,plr:getUUID() end
    end
    if player:getUUID() ~= uuid or nearest > 0.8 then return end -- don't trigger if the sound isn't near you

    --Replacing sounds here
    if id:find("shield") then
        local distance = (player:getPos() - pos):length()
        --if distance <= 0.8 then
        local randomPitch = 1.4 + math.random() * 0.2
        --sounds:playSound("minecraft:item.chain.break", player:getPos(), 1.0, randomPitch)
        sounds:playSound("minecraft:block.spawner.break", player:getPos(), 1.0, randomPitch)
        return true -- Cancel vanilla shield clink
        --end
    end

    ---------------------------------------------------------
    -- actual replacing starts here, feel free to edit below:
    --if id:find(".step") then                                                  -- if sound id contains ".step"
    --    sounds:playSound("minecraft:entity.iron_golem.step", pos, vol, pitch) -- play a custom sound
    --    return true                                                           -- stop the actual step sound
    --end
end


-- Backbone of the commands system, don't edit this
function events.chat_send_message(msg)
  --return chat_.HandleMessage(msg)
  return msg
end

-- This event runs automatically when you are struck by a source of damage
function events.damage(amount, source, type)
  --BlockingSoundDamage(amount, source, type)
end

