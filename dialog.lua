require "iuplua"

-- Bizarre kludge: For reasons I do not understand at all, radio buttons do not work in FCEUX. Switch to menus there only
local optionLetter = "o"
if FCEU then optionLetter = "l" end

function ircDialog(data)

	local function isInvalid(data)

		local failed = false
		local function scrub(invalid) errorMessage(invalid) failed = true end

		if not nonempty(data.server) then scrub("Server not valid")
		elseif not nonzero(data.port) then scrub("Port not valid")
		elseif not nonempty(data.nick) then scrub("Nick not valid")
		elseif not nonempty(data.partner) then scrub("Partner nick not valid")
		elseif data.nick == data.partner then scrub("Nicknames can't be the same")
		end

		if failed then gui.register(printMessage) end
		return failed
	end

	local function defaults()
		return {
			server="irc.speedrunslive.com",
			port=6667,
			nick="",
			partner="",
			forceSend=0
		}
	end

	if data == nil then data = defaults() end

	local res, server, port, nick, partner, forceSend = iup.GetParam("Connection settings", nil,
	    "Enter an IRC server: %s\n" ..
		"IRC server port: %i\n" ..
		"Your nick: %s\n" ..
		"Partner nick: %s\n" ..
		"%t\n" .. -- <hr>
		"Are you restarting\rafter a crash? %" .. optionLetter .. "|No|Yes|\n"
	    , data.server, data.port, data.nick, data.partner, data.forceSend)

	local newData = {server=server, port=port, nick=nick, partner=partner, forceSend=forceSend}

	if res == false then return nil end
	if isInvalid(newData) == true then return ircDialog(newData) end

	return {server=server, port=port, nick=nick, partner=partner, forceSend=forceSend==1 }
end

function selectDialog(specs, reason)
	local names = ""
	for i, v in ipairs(specs) do
		names = names .. v.name .. "|"
	end

	local res, selection = iup.GetParam("Select game", nil,
	    "Can't figure out\rwhich game to load\r(" .. reason .. ")\r" ..
	    "Which game is this? " ..
		"%l|" .. names .. "\n",
		0)

	if 0 == res or nil == selection then return nil end

	return specs[selection + 1]
end

function refuseDialog(options)
	iup.Message("Cannot run", "No ROM is running.")
end