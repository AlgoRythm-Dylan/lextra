--[[

    Lua-implemented JSON parsing and exporting library
    - Might do this in c if I'm bored and want a challenge



    VALID JSON:

    {"key": value, "numericvalue": 1}

    {"arrayValue": [1, "2", "three"], "oopsAnotherString": "JSON!"}

    {"otherObjectValue": {"numericValue": "NO ITS NOT LOL"}}

    {"dontForgetAbout": "escaped \"Values\"!", 'and': "double/singleQuotes"}

    ['JSON', "obJects", 'cAN', ":::BE", 123, 'just.arrays']

--]]
require("lextra")
local DEBUG = true
local JSON = {}
if DEBUG then JSON.debug = {} end

-- use string.byte instead of 1-string substrings, as to not need to allocate another string
-- each time we want to look at a character

local CHAR = {
    OPEN_C_BRACKET = string.byte('{'),
    CLOSE_C_BRACKET = string.byte('}'),
    OPEN_SQ_BRACKET = string.byte('['),
    CLOSE_SQ_BRACKET = string.byte(']'),
    DOUBLE_QUOTE = string.byte('\"'),
    SINGLE_QUOTE = string.byte('\''),
    COLON = string.byte(':'),
    COMMA = string.byte(','),
    ESCAPE = string.byte('\\'),
    FSLASH = string.byte('/'),
    STAR = string.byte('*')
}

function JSON.parse(str, start)
    position = start or 1
    local data = {}
    local started = false -- Did we find the first valid character yet?
    local isArray = false
    local currentLabel = nil
    local currentIndex = 1
    local finished = false
    local lastDataAlreadyAdded = false
    while position <= #str and not finished do
        local nextPos = nextInterestingChar(str, position)
        local interestingChar = string.byte(str, nextPos)
        if(interestingChar == -1) then error("Malformed JSON: ended improperly") end
        if interestingChar == CHAR.OPEN_C_BRACKET then
            if not started then
                started = true
                position = nextPos + 1
            else
                if isArray then
                    local newData, newPosition = JSON.parse(str, position)
                    position = newPosition + 1
                    data[currentIndex] = newData
                    lastDataAlreadyAdded = true
                else
                    if currentLabel == nil then
                        error("Malformed JSON at index "..position..": unexpected token '{'")
                    end
                    local newData, newPosition = JSON.parse(str, position)
                    position = newPosition + 1
                    data[currentLabel] = newData
                    lastDataAlreadyAdded = true
                    currentLabel = nil
                end
            end
        elseif interestingChar == CHAR.CLOSE_C_BRACKET then
            if not started then
                error("Malformed JSON at index "..position..": unexpected token '}'")
            end
            if isArray then
                error("Malformed JSON at index "..position..": unexpected token '}'")
            end
            -- Wrap up any unadded data
            if not lastDataAlreadyAdded then
                if currentLabel == nil then
                    if #data ~= 0 then -- Empty objects are acceptable
                        error("Malformed JSON at index "..position..": unexpected token '}'")
                    end
                else 
                    local rawData = string.sub(str, position + 1, nextPos - 1)
                    data[currentLabel] = stringToType(rawData)
                end
            end
            -- We're done here!
            position = nextPos
            finished = true
        elseif interestingChar == CHAR.OPEN_SQ_BRACKET then
            if not started then
                isArray = true
                started = true
                position = nextPos + 1
            else
                if isArray then -- This is an array in an array
                    newData, newPosition = JSON.parse(str, position);
                    data[currentIndex] = newData
                    position = newPosition + 1
                    currentIndex = currentIndex + 1
                    lastDataAlreadyAdded = true
                elseif currentLabel == nil then
                    error("Malformed JSON at index "..position..": unexpected token '['")
                    -- There can be anonymous objects in an array but not anonymous arrays in an object
                else
                    if currentLabel == nil then
                        error("Malformed JSON at index "..position..": unexpected token '['")
                    end
                    local newData, newPosition = JSON.parse(str, position)
                    data[currentLabel] = newData
                    position = newPosition + 1
                    currentLabel = nil
                    lastDataAlreadyAdded = true
                end
            end
        elseif interestingChar == CHAR.CLOSE_SQ_BRACKET then
            if not started then
                error("Malformed JSON at index "..position..": unexpected token ']'")
            else
                if isArray then
                    if not lastDataAlreadyAdded then
                        local rawData = string.sub(str, position, nextPos - 1)
                        if not (#data == 0 and string.trim(rawData) == "") then -- Empty arrays are valid, do nothing
                            data[currentIndex] = stringToType(rawData) -- May fail, which will cancel the parse
                        end
                    end
                    position = nextPos
                    finished = true
                else
                    error("Malformed JSON at index "..position..": unexpected token ']'")
                end
            end
        elseif interestingChar == CHAR.DOUBLE_QUOTE or interestingChar == CHAR.SINGLE_QUOTE then
            if isArray then
                -- This is the start of a string inside an array
                local stringEnd = findEndOfString(str, nextPos)
                data[currentIndex] = string.sub(str, nextPos + 1, stringEnd - 1)
                currentIndex = currentIndex + 1
                position = stringEnd + 1
                lastDataAlreadyAdded = true
            else
                if currentLabel == nil then
                    -- This is the new current label!
                    local stringEnd = findEndOfString(str, nextPos)
                    currentLabel = string.sub(str, nextPos + 1, stringEnd - 1)
                    position = stringEnd + 1
                else
                    -- This isn't the key, it's the value!
                    local stringEnd = findEndOfString(str, nextPos)
                    data[currentLabel] = string.sub(str, nextPos + 1, stringEnd - 1)
                    currentLabel = nil
                    position = stringEnd + 1
                    lastDataAlreadyAdded = true
                end
            end
        elseif interestingChar == CHAR.COLON then
            if isArray or currentLabel == nil then
                error("Malformed JSON at index "..position..": unexpected token ':'")
            else
                -- This is valid. Progress the reader
                position = nextPos + 1
            end
        elseif interestingChar == CHAR.COMMA then
            if isArray then -- [javascript arrays]
                if not lastDataAlreadyAdded then
                    -- Text UP TO the current comma from last interesting character
                    local rawData = string.sub(str, position, nextPos - 1)
                    data[currentIndex] = stringToType(rawData) -- May fail, which will cancel the parse
                    currentIndex = currentIndex + 1
                    position = nextPos + 1
                else
                    lastDataAlreadyAdded = false -- Reset the 'already added' flag
                    position = nextPos + 1
                end
            else -- {javascript: objects}
                if not lastDataAlreadyAdded then
                    if currentLabel == nil then
                        error("Malformed JSON at index "..position..": unexpected token ','")
                    end
                    local rawData = string.sub(str, position, nextPos - 1)
                    data[currentLabel] = stringToType(rawData)
                    currentLabel = nil
                    position = nextPos + 1
                else
                    lastDataAlreadyAdded = false
                    position = nextPos + 1
                end
            end
        elseif interestingChar == CHAR.FSLASH then
            if nextPos + 1 <= #str then
                if string.byte(str, nextPos + 1) == CHAR.STAR then
                    local endOfComment = findEndOfComment(str, position)
                    position = endOfComment + 1
                else
                    error("Malformed JSON at index "..position..": unexpected token '/'")
                end
            else
                error("Malformed JSON at index "..position..": unexpected token '/'")
            end
        end
    end
    return data, position -- Return the data and the place where parsing stopped. Helpful for recursion
end

local interesting = {
    CHAR.OPEN_C_BRACKET,
    CHAR.CLOSE_C_BRACKET,
    CHAR.OPEN_SQ_BRACKET,
    CHAR.CLOSE_SQ_BRACKET,
    CHAR.DOUBLE_QUOTE,
    CHAR.SINGLE_QUOTE,
    CHAR.COLON,
    CHAR.COMMA,
    CHAR.FSLASH
}
--[[

    Return the next "interesting" character in terms of syntax.
    Interesting items include a comma, which separates values,
    a colon, which separates key and value, open or close brackets,
    which indicate the start or stop of an object or array, and
    single/ double quotes, which ONLY indicate the START of a string
    in this function. Use findEndOfString to see the length of
    a string once you found the start, and then find the next
    interesting character after that to continue parsing

    This makes this JSON parser somewhat fault-tolerant.
    It ignores things it doesn't like (At least, it should. 
    Faulty JSON will still provoke undefined behavior)

--]]
function nextInterestingChar(str, start)
    local position = start or 0
    while position <= #str do
        --print(position)
        if table.contains(interesting, string.byte(str, position)) then return position end
        position = position + 1 -- That character wasn't interesting, continue
    end
    return -1 -- Every character was boring
end

--[[

    Find the end of a string, respecting the quotation style (' vs ") and
    escaped characters (\")

--]]
function findEndOfString(str, start)
    start = start or 0
    local escaped = false -- Is the next character escaped (like \t)? If so, ignore it
    local strChar = string.byte(str, start) -- Single or double quote string?
    local position = start + 1
    while position <= #str do
        if escaped then escaped = false else
            local charHere = string.byte(str, position)
            if charHere == strChar then return position end
            if charHere == CHAR.ESCAPE then escaped = true end
        end
        position = position + 1
    end
    return position
end

--[[

    /*    comment             */
    ^                          ^
    start                 return

--]]
function findEndOfComment(str, start)
    start = start or 0
    local position = start + 1
    while position <= #str do
        local charHere = string.byte(str, position)
        if charHere == CHAR.STAR then
            if position + 1 <= #str then
                if string.byte(str, position + 1) == CHAR.FSLASH then return position + 1 end
            end
        end
        position = position + 1
    end
    return position
end

--[[

    Turns a string into a valid Lua type. Fails on invalid data.

--]]
function stringToType(str)
    local data = string.trim(str)
    if data == "true" then return true
    elseif data == "false" then return false
    elseif data == "null" then return nil
    elseif tonumber(data) ~= nil then return tonumber(data)
    else error("Could not parse data; expected a type (got \""..data.."\")") end
end

--[[

    Checks to see if a table can be represented as a JSON array

--]]
function isArrayTable(t)
    local currentIndex = 1
    for _, __ in pairs(t) do
        if _ ~= currentIndex then return false end
        currentIndex = currentIndex + 1
    end
    return true
end

if DEBUG then
    JSON.debug.nextInterestingChar = nextInterestingChar
    JSON.debug.findEndOfString = findEndOfString
    JSON.debug.stringToType = stringToType
    JSON.debug.isArrayTable = isArrayTable
    JSON.debug.findEndOfComment = findEndOfComment
end

--[[

    Convert a Lua table to a valid JSON string

--]]
function JSON.stringify(t, arrayCheck)
    arrayCheck = arrayCheck or false
    local isArray = false
    local isFirstItem = true
    if arrayCheck then isArray = isArrayTable(t) end
    local JSONString = nil
    if isArray then JSONString = "["
    else JSONString = "{" end
    for _,__ in pairs(t) do
        local itemType = type(__)
        if not isArray then -- Add the key and the value
            if itemType == "number" or itemType == "string" or itemType == "boolean" then
                if not isFirstItem then JSONString = JSONString.."," end
                JSONString = JSONString..string.format("%q",_)..":"..string.format("%q",__)
                isFirstItem = false
            elseif itemType == "table" then
                if not isFirstItem then JSONString = JSONString.."," end
                JSONString = JSONString..string.format("%q",_)..":"..JSON.stringify(__,arrayCheck)
                isFirstItem = false
            end
        else --isArray
            if itemType == "number" or itemType == "string" or itemType == "boolean" then
                if not isFirstItem then JSONString = JSONString.."," end
                JSONString = JSONString..string.format("%q",__)
                isFirstItem = false
            elseif itemType == "table" then
                if not isFirstItem then JSONString = JSONString.."," end
                JSONString = JSONString..JSON.stringify(__,arrayCheck)
                isFirstItem = false
            end
        end
    end
    -- Finish up
    if isArray then JSONString = JSONString.."]"
    else JSONString = JSONString.."}" end
    return JSONString
end

return JSON