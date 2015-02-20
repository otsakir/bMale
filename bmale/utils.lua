module("bmale.utils", package.seeall)

local stdstring = require "std.string"

function tostring(o) 
	return stdstring.prettytostring(o)
end


-- a workaround to extract the bmaleticket from the header until we sort why orbit's web.cookies table does not work
-- header can be 'web.vars.HTTP_COOKIE'
-- returns the cookie's content or nil if no such cookie is found
function extractTicketFromHeader( header )
	return header:match("bmaleticket=([^;]+);?")
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end
