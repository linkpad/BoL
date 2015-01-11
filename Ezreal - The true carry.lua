local version = "0.2a"
 
if myHero.charName ~= "Ezreal" then return end
 
 _G.UseUpdater = true
 
local REQUIRED_LIBS = {
        ["SxOrbwalk"] = "https://raw.githubusercontent.com/Superx321/BoL/master/common/SxOrbWalk.lua",
        ["VPrediction"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua",
}
 
local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0
 
function AfterDownload()
        DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
        if DOWNLOAD_COUNT == 0 then
                DOWNLOADING_LIBS = false
                print("<b><font color=\"#FF001E\">Ezreal - The true carry</font></b> <font color=\"#FF980F\">Required libraries downloaded successfully, please reload (double F9).</font>")
        end
end
 
for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
        if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
                require(DOWNLOAD_LIB_NAME)
        else
                DOWNLOADING_LIBS = true
                DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
                DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
        end
end
 
if DOWNLOADING_LIBS then return end
 
local UPDATE_NAME = "Ezreal - The true carry"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/linkpad/BoL/master/Ezreal - The true carry.lua" .. "?rand=" .. math.random(1, 10000)
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "http://"..UPDATE_HOST..UPDATE_PATH
 
 
function AutoupdaterMsg(msg) print("<b><font color=\"#FF001E\">"..UPDATE_NAME..":</font></b> <font color=\"#FF980F\">"..msg..".</font>") end
if _G.UseUpdater then
        local ServerData = GetWebResult(UPDATE_HOST, UPDATE_PATH)
        if ServerData then
                local ServerVersion = string.match(ServerData, "local version = \"%d+.%d+\"")
                ServerVersion = string.match(ServerVersion and ServerVersion or "", "%d+.%d+")
                if ServerVersion then
                        ServerVersion = tonumber(ServerVersion)
                        if tonumber(version) < ServerVersion then
                                AutoupdaterMsg("New version available "..ServerVersion)
                                AutoupdaterMsg("Updating, please don't press F9")
                                DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Successfully updated. ("..version.." => "..ServerVersion.."), press F9 twice to load the updated version.") end)  
                        else
                                AutoupdaterMsg("You have got the latest version ("..ServerVersion..")")
                        end
                end
        else
                AutoupdaterMsg("Error downloading version info")
        end
end

function OnLoad()
        print("<b><font color=\"#FF001E\">Ezreal  The true carry : </font></b><font color=\"#FF980F\"> Free elo for you ! </font><font color=\"#FF001E\">| Linkpad |</font>")
        -- Variables()
        -- Menu()
end
