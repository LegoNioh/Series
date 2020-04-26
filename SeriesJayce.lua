require "PremiumPrediction"
require "DamageLib"
require "2DGeometry"

local EnemyHeroes = {}
local AllyHeroes = {}
-- [ AutoUpdate ] --
do
    
    local Version = 1.00
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "Series.lua",
            Url = "https://raw.githubusercontent.com/LegoNioh/Series/master/Series.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "Series.version",
            Url = "https://raw.githubusercontent.com/LegoNioh/Series/master/Series.version"    -- check if Raw Adress correct pls.. after you have create the version file on Github
        }
    }
    
    local function AutoUpdate()
        
        local function DownloadFile(url, path, fileName)
            DownloadFileAsync(url, path .. fileName, function() end)
            while not FileExist(path .. fileName) do end
        end
        
        local function ReadFile(path, fileName)
            local file = io.open(path .. fileName, "r")
            local result = file:read()
            file:close()
            return result
        end
        
        DownloadFile(Files.Version.Url, Files.Version.Path, Files.Version.Name)
        local textPos = myHero.pos:To2D()
        local NewVersion = tonumber(ReadFile(Files.Version.Path, Files.Version.Name))
        if NewVersion > Version then
            DownloadFile(Files.Lua.Url, Files.Lua.Path, Files.Lua.Name)
            print("New Series Version. Press 2x F6")     -- <-- you can change the massage for users here !!!!
        else
            print(Files.Version.Name .. ": No Updates Found")   --  <-- here too
            print("Version Changes: Added Lucian Auto Q On Minions") 
            print("Version Changes: Added Fizz")
            print("Version Changes: Added Fizz Last Hit") 
            print("Version Changes: Fixed FPS drops on Lucian Auto Q")
            print("Version Changes: Added Quinn")
            print("Version Changes: Lots of Quinn changes...")  
        end
    
    end
    
    AutoUpdate()

end

local function IsNearEnemyTurret(pos, distance)
    --PrintChat("Checking Turrets")
    local turrets = _G.SDK.ObjectManager:GetTurrets(GetDistance(pos) + 1000)
    for i = 1, #turrets do
        local turret = turrets[i]
        if turret and GetDistance(turret.pos, pos) <= distance+915 and turret.team == 300-myHero.team then
            --PrintChat("turret")
            return turret
        end
    end
end

local function IsUnderEnemyTurret(pos)
    --PrintChat("Checking Turrets")
    local turrets = _G.SDK.ObjectManager:GetTurrets(GetDistance(pos) + 1000)
    for i = 1, #turrets do
        local turret = turrets[i]
        if turret and GetDistance(turret.pos, pos) <= 915 and turret.team == 300-myHero.team then
            --PrintChat("turret")
            return turret
        end
    end
end

function GetDistanceSqr(Pos1, Pos2)
    local Pos2 = Pos2 or myHero.pos
    local dx = Pos1.x - Pos2.x
    local dz = (Pos1.z or Pos1.y) - (Pos2.z or Pos2.y)
    return dx^2 + dz^2
end

function GetDistance(Pos1, Pos2)
    return math.sqrt(GetDistanceSqr(Pos1, Pos2))
end

function GetEnemyHeroes()
    for i = 1, Game.HeroCount() do
        local Hero = Game.Hero(i)
        if Hero.isEnemy then
            table.insert(EnemyHeroes, Hero)
            PrintChat(Hero.name)
        end
    end
    --PrintChat("Got Enemy Heroes")
end

function GetAllyHeroes()
    for i = 1, Game.HeroCount() do
        local Hero = Game.Hero(i)
        if Hero.isAlly then
            table.insert(AllyHeroes, Hero)
            PrintChat(Hero.name)
        end
    end
    --PrintChat("Got Enemy Heroes")
end

local function GetWaypoints(unit) -- get unit's waypoints
    local waypoints = {}
    local pathData = unit.pathing
    table.insert(waypoints, unit.pos)
    if pathData.hasMovePath and pathData.pathCount > 0 then
        for i = pathData.pathIndex, pathData.pathCount do
            table.insert(waypoints, unit:GetPath(i))
        end
    end
    return waypoints
end

local function GetUnitPositionNext(unit)
    local waypoints = GetWaypoints(unit)
    if #waypoints == 1 then
        return nil -- we have only 1 waypoint which means that unit is not moving, return his position
    end
    return waypoints[2] -- all segments have been checked, so the final result is the last waypoint
end

local function GetUnitPositionAfterTime(unit, time)
    local waypoints = GetWaypoints(unit)
    if #waypoints == 1 then
        return unit.pos -- we have only 1 waypoint which means that unit is not moving, return his position
    end
    local max = unit.ms * time -- calculate arrival distance
    for i = 1, #waypoints - 1 do
        local a, b = waypoints[i], waypoints[i + 1]
        local dist = GetDistance(a, b)
        if dist >= max then
            return Vector(a):Extended(b, dist) -- distance of segment is bigger or equal to maximum distance, so the result is point A extended by point B over calculated distance
        end
        max = max - dist -- reduce maximum distance and check next segments
    end
    return waypoints[#waypoints] -- all segments have been checked, so the final result is the last waypoint
end

function GetTarget(range)
    if _G.SDK then
        return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
    else
        return _G.GOS:GetTarget(range,"AD")
    end
end

function GotBuff(unit, buffname)
    for i = 0, unit.buffCount do
        local buff = unit:GetBuff(i)
        if buff.name == buffname and buff.count > 0 then 
            return buff.count
        end
    end
    return 0
end

function IsReady(spell)
    return myHero:GetSpellData(spell).currentCd == 0 and myHero:GetSpellData(spell).level > 0 and myHero:GetSpellData(spell).mana <= myHero.mana and Game.CanUseSpell(spell) == 0
end

function Mode()
    if _G.SDK then
        if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
            return "Combo"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] or Orbwalker.Key.Harass:Value() then
            return "Harass"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] or Orbwalker.Key.Clear:Value() then
            return "LaneClear"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LASTHIT] or Orbwalker.Key.LastHit:Value() then
            return "LastHit"
        elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_FLEE] then
            return "Flee"
        end
    else
        return GOS.GetMode()
    end
end

function SetMovement(bool)
    if _G.PremiumOrbwalker then
        _G.PremiumOrbwalker:SetAttack(bool)
        _G.PremiumOrbwalker:SetMovement(bool)       
    elseif _G.SDK then
        _G.SDK.Orbwalker:SetMovement(bool)
        _G.SDK.Orbwalker:SetAttack(bool)
    end
end


function EnableMovement()
    SetMovement(true)
end

local function IsValid(unit)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        return true;
    end
    return false;
end


local function ValidTarget(unit, range)
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) then
        if range then
            if GetDistance(unit.pos) <= range then
                return true;
            end
        else
            return true
        end
    end
    return false;
end
class "Manager"

function Manager:__init()
    if myHero.charName == "Jayce" then
        DelayAction(function() self:LoadJayce() end, 1.05)
    end
end


function Manager:LoadJayce()
    Jayce:Spells()
    Jayce:Menu()
    --
    --GetEnemyHeroes()
    Callback.Add("Tick", function() Jayce:Tick() end)
    Callback.Add("Draw", function() Jayce:Draw() end)
    if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...) Jayce:OnPreAttack(...) end)
        _G.SDK.Orbwalker:OnPostAttackTick(function(...) Jayce:OnPostAttackTick(...) end)
    end
end


class "Jayce"

local EnemyLoaded = false
local casted = 0
local LastESpot = myHero.pos
local LastE2Spot = myHero.pos
local attackedfirst = 0
local Weapon = "Hammer"
local Wbuff = false
local LastCalledTime = 0
local StartSpot = nil
local Q2CD = Game.Timer()
local W2CD = Game.Timer()
local E2CD = Game.Timer()
local Q1CD = Game.Timer()
local W1CD = Game.Timer()
local E1CD = Game.Timer()
local WasInRange = false

function Jayce:Menu()
    self.Menu = MenuElement({type = MENU, id = "Jayce", name = "Jayce"})
    self.Menu:MenuElement({id = "Insec", name = "Insec Key", key = string.byte("A"), value = false})
    self.Menu:MenuElement({id = "QE", name = "Manual QE", key = string.byte("T"), value = false})
    self.Menu:MenuElement({id = "AimQE", name = "Aim Assist on Manual QE", value = true})
    self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
    self.Menu.ComboMode:MenuElement({id = "UseQ", name = "Use Q in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseW", name = "Use W in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseE", name = "Use E in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseR", name = "Use R in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseQ2", name = "Use Q2 in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseW2", name = "Use W2 in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseE2", name = "Use E2 in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseR2", name = "Use R2 in Combo", value = true})
    self.Menu:MenuElement({id = "KSMode", name = "KS", type = MENU})
    self.Menu.KSMode:MenuElement({id = "UseQ", name = "Use Q in KS", value = true})
    self.Menu.KSMode:MenuElement({id = "UseW", name = "Use W in KS", value = true})
    self.Menu.KSMode:MenuElement({id = "UseE", name = "Use E in KS", value = true})
    self.Menu.KSMode:MenuElement({id = "UseR", name = "Use R in KS", value = true})
    self.Menu.KSMode:MenuElement({id = "UseQ2", name = "Use Q2 in KS", value = true})
    self.Menu.KSMode:MenuElement({id = "UseW2", name = "Use W2 in KS", value = true})
    self.Menu.KSMode:MenuElement({id = "UseE2", name = "Use E2 in KS", value = true})
    self.Menu.KSMode:MenuElement({id = "UseR2", name = "Use R2 in KS", value = true})
    self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
    self.Menu.HarassMode:MenuElement({id = "UseQ", name = "Use Q in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseW", name = "Use W in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseE", name = "Use E in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseR", name = "Use R in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseQ2", name = "Use Q2 in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseW2", name = "Use W2 in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseE2", name = "Use E2 in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseR2", name = "Use R2 in Harass", value = false})
    self.Menu:MenuElement({id = "Draw", name = "Draw", type = MENU})
    self.Menu.Draw:MenuElement({id = "UseDraws", name = "Enable Draws", value = false})
end

function Jayce:Spells()
    QSpellData = {speed = 1450, range = 1050, delay = 0.1515, radius = 70, collision = {"minion"}, type = "linear"}
    Q2SpellData = {speed = 1890, range = 1470, delay = 0.1515, radius = 70, collision = {"minion"}, type = "linear"}
end

function Jayce:__init()
    DelayAction(function() self:LoadScript() end, 1.05)
end

function Jayce:LoadScript()
    self:Spells()
    self:Menu()
    --
    --GetEnemyHeroes()
    Callback.Add("Tick", function() self:Tick() end)
    Callback.Add("Draw", function() self:Draw() end)
    if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...) self:OnPreAttack(...) end)
        _G.SDK.Orbwalker:OnPostAttackTick(function(...) self:OnPostAttackTick(...) end)
        _G.SDK.Orbwalker:OnPostAttack(function(...) self:OnPostAttack(...) end)
    end
end

function Jayce:Tick()
    if _G.JustEvade and _G.JustEvade:Evading() or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or Game.IsChatOpen() or myHero.dead then return end
    --PrintChat(myHero:GetSpellData(_R).name)
    --PrintChat(myHero:GetSpellData(_R).toggleState)
    target = GetTarget(1600)
    --PrintChat(myHero.activeSpell.name)
    Wbuff = _G.SDK.BuffManager:HasBuff(myHero, "jaycehypercharge")
    if myHero:GetSpellData(_R).name == "JayceStanceHtG" then
        Weapon = "Hammer"
    else
        Weapon = "Gun"
    end
    self:GetCDs()
    --PrintChat(Q2CD)
    self:KS()
    if self.Menu.QE:Value() then 
    	self:QECombo()
    end
    if self.Menu.Insec:Value() then
    	SetMovement(false)
    	self:Insec()
    else
    	StartSpot = nil
    	SetMovement(true)
    	self:Logic()
    end
    if EnemyLoaded == false then
        local CountEnemy = 0
        for i, enemy in pairs(EnemyHeroes) do
            CountEnemy = CountEnemy + 1
        end
        if CountEnemy < 1 then
            GetEnemyHeroes()
        else
            EnemyLoaded = true
            PrintChat("Enemy Loaded")
        end
    end
end

function Jayce:Draw()
    if self.Menu.Draw.UseDraws:Value() then

        --Draw.Circle(LastESpot, 85, 1, Draw.Color(255, 0, 0, 255))
        --Draw.Circle(LastE2Spot, 85, 1, Draw.Color(255, 255, 0, 255))
        if target then
            AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
            Draw.Circle(myHero.pos, AARange, 1, Draw.Color(255, 0, 191, 255))
        end
    end
end

function Jayce:GetCDs()
    if Weapon == "Hammer" then
        if not IsReady(_Q) then
            Q1CD = Game:Timer() + myHero:GetSpellData(0).currentCd
        end
        if not IsReady(_W) then
            W1CD = Game:Timer() + myHero:GetSpellData(1).currentCd
        end
        if not IsReady(_E) then
            E1CD = Game:Timer() + myHero:GetSpellData(2).currentCd
        end
    else
        if not IsReady(_Q) then
            Q2CD = Game:Timer() + myHero:GetSpellData(0).currentCd
        end
        if not IsReady(_W) then
            W2CD = Game:Timer() + myHero:GetSpellData(1).currentCd
        end
        if not IsReady(_E) then
            E2CD = Game:Timer() + myHero:GetSpellData(2).currentCd
        end
    end
end

function Jayce:KS()
    --PrintChat("ksing")
    for i, enemy in pairs(EnemyHeroes) do
        if enemy and not enemy.dead and ValidTarget(enemy) then
        end
    end
end 

function Jayce:CanUse(spell, mode, rmode)
    if mode == nil then
        mode = Mode()
    end
    if not rmode then
        rmode = Weapon
    end
    --PrintChat(Mode())
    if rmode == "Hammer" then
        if spell == _Q then
            if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseQ:Value() then
                return true
            end
            if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseQ:Value() then
                return true
            end
            if mode == "KS" and IsReady(spell) and self.Menu.KSMode.UseQ:Value() then
                return true
            end
        elseif spell == _W then
            if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseW:Value() then
                return true
            end
            if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseW:Value() then
                return true
            end
            if mode == "KS" and IsReady(spell) and self.Menu.KSMode.UseW:Value() then
                return true
            end
        elseif spell == _E then
            if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseE:Value() then
                return true
            end
            if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseE:Value() then
                return true
            end
            if mode == "KS" and IsReady(spell) and self.Menu.KSMode.UseE:Value() then
                return true
            end
        elseif spell == _R then
            if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseR:Value() then
                return true
            end
            if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseR:Value() then
                return true
            end
            if mode == "KS" and IsReady(spell) and self.Menu.KSMode.UseR:Value() then
                return true
            end
        end
    else
        if spell == _Q then
            if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseQ2:Value() then
                return true
            end
            if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseQ2:Value() then
                return true
            end
            if mode == "KS" and IsReady(spell) and self.Menu.KSMode.UseQ2:Value() then
                return true
            end
        elseif spell == _W then
            if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseW2:Value() then
                return true
            end
            if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseW2:Value() then
                return true
            end
            if mode == "KS" and IsReady(spell) and self.Menu.KSMode.UseW2:Value() then
                return true
            end
        elseif spell == _E then
            if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseE2:Value() then
                return true
            end
            if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseE2:Value() then
                return true
            end
            if mode == "KS" and IsReady(spell) and self.Menu.KSMode.UseE2:Value() then
                return true
            end
        elseif spell == _R then
            if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseR2:Value() then
                return true
            end
            if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseR2:Value() then
                return true
            end
            if mode == "KS" and IsReady(spell) and self.Menu.KSMode.UseR2:Value() then
                return true
            end
        end
    end
    return false
end

function Jayce:Logic()
    if target == nil then return end
    if Mode() == "Combo" or Mode() == "Harass" and target then
        local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
        if GetDistance(target.pos) < AARange then
            WasInRange = true
        end
        if Weapon == "Hammer" then
            if self:CanUse(_Q, Mode(), Weapon) and ValidTarget(target, 600) and not myHero.pathing.isDashing then
                Control.CastSpell(HK_Q, target)
            end
            if self:CanUse(_W, Mode(), Weapon) and ValidTarget(target, 285) then
                Control.CastSpell(HK_W)
            end

            if self:CanUse(_E, Mode(), Weapon) and ValidTarget(target, 240) then
                local Edmg= getdmg("E", target, myHero, 1, myHero:GetSpellData(_E).level)
                if target.health < Edmg then
                    Control.CastSpell(HK_E, target)
                elseif (self:CanUse(_Q, Mode(), Weapon) or Q2CD < Game.Timer() or W2CD < Game.Timer()) and GetDistance(target.pos, myHero.pos) < 100 and self:CanUse(_R, Mode(), Weapon) then
                    Control.CastSpell(HK_E, target)
                elseif not self:CanUse(_Q, Mode(), Weapon) and not self:CanUse(_W, Mode(), Weapon) and self:CanUse(_R, Mode(), Weapon) then
                    Control.CastSpell(HK_E, target)
                end
            end
            if self:CanUse(_R, Mode(), Weapon) then
            	if GetDistance(target.pos, myHero.pos) > 700 then
            		Control.CastSpell(HK_R)
                elseif GetDistance(target.pos, myHero.pos) > 285 and not self:CanUse(_Q, Mode(), Weapon) then
                    Control.CastSpell(HK_R)
                elseif GetDistance(target.pos, myHero.pos) > 240 and not self:CanUse(_W, Mode(), Weapon) and not self:CanUse(_Q, Mode(), Weapon) then
                    Control.CastSpell(HK_R)
                elseif GetDistance(target.pos, myHero.pos) > AARange and not self:CanUse(_E, Mode(), Weapon) and not self:CanUse(_W, Mode(), Weapon) and not self:CanUse(_Q, Mode(), Weapon) then
                    Control.CastSpell(HK_R)
                elseif W2CD < Game.Timer() and not self:CanUse(_E, Mode(), Weapon) and not self:CanUse(_W, Mode(), Weapon) and not self:CanUse(_Q, Mode(), Weapon) then
                	Control.CastSpell(HK_R)
                end
            end
        else
        	--PrintChat("Gun")
            if self:CanUse(_Q, Mode(), Weapon) and ValidTarget(target, 1050) and not self:CanUse(_E, Mode(), Weapon) then
                self:UseQ(target)
            end

            if self:CanUse(_W, Mode(), Weapon) and ValidTarget(target, AARange+100) then
                if myHero.attackData.state == 3 then
                   --Control.CastSpell(HK_W)
                end
            end

            if self:CanUse(_E, Mode(), Weapon) and ValidTarget(target, 1470) and self:CanUse(_Q, Mode(), Weapon) then
            	self:UseQ2(target)
            end

            if self:CanUse(_R, Mode(), Weapon) then
                if GetDistance(target.pos, myHero.pos) < 125 then
                    if self:CanUse(_W, Mode(), Weapon) then
                        Control.CastSpell(HK_W)
                    end
                    Control.CastSpell(HK_R)
                elseif GetDistance(target.pos, myHero.pos) < 240 and (Q1CD < Game.Timer() or W1CD < Game.Timer() or E1CD < Game.Timer() or Wbuff) then
                    if self:CanUse(_W, Mode(), Weapon) then
                        Control.CastSpell(HK_W)
                    end
                    Control.CastSpell(HK_R)
                elseif GetDistance(target.pos, myHero.pos) < 600 and Q1CD < Game.Timer() and (W1CD < Game.Timer() or E1CD < Game.Timer() or Wbuff) and not self:CanUse(_Q, Mode(), Weapon) then
                    if self:CanUse(_W, Mode(), Weapon) then
                        Control.CastSpell(HK_W)
                    end
                    Control.CastSpell(HK_R)
                end
            end
        end
    else
        WasInRange = false
    end     
end

function Jayce:DelayEscapeClick(delay, pos)
	if Game.Timer() - LastCalledTime > delay then
		LastCalledTime = Game.Timer()
		Control.RightClick(pos:To2D())
	end
end

function Jayce:QECombo()
	local SmallDist = 1000
	local QETarget = nil
    for i, enemy in pairs(EnemyHeroes) do
        if enemy and not enemy.dead and ValidTarget(enemy) then
        	local MouseDist = GetDistance(enemy.pos, mousePos)
        	if MouseDist < SmallDist then
        		QETarget = enemy
        	end
        end
    end
    if QETarget and  Weapon == "Gun" and IsReady(_Q) and IsReady(_E) and ValidTarget(QETarget, 1470) and self.Menu.AimQE:Value() then
    	self:UseQ2Man(QETarget)
    else
    	local Espot = Vector(myHero.pos):Extended(mousePos, 100)
        DelayAction(function() Control.CastSpell(HK_Q, mousePos) end, 0.05)
        Control.CastSpell(HK_E, Espot)
   	end	
end

function Jayce:Insec(target)
	local SmallDist = 1000
	local InsecTarget = nil
    for i, enemy in pairs(EnemyHeroes) do
        if enemy and not enemy.dead and ValidTarget(enemy) then
        	local MouseDist = GetDistance(enemy.pos, mousePos)
        	if MouseDist < SmallDist then
        		InsecTarget = enemy
        	end
        end
    end
    if InsecTarget and ValidTarget(InsecTarget, 600) then
    	if Weapon == "Hammer" then
    		if IsReady(_Q) and IsReady(_E) and not myHero.pathing.isDashing then
    			if StartSpot == nil then
    				StartSpot = myHero.pos
    			end
    			Control.CastSpell(HK_Q, InsecTarget)
    		end
    		if StartSpot ~= nil and not IsReady(_Q) and IsReady(_E) then
    			local TargetFromStartDist = GetDistance(InsecTarget.pos, StartSpot)
    			local Espot = Vector(StartSpot):Extended(InsecTarget.pos, TargetFromStartDist+200)
    			self:DelayEscapeClick(0.10, Espot)
    			if GetDistance(myHero.pos, Espot) < 100 then
    				Control.CastSpell(HK_E, InsecTarget)
    				StartSpot = nil
    			end
    		else
    			self:DelayEscapeClick(0.10, mousePos)
    		end
    	else
    		if Q1CD < Game.Timer() and E1CD < Game.Timer() then
	    		local TargetDist = GetDistance(InsecTarget.pos, myHero.pos)
	    		local Espot = Vector(myHero.pos):Extended(InsecTarget.pos, TargetDist-200)
	    		if IsReady(_E) then
	        		Control.CastSpell(HK_E, Espot)
	        	end
	        	if IsReady(_R) then
	        		Control.CastSpell(HK_R)
	        	end
	        else
        		self:DelayEscapeClick(0.10, mousePos)
        	end
    	end
    else
    	self:DelayEscapeClick(0.10, mousePos)
    end
end


function Jayce:OnPostAttackTick(args)
    attackedfirst = 1
    if target then
    	if Weapon == "Gun" then
			local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
            if self:CanUse(_W, Mode(), Weapon) and ValidTarget(target, AARange+100) then
                Control.CastSpell(HK_W)
            end
    	end
    end
end


function Jayce:GetRDmg(unit)
    return getdmg("R", unit, myHero, stage, myHero:GetSpellData(_R).level)
end

function Jayce:OnPreAttack(args)
end

function Jayce:UseQ(unit)
        local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QSpellData)
        if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and myHero.pos:DistanceTo(pred.CastPos) < 1050 then
                Control.CastSpell(HK_Q, pred.CastPos)
        end 
end

function Jayce:UseQ2(unit)
        local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, Q2SpellData)
        if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and myHero.pos:DistanceTo(pred.CastPos) < 1470 then
        		local Espot = Vector(myHero.pos):Extended(pred.CastPos, 100)
        		DelayAction(function() Control.CastSpell(HK_Q, pred.CastPos) end, 0.05)
        		Control.CastSpell(HK_E, Espot)
        end 
end


function Jayce:UseQ2Man(unit)
        local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, Q2SpellData)
        if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and myHero.pos:DistanceTo(pred.CastPos) < 1470 then
        		local Espot = Vector(myHero.pos):Extended(pred.CastPos, 100)
        		DelayAction(function() Control.CastSpell(HK_Q, pred.CastPos) end, 0.05)
        		Control.CastSpell(HK_E, Espot)
       	else
       		local Espot = Vector(myHero.pos):Extended(mousePos, 100)
        	DelayAction(function() Control.CastSpell(HK_Q, mousePos) end, 0.05)
        	Control.CastSpell(HK_E, Espot)
        end 
end


function Jayce:UseE(unit)
        local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, ESpellData)
        if pred.CastPos and _G.PremiumPrediction.HitChance.Low(pred.HitChance) and myHero.pos:DistanceTo(pred.CastPos) < 700 then
                Control.CastSpell(HK_E, pred.CastPos)
                LastESpot = pred.CastPos
        end 
end

function Jayce:UseR(unit)
        local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, RSpellData)
        if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and myHero.pos:DistanceTo(pred.CastPos) < 1300  then
                Control.CastSpell(HK_R, pred.CastPos)
        end 
end

function OnLoad()
    Manager()
end
