local lizard_ = models.models.hypno
local lizardFullbody_ = lizard_.Fullbody
local lizardBody_ = lizardFullbody_.Body
local lizardLegs_ = lizardFullbody_.Legs
local lizardTail_ = lizardFullbody_.Tail
local lizardHead_ = lizardBody_.FrontBodySection.vHead

local globalVariables =
{
  lizard = lizard_,
  lizardFullbody = lizardFullbody_,
  lizardBody = lizardBody_,
  lizardLegs = lizardLegs_,
  lizardTail = lizardTail_,
  lizardHead = lizardHead_
}

return globalVariables