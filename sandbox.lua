local models = require "bmale.models"
local stdstring = require "std.string"
local http = require "socket.http"
local cjson = require "cjson"
-- require "bmale.config"
require "bmale.queries"
require "bmale.utils"

-- local config = require "bmale.config"

print(bmale.models.info())

-- for key in pairs(_G) do print(key) end
--local message = models.Message.new( {type="asdf"})
print( stdstring.prettytostring(message) )


--[[
local b,c,h = http.request(bmale.config.storageUrl.."/messages/_design/drafts/_view/drafts")
if (c==200) then 
	local body = cjson.decode(b)
end

print("code: "..c)
print("body: "..b)
print("headers: " .. stdstring.prettytostring(h))

--]]

-- http://localhost:5984/messages/_design/drafts/_view/drafts

-- local r = bmale.queries.fetchMessages()
--local r = bmale.queries.fetchUserMessages("max")
--print( bmale.utils.tostring(r) )

--local r = bmale.queries.fetchUserDrafts("max")
--print( bmale.utils.tostring(r) )

local r = bmale.queries.fetchMessage(nil)
print(bmale.utils.tostring(r))



