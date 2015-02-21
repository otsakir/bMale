module("bmale.queries", package.seeall)
require "bmale.models"
require "bmale.utils"
require "bmale.config"
local cjson = require "cjson"
local http = require "socket.http"
local ltn12 = require "ltn12"



--[[
	This modules contains all the http queries to the Couch db server. It also handles json decoding into lua models
--]]

--[[
function fetchDrafts()
	local b,c,h = http.request(bmale.config.storageUrl.."/messages/_design/drafts/_view/drafts")
	if (c==200) then
		local body = cjson.decode(b)
		drafts = {}
		for rawindex = 1,body.total_rows do
			drafts[rawindex] = body.rows[rawindex].value
		end
		return drafts
	end
end
--]]

function fetchMessages()
	local b,c,h = http.request(bmale.config.storageUrl.."/messages/_design/messages/_view/messages")
	if (c==200) then
		local body = cjson.decode(b)
		local drafts = {}
		for rawindex = 1,body.total_rows do
			local message = bmale.models.MessageDto.fromMessage(body.rows[rawindex].value)
			drafts[rawindex] = messageDto
		end
		return drafts
	end
end

function fetchUserMessages(username)
	assert(username and type(username)=="string", "fetchUserMessages(): bad username")
	local b,c,h = http.request(bmale.config.storageUrl.."/messages/_design/messages/_view/byFrom?key=\""..username.."\"")
	if (c==200) then
		local body = cjson.decode(b)
		local drafts = {}
		-- print("total rows: "..body.total_rows)
		for rawindex = 1,#body.rows do
			local messageDto = bmale.models.MessageDto.fromMessage(body.rows[rawindex].value)
			drafts[rawindex] = messageDto
		end
		return drafts
	end
end
-- retrieves the messages received by a user
function fetchInboxMessages(username)
	local b,c,h = http.request(bmale.config.storageUrl.."/messages/_design/messages/_view/inboxByDestination?key=\""..username.."\"")
	if (c==200) then
		local body = cjson.decode(b)
		local messages = {}
		-- print("total rows: "..body.total_rows)
		for rawindex = 1,#body.rows do
			local messageDto = bmale.models.MessageDto.fromMessageContent(body.rows[rawindex].value, body.rows[rawindex].id)
			messages[rawindex] = messageDto
		end
		return messages
	end	
end

function fetchUserDrafts(username)
	assert(username and type(username)=="string", "fetchUserDrafts(): bad username")
	local b,c,h = http.request(bmale.config.storageUrl.."/messages/_design/messages/_view/draftsBySender?key=\""..username.."\"")
	if (c==200) then
		local body = cjson.decode(b)
		local drafts = {}
		-- print("total rows: "..body.total_rows)
		for rawindex = 1,#body.rows do
			local messageDto = bmale.models.MessageDto.fromMessage(body.rows[rawindex].value)
			drafts[rawindex] = messageDto
		end
		return drafts
	end
end

function fetchUserInbox(username)

end

-- TODO search for messages belonging to this user only
-- Fetches a message and returns it as is
function fetchMessage(id, username)
	assert(id, "no message id specified")
	local b,c,h = http.request(bmale.config.storageUrl.."/messages/"..id)
	if (c==200) then
		local body = cjson.decode(b)
		return body
		--local message = bmale.models.MessageDto.fromMessage(body)
		--return message
	end	
end

-- returns couch's response or nil in case of http error
function storeMessage(id, message)
	local message_json = cjson.encode(message)
	local url = bmale.config.storageUrl.."/messages/"..(id and id or "")
	local response_table = {}
	local r,c,h = http.request({
		url = url,
		method = (id and "PUT" or "POST"),
		source = ltn12.source.string(message_json),
		sink = ltn12.sink.table(response_table),
		headers = { 
			["Content-Type"] = "application/json",
			["Content-Length"] = tostring(#message_json)
		}
	})
	
	if (c>=200 and c<300) then
		print("OK")
		local response = cjson.decode( table.concat(response_table) )
		return response
	else
		return nil
	end
end

-- returns 1 if successfull or nil in case of error
function removeMessage(id, revision) 
	assert( type(id)=="string" and type(revision)=="string" )
	local url = bmale.config.storageUrl.."/messages/"..id.."?rev="..revision
print("url: "..url)
	local r = http.request({
		url = url,
		method = "DELETE"
	})
	return r
end

