local json = require "json"
local suit = require "suit"
local enet = require "enet"

local normalfont = love.graphics.newFont(14)

local host = enet.host_create("localhost:12345")

local receivedata = "Empty"

local labeltheme = {align='left', font=normalfont}

local actions = {}
local reverseactions = {'attack', 'defense', 'move', 'heal'}
for i, v in ipairs(reverseactions) do
  actions[v] = i
end

local user

local logfile

function love.load()

end

function love.update(deltatime)
  suit.layout:reset(50, 50)
  
  suit.Label("server", labeltheme, suit.layout:row(300, 50))
  
  local event = host:service(100)
  if event then
    if event.type == "connect" then
      user = event.peer
      logfile = io.open("user.log", "a")
    elseif event.type == "receive" then
      receivedata = decodedata(event.data)
      user:send(digestData(event.data))
      --receivedata = event.data
      if logfile then logfile:write(receivedata.."\n") end
    elseif event.type == "disconnect" then
      user = nil
      if logfile then logfile.close() end
    end
  end
  
  
  suit.Label("listening...", labeltheme, suit.layout:row())
  
  if user then
    suit.Label(string.format("connected <- %s", user), labeltheme, suit.layout:row())
    suit.Label("receive: "..receivedata, labeltheme, suit.layout:row())
  end
  
  
  
  
end

function decodedata(data)
  data = json.decode(data)
  if data then
    return string.format("id: "..data.id.." action: "..reverseactions[data.action])
  end
  return ""
end

function digestData(data)
  return data.." from server"
end

function love.draw()
  suit.draw()
end

function love.quit()
  if user then
    user.disconnect_now()
  end
end