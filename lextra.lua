-- Get the global config
local config = require("lextra_config");

--[[

    Serialize a table, which is similar to converting it
    to a string, but ignores all non-serializable data
    (Such as functions and userdata)

--]]
if config.MODIFY_BUILTIN_LIBS then
function table.serialize(t)
    local serializedTable = "{";
    local firstElement = true;
    for _,__ in pairs(t) do
        local dataType = type(__);
        if datatype == "number" or dataType == "boolean" then
            -- This can just be serialized, no problem
            if not firstElement then serializedTable = serializedTable.."," end
            serializedTable = serializedTable..tostring(_).."="..tostring(__);
            firstElement = false;
        elseif dataType == "string" then
            -- Remember to escape any quotation marks
            if not firstElement then serializedTable = serializedTable.."," end
            serializedTable = serializedTable..tostring(_).."="..string.format("%q", __);
            firstElement = false;
        elseif dataType == "table" then
            if not firstElement then serializedTable = serializedTable.."," end
            serializedTable = serializedTable..","..tostring(_).."="..__.serialize();
            firstElement = false;
        end
    end
    return serializedTable.."}";
end
end

--[[

    De-serialize tables using the interpreter for performance

--]]
if config.MODIFY_BUILTIN_LIBS then
function table.deserialize(str)
    local f = load("return "..str);
    if f and type(f) == "function" then return f() else return nil end
end
end

--[[

    Pretty print tables, for debugging

--]]
if config.MODIFY_BUILTIN_LIBS then
function table.prettyprint(t, indentLevel)
    indentLevel = indentLevel or 0;
    local prettyTable = "";
    local indentation = string.rep("\t", indentLevel);
    local first = true;
    for _,__ in pairs(t) do
        if not first then prettyTable = prettyTable.."\n" end
        first = false;
        prettyTable = prettyTable..indentation.."["..type(__).."] "..tostring(_);
        local dataType = type(__);
        if dataType == "number" or dataType == "boolean" then
            prettyTable = prettyTable.."\t"..tostring(__);
        elseif dataType == "string" then
            prettyTable = prettyTable.."\t"..string.format("%q", __);
        elseif dataType == "table" then
            if __ == t then
                prettyTable = prettyTable.."\t".."[SELF]";
            else
                prettyTable = prettyTable.."\n"..table.prettyprint(__, indentLevel + 1);
            end
        end
    end
    return prettyTable;
end
end

--[[

    Get the keys of a table

--]]
if config.MODIFY_BUILTIN_LIBS then
function table.keys(t)
    local i = 0;
    local keys = {};
    for _,__ in pairs(t) do
        i = i + 1;
        keys[i] = _;
    end
    return keys;
end
end