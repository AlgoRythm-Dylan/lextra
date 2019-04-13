require("lextra")
local JSON = require("json")

local devRantData = [[

    {"success":true,"rants":[{"id":2062781,"text":"My wife took the kids to the mall.\nI work from home.\n\nme: fuck yeah, I'll be able to work now, since I focus a lot more when there's a lot of silence in the house, looking forward to this coding session\nme: *takes the fattest 2 hour nap*\n\nI guess I was tired...","score":31,"created_time":1555093191,"attached_image":"","num_comments":4,"tags":["random","work from home","tired"],"vote_state":0,"edited":false,"rt":1,"rc":6,"user_id":2022991,"user_username":"erandria","user_score":1243,"user_avatar":{"b":"2a8b9d","i":"v-35_c-3_b-4_g-m_9-1_1-9_16-5_3-8_8-1_7-1_5-1_12-9_6-79_10-1_2-20_22-4_4-1.jpg"},"user_avatar_lg":{"b":"2a8b9d","i":"v-35_c-1_b-4_g-m_9-1_1-9_16-5_3-8_8-1_7-1_5-1_12-9_6-79_10-1_2-20_22-4_4-1.png"}}],"settings":[],"set":"5cb16883b904b","wrw":151,"news":{"id":189,"type":"intlink","headline":"Weekly Group Rant","body":"Worst work culture you've experienced?","footer":"Add tag 'wk151' to your rant","height":100,"action":"grouprant"}}

]]

local data = JSON.parse(devRantData)
print(table.prettyprint(data))