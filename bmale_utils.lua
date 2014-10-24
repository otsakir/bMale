local module = {}

-- a workaround to extract the bmaleticket from the header until we sort why orbit's web.cookies table does not work
-- header can be 'web.vars.HTTP_COOKIE'
-- returns the cookie's content or nil if no such cookie is found
function module.extractTicketFromHeader( header )
	return header:match("bmaleticket=([^;]+);?")
end

return module
