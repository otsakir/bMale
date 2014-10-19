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



return module
