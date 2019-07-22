
local protocol = "download_file"
local w,h = term.getSize()

local sModemSide = nil
for n,sSide in pairs( rs.getSides() ) do
    if peripheral.getType( sSide ) == "modem" and peripheral.call( sSide, "isWireless" ) then
        sModemSide = sSide
        break
    end
end

if sModemSide == nil then
    print( "No wireless modems found. 1 required." )
    return
end

rednet.open( sModemSide )

local hosts = nil
local tPaths = {}
local pathIndex = 0

function reset()
    term.setBackgroundColor(colors.black)
    term.clear()
    term.setTextColor(colors.white)
    term.setCursorPos(1,1)
end

function saveFile(filePath,content)
    print("Saving file to system...")
    file = io.open(filePath,"w")
    file:write(content)
    return file:close()
end

function error()
    print("Error: Download failed!")
end

function selectFromTable(tableIn,title)
  if title == nil then title = "Select" end
  local l = 1
  local m = #tableIn
  local host = tostring(tableIn[1])

  while true do
    term.setBackgroundColor(2048)
    term.setTextColor(1)
    term.clear()
    term.setCursorPos(math.floor(w/2-#title/2),3)
    term.write(title)

    for n=1,m do
      host = tostring(tableIn[n])
      if l == n then host = "["..host.."]" end
      term.setCursorPos(math.floor(w/2-#host/2), 5+n)
      print(host)
    end

    local a,b = os.pullEvent("key")
    if b == keys.up and l > 1 then l = l-1 end
    if b == keys.down and l < m then l = l+1 end
    if b == keys.enter then break end
  end
  return tableIn[l]
end

function download()
    serverId = selectFromTable(hosts,"Select host id")
    if serverId == nil then return end
    rednet.send(serverId,"request_download_file",protocol)
    id,msg,p = rednet.receive(protocol,5)
    if id == serverId then
        if msg == "ready_for_download" then
            id,paths,p = rednet.receive(p,5)
            tPaths = textutils.unserialize(paths)
            pathIndex = selectFromTable(tPaths)
            rednet.send(serverId,pathIndex,protocol)
            id,content,p = rednet.receive(protocol,5)
            if id == serverId then
                local targetFilePath = read()
                if saveFile(targetFilePath,content) then
				            print("Download success!")
                    sleep(1)
                    reset()
                end
            else
                error()
            end
        end
    else
        error()
    end
end

term.setBackgroundColor(2048)
term.clear()
term.setCursorPos(w/2-string.len("Searching for hosts...")/2,3)
print("Searching for hosts...")
hosts = { rednet.lookup(protocol) }
if hosts == {} then
  reset()
  print("No hosts are available! :/")
  return
else
  download()
end
