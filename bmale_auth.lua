local module = {}

local luchia = require "luchia" -- couchdb client
local stdstring = require "std.string"

function module.createUser( username, password, profile )
	local user = {username = username, password = password, profile = profile} -- at some point the password should be hashed. We'll see about that...	
	local docHandler = luchia.document:new("users")
	local resp = docHandler:create(user, user.username)
	if docHandler:response_ok(resp) then
		return true, resp.id
	else
		return nil, "Error creating user"
	end
end

function module.removeUser(username)
end

function module.updateUser(username, profile)
end

function module.authenticateUser(username, password)
	local db = luchia.document:new("users")
	local resp = db:retrieve(username)
	if resp and resp.password == password then 
		return true
	else
		return false
	end
end

-- Returns the user object for the user currently sign-in based on his ticket. If no user is signed it returns null
function module.getLoggedUser(ticket)
	local sessiondb = luchia.document:new("sessions")
	local session = sessiondb:retrieve(ticket)
	-- if there is a session retrieve the user owning it
	if session then
		local userdb = luchia.document:new("users")
		local user = userdb:retrieve(session.username)
		if not user then
			return nil, "Internal Error. User in session does not exist"
		else
			return true, user
		end
	else
		return false, "User not logged in"
	end
end



return module
