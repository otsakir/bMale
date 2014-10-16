#!/usr/bin/env wsapi.cgi

local orbit = require "orbit"

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
