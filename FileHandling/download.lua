
local protocol = "download_file"

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

function download(serverId,filePath,targetFilePath)
    rednet.send(serverId,"request_download_file",protocol)
    print("Requested server to download file.")
    id,msg,p = rednet.receive(protocol,5)
    if id == serverId then
        if msg == "ready_for_download" then
            print("Server is ready for download.")
            rednet.send(serverId,filePath,protocol)
            id,content,p = rednet.receive(protocol,5)
            if id == serverId then
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

function start()
    reset()
    term.setCursorPos(1,4)
    term.write("Server-ID: ")
    serverId = tonumber(read())
    term.write("Server File Path: ")
    filePath = read()
    term.write("Target File Name: ")
    targetFilePath = read()
    term.setCursorPos(1,8)
    term.write("confirm with 'yes'")
    term.setCursorPos(1,7)
    term.write("Are you sure? ")
    if read() == "yes" then
        term.setCursorPos(1,9)
        download(serverId,filePath,targetFilePath)
    end
end

start()
