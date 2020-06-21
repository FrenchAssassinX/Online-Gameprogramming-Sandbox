-- Get an instance of Luasocket
local socket = require "socket"

-- Request an UDP socket from Luasocket
local udp = socket.udp()

-- Disable the timeout for waiting forever
udp::settimeout(0)

-- Linking socket to an adress and port of our choice
-- Using "*" can linking all local IP adresses
udp:setsocketname('*', 55555)

-- Var local to main.lua
local data, ip, port -- To read received datas
local running = true -- Can handling a condition to get out of the infinite loop


print "=================================="
print "| FrenchAssassinX server started |"
print "=================================="


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

        -- ...then we respond on the IP and the Port of the client
        udp:sento("How are you ", ip, port)
    end

    -- Waiting a few seconds to avoid processor saturation
    socket.sleep(0.01)

end