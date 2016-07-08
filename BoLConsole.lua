class 'SocketConnection'
function SocketConnection:CreateSocket()
	print("try to connect")
	socket = require("socket")
	self.socket = socket.tcp()
	self.socket:settimeout(0, 'b')
	self.socket:settimeout(99999999, 't')
	self.socket:connect("127.0.0.1", 8080)
	AddTickCallback(function() self:ReceiveData() end)
	socketCreated = true
	_G.WriteConsole = WriteConsole
	_G.PrintChat = _G.WriteConsole
end

function SocketConnection:CloseSocket()
	self.socket:close()
end

function SocketConnection:SendData(str)
	self.socket:send(str)
end

function SocketConnection:ReceiveData()
	local Receive, Status, Snipped = self.socket:receive(1024)
	if (Receive or (#Snipped > 0)) then
		SocketConnection:Handler((Receive or Snipped))
	end
end

function SocketConnection:Handler(packet)
	ExecuteCommand(packet)
end

function OnLoad()
	SocketConnection:CreateSocket()
	SocketConnection:SendData("[BoL console] Connection establish !<EOF>")
end

function OnUnload()
	print("unloaded")
	SocketConnection:CloseSocket()
end


function ExecuteCommand(cmd)
    if cmd ~= "" then 
        ExecuteLUA(cmd)
    end
end

function ExecuteLUA(cmd)
    local func, err = load(cmd, "", "t", _ENV)
    if func then
        return pcall(func)
    else
        return false, err
    end
end

function WriteConsole(msg)
	if socketCreated then
		SocketConnection:SendData(msg .. "\n\r<EOF>")
	end
end
