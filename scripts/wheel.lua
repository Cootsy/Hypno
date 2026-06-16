--==========================================================================================
-- This is a side script that manages extended wheel controls
--==========================================================================================
local wh_ = {}
wh_.version_ = "1.0.4"

--Config
local modelConfig_ = require("scripts.config")
local lizard_ = modelConfig_.lizard
local lizardFullbody_ = modelConfig_.lizardFullbody
local lizardBody_ = modelConfig_.lizardBody
local lizardLegs_ = modelConfig_.lizardLegs
local lizardTail_ = modelConfig_.lizardTail
local lizardHead_ = modelConfig_.lizardHead

--Pages
local menuPage_ = action_wheel:newPage()

local weightPage_ = action_wheel:newPage()
local weightNumbersPage_ = action_wheel:newPage()

local modelPage_ = action_wheel:newPage()
local eyesPage_ = action_wheel:newPage()
local itemsPage_ = action_wheel:newPage()
local armorPage_ = action_wheel:newPage()
local scalePage_ = action_wheel:newPage()
local otherPage_ = action_wheel:newPage()

local prevPages_ = {}

--==========================================================================================
--Page Management Functions
--==========================================================================================

local function GetPreviousPage()
	return table.remove(prevPages_)
end
local function SetPreviousPage(page)
	table.insert(prevPages_,page)
end

--==========================================================================================
--Action Setter
--==========================================================================================

local function SetActions()
  --- MENU ---
	--Transition to Weight Page
	menuPage_:newAction()
	:title("Weight Page")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 32, 96, 32, 32)
	:onLeftClick(function()
	  SetPreviousPage(action_wheel:getCurrentPage())
  	action_wheel:setPage(weightPage_)
  end)
	:setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))
	--Transition to Model Page
	menuPage_:newAction()
	:title("Model Page")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 0, 96, 32, 32)
	:onLeftClick(function()
		SetPreviousPage(action_wheel:getCurrentPage())
		action_wheel:setPage(modelPage_)
	end)
	:setColor(vectors.hexToRGB("#2c43b7"))
	:setHoverColor(vectors.hexToRGB("#95a1db"))

	

	--- MODELPAGE ---
	--Go back a page
	modelPage_:newAction()
	:title("Back")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 64, 64, 32, 32)
  :onLeftClick(function()
		action_wheel:setPage(GetPreviousPage())
  end)
	:setColor(vectors.hexToRGB("#b82934"))
	:setHoverColor(vectors.hexToRGB("#db9499"))
	--Transition to Eyes Page
	modelPage_:newAction()
	:title("Eyes Page")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 128, 64, 32, 32)
	:onLeftClick(function()
		SetPreviousPage(action_wheel:getCurrentPage())
		action_wheel:setPage(eyesPage_) 
	end)
	:setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))
	--Transition to Items Page
	modelPage_:newAction()
	:title("Items Page")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 160, 0, 32, 32)
	:onLeftClick(function()
		SetPreviousPage(action_wheel:getCurrentPage())
		action_wheel:setPage(itemsPage_) 
	end)
	:setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))
	--Transition to Scale Page
	modelPage_:newAction()
	:title("Scale Page")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 64, 96, 32, 32)
	:onLeftClick(function() 
		SetPreviousPage(action_wheel:getCurrentPage())
		action_wheel:setPage(scalePage_) 
	end)
	:setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))
	--Transition to Misc Page
	modelPage_:newAction()
	:title("Other Page")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 64, 32, 32, 32)
	:onLeftClick(function() 
		SetPreviousPage(action_wheel:getCurrentPage())
		action_wheel:setPage(otherPage_) 
	end)
	:setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))

	--- EYES ---
	--Go back a page
	eyesPage_:newAction()
	:title("Back")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 64, 64, 32, 32)
  :onLeftClick(function()
		action_wheel:setPage(GetPreviousPage())
  end)
	:setColor(vectors.hexToRGB("#b82934"))
	:setHoverColor(vectors.hexToRGB("#db9499"))
	--Toggle Regular Eyes
	eyesPage_:newAction()
	:title("Regular Eyes")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 96, 96, 32, 32)
	:toggled(false)
	:onToggle(pings.RegularEyes)
	:setColor(vectors.hexToRGB("#2c43b7"))
	:setHoverColor(vectors.hexToRGB("#95a1db"))
	:setToggleColor(vectors.hexToRGB("#57cee8"))
	--Toggle Emmissive Eyes
	eyesPage_:newAction()
	:title("Emissive")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 192, 0, 32, 32)
	:toggled(false)
	:onToggle(pings.EmmissiveEyes)
	:setColor(vectors.hexToRGB("#2c43b7"))
	:setHoverColor(vectors.hexToRGB("#95a1db"))
	:setToggleColor(vectors.hexToRGB("#57cee8"))
	--Toggle Effects on eyes Eyes
	eyesPage_:newAction()
	:title("Effects")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 192, 0, 32, 32)
	:toggled(false)
	:onToggle(pings.EffectsEyes)
	:setColor(vectors.hexToRGB("#2c43b7"))
	:setHoverColor(vectors.hexToRGB("#95a1db"))
	:setToggleColor(vectors.hexToRGB("#57cee8"))

	--- SCALE ---
	--Go back a page
	scalePage_:newAction()
	:title("Back")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 64, 64, 32, 32)
  :onLeftClick(function()
		action_wheel:setPage(GetPreviousPage())
  end)
	:setColor(vectors.hexToRGB("#b82934"))
	:setHoverColor(vectors.hexToRGB("#db9499"))
	--On Click Decrease Scale
	scalePage_:newAction()
	:title("Decrease Scale")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 0, 0, 32, 32)
	:onLeftClick(function() pings.ModelScaler(-1) end)
	:setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))
	--On Click Increase Scale
	scalePage_:newAction()
  :title("Increase Scale")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 32, 32, 32, 32)
	:onLeftClick(function() pings.ModelScaler(1) end)
	:setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))
	--On Click Set to Default Scale
	scalePage_:newAction()
  :title("Default Scale")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 96, 32, 32, 32)
	:onLeftClick(function() pings.ModelScaler(0) end)
	:setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))
	--Toggle looking through model height
	scalePage_:newAction()
	:title("Eye Height")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 128, 0, 32, 32)
	:toggled(false)
	:onToggle(pings.EyeHeight)
	:setColor(vectors.hexToRGB("#2c43b7"))
	:setHoverColor(vectors.hexToRGB("#95a1db"))
	:setToggleColor(vectors.hexToRGB("#57cee8"))

	--- Items ---
	--Go back a page
	itemsPage_:newAction()
	:title("Back")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 64, 64, 32, 32)
  :onLeftClick(function()
		action_wheel:setPage(GetPreviousPage())
  end)
	:setColor(vectors.hexToRGB("#b82934"))
	:setHoverColor(vectors.hexToRGB("#db9499"))
	--Transition to Armor Page
	itemsPage_:newAction()
	:title("Armor Page")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 128, 64, 32, 32)
	:onLeftClick(function()
		SetPreviousPage(action_wheel:getCurrentPage())
		action_wheel:setPage(armorPage_) 
	end)
	:setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))
	--Toggle whether using explosive spear
	itemsPage_:newAction()
  :title("Explosive Spear")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 0, 32, 32, 32)
	:toggled(false)
	:onToggle(pings.spear)
	:setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))
	:setToggleColor(vectors.hexToRGB("#722dbd"))

	--- Armor ---
	--Go back a page
	armorPage_:newAction()
	:title("Back")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 64, 64, 32, 32)
  :onLeftClick(function()
		action_wheel:setPage(GetPreviousPage())
  end)
	:setColor(vectors.hexToRGB("#b82934"))
	:setHoverColor(vectors.hexToRGB("#db9499"))
	--Toggle whether using armor models
	armorPage_:newAction()
  :title("Lizard Armor")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 0, 32, 32, 32)
	:toggled(false)
	:onToggle(pings.LizardArmor)
	:setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))
	:setToggleColor(vectors.hexToRGB("#722dbd")) 
	--Toggle whether using the decorative bag
	armorPage_:newAction()
  :title("Lizard Bag")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 64, 32, 32, 32)
	:toggled(false)
	:onToggle(pings.LizardBag)
	:setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))
	:setToggleColor(vectors.hexToRGB("#722dbd"))
	--Toggle whether using the collar
	armorPage_:newAction()
  :title("Lizard Collar")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 96, 32, 32, 32)
	:toggled(false)
	:onToggle(pings.LizardCollar)
	:setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))
	:setToggleColor(vectors.hexToRGB("#722dbd"))


	--- Other ---
	--Go back a page
	otherPage_:newAction()
	:title("Back")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 64, 64, 32, 32)
  :onLeftClick(function()
		action_wheel:setPage(GetPreviousPage())
  end)
	:setColor(vectors.hexToRGB("#b82934"))
	:setHoverColor(vectors.hexToRGB("#db9499"))
	--Toggle whether using the Ravenous effect
	otherPage_:newAction()
  :title("Ravenous")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 96, 32, 32, 32)
	:toggled(false)
	:onToggle(pings.Ravenous)
	:setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))
	:setToggleColor(vectors.hexToRGB("#722dbd"))
	--Toggle whether using the Hunger Stare effect
	otherPage_:newAction()
  :title("Hunger Stare")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 0, 32, 32, 32)
	:toggled(false)
	:onToggle(pings.HungerStare)
	:setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))
	:setToggleColor(vectors.hexToRGB("#722dbd"))



	--- WEIGHT ---
	--Go back a page
	weightPage_:newAction()
	:title("Back")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 64, 64, 32, 32)
  :onLeftClick(function()
		action_wheel:setPage(GetPreviousPage())
  end)
	:setColor(vectors.hexToRGB("#b82934"))
	:setHoverColor(vectors.hexToRGB("#db9499"))
	--Transition to WeightNumbers Page
	weightPage_:newAction()
	:title("Weight Numbers Page")
	:texture(textures["textures.icons"] or textures["models.textures.icons"], 160, 96, 32, 32)
	:onLeftClick(function()
	  SetPreviousPage(action_wheel:getCurrentPage())
  	action_wheel:setPage(weightNumbersPage_)
  end)
	:setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))

	-- Create burp action
  weightPage_:newAction()
  :title("Burp")
  :item("cooked_beef")
  :onLeftClick(function()
    pings.burp()
  end)
  :setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))

	--Create macro action
  weightPage_:newAction()
  :title("Macro")
  :item("netherite_block")
  :toggled(false)
  :onToggle(pings.setMacro)
  :setColor(vectors.hexToRGB("#2c43b7"))
	:setHoverColor(vectors.hexToRGB("#95a1db"))
	:setToggleColor(vectors.hexToRGB("#57cee8"))

  
  -- Create reset action
  weightPage_:newAction()
  :title("Reset")
  :item("bone")
  :onLeftClick(function()
    pings.ResetWeight()
  end)
  :setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))

  

  -- Create max action
  weightPage_:newAction()
  :title("Max")
  :item("cake")
  :onLeftClick(function()
    pings.MaxWeight()
  end)
  :setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))

	-- Create reduce action
  weightPage_:newAction()
  :title("Reduce")
  :item("dried_kelp")
  :onLeftClick(function()
    pings.ChangeWeight(-1)
  end)
  :setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))

  -- Create gain action
  weightPage_:newAction()
  :title("Gain")
  :item("cookie")
  :onLeftClick(function()
    pings.ChangeWeight(1)
  end)
  :setColor(vectors.hexToRGB("#f691ff"))
	:setHoverColor(vectors.hexToRGB("#fac8ff"))




	--- WEIGHTNUMBERS---
	--Go back a page
	weightNumbersPage_:newAction()
	:title("Back")
	:texture(textures["textures.icons"] or textures["models.slugcat.icons"], 64, 64, 32, 32)
  :onLeftClick(function()
		action_wheel:setPage(GetPreviousPage())
  end)
	:setColor(vectors.hexToRGB("#b82934"))
	:setHoverColor(vectors.hexToRGB("#db9499"))


end

--==========================================================================================
--Main Functions
--==========================================================================================

function wh_.Init()
	action_wheel:setPage(menuPage_)
	SetActions()
end

return wh_