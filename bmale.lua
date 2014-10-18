#!/usr/bin/env wsapi.cgi

local orbit = require "orbit"
local cjson = require "cjson"
local luchia = require "luchia" -- couchdb client
local stdstring = require "std.string"

module("bmale", package.seeall, orbit.new)

-- controller functions

function get(web)
	for k,v in pairs(web.GET) do
		print (k.." = "..tostring(v))
	end
end

function post(web)
	for k,v in pairs(web.POST) do
		print (k.." = "..tostring(v))
	end
end

function rawpost(web)
	print (web.POST.post_data)
end


function say(web, name)
	return render_say(web, name)
end

function send(web)
	print ("sending mail")
	print (web.POST.post_data)
	
	-- decode json message
	decodedMessage = cjson.decode(web.POST.post_data)
	print("sending to "..decodedMessage.to)

	-- prepare an outgoing message for each destination
	local outgoingMessage = { 
		destination = decodedMessage.to,
		message = decodedMessage.message
	}

	-- put the message in the outbox_queue
	local docHandler = luchia.document:new("outbox_queue")
	local couchResp = docHandler:create(outgoingMessage)
	if docHandler:response_ok(couchResp) then
		print("document created successfully: "..tostring(couchResp.id))
		local response = {status = "ok", payload = {id = couchResp.id}}
		local jsonResponse = cjson.encode(response)
		return jsonResponse
		-- print( stdstring.prettytostring(couchResp) )
	else
		print("error creating document")
	end	
end

-- Builds the application's dispatch table, you can
-- pass multiple patterns, and any captures get passed to
-- the controller

bmale:dispatch_get(get, "/get")
bmale:dispatch_post(post, "/post")
bmale:dispatch_post(rawpost, "/rawpost")
bmale:dispatch_post(send, "/send")
-- bmale:dispatch_static("index.html","/")

-- hello:dispatch_get(say, "/say/(%a+)")


orbit.htmlify(bmale, "render_.+")

return _M
