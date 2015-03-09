#!/usr/bin/env wsapi.cgi

local orbit = require "orbit"
local cjson = require "cjson"
local luchia = require "luchia" -- couchdb client
local stdstring = require "std.string"
local bmale_auth = require "bmale_auth"
local uuid = require "uuid"
-- local  bmale_utils = require "bmale_utils"

require "bmale.utils"
require "bmale.models"
require "bmale.queries"
require "bmale.core"

module("bmale", package.seeall, orbit.new)

-- *** Controller Utility functions ***

-- prepares a response for unauthorized access
function unauthorized(web)
	web.status = "401 Unauthorized"
	return cjson.encode({status = "error", message = "Unauthorized"})
end


function list_drafts(web)
	print ("in list_drafts")
	-- check authenticated
	local status,user = bmale_auth.getLoggedUser( bmale.utils.extractTicketFromHeader( web.vars.HTTP_COOKIE ) )
	if status == false then 
		return unauthorized(web)	
	elseif status == nil then
		return orbit.server_error(web, "")
	end
	--]]
	
	local drafts = bmale.queries.fetchUserDrafts(user.username);
	local response = {status = "ok", payload = drafts}
	local jsonResponse = cjson.encode(response)
	return jsonResponse
end

function get_inbox(web)
	print ("in get_inbox")
	-- check authenticated
	local status,user = bmale_auth.getLoggedUser( bmale.utils.extractTicketFromHeader( web.vars.HTTP_COOKIE ) )
	if status == false then 
		return unauthorized(web)	
	elseif status == nil then
		return orbit.server_error(web, "")
	end
	--]]
	
	local inboxMessages = bmale.queries.fetchInboxMessages(user.username);
	print (bmale.utils.tostring(inboxMessages) )
	local response = {status = "ok", payload = inboxMessages}
	local jsonResponse = cjson.encode(response)
	return jsonResponse		
end

function get_sent(web)
	print("in get_sent")
	-- check authenticated
	local status,user = bmale_auth.getLoggedUser( bmale.utils.extractTicketFromHeader( web.vars.HTTP_COOKIE ) )
	if status == false then 
		return unauthorized(web)	
	elseif status == nil then
		return orbit.server_error(web, "")
	end
	--]]
	
	local sentMessages = bmale.queries.fetchSentMessages(user.username);
	print (bmale.utils.tostring(sentMessages) )
	local response = {status = "ok", payload = sentMessages}
	local jsonResponse = cjson.encode(response)
	return jsonResponse		
end

function get_draft_message(web, id)
	print("in get_draft_message")
	print("id "..id)
	-- check authenticated
	local status,user = bmale_auth.getLoggedUser( bmale.utils.extractTicketFromHeader( web.vars.HTTP_COOKIE ) )
	if status == false then 
		return unauthorized(web)	
	elseif status == nil then
		return orbit.server_error(web, "")
	end
	--]]
	
	local draftMessage = bmale.models.MessageDto.fromMessage( bmale.queries.fetchMessage(id, user.username) )
	local response = {status = "ok", payload = draftMessage}
	local jsonResponse = cjson.encode(response)
	return jsonResponse
end

function save_draft_message(web,id,revision)
--print(bmale.utils.tostring(web))
	if web.path_info == id then -- all path was matched
		id = nil
		revision = nil
	end
	print("in save_draft_message")
	--print("id "..id)
	--print("revision "..revision)
	-- check authenticated
	local status,user = bmale_auth.getLoggedUser( bmale.utils.extractTicketFromHeader( web.vars.HTTP_COOKIE ) )
	if status == false then 
		return unauthorized(web)	
	elseif status == nil then
		return orbit.server_error(web, "")
	end
	--]]
	
	local messageDto = cjson.decode(web.POST.post_data)
print("messageDto: " .. bmale.utils.tostring(messageDto))
	local message = bmale.models.Message.fromMessageDto(messageDto)
	message.message.from = user.username
	message._rev = revision
	message.message.messageType = "draft"
	
	local dbResponse = queries.storeMessage(id, message)
	if ( dbResponse and dbResponse.ok ) then
		return cjson.encode( {status = "ok", payload = {id = dbResponse.id, revision = dbResponse.rev}} )
	else
		return cjson.encode( {status = "error"} )
	end
end

function remove_draft_message(web,id,revision)
print("in remove_draft_message")
	local status,user = bmale_auth.getLoggedUser( bmale.utils.extractTicketFromHeader( web.vars.HTTP_COOKIE ) )
	if status == false then 
		return unauthorized(web)	
	elseif status == nil then
		return orbit.server_error(web, "")
	end
	
	if queries.removeMessage(id,revision) then
		return cjson.encode({status="ok"})
	else
		return cjson.encode({status="error"})
	end
end

function send_message(web,id)
	print("in send_message "..id)
	local status,user = bmale_auth.getLoggedUser( bmale.utils.extractTicketFromHeader( web.vars.HTTP_COOKIE ) )
	if status == false then 
		return unauthorized(web)	
	elseif status == nil then
		return orbit.server_error(web, "")
	end
	
	core.sendMessage(id,user)
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
		web:set_cookie("bmaleticket",{value = newUuid, path = "/"})
		local docHandler = luchia.document:new("sessions")
		local couchResp = docHandler:create({username = data.username},newUuid)
		
		if docHandler:response_ok(couchResp) then
			print("created new session for " .. data.username.." - "..newUuid) 
			-- print("document created successfully: "..tostring(couchResp.id))
			return cjson.encode({status = "ok"})
		else
			-- log the error 
			print("error creating session document")
			return cjson.encode({status = "error", message = "internal server error"})
		end
	else	
		print("Error authenticating " .. data.username)
		return cjson.encode({status = "error", message = "authentication error"})
	end
end

function signout(web)
		local webCookie = bmale.utils.extractTicketFromHeader( web.vars.HTTP_COOKIE)
		if webCookie then
			-- clear the cookie from the user's browser
			web:set_cookie("bmaleticket",{value = "", path="/", expires=0})
			-- clear the session record
			local docHandler = luchia.document:new("sessions")
			local session = docHandler:retrieve(webCookie)
			
			if session then
				print( "logging out session ".. stdstring.prettytostring(session))
				docHandler:delete(session._id, session._rev)
				return cjson.encode({status = "ok"})
			else
				return cjson.encode({status = "error"})
			end
		end
end


-- build dispatch table

-- bmale:dispatch_post(send, "/send")
bmale:dispatch_put(createUser, "/users")
bmale:dispatch_post(signin, "/signin")
bmale:dispatch_get(signout, "/signout")

-- bmale:dispatch_post(update_draft, "/drafts")
bmale:dispatch_get(get_draft_message, "/drafts/(%w+)")

bmale:dispatch_get(list_drafts, "/drafts")
bmale:dispatch_post(save_draft_message, "/drafts")
bmale:dispatch_put(save_draft_message, "/drafts/(%w+)/([%w-]+)/save")
bmale:dispatch_delete(remove_draft_message, "/drafts/(%w+)/([%w-]+)")

bmale:dispatch_put(send_message, "/messages/(%w+)/send")

bmale:dispatch_get(get_inbox, "/inbox")

bmale:dispatch_get(get_sent, "/sent")

-- bmale:dispatch_static("index.html","/")

orbit.htmlify(bmale, "render_.+")

return _M
