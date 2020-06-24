io.stdout:setvbuf('no')

--Socket and its properties
local socket = require "socket"
local address = "localhost"
local port = 55555

-- Get an instance of lib json.lua
local json = require("json")

local uuid

local updateRate = 1
local updateTimer
local isConnected = false
local bChanged = true

local lastMessage = ""

local X,Y = love.math.random(1, 800), love.math.random(1, 600)
local sprite = "fish_1"

local clientsList = {}


print "===================================="
print "| FrenchAssassinX client started ! |"
print "===================================="


--------------------------------------------- Specifice functions ------------------------------------------
function NewClient(pUUID, pSprite, pX, pY)
    local myClient = {}

    myClient.uuid = pUUID
    myClient.sprite = love.graphics.newImage("pics/"..pSprite..".png")
    --myClient.sprite = pSprite
    myClient.x = pX
    myClient.y = pY

    table.insert(clientsList, myClient)
    print("New Client "..myClient.uuid)
    print("There is|are "..#clientsList.." client|s connected !")
end

-- Function to generate an unique client ID
local function GenUuid()
    local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and love.math.random(0, 0xf) or love.math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

function SendKeyword(pKeyword, pData)
    local datagram = pKeyword..":"..uuid..":"..pData
    udp:send(datagram)
end
--------------------------------------------- End Specific functions ------------------------------------------


-------------------------------------------------- Love 2D ----------------------------------------------------
function love.load()
    udp = socket.udp()
    udp:settimeout(0)
    udp:setpeername(address, port)

    math.randomseed(os.time())
    uuid = GenUuid()

    updateTimer = 0
end

function love.update(dt)

    if isConnected == false then
        SendKeyword("Connect", uuid)
        isConnected = true
    end

    updateTimer = updateTimer + dt

    if updateTimer > updateRate then
        updateTimer = updateTimer - updateRate
        
        if bChanged then
            SendKeyword("X", X)
            SendKeyword("Y", Y)
            bChanged = false
        end
    end

    data, msg = udp:receive()

    local bExist = false    -- Boolean to detect if a client already exist on the list
    if data then
        print(string.format("Received at %s : %s", socket.gettime(), data))
        local datagram = json.decode(data)

        -- Updating our clients
        if string.upper(datagram.keyword) == "UPDATE" then
            for client=1, #clientsList do
                c = clientsList[client]
                
                -- If the client already exists on the list then updating it with sprite and pos
                if c.uuid == datagram.uuid then
                    bExist = true

                    c.sprite = love.graphics.newImage("pics/"..datagram.sprite..".png")
                    c.x = datagram.x
                    c.y = datagram.y
                end
            end

            -- Else create the new client
            if bExist == false then
                NewClient(datagram.uuid, datagram.sprite, datagram.x, datagram.y)
            end
        end

    elseif msg ~= "timeout" then
        error("Network error: "..tostring(msg))
    end

    if love.keyboard.isDown("right") then
        X = X + 1
        bChanged = true
    end
    if love.keyboard.isDown("left") then
        X = X - 1
        bChanged = true
    end
    if love.keyboard.isDown("up") then
        Y = Y - 1
        bChanged = true
    end
    if love.keyboard.isDown("down") then
        Y = Y + 1
        bChanged = true
    end
end

function love.draw()
    love.graphics.print("Client "..uuid.." | Nb clients: "..#clientsList)

    for client=1, #clientsList do
        c = clientsList[client]
        love.graphics.draw(c.sprite, c.x, c.y)
    end
end

function love.keypressed(pKey)
    if pKey == "0" then
        SendKeyword("Sprite", "fish_1")
        sprite = "fish_1"
    end
    if pKey == "1" then
        SendKeyword("Sprite", "fish_2")
        sprite = "fish_2"
    end
    if pKey == "2" then
        SendKeyword("Sprite", "fish_3")
        sprite = "fish_3"
    end
    if pKey == "3" then
        SendKeyword("Sprite", "fish_4")
        sprite = "fish_4"
    end
    if pKey == "4" then
        SendKeyword("Sprite", "fish_5")
        sprite = "fish_5"
    end
    if pKey == "5" then
        SendKeyword("Sprite", "fish_6")
        sprite = "fish_6"
    end
    if pKey == "6" then
        SendKeyword("Sprite", "fish_7")
        sprite = "fish_7"
    end
    if pKey == "7" then
        SendKeyword("Sprite", "fish_8")
        sprite = "fish_8"
    end
    if pKey == "8" then
        SendKeyword("Sprite", "fish_9")
        sprite = "fish_9"
    end
    if pKey == "9" then
        SendKeyword("Sprite", "fish_10")
        sprite = "fish_10"
    end
end
------------------------------------------------ End Love 2D ---------------------------------------------------