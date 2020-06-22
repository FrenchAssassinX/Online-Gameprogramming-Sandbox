io.stdout:setvbuf('no')

--Socket and its properties
local socket = require "socket"
local address = "localhost"
local port = 55555

local uuid

local updateRate = 1
local updateTimer


print "===================================="
print "| FrenchAssassinX client started ! |"
print "===================================="


-- Function to generate an unique client ID
local function GenUuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(
        template, 
        '[xy]',
        function (c)
            local v = (c == 'x') and love.math.random(0, 0xf) or love.math.random(8, 0xb)
            return string.format('%x', v)
        end
    )
end

function love.load()
    udp = socket.udp()
    udp:settimeout(0)
    udp:setpeername(address, port)

    math.randomseed(os.time())
    uuid = GenUuid()

    updateTimer = 0
end

function love.update(dt)

    updateTimer = updateTimer + dt

    if updateTimer > updateRate then
        local dg = "Hello I am "..uuid
        udp:send(dg)
        updateTimer = updateTimer - updateRate
    end

    print("Update "..os.time())

    data, msg = udp:receive()

    if data then
        print(string.format("Received at %s : %s", socket.gettime(), data))
    elseif msg ~= "timeout" then
        error("Network error: "..tostring(msg))
    end

end

function love.draw()
    love.graphics.print("Client "..uuid)
end