-- Debug logs go to the SERVER console (txAdmin Live Console / server terminal), not the game client.
-- First line: if you never see this, server.lua is not running (resource not started or wrong folder name in server.cfg).
print('^2[radio] server.lua is running^0')

local endpoint = 'https://tkcplmaczfdevzrlimpg.supabase.co/functions/v1/public-requests'

local resName = GetCurrentResourceName()
print(('[radio:debug] Resource name: %s'):format(tostring(resName)))

local Config = {}
local configFile = LoadResourceFile(resName, 'config.json')
print(('[radio:debug] config.json loaded: %s (%s bytes)'):format(configFile and 'yes' or 'no', configFile and #configFile or 0))
if configFile and configFile ~= '' then
    local ok, result = pcall(json.decode, configFile)
    if ok and result and type(result) == 'table' then
        Config = result
        print(('[radio:debug] Config parsed. communityName: %s'):format(tostring(Config.communityName)))
    else
        print(('[radio:debug] config.json parse failed: %s'):format(tostring(result)))
    end
else
    print('[radio:debug] No config file content')
end

-- Make a string safe for JSON: escape backslash and quote, strip control characters.
local function jsonSafeString(s)
    if s == nil then return '' end
    s = tostring(s)
        :gsub('\\', '\\\\')
        :gsub('"', '\\"')
        :gsub('[\0-\31]', '')  -- remove control characters
    return s
end

local function sendRequest(source, type, message)
    local displayName = GetPlayerName(source)
    if not displayName or displayName == '' then
        displayName = 'Player'
    end

    local serverName = (Config.communityName and Config.communityName ~= '') and Config.communityName or GetConvar('sv_hostname', 'FiveM Server')

    message = jsonSafeString(message)
    displayName = jsonSafeString(displayName)
    serverName = jsonSafeString(serverName)

    print(('[radio:debug] sendRequest source=%s type=%s message=%s displayName=%s serverName=%s'):format(tostring(source), type, message, displayName, serverName))

    local body = json.encode({
        type = type,
        message = message,
        display_name = displayName,
        server_name = serverName,
        source = 'FiveM'
    })

    local headers = { ['Content-Type'] = 'application/json' }

    PerformHttpRequest(endpoint, function(statusCode, responseText, responseHeaders)
        print(('[radio:debug] HTTP response status=%s body=%s'):format(tostring(statusCode), responseText and responseText:sub(1, 200) or 'nil'))
        if statusCode >= 200 and statusCode < 300 then
            -- optional: notify player of success
        else
            if source > 0 then
                local msg
                if statusCode == 403 then
                    msg = 'Presenter is not live.'
                else
                    msg = ('Request failed (%s).'):format(tostring(statusCode))
                end
                TriggerClientEvent(resName .. ':notify', source, msg)
            else
                print(('[radio] Request failed (type=%s): %s'):format(type, tostring(statusCode)))
            end
        end
    end, 'POST', body, headers)
end

-- Get message from raw command string so # and other chars aren't stripped by the shell/chat.
-- rawCommand is the full line (e.g. "/requestsong Coldplay - Yellow #1"); we strip the command prefix and use the rest.
local function messageFromRaw(rawCommand, commandName)
    if not rawCommand or rawCommand == '' then return '' end
    local escaped = commandName:gsub('([%-%^%$%(%)%%%.%[%]*%+%?])', '%%%1')
    local message = rawCommand:match('^/?%s*' .. escaped .. '%s*(.*)$')
    if message then
        return message:match('^%s*(.-)%s*$') or message
    end
    return ''
end

print('[radio:debug] Registering command /requestsong')
RegisterCommand('requestsong', function(source, args, rawCommand)
    local message = messageFromRaw(rawCommand, 'requestsong')
    print(('[radio:debug] /requestsong invoked source=%s raw=%s message=%s'):format(tostring(source), tostring(rawCommand), message))
    if message == '' then
        if source > 0 then
            TriggerClientEvent(resName .. ':notify', source, 'Usage: /requestsong <message>')
        else
            print('Usage: requestsong <message>')
        end
        return
    end
    sendRequest(source, 'song', message)
end, false)

print('[radio:debug] Registering command /shoutout')
RegisterCommand('shoutout', function(source, args, rawCommand)
    local message = messageFromRaw(rawCommand, 'shoutout')
    print(('[radio:debug] /shoutout invoked source=%s raw=%s message=%s'):format(tostring(source), tostring(rawCommand), message))
    if message == '' then
        if source > 0 then
            TriggerClientEvent(resName .. ':notify', source, 'Usage: /shoutout <message>')
        else
            print('Usage: shoutout <message>')
        end
        return
    end
    sendRequest(source, 'shoutout', message)
end, false)

-- Register chat suggestions so commands show when players type /
local function addChatSuggestions(target)
    print(('[radio:debug] addChatSuggestions target=%s'):format(tostring(target)))
    TriggerClientEvent('chat:addSuggestion', target, '/requestsong', 'Request a song (when presenter is live).', {
        { name = 'message', help = 'Your song request' }
    })
    TriggerClientEvent('chat:addSuggestion', target, '/shoutout', 'Send a shoutout (when presenter is live).', {
        { name = 'message', help = 'Your shoutout message' }
    })
end

print('[radio:debug] Registering onResourceStart handler')
AddEventHandler('onResourceStart', function(resourceName)
    print(('[radio:debug] onResourceStart resourceName=%s current=%s'):format(tostring(resourceName), resName))
    if resName ~= resourceName then return end
    print('[radio:debug] Radio resource started, sending chat suggestions to all players')
    addChatSuggestions(-1)
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    print(('[radio:debug] playerConnecting source=%s'):format(tostring(source)))
    addChatSuggestions(source)
end)

print('[radio:debug] server.lua loaded (commands and events registered)')
