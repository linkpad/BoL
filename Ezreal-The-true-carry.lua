if myHero.charName ~= "Ezreal" then return end

local Ez_version = 1.1


class "SxUpdate"
function SxUpdate:__init(LocalVersion, Host, VersionPath, ScriptPath, SavePath, Callback)
    self.Callback = Callback
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = VersionPath
    self.ScriptPath = ScriptPath
    self.SavePath = SavePath
    self.LuaSocket = require("socket")
    AddTickCallback(function() self:GetOnlineVersion() end)
end

function SxUpdate:GetOnlineVersion()
    if not self.OnlineVersion and not self.VersionSocket then
        self.VersionSocket = self.LuaSocket.connect("sx-bol.eu", 80)
        self.VersionSocket:send("GET /BoL/TCPUpdater/GetScript.php?script="..self.Host..self.VersionPath.."&rand="..tostring(math.random(1000)).." HTTP/1.0\r\n\r\n")
    end

    if not self.OnlineVersion and self.VersionSocket then
        self.VersionSocket:settimeout(0, 'b')
        self.VersionSocket:settimeout(99999999, 't')
        self.VersionReceive, self.VersionStatus = self.VersionSocket:receive('*a')
    end

    if not self.OnlineVersion and self.VersionSocket and self.VersionStatus ~= 'timeout' then
        if self.VersionReceive then
            self.OnlineVersion = tonumber(string.sub(self.VersionReceive, string.find(self.VersionReceive, "<bols".."cript>")+11, string.find(self.VersionReceive, "</bols".."cript>")-1))
        else
            print('AutoUpdate Failed')
			self.OnlineVersion = 0
        end
        self:DownloadUpdate()
    end
end

function SxUpdate:DownloadUpdate()
    if self.OnlineVersion > self.LocalVersion then
        self.ScriptSocket = self.LuaSocket.connect("sx-bol.eu", 80)
        self.ScriptSocket:send("GET /BoL/TCPUpdater/GetScript.php?script="..self.Host..self.ScriptPath.."&rand="..tostring(math.random(1000)).." HTTP/1.0\r\n\r\n")
        self.ScriptReceive, self.ScriptStatus = self.ScriptSocket:receive('*a')
        self.ScriptRAW = string.sub(self.ScriptReceive, string.find(self.ScriptReceive, "<bols".."cript>")+11, string.find(self.ScriptReceive, "</bols".."cript>")-1)
        local ScriptFileOpen = io.open(self.SavePath, "w+")
        ScriptFileOpen:write(self.ScriptRAW)
        ScriptFileOpen:close()
    end

    if type(self.Callback) == 'function' then
        self.Callback(self.OnlineVersion)
    end
end

local ForceReload = false
SxUpdate(Ez_version,
	"raw.githubusercontent.com",
	"/linkpad/BoL/master/Ezreal-The-true-carry.version",
	"/linkpad/BoL/master/Ezreal-The-true-carry.lua",
	SCRIPT_PATH.."/" .. GetCurrentEnv().FILE_NAME,
	function(NewVersion) if NewVersion > Ez_version then print("<font color=\"#F0Ff8d\"><b>Ezreal - The true carry : </b></font> <font color=\"#FF0F0F\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") ForceReload = true else print("<font color=\"#F0Ff8d\"><b>Ezreal - The true carry : </b></font> <font color=\"#FF0F0F\">You have the Latest Version</b></font>") end 
end)
	
if FileExist(LIB_PATH .. "/SxOrbWalk.lua") then
	require("SxOrbWalk")
else
	SxUpdate(0,
		"raw.githubusercontent.com",
		"/Superx321/BoL/master/common/SxOrbWalk.Version",
		"/Superx321/BoL/master/common/SxOrbWalk.lua",
		LIB_PATH.."/SxOrbWalk.lua",
		function(NewVersion) if NewVersion > 0 then print("<font color=\"#F0Ff8d\"><b>SxOrbWalk: </b></font> <font color=\"#FF0F0F\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") ForceReload = true end 
	end)
end
	
if FileExist(LIB_PATH .. "/VPrediction.lua") then
	require("VPrediction")
	VP = VPrediction()
	if VP.version >= 3 then	
		SxUpdate(0,
			"raw.githubusercontent.com",
			"/Ralphlol/BoLGit/master/VPrediction.version",
			"/Ralphlol/BoLGit/master/VPrediction.lua",
			LIB_PATH.."/VPrediction.lua",
			function(NewVersion) if NewVersion > 0 then print("<font color=\"#F0Ff8d\"><b>VPrediction: </b></font> <font color=\"#FF0F0F\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") ForceReload = true end 
		end)
	end
else
	SxUpdate(0,
		"raw.githubusercontent.com",
		"/Ralphlol/BoLGit/master/VPrediction.version",
		"/Ralphlol/BoLGit/master/VPrediction.lua",
		LIB_PATH.."/VPrediction.lua",
		function(NewVersion) if NewVersion > 0 then print("<font color=\"#F0Ff8d\"><b>VPrediction: </b></font> <font color=\"#FF0F0F\">Updated to "..NewVersion..". Please Reload with 2x F9</b></font>") ForceReload = true end 
	end)
end




function OnLoad()
        print("<b><font color=\"#FF001E\">Ezreal - The true carry : </font></b><font color=\"#FF980F\"> Free elo for you ! </font><font color=\"#FF001E\">| Linkpad |</font>")
        if ForceReload then return end
        Skills()
        TargetSelector = TargetSelector(TARGET_LESS_CAST_PRIORITY, SkillQ.range + 500, DAMAGE_PHYSICAL, false, true)
        VP = VPrediction()
        Menu()
end


function OnTick()
	if ForceReload then return end
	KillSteall()
	Checks()
	ComboKey = Settings.combo.comboKey

	TargetSelector:update()
	Target = GetCustomTarget()
	SxOrb:ForceTarget(Target)
	
	if ComboKey then
		Combo(Target)
	end

	if SxOrb.IsHarass or Settings.harass.toggle or Settings.harass.key then
		Harass(Target)
	end

	if (SxOrb.IsLaneClear or Settings.laneclear.toggle or Settings.laneclear.key) and not ComboKey then
		LaneClear()
	end
	
end

function LaneClear()
	enemyMinions:update()
	if not IsMyManaLowLaneClear() then
		for i, minion in pairs(enemyMinions.objects) do
			if ValidTarget(minion) and minion ~= nil then
				if Settings.laneclear.useQ and GetDistance(minion) <= SkillQ.range and SkillQ.ready then
					CastSpell(_Q, minion.x, minion.z)
				end
			end		 
		end
	end
end

function Harass(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type and not IsMyManaLowHarass() then
	
		if Settings.harass.useQ then 
			CastQ(unit)
		end	

		if Settings.harass.useW then
			CastW(unit)
		end
	end
end

function Combo(unit)
	if ValidTarget(unit) and unit ~= nil and unit.type == myHero.type then
	
		if Settings.combo.useQ then 
			CastQ(unit)
		end	
		if Settings.combo.useW then 
			CastW(unit)
		end	

		if Settings.combo.RifKilable then
				local dmgR = getDmg("R", unit, myHero) + ((myHero.damage)*0.44) + ((myHero.ap)*0.9)
				if unit.health < dmgR then
					CastR(unit)
				end
		end
	end
end

function KillSteall()
	for _, unit in pairs(GetEnemyHeroes()) do
		local health = unit.health
		local dmgW = getDmg("W", unit, myHero) + ((myHero.ap)*0.8)
		local dmgQ = getDmg("Q", unit, myHero) + ((myHero.damage)*1.1) + ((myHero.ap)*0.4)
			if health < dmgW and Settings.killsteal.useW and ValidTarget(unit) then
				CastW(unit)
			end
			if health < dmgQ and Settings.killsteal.useQ and ValidTarget(unit) then
				CastQ(unit)
			end
	 end
end

function IsMyManaLowLaneClear()
    if myHero.mana < (myHero.maxMana * ( Settings.laneclear.mManager / 100)) then
        return true
    else
        return false
    end
end

function IsMyManaLowHarass()
    if myHero.mana < (myHero.maxMana * ( Settings.harass.mManager / 100)) then
        return true
    else
        return false
    end
end

function Checks()
	SkillQ.ready = (myHero:CanUseSpell(_Q) == READY)
	SkillW.ready = (myHero:CanUseSpell(_W) == READY)
	SkillR.ready = (myHero:CanUseSpell(_R) == READY)
	
	if Settings.drawing.lfc.lfc then 
		_G.DrawCircle = DrawCircle2 
	else 
		_G.DrawCircle = _G.oldDrawCircle 
	end
end

function GetCustomTarget()
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, 1500) then
		return SelectedTarget
	end
	TargetSelector:update()	
	if TargetSelector.target and not TargetSelector.target.dead and TargetSelector.target.type == myHero.type then
		return TargetSelector.target
	else
		return nil
	end
end

function CastQ(unit)
	if unit ~= nil and GetDistance(unit) <= SkillQ.range and SkillQ.ready then
		CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, SkillQ.delay, SkillQ.width, SkillQ.range, SkillQ.speed, myHero, true)
				
		if HitChance >= 2 then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

function CastW(unit)
	if unit ~= nil and GetDistance(unit) <= SkillW.range and SkillW.ready then
		CastPosition,  HitChance,  Position = VP:GetLineCastPosition(unit, SkillW.delay, SkillW.width, SkillW.range, SkillW.speed, myHero, false)
				
		if HitChance >= 2 then
			CastSpell(_W, CastPosition.x, CastPosition.z)
		end
	end
end

function CastR(unit)
	if unit ~= nil and SkillR.ready then
		CastPosition,  HitChance,  Position = VP:GetLineAOECastPosition(unit, SkillR.delay, SkillR.width, SkillR.range, SkillR.speed, myHero)
				
		if HitChance >= 2 then
			CastSpell(_R, CastPosition.x, CastPosition.z)
		end
	end
end

function Skills()
	SkillQ = { name = "Mystic Shot", range = 1150, delay = 0.25, speed = 2000, width = 60, ready = false }
	SkillW = { name = "Essence Flux", range = 950, delay = 0.25, speed = 1600, width = 80, ready = false }
	SkillR = { name = "Trueshot Barrage", range = math.huge, delay = 1.0, speed = 2000, width = 160, ready = false }

	enemyMinions = minionManager(MINION_ENEMY, SkillQ.range, myHero, MINION_SORT_HEALTH_ASC)

	lastSkin = 0
	
	_G.oldDrawCircle = rawget(_G, 'DrawCircle')
	_G.DrawCircle = DrawCircle2
end

function Menu()
	Settings = scriptConfig("| Ezreal - The true carry |", "Linkpad")
	
	Settings:addSubMenu("["..myHero.charName.."] - Combo Settings", "combo")
		Settings.combo:addParam("comboKey", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
		Settings.combo:addParam("useQ", "Use (Q) in Combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("useW", "Use (W) in Combo", SCRIPT_PARAM_ONOFF, true)
		Settings.combo:addParam("RifKilable", "Use (R) if enemy is kilable", SCRIPT_PARAM_ONOFF, true)
		
	Settings:addSubMenu("["..myHero.charName.."] - KillSteal", "killsteal")
		Settings.killsteal:addParam("useQ", "Steal With (Q)", SCRIPT_PARAM_ONOFF, true)
		Settings.killsteal:addParam("useW", "Steal With (W)", SCRIPT_PARAM_ONOFF, true)

	Settings:addSubMenu("["..myHero.charName.."] - Harass", "harass")
		Settings.harass:addParam("key", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
		Settings.harass:addParam("toggle", "Toggle Harass", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
		Settings.harass:addParam("useQ", "Harass With (Q)", SCRIPT_PARAM_ONOFF, true)
		Settings.harass:addParam("useW", "Harass With (W)", SCRIPT_PARAM_ONOFF, true)
		Settings.harass:addParam("mManager", "Min. Mana To Harass", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)

	Settings:addSubMenu("["..myHero.charName.."] - Lane Clear", "laneclear")
		Settings.laneclear:addParam("key", "Lane Clear Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
		Settings.laneclear:addParam("toggle", "Toggle Lane Clear", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("T"))
		Settings.laneclear:addParam("useQ", "Lane Clear With (Q)", SCRIPT_PARAM_ONOFF, true)
		Settings.laneclear:addParam("mManager", "Min. Mana To Lane Clear", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)
		
	Settings.combo:permaShow("comboKey")
	Settings.combo:permaShow("RifKilable")
	Settings.killsteal:permaShow("useQ")
	Settings.killsteal:permaShow("useW")
	Settings.harass:permaShow("toggle")
	Settings.laneclear:permaShow("toggle")
	
	
	Settings:addSubMenu("["..myHero.charName.."] - Draw Settings", "drawing")	
		Settings.drawing:addParam("mDraw", "Disable All Range Draws", SCRIPT_PARAM_ONOFF, false)
		Settings.drawing:addParam("myHero", "Draw My Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("myColor", "Draw My Range Color", SCRIPT_PARAM_COLOR, {255, 100, 44, 255})
		Settings.drawing:addParam("qDraw", "Draw "..SkillQ.name.." (Q) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("qColor", "Draw "..SkillQ.name.." (Q) Color", SCRIPT_PARAM_COLOR, {255, 100, 44, 255})
		Settings.drawing:addParam("wDraw", "Draw "..SkillW.name.." (W) Range", SCRIPT_PARAM_ONOFF, true)
		Settings.drawing:addParam("wColor", "Draw "..SkillW.name.." (W) Color", SCRIPT_PARAM_COLOR, {255, 100, 44, 255})
		Settings.drawing:addParam("tColor", "Draw Target Color", SCRIPT_PARAM_COLOR, {255, 100, 44, 255})
		Settings.drawing:addParam("tText", "Draw Current Target Text", SCRIPT_PARAM_ONOFF, true)

	Settings.drawing:addSubMenu("Lag Free Circles", "lfc")	
		Settings.drawing.lfc:addParam("lfc", "Lag Free Circles", SCRIPT_PARAM_ONOFF, false)
		Settings.drawing.lfc:addParam("CL", "Quality", 4, 75, 75, 2000, 0)
		Settings.drawing.lfc:addParam("Width", "Width", 4, 1, 1, 10, 0)

	Settings:addSubMenu("["..myHero.charName.."] - Orbwalking Settings", "Orbwalking")
		SxOrb:LoadToMenu(Settings.Orbwalking)

	Settings:addTS(TargetSelector)
end

function OnDraw()
	if not myHero.dead and not Settings.drawing.mDraw then
		if SkillQ.ready and Settings.drawing.qDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillQ.range, RGB(Settings.drawing.qColor[2], Settings.drawing.qColor[3], Settings.drawing.qColor[4]))
		end
		if SkillW.ready and Settings.drawing.wDraw then 
			DrawCircle(myHero.x, myHero.y, myHero.z, SkillW.range, RGB(Settings.drawing.wColor[2], Settings.drawing.wColor[3], Settings.drawing.wColor[4]))
		end
		
		if Settings.drawing.myHero then
			
			DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range + GetDistance(myHero, myHero.minBBox), RGB(Settings.drawing.myColor[2], Settings.drawing.myColor[3], Settings.drawing.myColor[4]))
		end

		if Target ~= nil and ValidTarget(Target) then
			if Settings.drawing.tText then
				DrawText3D("Current Target",Target.x-100, Target.y-50, Target.z, 20, 0xFFFFFF00)
			end
			DrawCircle(Target.x, Target.y, Target.z, 200, RGB(Settings.drawing.tColor[2], Settings.drawing.tColor[3], Settings.drawing.tColor[4]))
		end
	end
end

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN then
		local minD = 0
		local starget = nil
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy) then
				if GetDistance(enemy, mousePos) <= minD or starget == nil then
					minD = GetDistance(enemy, mousePos)
					starget = enemy
				end
			end
		end
		
		if starget and minD < 500 then
			if SelectedTarget and starget.charName == SelectedTarget.charName then
				SelectedTarget = nil
			else
				SelectedTarget = starget
				SxOrb:ForceTarget(SelectedTarget)
			end
		end
	end
end

function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
  radius = radius or 300
  quality = math.max(8,round(180/math.deg((math.asin((chordlength/(2*radius)))))))
  quality = 2 * math.pi / quality
  radius = radius*.92
  
  local points = {}
  for theta = 0, 2 * math.pi + quality, quality do
    local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
    points[#points + 1] = D3DXVECTOR2(c.x, c.y)
  end
  
  DrawLines2(points, width or 1, color or 4294967295)
end

function round(num) 
  if num >= 0 then return math.floor(num+.5) else return math.ceil(num-.5) end
end

function DrawCircle2(x, y, z, radius, color)
  local vPos1 = Vector(x, y, z)
  local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
  local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
  local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))

  if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y }) then
    DrawCircleNextLvl(x, y, z, radius, Settings.drawing.lfc.Width, color, Settings.drawing.lfc.CL) 
  end
end


assert(load(Base64Decode("G0x1YVIAAQQEBAgAGZMNChoKAAAAAAAAAAAAAQIKAAAABgBAAEFAAAAdQAABBkBAAGUAAAAKQACBBkBAAGVAAAAKQICBHwCAAAQAAAAEBgAAAGNsYXNzAAQNAAAAU2NyaXB0U3RhdHVzAAQHAAAAX19pbml0AAQLAAAAU2VuZFVwZGF0ZQACAAAAAgAAAAgAAAACAAotAAAAhkBAAMaAQAAGwUAABwFBAkFBAQAdgQABRsFAAEcBwQKBgQEAXYEAAYbBQACHAUEDwcEBAJ2BAAHGwUAAxwHBAwECAgDdgQABBsJAAAcCQQRBQgIAHYIAARYBAgLdAAABnYAAAAqAAIAKQACFhgBDAMHAAgCdgAABCoCAhQqAw4aGAEQAx8BCAMfAwwHdAIAAnYAAAAqAgIeMQEQAAYEEAJ1AgAGGwEQA5QAAAJ1AAAEfAIAAFAAAAAQFAAAAaHdpZAAEDQAAAEJhc2U2NEVuY29kZQAECQAAAHRvc3RyaW5nAAQDAAAAb3MABAcAAABnZXRlbnYABBUAAABQUk9DRVNTT1JfSURFTlRJRklFUgAECQAAAFVTRVJOQU1FAAQNAAAAQ09NUFVURVJOQU1FAAQQAAAAUFJPQ0VTU09SX0xFVkVMAAQTAAAAUFJPQ0VTU09SX1JFVklTSU9OAAQEAAAAS2V5AAQHAAAAc29ja2V0AAQIAAAAcmVxdWlyZQAECgAAAGdhbWVTdGF0ZQAABAQAAAB0Y3AABAcAAABhc3NlcnQABAsAAABTZW5kVXBkYXRlAAMAAAAAAADwPwQUAAAAQWRkQnVnc3BsYXRDYWxsYmFjawABAAAACAAAAAgAAAAAAAMFAAAABQAAAAwAQACBQAAAHUCAAR8AgAACAAAABAsAAABTZW5kVXBkYXRlAAMAAAAAAAAAQAAAAAABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAUAAAAIAAAACAAAAAgAAAAIAAAACAAAAAAAAAABAAAABQAAAHNlbGYAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAtAAAAAwAAAAMAAAAEAAAABAAAAAQAAAAEAAAABAAAAAQAAAAEAAAABAAAAAUAAAAFAAAABQAAAAUAAAAFAAAABQAAAAUAAAAFAAAABgAAAAYAAAAGAAAABgAAAAUAAAADAAAAAwAAAAYAAAAGAAAABgAAAAYAAAAGAAAABgAAAAYAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAHAAAABwAAAAcAAAAIAAAACAAAAAgAAAAIAAAAAgAAAAUAAABzZWxmAAAAAAAtAAAAAgAAAGEAAAAAAC0AAAABAAAABQAAAF9FTlYACQAAAA4AAAACAA0XAAAAhwBAAIxAQAEBgQAAQcEAAJ1AAAKHAEAAjABBAQFBAQBHgUEAgcEBAMcBQgABwgEAQAKAAIHCAQDGQkIAx4LCBQHDAgAWAQMCnUCAAYcAQACMAEMBnUAAAR8AgAANAAAABAQAAAB0Y3AABAgAAABjb25uZWN0AAQRAAAAc2NyaXB0c3RhdHVzLm5ldAADAAAAAAAAVEAEBQAAAHNlbmQABAsAAABHRVQgL3N5bmMtAAQEAAAAS2V5AAQCAAAALQAEBQAAAGh3aWQABAcAAABteUhlcm8ABAkAAABjaGFyTmFtZQAEJgAAACBIVFRQLzEuMA0KSG9zdDogc2NyaXB0c3RhdHVzLm5ldA0KDQoABAYAAABjbG9zZQAAAAAAAQAAAAAAEAAAAEBvYmZ1c2NhdGVkLmx1YQAXAAAACgAAAAoAAAAKAAAACgAAAAoAAAALAAAACwAAAAsAAAALAAAADAAAAAwAAAANAAAADQAAAA0AAAAOAAAADgAAAA4AAAAOAAAACwAAAA4AAAAOAAAADgAAAA4AAAACAAAABQAAAHNlbGYAAAAAABcAAAACAAAAYQAAAAAAFwAAAAEAAAAFAAAAX0VOVgABAAAAAQAQAAAAQG9iZnVzY2F0ZWQubHVhAAoAAAABAAAAAQAAAAEAAAACAAAACAAAAAIAAAAJAAAADgAAAAkAAAAOAAAAAAAAAAEAAAAFAAAAX0VOVgA="), nil, "bt", _ENV))() ScriptStatus("OBECFCEBBCG") 
