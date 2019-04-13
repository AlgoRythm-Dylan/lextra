require("lextra")
local JSON = require("json")

devRantJsonString = [[
    {
        "success": true,
        "rants": [
            {
                "id": 2061692,
                "text": "Returning moron here, missed ya guys.\nNow, idk if this qualifies as politics but i guess",
                "score": 6,
                "created_time": 1555010893,
                "attached_image": "",
                "num_comments": 33,
                "tags": [
                    "random",
                    "assange"
                ],
                "vote_state": 0,
                "edited": false,
                "rt": 1,
                "rc": 6,
                "user_id": 2061681,
                "user_username": "fuck2code",
                "user_score": 13,
                "user_avatar": {
                    "b": "7bc8a4"
                },
                "user_avatar_lg": {
                    "b": "7bc8a4"
                }
            }
        ],
        "settings": [],
        "set": "5cb006c385d10",
        "wrw": 151,
        "news": {
            "id": 189,
            "type": "intlink",
            "headline": "Weekly Group Rant",
            "body": "Worst work culture you've experienced?",
            "footer": "Add tag 'wk151' to your rant",
            "height": 100,
            "action": "grouprant"
        }
    }
]]

--data = JSON.parse(devRantJsonString)

--print(table.prettyprint(data))

arrayTable = {3, 4, 5}
anotherArrayTable = {"Hello", "general", "Kenobi", false}
notArrayTable = {is_array_table = false}
emptyTable = {}

print(JSON.stringify(arrayTable, true))
print(JSON.stringify(anotherArrayTable, true))
print(JSON.stringify(notArrayTable, true))
print(JSON.stringify(emptyTable, true))