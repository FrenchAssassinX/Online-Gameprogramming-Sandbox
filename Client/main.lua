io.stdout:setvbuf('no')

--Socket and its properties
local socket = require "socket"
local address = "localhost"
local port = 55555

local uuid

local updateRate = 1
local updateTimer
local isConnected = false

local lastMessage = ""


print "===================================="
print "| FrenchAssassinX client started ! |"
print "===================================="


-- Function to generate an unique client ID
local function GenUuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and love.math.random(0, 0xf) or love.math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

function love.load()
    udp = socket.udp()
    udp:settimeout(0)
    udp:setpeername(address, port)

    math.randomseed(os.time())
    uuid = GenUuid()

    updateTimer = 0
end

function SendKeyword(pKeyword, pData)
    local dg = pKeyword..":"..pData
    udp:send(dg)
end

function love.update(dt)

    if isConnected == false then
        SendKeyword("Connect:", uuid)
        isConnected = true
    end

    updateTimer = updateTimer + dt

    if updateTimer > updateRate then
        --SendKeyword("Update:", uuid)
        updateTimer = updateTimer - updateRate
    end

    data, msg = udp:receive()

    if data then
        print(string.format("Received at %s : %s", socket.gettime(), data))

        local separatorPos = string.find(data, ":")

        if separatorPos ~= nil then
            local keyword = string.sub(data, 1, separatorPos - 1) -- Using (separatorPos - 1) for avoid to get ":" in the keyword variable
            print("Keyword : "..keyword)
            local value = string.sub(data, separatorPos + 1) -- Getting all informations of the client after ":"

            if string.upper(keyword) == "MESSAGE" then
                lastMessage = value
                print("Message: "..lastMessage)
            end
        end

    elseif msg ~= "timeout" then
        error("Network error: "..tostring(msg))
    end

end

function love.draw()
    love.graphics.print("Client "..uuid)
end

function love.keypressed(pKey)
    if pKey == "0" then
        SendKeyword("Message", "Ahoy!")
    end
    if pKey == "1" then
        SendKeyword("Message", "Go!")
    end
    if pKey == "2" then
        SendKeyword("Message", "Alert!")
    end
    if pKey == "3" then
        SendKeyword("Message", "Where is Brian ?")
    end
    if pKey == "4" then
        SendKeyword("Message", "Brian is in the kitchen")
    end
    if pKey == "5" then
        SendKeyword("Message", "Attack")
    end
    if pKey == "6" then
        SendKeyword("Message", "Defense")
    end
    if pKey == "7" then
        SendKeyword("Message", "Run!")
    end
    if pKey == "8" then
        SendKeyword("Message", "Exit")
    end
    if pKey == "9" then
        SendKeyword("Message", "Fire!")
    end
end