module("bmale.core", package.seeall)

require "bmale.queries"
require "bmale.utils"

function sendMessage(id, sender)
	print("sending message for user "..bmale.utils.tostring(sender))
	local document = bmale.queries.fetchMessage(id,sender)
	document.message.messageType = "sent"
	document.message.content.from = sender.username
	
	-- parse message.content.destinationsQuote  and populate message.destinations
	local destQuote = document.message.content.destinationsQuote
	print("destinations quote: "..destQuote)
	document.message.destinations = {}
	document.message.submissionTasks = {}
	for dest in string.gmatch(destQuote, '([^,]+)') do
		dest = bmale.utils.trim(dest)
		local matched,name,addressType,domain
		matched,_,name = string.find(dest,"^(%a[%w.]*)$")
		print("dest: "..name)
		print("matched: "..matched)		
		if (matched) then
			-- This is a locally delivered message. We will need to create local copies for each destination
			local messageCopy = bmale.models.Message.copy(document)
			messageCopy.message.to = name
			messageCopy.message.from = sender.username
			print("message copy "..bmale.utils.tostring(messageCopy))
			bmale.queries.storeMessage(nil,messageCopy)
			--table.insert(document.message.destinations,name)
		else
			matched,_,name,addressType,domain = string.find(dest, "^(%a[%w.]*)([@#]?)(%a[%w.]*)$")
			if (matched) then
				local key = addressType..domain
				if ( not document.message.submissionTasks[ key ]) then
					document.message.submissionTasks[ key ] = {type = "sendremote", destinations = {}}
				end
				table.insert( document.message.submissionTasks[ key ]["destinations"], name )
			end
		end
	end
	print("local destinations "..bmale.utils.tostring(document.message.destinations) )
	print("submission tasks "..bmale.utils.tostring(document.message.submissionTasks) )

	return bmale.queries.storeMessage(id,document)
end
