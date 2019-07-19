local protocol = "upload_file"

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

function getFileContent(filePath)
    print("Getting file content...")
    file = io.open(filePath,"r")
    content = file:read("*a")
    file:close()
    return content
end

function error()
    print("Error: Upload failed!")
end

function upload(serverId,filePath,targetFilePath)
    fileContent = getFileContent(filePath)
    rednet.send(serverId,"request_upload_file",protocol)
    print("Requested server to upload file.")
    id,msg,p = rednet.receive(protocol,5)
    if id == serverId then
        if msg == "ready_for_upload" then
            print("Server is ready for upload.")
            rednet.send(serverId,targetFilePath,protocol)
            rednet.send(serverId,fileContent,protocol)
            id,msg,p = rednet.receive(protocol,5)
            if id == serverId then
                if msg == "upload_success" then
                    print("Success!")
                    sleep(3)
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
    term.setCursorPos(1,3)
    term.write("Server-ID: ")
    serverId = tonumber(read())
    term.write("File Path: ")
    filePath = read()
    term.write("Target File Name: ")
    targetFilePath = read()
    term.setCursorPos(1,7)
    term.write("confirm with 'yes'")
    term.setCursorPos(1,6)
    term.write("Are you sure? ")
    if read() == "yes" then
        term.setCursorPos(1,8)
        upload(serverId,filePath,targetFilePath)
    end
end

start()
