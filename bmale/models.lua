module("bmale.models", package.seeall)

print("executing bmale.models module")

function info()
	return "in bmale.models module"
end


Message = {}

--[[
{
	type = "message",
	message = {
		messageType = "normal"
		from = "max",
		local = "true" ?
		destinations = ["alice#earth","bob#earth","zodiac#zeus"]
		content = {
			title = "Hello guys",
			body = "This is Max",
			destinationsQuote = "alice#earth, bob#earth, zodiac#zeus"
		}
	}
}
--]]
function Message.default()
	local o = {
		type = "message",
		message = {
			messageType = "normal",
			--from = "max",
			--local = "true" ?
			--destinations = ["alice#earth","bob#earth","zodiac#zeus"]
			content = {
				title = "",
				-- body = "",
				-- destinationsQuote = "alice#earth, bob#earth, zodiac#zeus"
			}
		}
	}
	return o
end
function Message.new(p)
	local d = Message.default()
	if (p) then
		for key in pairs(p) do
			d[key] = p[key]			
		end
	end
	return d
end
-- only common fields are populated
function Message.fromMessageDto(dto)
	local o = Message.default()
	o.message.content.title = dto.title
	o.message.content.body = dto.body
	o.message.content.destinationsQuote = dto.typedDestinations
	return o
end


MessageDto = {}
--[[
{
	id = "xxxxx",
	revision = "x-xxxx",
	title = "Hello guys",
	body = "This is Max",
	typedDestinations = "alice#earth, bob#earth, zodiac#zeus",
	from = "max"
}	
--]]
function MessageDto.fromMessage(m)
	local o = {
		id = m._id,
		revision = m._rev,
		title = m.message.content.title,
		body = m.message.content.body,
		typedDestinations = m.message.content.destinationsQuote,
		from = m.message.from
	}
	return o
end
function MessageDto.fromMessageContent(c,id)
	local o = {
		id = id,
		-- revision = m._rev,
		title = c.title,
		body = c.body,
		typedDestinations = c.destinationsQuote,
		from = c.from		
	}
	return o
end

SubmissionTask = {}
function SubmissionTask.default()
	local o = {
		type = "sendremote",
		--destinations = {}	
	}
	return o
end

--[[ 	submissionTasks = [
		{type = "sendremote", destinations = ["alice#earth", "bob#earth"]}, 
		{type = "sendremote", destinations = ["zodiac#zeus"]}
	]
--]]
