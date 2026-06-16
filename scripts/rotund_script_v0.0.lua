--==========================================================================================
-- Rotund
-- Stuckage script by WilloWisp
--==========================================================================================

---@diagnostic disable: undefined-field

--Version
local ro_ = {}
ro_.version_ = "0.0.0"
ro_.size_ = 1

--Config
local modelConfig_ = require("scripts.config")
local lizard_ = modelConfig_.lizard
local lizardFullbody_ = modelConfig_.lizardFullbody
local lizardBody_ = modelConfig_.lizardBody
local lizardLegs_ = modelConfig_.lizardLegs
local lizardTail_ = modelConfig_.lizardTail
local lizardHead_ = modelConfig_.lizardHead

-- Functionality
----
local pehkui_ = require('scripts.api.Pehkui')

--Rest of the Vars
-----
local stuckTimerBase_ = 10
local stuckTimer_ = stuckTimerBase_
local mySpeedMult_ = 1
local myJumpMult_ = 1
local myWidthMult_ = 1
local jumpMod_ = 1 --NOT TO BE CONFUSED WITH myJumpMult_. THIS ONES EITHER 1 OR 0 DEPENDING ON IF STUCK 
local lastJumpMod_ = 1
local moveMod_ = 1 --SAME, 0 OR 1
local lastMoveMod_ = 1
local lastSqueezed_ = false
local lastWeightStage_ = -1 --TO FORCE A WEIGHT CHANGE ON LOAD
local squeezeLoop_ = nil
local struggleFlag_ = false --DELAYED START TO STRUGGLE WHILE STUCK
local struggleTimer_ = 0 --HOW MANY FRAMES TO STRUGGLE
local myFoodPoints_ = 0
local lateUpdateFlag_ = false
local crouchSqzTick_ = 0
local crouchSqz_
local lastCrouchSqz_


local syncPingTimer_ = 0 -- Used to sync the weight variables with players that joined a server and haven't gotten pinged yet
-- Eating variables
local prevFood_
local prevSaturation_


--KEYBINDS
local struggleKey_ = keybinds:newKeybind("Struggle", keybinds:getVanillaKey("key.jump"))




function updateWeightGraphics(stage)
	
	--EVERYTHING IN HERE IS FOR GRAPHICAL CHANGES TO YOUR MODEL.
	--EVERYONES MODEL RESIZE SCRIPT WILL BE DIFFERENT. BUT IF YOU ALREADY HANDLE YOUR RESIZING ELSE WHERE YOU CAN JUST DELETE EVERYTHING IN THIS FUNCTION.
	
	--[[
	slugcatUpperBody.Body.Main.Gourmand:setVisible(true) --ASSUME THIS IS TRUE UNLESS TOLD OTHERWISE
	
	if stage <= 0 then
	
		slugcatUpperBody.Body.Main.Gourmand:setVisible(false)
		slugcatUpperBody.Body.Main:setScale(1.0, 1, 1.0)
		slugcatUpperBody.Body.Main.Gourmand:setScale(1.0, 1.0, 1.0)
		slugcatUpperBody.Body.Chestplate:setScale(1.0, 1.0, 1.0)
		slugcatUpperBody.Body.Main.Bottom:setScale(1,1,1) --UNDERSIDE
		
		slugcatUpperBody.head.Main.Base:setScale(1.0, 1, 1) --HEAD
		slugcatUpperBody.head.Main.Gourmand.Snout:setScale(0.5, 0.5, 0.5) --NECK ROLL
		
		slugcatLowerBody.LeftLeg:setScale(1.0, 1, 1.0)
		slugcatLowerBody.RightLeg:setScale(1.0, 1, 1.0)
		-- slugcatLowerBody.LeftLeg.Main.Base.Upper.Main:setScale(1.7, 1, 1) --NAH JUST MAKE THE MODELS THIGH BIGGER
		slugcatLowerBody.LeftLeg:setPos(-0.5, 0, 0)
		slugcatLowerBody.RightLeg:setPos(0.5, 0, 0)
		
		slugcatUpperBody.Arms:setPos(0.0, 0, 0) --RIGHT ARM IS STUCK! TRY AND FIX THAT...
		slugcatUpperBody.Arms.LeftArm:setPos(0, -0.25, 0)
		-- slugcatUpperBody.Arms.RightArm:setPos(20, 20, 0) --WON'T MOVE FOR SOME REASON...
		slugcatUpperBody.Arms.LeftArm:setRot(0, 0, 0)
		slugcatUpperBody.Arms.RightArm:setRot(0, 0, 0)
		
		slugcatUpperBody.Arms.LeftArm:setScale(1.0, 1.0, 1)
		slugcatUpperBody.Arms.RightArm:setScale(1.0, 1.0, 1)
		
		slugcatUpperBody.Body.Tail1:setPos(0, 0, 0.0)
		slugcatUpperBody.Body.Tail1:setScale(1.0, 1.0, 1.0)
		slugcatUpperBody.Body.Tail1.Tail2:setScale(1, 1, 1)
		slugcatUpperBody.Body.Tail1.Tail2.Tail3:setScale(1, 1, 1)
		
	elseif stage == 1 then
		
		slugcatUpperBody.Body.Main:setScale(1.2, 1, 1.3)
		slugcatUpperBody.Body.Main.Gourmand:setScale(1.0, 1.0, 1.2)
		slugcatUpperBody.Body.Chestplate:setScale(1.2, 1.0, 1.4)
		slugcatUpperBody.Body.Main.Bottom:setScale(1,1.5,1) --UNDERSIDE
		
		slugcatUpperBody.head.Main.Base:setScale(1.0, 1, 1) --HEAD
		slugcatUpperBody.head.Main.Gourmand.Snout:setScale(0.5, 0.5, 0.5) --NECK ROLL
		
		slugcatLowerBody.LeftLeg:setScale(1.35, 1, 1.0)
		slugcatLowerBody.RightLeg:setScale(1.35, 1, 1.0)
		slugcatLowerBody.LeftLeg:setPos(-1.0, 0, 0)
		slugcatLowerBody.RightLeg:setPos(1.0, 0, 0)
		
		slugcatUpperBody.Arms:setPos(0.5, 0, 0)
		slugcatUpperBody.Arms.LeftArm:setPos(-1, -0.25, 0)
		slugcatUpperBody.Arms.LeftArm:setRot(0, 0, -15)
		slugcatUpperBody.Arms.RightArm:setRot(0, 0, 15)
		
		slugcatUpperBody.Arms.LeftArm:setScale(1.1, 1.1, 1)
		slugcatUpperBody.Arms.RightArm:setScale(1.1, 1.1, 1)
		
		slugcatUpperBody.Body.Tail1:setPos(0, 0, 1.0)
		slugcatUpperBody.Body.Tail1:setScale(1.25, 1.25, 1.0)
		slugcatUpperBody.Body.Tail1.Tail2:setScale(0.9, 0.9, 1)
		slugcatUpperBody.Body.Tail1.Tail2.Tail3:setScale(0.9, 0.9, 1)
		
	elseif stage == 2 then
		
		slugcatUpperBody.Body.Main:setScale(1.2, 1, 1.2)
		slugcatUpperBody.Body.Main.Gourmand:setScale(1.2, 1.0, 1.4)
		slugcatUpperBody.Body.Chestplate:setScale(1.44, 1.0, 1.4)
		slugcatUpperBody.Body.Main.Bottom:setScale(1,2,1) --UNDERSIDE
		
		slugcatUpperBody.head.Main.Base:setScale(1.0, 1, 1) --HEAD
		slugcatUpperBody.head.Main.Gourmand.Snout:setScale(1.0, 0.5, 1.0) --NECK ROLL
		
		slugcatLowerBody.LeftLeg:setScale(1.6, 1, 1.25)
		slugcatLowerBody.RightLeg:setScale(1.6, 1, 1.25)
		slugcatLowerBody.LeftLeg:setPos(-1.5, 0, 0)
		slugcatLowerBody.RightLeg:setPos(1.5, 0, 0)
		
		slugcatUpperBody.Arms:setPos(1, 1.0, 0)
		slugcatUpperBody.Arms.LeftArm:setPos(-2, -0.75, 0)
		slugcatUpperBody.Arms.LeftArm:setRot(0, 0, -30)
		slugcatUpperBody.Arms.RightArm:setRot(0, 0, 30)
		
		slugcatUpperBody.Arms.LeftArm:setScale(1.25, 1.25, 1)
		slugcatUpperBody.Arms.RightArm:setScale(1.25, 1.25, 1)
		
		slugcatUpperBody.Body.Tail1:setPos(0, 0, 2.0)
		slugcatUpperBody.Body.Tail1:setScale(1.5, 1.5, 1.1)
		slugcatUpperBody.Body.Tail1.Tail2:setScale(0.8, 0.8, 1)
		slugcatUpperBody.Body.Tail1.Tail2.Tail3:setScale(0.8, 0.8, 1)
		
	elseif stage == 3 then
		
		slugcatUpperBody.Body.Main:setScale(2.0, 1, 2.0)
		slugcatUpperBody.Body.Main.Gourmand:setScale(1.0, 1.0, 1.1)
		slugcatUpperBody.Body.Chestplate:setScale(2.0, 1.0, 1.8)
		slugcatUpperBody.Body.Main.Bottom:setScale(1,3,1) --UNDERSIDE
		
		slugcatUpperBody.head.Main.Base:setScale(1.1, 1, 1) --HEAD
		slugcatUpperBody.head.Main.Gourmand.Snout:setScale(1.4, 1.0, 1.4) --NECK ROLL
		
		slugcatLowerBody.LeftLeg:setScale(2, 1, 1.5)
		slugcatLowerBody.RightLeg:setScale(2, 1, 1.5)
		slugcatLowerBody.LeftLeg:setPos(-2, 0, 0)
		slugcatLowerBody.RightLeg:setPos(2, 0, 0)
		
		slugcatUpperBody.Arms:setPos(2, 1.0, 0)
		slugcatUpperBody.Arms.LeftArm:setPos(-4, -0.75, 0)
		slugcatUpperBody.Arms.LeftArm:setRot(0, 0, -45)
		slugcatUpperBody.Arms.RightArm:setRot(0, 0, 45)
		
		slugcatUpperBody.Arms.LeftArm:setScale(1.5, 1.5, 1)
		slugcatUpperBody.Arms.RightArm:setScale(1.5, 1.5, 1)
		
		slugcatUpperBody.Body.Tail1:setPos(0, 0, 2.5)
		slugcatUpperBody.Body.Tail1:setScale(1.8, 1.8, 1.2)
		slugcatUpperBody.Body.Tail1.Tail2:setScale(0.8, 0.8, 1)
		slugcatUpperBody.Body.Tail1.Tail2.Tail3:setScale(0.8, 0.8, 1)
		
	elseif stage == 4 then
		
		slugcatUpperBody.Body.Main:setScale(2.5, 1, 2.5)
		slugcatUpperBody.Body.Main.Gourmand:setScale(1.0, 1.0, 1.1)
		slugcatUpperBody.Body.Chestplate:setScale(2.2, 1.0, 2)
		slugcatUpperBody.Body.Main.Bottom:setScale(1,3,1) --UNDERSIDE
		
		slugcatUpperBody.head.Main.Base:setScale(1.2, 1, 1) --HEAD
		slugcatUpperBody.head.Main.Gourmand.Snout:setScale(1.8, 1.2, 1.8) --NECK ROLL
		
		slugcatLowerBody.LeftLeg:setScale(2, 1, 1.5)
		slugcatLowerBody.RightLeg:setScale(2, 1, 1.5)
		slugcatLowerBody.LeftLeg:setPos(-2, 0, 0)
		slugcatLowerBody.RightLeg:setPos(2, 0, 0)
		
		slugcatUpperBody.Arms:setPos(2, 2.25, 0)
		slugcatUpperBody.Arms.LeftArm:setPos(-4, -1, 0)
		slugcatUpperBody.Arms.LeftArm:setRot(0, 0, -65)
		slugcatUpperBody.Arms.RightArm:setRot(0, 0, 65)
		
		slugcatUpperBody.Arms.LeftArm:setScale(1.5, 1.5, 1)
		slugcatUpperBody.Arms.RightArm:setScale(1.5, 1.5, 1)
		
		slugcatUpperBody.Body.Tail1:setPos(0, 0, 3)
		slugcatUpperBody.Body.Tail1:setScale(2, 2, 1.2)
		slugcatUpperBody.Body.Tail1.Tail2:setScale(0.8, 0.8, 1)
		slugcatUpperBody.Body.Tail1.Tail2.Tail3:setScale(0.8, 0.8, 1)
	elseif stage == 5 then
		
		slugcatUpperBody.Body.Main:setScale(2.5, 1, 2.5)
		slugcatUpperBody.Body.Main.Gourmand:setScale(1.0, 1.0, 1.1)
		slugcatUpperBody.Body.Chestplate:setScale(2.2, 1.0, 2)
		slugcatUpperBody.Body.Main.Bottom:setScale(1,3,1) --UNDERSIDE
		
		slugcatUpperBody.head.Main.Base:setScale(1.2, 1, 1) --HEAD
		slugcatUpperBody.head.Main.Gourmand.Snout:setScale(1.8, 1.2, 1.8) --NECK ROLL
		
		slugcatLowerBody.LeftLeg:setScale(2, 1, 1.5)
		slugcatLowerBody.RightLeg:setScale(2, 1, 1.5)
		slugcatLowerBody.LeftLeg:setPos(-2, 0, 0)
		slugcatLowerBody.RightLeg:setPos(2, 0, 0)
		
		slugcatUpperBody.Arms:setPos(2, 2.25, 0)
		slugcatUpperBody.Arms.LeftArm:setPos(-4, -1, 0)
		slugcatUpperBody.Arms.LeftArm:setRot(0, 0, -65)
		slugcatUpperBody.Arms.RightArm:setRot(0, 0, 65)
		
		slugcatUpperBody.Arms.LeftArm:setScale(1.5, 1.5, 1)
		slugcatUpperBody.Arms.RightArm:setScale(1.5, 1.5, 1)
		
		slugcatUpperBody.Body.Tail1:setPos(0, 0, 3)
		slugcatUpperBody.Body.Tail1:setScale(2, 2, 1.2)
		slugcatUpperBody.Body.Tail1.Tail2:setScale(0.8, 0.8, 1)
		slugcatUpperBody.Body.Tail1.Tail2.Tail3:setScale(0.8, 0.8, 1)
		
	end
	]]--
	
end


function struggleCheck()
	if weightStage() >= 3 and isNarrowSqueezed() then
		if player:isMoving() == false then 
			--stuckTimer_ = 10 --WE NEED TO DELAY THIS A TICK OTHERWISE WE'LL JUMP
			struggleFlag_ = true
			pings.strugglePing() --DOES THIS *NEED* TO BE A PING?...
		else
			--OKAY OKAY. WE CAN LET THEM JUMP A LITTLE BIT, AS A TREAT. BUT ONLY IF THEY DOUBLE TAP JUMP.
			if struggleTimer_ > 0 then 
				-- stuckTimer_ = 2 --WHY IS IT SUDDENLY SO HARD TO JUMP NOW LOL...
				jumpMod_ = 1
			end
		end
	end
end






--FIRST CALL THE ONE THAT RUNS LOCALLY
function setWeight()
	-- if (host:isHost()) then --DO WE NEED THIS PART?...
	pings.setWeight(weightStage(), isNarrowSqueezed(), moveMod_, jumpMod_, crouchSqz_) --THEN RUN THE PING THAT RUNS ON THE SERVER
end




function updateWeightStats(stage, squeezed, mm, jm, crouchSqz) --OKAY WE NEED TO TAKE OUR SQUEEZED BOOL INTO ACCOUNT AND 'ONLY' RUN MOVEMENT SCALING IN HERE TO AVOID SPEED DESYNCS AND SERVER FALL DAMAGE
	-- print("UPDATE WS " .. tostring(stage)) --tostring(player:getSaturation())
	
	local rst = false --RE-SIZE TOGGLE. 
	
	if stage <= 0 then
		-- pehkui_.setScale("pehkui:motion", 1)
		mySpeedMult_ = 1
		myWidthMult_ = (1)
	elseif stage == 1 then
		--JUST A BIT SLOW
		mySpeedMult_ = 0.9
		myWidthMult_ = ((crouchSqz and 1.0) or 1.1)
	elseif stage == 2 then
		-- SQUEEZE
		mySpeedMult_ = 0.85
		myWidthMult_ = ((crouchSqz and 1.0) or (squeezed and rst and 1.28) or 1) --JUST BARELY FITS DOORS
	elseif stage == 3 then
		--SQUEEZE AND GET STUCK
		-- pehkui_.setScale("pehkui:motion", 0) --??? WHY DOES RUNNING THIS ON-TICK MAKE ME NOT HALT???
		mySpeedMult_ = 0.8
		myWidthMult_ = ((crouchSqz and 1.0) or (squeezed and rst and 1.62) or 1.28) --TOO WIDE FOR SINGLE DOORS
	elseif stage == 4 then
		--INSTANT STUCK
		mySpeedMult_ = 0.75
		myWidthMult_ = ((crouchSqz and 1.0) or (squeezed and rst and 1.62) or 1.28)
	elseif stage == 5 then
		mySpeedMult_ = 0.5
		-- myWidthMult_ = ((crouchSqz and 1.28) or (squeezed and rst and 1.62) or 1.28) --TOO WIDE FOR 1X WIDE GAPS
		myWidthMult_ = ((crouchSqz and 2) or (squeezed and rst and 2.6) or 2.6)
	end
	
	--GET SLIGHTLY LOWER FOR CROUCHSQUEEZE
	pehkui_.setScale("pehkui:hitbox_height", (crouchSqz and 0.6) or 1, false)
	pehkui_.setScale("pehkui:eye_height", (crouchSqz and 0.6) or 1, false)
	
	--REDUCE SPEED VALUES WHEN SQUEEZED
	if squeezed then
		if weightStage() >= 2 then
			-- mySpeedMult_ = 0.3
			mySpeedMult_ = mySpeedMult_ * 0.4
		end
	end
	
	
	pehkui_.setScale("pehkui:motion", mySpeedMult_ * mm, false)
	pehkui_.setScale("pehkui:hitbox_width", myWidthMult_, false)
	
	--WTF IS IT DOING TO OUR GRAVITY?? FIX THAT
	local speedlerp = (math.lerp(mySpeedMult_, 1, 0.4))
	myJumpMult_ = (1/speedlerp)
	pehkui_.setScale("pehkui:jump_height", myJumpMult_ * jm, false)
	pehkui_.setScale("pehkui:step_height", 1/mySpeedMult_, false)
	
	--IF WE'RE IMMOBILE MINING SPEED IS BROKE FOR SOME REASON. UNDO THAT.
	if mm == 0 then
		pehkui_.setScale("pehkui:mining_speed", 6, false)
	else
		pehkui_.setScale("pehkui:mining_speed", 1, false)
	end
	
	updateWeightGraphics(stage)
	
	lastWeightStage_ = weightStage()
	lastSqueezed_ = squeezed
	lastJumpMod_ = jm
	lastMoveMod_ = mm
	lateUpdateFlag_ = false
end





--DETECT IF THERE ARE BLOCKS AT BOTH SIDES OF EITHER AXIS
function isNarrowSqueezed()
	
	local distCheck = 0.7 * myWidthMult_
	-- local myPos = player:getPos() --OKAY DON'T USE :add ON A LOCAL VAR LIKE THIS OR IT WILL MESS UP THE REST OF THE FORMULA
	local xSqueezed = (world.getBlockState(player:getPos():add(-distCheck, 0.6, 0)):isSolidBlock()) and (world.getBlockState(player:getPos():add(distCheck, 0.6, 0)):isSolidBlock())
	local zSqueezed = (world.getBlockState(player:getPos():add(0, 0.6, distCheck)):isSolidBlock()) and (world.getBlockState(player:getPos():add(0, 0.6, -distCheck)):isSolidBlock())
	if xSqueezed or zSqueezed then
		return true
	else
		return false
	end
end

--DETECT IF THERE'S A BLOCK DIRECTLY ABOVE OUR HEAD.
function canUncrouch()
	local distCheck = 0.65 * myWidthMult_
	return world.getBlockState(player:getPos():add(distCheck, 1.1, distCheck)):isSolidBlock() == false
		and world.getBlockState(player:getPos():add(-distCheck, 1.1, distCheck)):isSolidBlock() == false
		and world.getBlockState(player:getPos():add(distCheck, 1.1, -distCheck)):isSolidBlock() == false
		and world.getBlockState(player:getPos():add(-distCheck, 1.1, -distCheck)):isSolidBlock() == false
end

function weightStage()
	--if true then return 3 end --UNCOMMENT THIS TO FORCE SPECIFIC WEIGHT STAGES FOR TESTING
	
	local foodPoints = myFoodPoints_
	--UNCOMMENT THE LINE BELOW TO USE A SIMPLER WEIGHT SYSTEM THAT JUST LOOKS AT YOUR COMBINED FOOD + SATURATION VALUES (MAX 20 POINTS EACH)
	--foodPoints = player:getFood() + player:getSaturation() 
	
	if foodPoints >= 400 then
		return 5
	elseif foodPoints >= 300 then
		return 4
	elseif foodPoints >= 120 then
		return 3
	elseif foodPoints >= 100 then
		return 2
	elseif foodPoints >= 50 then
		return 1
	else
		return 0
	end
end




--==========================================================================================
--Pings
--==========================================================================================

function pings.setWeight(amount, squeezed, mm, jm, crouchSqz)
    -- print("pings.setWeight " .. tostring(amount) .. " " .. tostring(squeezed) .. " " .. tostring(mm) .. " " .. tostring(jm))
	updateWeightStats(amount, squeezed, mm, jm, crouchSqz)
end




function pings.strugglePing()
	-- print("pings.strugglePing ")
	-- struggleFlag_ = true
end




function pings.squeezeSfxPing(command, pos)
    -- print("pings.squeezeSfxPing " .. command)
	if command == "start" then
		squeezeLoop_ = sounds:playSound("sounds.squeezesLOOP1", pos, 1, 1, true) --(NAME, POS, VOL, PITCH, LOOP)
		--ALSO SHOW THE > < EYES UNTIL THE SOUND STOPS. NOT SURE ANY OTHER "GOOD" WAYS TO DO THIS...
		-- slugcatUpperBody.head.Main.Eyes.Base:setVisible(false) --SLUGCAT SPECIFIC
		-- slugcatUpperBody.head.Main.Eyes.Squint:setVisible(true) --SLUGCAT SPECIFIC
	elseif command == "stop" then
		sounds:stopSound("sounds.squeezesLOOP1")
		-- slugcatUpperBody.head.Main.Eyes.Base:setVisible(true) --SLUGCAT SPECIFIC
		-- slugcatUpperBody.head.Main.Eyes.Squint:setVisible(false) --SLUGCAT SPECIFIC
	elseif command == "pause" and squeezeLoop_ ~= nil then
		squeezeLoop_:pause()
	elseif command == "play" and squeezeLoop_ ~= nil then
		squeezeLoop_:play()
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

--RUNS ON STARTUP AND RELOAD
function ro_.Init()
  prevFood_ = player:getFood()
	prevSaturation_ = player:getSaturation()
	myFoodPoints_ = player:getFood() + player:getSaturation()
	
	setWeight()
	
	-- SLUGCAT SPECIFIC THINGS
	-- pehkui_.setScale("pehkui:hitbox_height", 0.6)
	-- pehkui_.setScale("pehkui:eye_height", 0.6)
	-------------
end



function ro_.Tick()
	
	--RESET OUR FOOD AND WEIGHT LEVELS ON DEATH
	if player:isAlive() == false then
		prevFood_ = 20
		prevSaturation_ = 5
		myFoodPoints_ = 0
		return end --AND THEN SKIP EVERYTHING UNDER THIS
	
	
	if struggleTimer_ > 0 then
		struggleTimer_ = struggleTimer_ - 1
	end
	
	--ALLOW US TO SHRINK OUR HITBOX SLIGHTLY IF WE CROUCH LONG ENOUGH. OR CLIMB LADDERS...
	lastCrouchSqz_ = crouchSqz_
	if player:getPose() == "CROUCHING" or (player:isClimbing() and world.getBlockState(player:getPos():add(0, -0.1, 0)):isSolidBlock() == false) then
		crouchSqzTick_ = crouchSqzTick_ + 1
		if crouchSqzTick_ >= 15 then
			crouchSqz_ = true
		end
	elseif crouchSqz_ and canUncrouch() then
		crouchSqz_ = false
		crouchSqzTick_ = 0
	end
	
	
	
	----- WEIGHT GAIN SCRIPT ---------
	syncPingTimer_ = syncPingTimer_ + 1
    if (syncPingTimer_ >= 80) then
        setWeight()
        syncPingTimer_ = 0
    end
	
	-- Gain weight through food consumption
    if (player:getFood() > prevFood_ or player:getSaturation() > prevSaturation_) or 
		((player:getFood() < prevFood_ and player:getFood() < 20) or (player:getSaturation() < prevSaturation_ and player:getSaturation() < 20)) then --MODIFIED TO ACCOUNT FOR WEIGHT LOSS TOO
        local amount = player:getFood() - prevFood_ + player:getSaturation() - prevSaturation_ -- Get number of points increased
		myFoodPoints_ = myFoodPoints_ + amount
		--print("FOOD POINTS: " .. tostring(myFoodPoints_)) --tostring(player:getSaturation())
    end
    prevFood_ = player:getFood()
    prevSaturation_ = player:getSaturation()
	----------------------------------
	
	
	if lastSqueezed_ ~= isNarrowSqueezed() then
		lateUpdateFlag_ = true --OKAY THIS WAS GONNA BOTHER ME. AVOID RUNNING THE UPDATE 2 TICKS IN A ROW WHEN CHANGING SQUEEZE STATES
	end
	
	if lastWeightStage_ ~= weightStage() or lastJumpMod_ ~= jumpMod_ or lastMoveMod_ ~= moveMod_ or lastCrouchSqz_ ~= crouchSqz_ then
		-- updateWeightStats(myFoodPoints_)
		setWeight()
	end
	
	
	if isNarrowSqueezed() then
		
		if weightStage() >= 3 then
			-- pehkui_.setScale("pehkui:motion", 0.2) --OKAY NO MORE MODIFYING pehkui VALUES OUTSIDE OF THE PINGED updateWeightStats!!! THESE NEED TO ALL UPDATE AT THE SAME TIME ON THE SERVER
			--SQUEEZE SOUND
			if stuckTimer_ == stuckTimerBase_ then
				pings.squeezeSfxPing("start", player:getPos())
			end
			
			--ONLY PLAY THE SQUEEZE SOUND WHILE MOVING
			if squeezeLoop_ ~= nil then
				if player:isMoving() == false then	
					if squeezeLoop_:isPlaying() then
						pings.squeezeSfxPing("pause", nil)
					end
				elseif squeezeLoop_:isPlaying() == false then
					pings.squeezeSfxPing("play", nil)
				end
			end
			
			--ALLOW MOVEMENT BRIEFLY BEFORE GETTING STUCK
			stuckTimer_ = stuckTimer_ - 1
			if (stuckTimer_ <= 0 or weightStage() >= 4) and struggleTimer_ <= 0 then --STUCK. UNTIL THE TIMER RESETS WHEN WE AREN'T SQUEEZED
				-- pehkui_.setScale("pehkui:motion", 0) --THIS ACTUALLY DOESN'T STOP US RIGHT AWAY, WE MAINTAIN SOME MOMENTUM I GUESS
				moveMod_ = 0
				if player:isMoving() == false then
					-- pehkui_.setScale("pehkui:jump_height", 0) --STOP JUMPING UNTIL WE SQUEEZE FREE
					jumpMod_ = 0
				end
			end
		end
	else
		moveMod_ = 1 -- pehkui_.setScale("pehkui:motion", mySpeedMult_)
		jumpMod_ = 1 -- pehkui_.setScale("pehkui:jump_height", myJumpMult_)
		stuckTimer_ = stuckTimerBase_
		if squeezeLoop_ ~= nil then
			pings.squeezeSfxPing("stop", nil)
			squeezeLoop_ = nil
		end
	end
	
	
	--OKAY NOW RUN A SQUEEZE RELATED WEIGHT UPDATE, IF WE DIDN'T ALREADY
	if lateUpdateFlag_ then
		setWeight()
	end
	
	
	if struggleFlag_ then
		struggleTimer_ = 7 --MODIFY THIS TO DETERMINE HOW LONG YOUR STRUGGLE BOOSTS LAST
		moveMod_ = 1
		struggleFlag_ = false
	end
end






return ro_