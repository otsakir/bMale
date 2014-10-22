#!/usr/bin/env wsapi.cgi

local orbit = require "orbit"
local cjson = require "cjson"
local luchia = require "luchia" -- couchdb client
local stdstring = require "std.string"
local bmale_auth = require "bmale_auth"
local uuid = require "uuid"

module("bmale", package.seeall, orbit.new)

-- controller functions

function get(web)
	-- bmale_auth.createUser("otsakir","diskolo")
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
	else
		print("error creating document")
	end	
end

function createUser(web)
	local userData = cjson.decode(web.POST.post_data)
	local user = cjson.decode(web.POST.post_data)
	local status, userId = bmale_auth.createUser( userData.username, userData.password, userData.profile )
	if status then
		return cjson.encode({status = "ok", payload = {id=userId}})
	else
		return cjson.encode({status = "error", message = "cannot create user"})
	end
end

function signin(web)
	local data = cjson.decode(web.POST.post_data)
	if bmale_auth.authenticateUser(data.username, data.password) then
		local newUuid = uuid()
		web:set_cookie("bmaleticket",newUuid)
		local docHandler = luchia.document:new("sessions")
		local couchResp = docHandler:create({},newUuid)
		
		if docHandler:response_ok(couchResp) then
			print("created new session for " .. data.username.." - "..newUuid) 
			-- print("document created successfully: "..tostring(couchResp.id))
			return cjson.encode({status = "ok"})
		else
			-- log the error 
			print("error creating document")
			return cjson.encode({status = "error", message = "internal server error"})
		end
	else	
		print("Error authenticating " .. data.username)
		return cjson.encode({status = "error", message = "authentication error"})
	end
end

function testrequest(web)
	local getCookie = stdstring.prettytostring(web.vars.HTTP_COOKIE)
	
	print (getCookie)
	
	return cjson.encode({status = "ok"})
end


-- Builds the application's dispatch table, you can
-- pass multiple patterns, and any captures get passed to
-- the controller

bmale:dispatch_get(get, "/get")
bmale:dispatch_post(post, "/post")
bmale:dispatch_post(rawpost, "/rawpost")

bmale:dispatch_post(send, "/send")
bmale:dispatch_put(createUser, "/users")
bmale:dispatch_post(signin, "/signin")
bmale:dispatch_get(testrequest, "/test")

-- bmale:dispatch_static("index.html","/")

-- hello:dispatch_get(say, "/say/(%a+)")


orbit.htmlify(bmale, "render_.+")

return _M
