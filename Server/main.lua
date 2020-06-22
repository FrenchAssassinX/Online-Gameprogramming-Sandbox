-- Get an instance of Luasocket
local socket = require "socket"

-- Request an UDP socket from Luasocket
local udp = socket.udp()

-- Disable the timeout for waiting forever
udp:settimeout(0)

-- Linking socket to an adress and port of our choice
-- Using "*" can linking all local IP adresses
udp:setsockname('*', 55555)

-- Var local to main.lua
local data, ip, port -- To read received datas
local running = true -- Can handling a condition to get out of the infinite loop


print "=================================="
print "| FrenchAssassinX server started |"
print "=================================="


local clientsList = {}

function newClient(pUUID, pIP, pPort)
    local myClient = {}

    myClient.uuid = pUUID
    myClient.ip = pIP
    myClient.port = pPort

    table.insert(clientsList, myClient)
    print("New Client "..pUUID)
    print("Their is|are "..#clientsList.." client|s connected !")
end

-- Infinite loop
while running do

    -- Reading socket
    data, ip, port = udp:receivefrom()

    -- If we have received datas...
    if data then
        print(string.format(
            "Received at %d : [%s] from %s | Port : %s",
            socket.gettime(), data, ip, port
        ))

        local separatorPos = string.find(data, ":")
        local keyword = string.sub(data, 1, separatorPos - 1) -- Using (separatorPos - 1) for avoid to get ":" in the keyword variable
        print("Keyword : "..keyword)

        local value = string.sub(data, separatorPos + 1) -- Getting all informations of the client after ":"

        if string.upper(keyword) == "CONNECT" then
            newClient(value, ip, port)
        elseif string.upper(keyword) == "MESSAGE" then
            for client=1, #clientsList do
                udp:sendto(data, clientsList[client].ip, clientsList[client].port)
            end
        end

        -- ...then we respond on the IP and the Port of the client
        udp:sendto("How are you ", ip, port)
    end

    -- Waiting a few seconds to avoid processor saturation
    socket.sleep(0.01)

end