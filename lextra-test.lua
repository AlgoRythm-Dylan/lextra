local JSON = require("json")

local JSONString = "{'json_parser': true}"
local data = JSON.parse(JSONString)

print(table.prettyprint(data))

local testTable = {this_is_a_boolean = true, {1, 3, 4, 5, 6}};

print(JSON.stringify(testTable, true))