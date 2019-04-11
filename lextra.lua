-- Get the global config
local config = require("config")

-- Set the global lextra version
_LEXTRA_VERSION = "0.0.1" -- major.minor.patch

-- Seed random
if config.AUTO_SEED_RANDOM then math.randomseed(os.time()) end

-- Put the table functions in the lextra library if we aren't allowed to modify table
local tableLib = table
if config.PROTECT_BUILTIN_LIBS then
	lextra = lextra or {table = {}}
	tableLib = lextra.table
end

--[[

    Serialize a table, which is similar to converting it
    to a string, but ignores all non-serializable data
    (Such as functions and userdata)

--]]
function tableLib.serialize(t)
    local serializedTable = "{"
    local firstElement = true
    for _,__ in pairs(t) do
        local dataType = type(__)
        if datatype == "number" or dataType == "boolean" then
            -- This can just be serialized, no problem
            if not firstElement then serializedTable = serializedTable.."," end
            serializedTable = serializedTable..tostring(_).."="..tostring(__)
            firstElement = false
        elseif dataType == "string" then
            -- Remember to escape any quotation marks
            if not firstElement then serializedTable = serializedTable.."," end
            serializedTable = serializedTable..tostring(_).."="..string.format("%q", __)
            firstElement = false
        elseif dataType == "table" then
            if not firstElement then serializedTable = serializedTable.."," end
            serializedTable = serializedTable..","..tostring(_).."="..__.serialize()
            firstElement = false
        end
    end
    return serializedTable.."}"
end

--[[

    De-serialize tables using the interpreter for performance

--]]
function tableLib.deserialize(str)
    local f = load("return "..str)
    if f and type(f) == "function" then return f() else return nil end
end

--[[

    Pretty print tables, for debugging

--]]
function tableLib.prettyprint(t, indentLevel)
    indentLevel = indentLevel or 0
    local prettyTable = ""
    local indentation = string.rep("\t", indentLevel)
    local first = true
    for _,__ in pairs(t) do
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
    return prettyTable;
end

--[[

    Get the keys of a table

--]]
function tableLib.keys(t)
    local i = 0
    local keys = {}
    for _,__ in pairs(t) do
        i = i + 1
        keys[i] = _
    end
    return keys
end
