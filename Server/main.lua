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
local bUpdateNeeded = false

function NewClient(pUUID, pIP, pPort)
    local myClient = {}

    myClient.uuid = pUUID
    myClient.ip = pIP
    myClient.port = pPort
    myClient.x = 0
    myClient.y = 0
    myClient.sprite = "X"

    table.insert(clientsList, myClient)
    print("New Client "..pUUID)
    print("There is|are "..#clientsList.." client|s connected !")
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
        local keyword = string.sub(data, 1, separatorPos - 1)   -- Using (separatorPos - 1) for avoid to get ":" in the keyword variable
        print("Keyword : "..keyword)

        local data2 = string.sub(data, separatorPos + 1)        -- Getting all informations of the client after ":"
        local separatorPos = string.find(data2, ":")
        local UUID = string.sub(data2, 1, separatorPos - 1)      -- Get UUID
        print("UUID : "..UUID)

        local value = string.sub(data2, separatorPos + 1)        -- Then get the value
        print("Value : "..value)

        if string.upper(keyword) == "CONNECT" then
            NewClient(value, ip, port)
        elseif string.upper(keyword) == "SPRITE" then
            for client=1, #clientsList do
                if clientsList[client].uuid == UUID then
                    clientsList[client].sprite = value
                    print("Client "..client.." changed sprite to "..value)
                end
            end
            
            bUpdateNeeded = true

        elseif string.upper(keyword) == "X" then
            for client=1, #clientsList do
                if clientsList[client].uuid == UUID then
                    clientsList[client].x = value
                    print("Client "..client.." changed X to "..value)
                end
            end

            bUpdateNeeded = true

        elseif string.upper(keyword) == "Y" then
            for client=1, #clientsList do
                if clientsList[client].uuid == UUID then
                    clientsList[client].y = value
                    print("Client "..client.." changed Y to "..value)
                end
            end

            bUpdateNeeded = true

        end

        -- ...then we respond on the IP and the Port of the client
        datagram = string.format('{"keyword":"OK"}')
        udp:sendto(datagram, ip, port)
    end

    if bUpdateNeeded then
        for client=1, #clientsList do
            local destC = clientsList[client]

            for destClient=1, #clientsList do
                local c = clientsList[destClient]
                local datagram = ""
                datagram = string.format('{"keyword":"update","sprite":"%s","uuid":"%s","x":%d,"y":%d}', c.sprite, c.uuid, c.x, c.y)
                print("Send "..datagram)

                udp:sendto(datagram, destC.ip, destC.port)  -- Send new position to all clients
            end
        end

        bUpdateNeeded = false
    end

    -- Waiting a few seconds to avoid processor saturation
    socket.sleep(0.01)

end