class 'AutoUpdate'

function AutoUpdate:__init(localVersion, host, versionPath, scriptPath, savePath, callbackUpdate, callbackNoUpdate, callbackNewVersion, callbackError)
	self.localVersion = localVersion
	self.versionPath = host .. versionPath
	self.scriptPath = host .. scriptPath
	self.savePath = savePath
	self.callbackUpdate = callbackUpdate
	self.callbackNoUpdate = callbackNoUpdate
	self.callbackNewVersion = callbackNewVersion
	self.callbackError = callbackError
	self:createSocket(self.versionPath)
	self.downloadStatus = 'Connect to Server for VersionInfo'
	AddTickCallback(function() self:getVersion() end)
end

function AutoUpdate:createSocket(url)
	if not self.LuaSocket then
	    self.LuaSocket = require("socket")
	else
	    self.socket:close()
	    self.socket = nil
	end
	self.LuaSocket = require("socket")
	self.socket = self.LuaSocket.tcp()
	self.socket:settimeout(0, 'b')
	self.socket:settimeout(99999999, 't')
	self.socket:connect("linkpad.fr", 80)
	self.url = "/aurora/TcpUpdater/getscript.php?page=" .. url
	self.started = false
	self.File = ''
end

function AutoUpdate:getVersion()
	if self.gotScriptVersion then return end

	local Receive, Status, Snipped = self.socket:receive(1024)
	if Status == 'timeout' and self.started == false then
		self.started = true
	    self.socket:send("GET ".. self.url .." HTTP/1.0\r\nHost: linkpad.fr\r\n\r\n")
	end
	if (Receive or (#Snipped > 0)) then
		self.File = self.File .. (Receive or Snipped)
	end
	if Status == "closed" then
		local _, ContentStart = self.File:find('<scriptdata>')
		local ContentEnd, _ = self.File:find('</scriptdata>')
		if not ContentStart or not ContentEnd then
		    self.callbackError()
		else
			self.onlineVersion = tonumber(self.File:sub(ContentStart + 1,ContentEnd-1))
			if self.onlineVersion > self.localVersion then
				self.callbackNewVersion(self.onlineVersion)
				self:createSocket(self.scriptPath)
				self.DownloadStatus = 'Connect to Server for ScriptDownload'
				AddTickCallback(function() self:downloadUpdate() end)

			elseif self.onlineVersion <= self.localVersion then
				self.callbackNoUpdate()
			end
		end
		self.gotScriptVersion = true

	end
end

function AutoUpdate:downloadUpdate()
	if self.gotScriptUpdate then return end

	local Receive, Status, Snipped = self.socket:receive(1024)
	if Status == 'timeout' and self.started == false then
		self.started = true
	    self.socket:send("GET ".. self.url .." HTTP/1.0\r\nHost: linkpad.fr\r\n\r\n")
	end
	if (Receive or (#Snipped > 0)) then
		self.File = self.File .. (Receive or Snipped)
	end
	if Status == "closed" then
		local _, ContentStart = self.File:find('<scriptdata>')
		local ContentEnd, _ = self.File:find('</scriptdata>')

		if not ContentStart or not ContentEnd then
		    self.callbackError()
		else
			self.File = self.File:sub(ContentStart + 1,ContentEnd-1)
			local f = io.open(self.savePath,"w+b")
			f:write(self.File)
			f:close()
			self.CallbackUpdate(self.onlineVersion, self.localVersion)
		end
		self.gotScriptUpdate = true

	end
end

function checkUpdate()
	local ToUpdate = {}
	ToUpdate.Version = 0.2
	ToUpdate.Name = "Auth"
	ToUpdate.Host = "raw.githubusercontent.com"
	ToUpdate.VersionPath = "/linkpad/BoL/master/autoupdate.version"
	ToUpdate.ScriptPath =  "/linkpad/BoL/master/autoupdate.lua"
	ToUpdate.SavePath = SCRIPT_PATH.."/" .. GetCurrentEnv().FILE_NAME
	ToUpdate.CallbackUpdate = function(NewVersion,OldVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") end
	ToUpdate.CallbackNoUpdate = function() print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">No Updates Found</b></font>") end
	ToUpdate.CallbackNewVersion = function(NewVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">New Version found ("..NewVersion.."). Please wait until its downloaded</b></font>") end
	ToUpdate.CallbackError = function(NewVersion) print("<font color=\"#FF794C\"><b>" .. ToUpdate.Name .. ": </b></font> <font color=\"#FFDFBF\">Error while Downloading. Please try again.</b></font>") end
	AutoUpdate(ToUpdate.Version, ToUpdate.Host, ToUpdate.VersionPath, ToUpdate.ScriptPath, ToUpdate.SavePath, ToUpdate.CallbackUpdate,ToUpdate.CallbackNoUpdate, ToUpdate.CallbackNewVersion,ToUpdate.CallbackError)
end

function OnLoad()
	checkUpdate()

	print('This is the second version')
end
