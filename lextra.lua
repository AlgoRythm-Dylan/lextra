-- Set the global lextra version
_LEXTRA_VERSION = "0.0.1" -- major.minor.patch

-- Seed random
math.randomseed(os.time())

--[[

    Serialize a table, which is similar to converting it
    to a string, but ignores all non-serializable data
    (Such as functions and userdata)

--]]
function table.serialize(t)
    local serializedTable = "{"
    local firstElement = true
    for _,__ in pairs(t) do
        local dataType = type(__)
        if dataType == "number" or dataType == "boolean" or dataType == "string" then
            -- This can just be serialized, no problem
            if not firstElement then serializedTable = serializedTable.."," end
            serializedTable = serializedTable..tostring(_).."="..string.format("%q", __)
            firstElement = false
        elseif dataType == "table" then
            if not firstElement then serializedTable = serializedTable.."," end
            if not __ == t then
                serializedTable = serializedTable..","..tostring(_).."="..__:serialize()
            end
            firstElement = false
        end
    end
    return serializedTable.."}"
end

--[[

    De-serialize tables using the interpreter for performance

--]]
function table.deserialize(str)
    local f = load("return "..str)
    if f and type(f) == "function" then return f() else return nil end
end

--[[

    Pretty print tables, for debugging

--]]
function table.prettyprint(t, indentLevel)
    indentLevel = indentLevel or 0
    local prettyTable = ""
    local indentation = string.rep("\t", indentLevel)
    local first = true
    local itemCount = 0
    for _,__ in pairs(t) do
        itemCount = itemCount + 1
        if not first then prettyTable = prettyTable.."\n" end
        first = false
        prettyTable = prettyTable..indentation.."["..type(__).."] "..tostring(_)
        local dataType = type(__);
        if dataType == "number" or dataType == "boolean" then
            prettyTable = prettyTable.."\t"..tostring(__)
        elseif dataType == "string" then
            prettyTable = prettyTable.."\t"..string.format("%q", __)
        elseif dataType == "table" then
            if __ == t then
                prettyTable = prettyTable.."\t".."[SELF]"
            else
                prettyTable = prettyTable.."\n"..table.prettyprint(__, indentLevel + 1)
            end
        end
    end
    if itemCount == 0 then
        prettyTable = prettyTable..indentation.."[EMPTY TABLE]"
    end
    return prettyTable;
end

--[[

    Get the keys of a table

--]]
function table.keys(t)
    local i = 0
    local keys = {}
    for _,__ in pairs(t) do
        i = i + 1
        keys[i] = _
    end
    return keys
end


--[[

    See if a table contains a specific value

--]]
function table.contains(t, item)
    for _,__ in pairs(t) do
        if __ == item then return true end
    end
    return false
end

--[[

    Get a single value from a string

--]]
function string.at(str, index)
    return string.char(string.byte(str, index))
end

--[[

    Trim leading and trailing whitespaces from a string

--]]
function string.trim(str)
    local startPos = 1
    local endPos = #str
    if endPos == 0 then return str end -- Check for empty strings
    while string.byte(str, startPos) == 32 do startPos = startPos + 1 end
    while string.byte(str, endPos) == 32 do endPos = endPos - 1 end
    return string.sub(str, startPos, endPos)
end

--[[

    Trim all leading whitespaces ONLY

]]--
function string.trimRight(str)
    local pos = 1
    if #str == 0 then return str end
    while string.byte(str, pos) == 32 do pos = pos + 1 end
    return string.sub(str, pos, #str)
end

--[[

    Trim all trailing whitespaces ONLY

]]--
function string.trimLeft(str)
    local pos = #str
    if #str == 0 then return str end
    while string.byte(str, pos) == 32 do pos = pos - 1 end
    return string.sub(str, 1, pos)
end


-- TODO: string.trimRight, string.trimLeft