--==========================================================================================
-- This is a side script that manages chat commands
--==========================================================================================
--Version
local ch_ = {}
ch_.version_ = "1.0.4"
ch_.size_ = 1

-- Helpers
local h_ = require("scripts.api.helper")

-- Chat Commands
local chatCommandList_ = {} -- List of chat commands entry = {scriptName, storedFunction, terms, use}
local ALL_PLAYERS_LC = {"white","brown", "red","orange","yellow",
                  "green","teal","blue","purple","pink","grey","black"} -- All the possible player colors lowercased

--==========================================================================================
-- Chat Commands
--==========================================================================================





local function FormatChatMessage(message)
  local messageWithoutCommand = string.sub(message, 2, string.len(message))
  local messageWithoutCommandAndLowerCase = string.lower(messageWithoutCommand)
  local words = {}
  local originalWords = {}
  for word in messageWithoutCommandAndLowerCase:gmatch("%w+") do
    table.insert(words, word)
  end
  for word in messageWithoutCommand:gmatch("%S+") do
    table.insert(originalWords, word)
  end

  return {message = message, lowerCaseWords = words, originalWords = originalWords}
end

local function ExplainWhyTermsFailed(command, commandTerm, term)
  local properCommand = "/" .. table.concat(command.terms, " ")
  print(properCommand)

  if term == nil then
    print("Is missing one or more terms required for this command.")
    return
  end

  if commandTerm == "[Color]" then
    print("'" .. term .. "' is not a Color")
  elseif commandTerm == "[Number]" then
    print("'" .. term .. "' is not a Number")
  else
    print("'" .. term .. "' is not valid for command. Expected: '" .. commandTerm .. "'")
  end
end

local function ExplainWhatTermsAreMissing(command, message, numberOfTermsGiven)
  print(message)

  local properCommand = "/" .. table.concat(command.terms, " ")
  print(properCommand)

  for i, term in ipairs(command.terms) do
    if i > numberOfTermsGiven then
      if term == "[Color]" then
        print("Missing a Color")
      elseif term == "[Number]" then
        print("Missing a Number")
      elseif term == "[Rest of Message]" then
        print("Missing the rest of the message for the command.")
      elseif h_.check_brackets(term) then
        print("Missing a word in the category '" .. term .. "'.")
      else
        print("Missing the keyword '" .. term .. "'.")
      end
    end
  end
end

local function ConvertToColorIfColor(entry)
  for _, value in pairs(ALL_PLAYERS_LC) do
    if entry == value  then
      return "[Color]" -- Found the string
    end
  end
  return entry
end

local function ConvertToNumberIfNumber(entry)
  if tonumber(entry) ~= nil then
    return "[Number]"
  else
    return entry
  end
end

local function ConvertToTerm(entry)
  local term =  ConvertToColorIfColor(entry)
  term =  ConvertToNumberIfNumber(term)
  return term
end


local function CheckIfTermsMatch(term, commandTerm)
  if commandTerm == ConvertToTerm(term) or commandTerm == "[Rest of Message]" or h_.check_brackets(commandTerm) then
    return true
  else
    return false
  end
end


--format = {message = message, lowerCaseWords = words, originalWords = originalWords}
local function FindChatCommand(format)
  local lastBatchOfCommands = {}
  local currentBatchOfCommands = {}

  --remove nils and impossible to call functions
  for _, command in ipairs(chatCommandList_) do
    if command ~= nil and command.storedFunction ~= nil then
      table.insert(lastBatchOfCommands, command)
    end
  end

  --loop through all terms submitted through chat
  for i, term in ipairs(format.lowerCaseWords) do
    --clear current batch
    currentBatchOfCommands = {}

    --if the last batch has terms left to compare and the current term matches, add it to current
    for _, command in ipairs(lastBatchOfCommands) do
      if #command.terms >= i and CheckIfTermsMatch(term, command.terms[i]) then
        table.insert(currentBatchOfCommands, command)
      end
    end

    --In the case nothing passes, get up to 3 from the last batch to explain why they failed
    if currentBatchOfCommands == nil or #currentBatchOfCommands == 0 then
      print(format.message)
      for k, last in ipairs(lastBatchOfCommands) do
        if k > 3 then
          return nil
        end
        ExplainWhyTermsFailed(last, last.terms[i], term)
      end
      return nil
    end

    --If there's one command and all terms the command held are matched, it is the correct one
    if #currentBatchOfCommands == 1 and #currentBatchOfCommands[1].terms == i then
      return currentBatchOfCommands[1]
    end

    lastBatchOfCommands = currentBatchOfCommands
  end

  if currentBatchOfCommands ~= nil and #currentBatchOfCommands == 1 then
    --Check if the extra terms in the command are Optional
    local numberOfCheckedTerms = #format.lowerCaseWords
    local restAreOptionals = true

    for i, term in ipairs(currentBatchOfCommands[1].terms) do
      if i > numberOfCheckedTerms then
        if term ~= "{Optional}" then
          restAreOptionals = false
        end
      end
    end

    if restAreOptionals == true then
      return currentBatchOfCommands[1]
    end


    ExplainWhatTermsAreMissing(currentBatchOfCommands[1], format.message, #format.lowerCaseWords)
    return nil
  end
end





local function FinalizeFormat(command, format)
  local finalFormat = {}
  local rest = false
  --Convert the format into the method the function itself can actually use
  for i, term in ipairs(command.terms) do
    if term == "[Number]" then
      table.insert(finalFormat, tonumber(format.originalWords[i]))
    elseif h_.check_brackets(term) then
      table.insert(finalFormat, format.originalWords[i])
    elseif term == "[Rest of Message]" then
      table.insert(finalFormat, table.concat(format.originalWords, " ", i))
    end
  end

  return finalFormat
end

--entry = {scriptName, storedFunction, terms, use}
local function AttemptChatCommand(command, format)
  if command.scriptName == nil or command.scriptName == "" then
    print("Error : This command lacks a scriptName")
    return
  end
  if command.storedFunction == nil then
    print("Error : This command has no function  to be called")
    return
  end

  local finalFormat = {}
  finalFormat = FinalizeFormat(command, format)

  print("Running Command.")
  command.storedFunction(table.unpack(finalFormat))
end




local function PrintChatCommandsToPlayerChatCommand(format)


  print("Printing All Commands in Chat Command List")
  for _, command in ipairs(chatCommandList_) do
    local system = command.system
    if system == "self" then
      system = "Central Command"
    end
    local terms = ""
    for _, term in ipairs(command.terms) do
      terms = terms .. term .. " "
    end
    local use = command.use
    if use == nil then
      use = "unknown use"
    end
    
    print(system .. ": !" .. terms .. "- " .. use)
    
  end
end



function ch_.HandleMessage(msg)
  if string.sub(msg, 1, 1) == "/" and string.len(msg) > 1 then

    local format = FormatChatMessage(msg)
    local command = FindChatCommand(format)

    if command == nil then
      return msg
    end

    AttemptChatCommand(command,format)
    --pings.command(cmd)
    return nil
  else
    return msg
  end
end


--==========================================================================================
--Main Functions
--==========================================================================================


function ch_.Init()
  
end

function ch_.new(name, funct, terms, use)
  table.insert(chatCommandList_, {scriptName = name, storedFunction = funct, terms = terms, use=use})
end



--==========================================================================================
--HELPERS
--==========================================================================================






return ch_