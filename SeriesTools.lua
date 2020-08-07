require "PremiumPrediction"
require "DamageLib"
require "2DGeometry"
require "MapPositionGOS"


MeleeHelperActive = false
local EnemyHeroes = {}
local AllyHeroes = {}
local EnemySpawnPos = nil
local Flipped = false
local SavedSpot = myHero.pos
-- [ AutoUpdate ] --
do
    
    local Version = 120.00
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "SeriesTools.lua",
            Url = "https://raw.githubusercontent.com/LegoNioh/Series/master/SeriesTools.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "SeriesTools.version",
            Url = "https://raw.githubusercontent.com/LegoNioh/Series/master/SeriesTools.version"    -- check if Raw Adress correct pls.. after you have create the version file on Github
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
        end
    
    end
    
    AutoUpdate()

end

local function IsNearEnemyTurret(pos, distance)
    --PrintChat("Checking Turrets")
    local turrets = _G.SDK.ObjectLoader:GetTurrets(GetDistance(pos) + 1000)
    for i = 1, #turrets do
        local turret = turrets[i]
        if turret and GetDistance(turret.pos, pos) <= distance+915 and turret.team == 300-myHero.team then
            --PrintChat("turret")
            return turret
        end
    end
    return nil
end


local function IsUnderEnemyTurret(pos, dist)
    --PrintChat("Checking Turrets")
    if not dist then
        dist = 0
    end

    local turrets = _G.SDK.ObjectManager:GetTurrets(GetDistance(pos) + 1000+dist)
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
        return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_MAGICAL);
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

function AntiDash(unit)
    local path = unit.pathing;
    local PathStart = unit.pathing.pathIndex
    local PathEnd = unit.pathing.pathCount
    if PathStart and PathEnd and PathStart >= 0 and PathEnd <= 20 and path.hasMovePath then
        for i = path.pathIndex, path.pathCount do
            local path_vec = unit:GetPath(i)
            if path.isDashing then
                return path_vec
            end
        end
    end
    return false
end

function IsFacing(unit)
    local V = Vector((unit.pos - myHero.pos))
    local D = Vector(unit.dir)
    local Angle = 180 - math.deg(math.acos(V*D/(V:Len()*D:Len())))
    if math.abs(Angle) < 80 then 
        return true  
    end
    return false
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
class "Loader"

function Loader:__init()
    if myHero.charName then
        DelayAction(function() self:LoadUtility() end, 1.05)
    end
end


function Loader:LoadUtility()
    Utility:Spells()
    Utility:Menu()
    --
    --GetEnemyHeroes()

    for i = 1, Game.ObjectCount() do
        local object = Game.Object(i)
        
        if not object.isAlly and object.type == Obj_AI_SpawnPoint then 
            EnemySpawnPos = object
            break
        end
    end
    Callback.Add("Tick", function() Utility:Tick() end)
    Callback.Add("Draw", function() Utility:Draw() end)
end


class "Utility"

local EnemyLoaded = false
local recalls = {}
local Exhaust = nil
local ExhaustSpell = nil
local Range = 650
local MovementSet = "True"

function Utility:Menu()
    self.Menu = MenuElement({type = MENU, id = "Utility", name = "Series Tools"})
    self.Menu:MenuElement({id = "ExKey", name = "Exhaust Key", key = string.byte("A"), value = false})  
    self.Menu:MenuElement({id = "MeleeKey", name = "Melee Helper Toggle Key", key = string.byte("H"), toggle = true, value = true})
    self.Menu:MenuElement({id = "RangedKey", name = "Ranged Helper Toggle Key", key = string.byte("H"), toggle = true, value = true})
    self.Menu:MenuElement({id = "StopHelperKey", name = "Stop Helper On Hold", key = string.byte("A"), value = false})
    self.Menu:MenuElement({id = "OrbMode", name = "Orbwalker", type = MENU})
    self.Menu.OrbMode:MenuElement({id = "UseMeleeHelper", name = "Enable Melee Movement Helper", value = true})
    self.Menu.OrbMode:MenuElement({id = "UseMeleeHelperHarass", name = "Enable MeleeHelper In harass", value = false})
    self.Menu.OrbMode:MenuElement({id = "MeleeHelperMouseDistance", name = "Mouse Distance From Target To Enable", value = 550, min = 0, max = 1500, step = 50})
    self.Menu.OrbMode:MenuElement({id = "MeleeHelperExtraDistance", name = "Extra Distance To Stick To target", value = 0, min = 0, max = 1500, step = 10})
    self.Menu.OrbMode:MenuElement({id = "MeleeHelperSkillsOnly", name = "Enabled = Only Move to help for skills", value = false})
    self.Menu:MenuElement({id = "OrbModeR", name = "Orbwalker Ranged", type = MENU})
    self.Menu.OrbModeR:MenuElement({id = "UseRangedHelper", name = "Enable Ranged Movement Helper", value = true})
    self.Menu.OrbModeR:MenuElement({id = "UseRangedHelperHarass", name = "Enable RangedHelper In harass", value = false})
    self.Menu.OrbModeR:MenuElement({id = "RangedHelperStandStill", name = "Stand Still When In Perfect Spot", value = false})
    self.Menu.OrbModeR:MenuElement({id = "RangedHelperMouseDistance", name = "Mouse Distance From Target To Enable", value = 1500, min = 0, max = 1500, step = 50})
    self.Menu.OrbModeR:MenuElement({id = "RangedHelperExtraDistance", name = "Extra Distance To Stick To target", value = 0, min = -500, max = 1500, step = 10})
    self.Menu.OrbModeR:MenuElement({id = "RangedHelperSkillsOnly", name = "Enabled = Only Move to help for skills", value = false})
    self.Menu:MenuElement({id = "Draw", name = "Draw", type = MENU})
    self.Menu.Draw:MenuElement({id = "UseDraws", name = "Enable Draws", value = false})
    self.Menu.Draw:MenuElement({id = "DrawSummonerRange", name = "Enable Summoner Range", value = false})
    self.Menu.Draw:MenuElement({id = "MeleeHelperSpot", name = "Draw Melee Helper Spot", value = false})
    self.Menu.Draw:MenuElement({id = "MeleeHelperDistance", name = "Draw Melee Helper Mouse Distance", value = false})
    self.Menu.Draw:MenuElement({id = "MeleeHelperText", name = "Draw Melee Helper Text (On/Off)", value = false})
    self.Menu.Draw:MenuElement({id = "RangedHelperSpot", name = "Draw Ranged Helper Spot", value = false})
    self.Menu.Draw:MenuElement({id = "RangedHelperDistance", name = "Draw Ranged Helper Mouse Distance", value = false})
    self.Menu.Draw:MenuElement({id = "RangedHelperText", name = "Draw Melee Ranged Text (On/Off)", value = false})
end

function Utility:NasusHelper()
    local LastHitTarget = _G.SDK.HealthPrediction:GetLaneMinion()
    if LastHitTarget then
        local QDamage = getdmg("Q", LastHitTarget, myHero)
        local AADamage = getdmg("AA", LastHitTarget, myHero)
        local TotalDamage = QDamage + AADamage
        PrintChat(TotalDamage)
        if LastHitTarget.health < TotalDamage then
            return LastHitTarget
        end
    end
end

function Utility:Spells()

end

function Utility:Tick()
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
    if myHero.charName == "Nasus" then
        local LastHitTarget = self:NasusHelper()
        if LastHitTarget and IsReady(_Q) then
            --PrintChat("Yes")
            Control.CastSpell(HK_Q)
        end
    end
    if _G.QHelperActive then
        --PrintChat("Q helper Active")
    else
        --PrintChat("Q helper OFF")
    end
    if Game.IsChatOpen() or myHero.dead then return end
    --PrintChat(myHero.attackData.state)
    --PrintChat(myHero.activeSpell.name)
    target = GetTarget(1400)
    if self.Menu.OrbMode.UseMeleeHelper:Value() then
        self:MeleeHelper()
    end
    if self.Menu.OrbModeR.UseRangedHelper:Value() then
        self:RangedHelper()
    end
    if self.Menu.ExKey:Value() then
    	self:Exhaust()
    end
    if myHero:GetSpellData(SUMMONER_1).name:find("Exhaust") or myHero:GetSpellData(SUMMONER_1).name:find("Dot") then
        Exhaust = SUMMONER_1
        ExhaustSpell = HK_SUMMONER_1
        if myHero:GetSpellData(SUMMONER_1).name:find("Dot") then
            Range = 600
        else
            Range = 650
        end
    elseif myHero:GetSpellData(SUMMONER_2).name:find("Exhaust") or myHero:GetSpellData(SUMMONER_2).name:find("Dot")  then
        Exhaust = SUMMONER_2
        ExhaustSpell = HK_SUMMONER_2
        if myHero:GetSpellData(SUMMONER_2).name:find("Dot") then
            Range = 600
        else
            Range = 650
        end
    else 
        Exhaust = nil
    end
end

function Utility:CanClick()
    if self.Menu.StopHelperKey:Value() then
        return false
    end
    return true
end


function Utility:Draw()
    if self.Menu.Draw.UseDraws:Value() then

        for i, enemy in pairs(EnemyHeroes) do
            if enemy and not enemy.dead and ValidTarget(enemy) then
                if enemy.activeSpell and enemy.activeSpell.placementPos then
                    local SpellPlacementPos = enemy.activeSpell.placementPos
                    local VectorSpellPlacementPos = Vector(SpellPlacementPos.x,SpellPlacementPos.y,SpellPlacementPos.z)
                    Draw.Circle(VectorSpellPlacementPos, 100, 1, Draw.Color(255, 0, 191, 255))
                end
            end
        end

        if myHero.charName == "Nasus" then
            LastHitTarget = self:NasusHelper()
            if LastHitTarget then
                Draw.Circle(LastHitTarget.pos, 200, 1, Draw.Color(255, 0, 191, 255))
            end
        end
        if self.Menu.Draw.DrawSummonerRange:Value() then
            Draw.Circle(myHero.pos, Range, 1, Draw.Color(255, 0, 191, 255))
        end
        if self.Menu.OrbMode.UseMeleeHelper:Value() and target and self.Menu.Draw.MeleeHelperDistance:Value() then
            Draw.Circle(target.pos, self.Menu.OrbMode.MeleeHelperMouseDistance:Value(), 1, Draw.Color(255, 0, 0, 0))
        end



        if self.Menu.OrbModeR.UseRangedHelper:Value() and target and self.Menu.Draw.RangedHelperDistance:Value() then
            Draw.Circle(target.pos, self.Menu.OrbModeR.RangedHelperMouseDistance:Value(), 1, Draw.Color(255, 0, 0, 0))
        end
        if self.Menu.OrbMode.UseMeleeHelper:Value() and target and self.Menu.Draw.MeleeHelperSpot:Value() then
            local MeleeSpot = self:DrawMeleeHelper()
            if MeleeSpot then
                Draw.Circle(MeleeSpot, 25, 1, Draw.Color(255, 0, 100, 255))
                Draw.Circle(MeleeSpot, 35, 1, Draw.Color(255, 0, 100, 255))
                Draw.Circle(MeleeSpot, 45, 1, Draw.Color(255, 0, 100, 255))
            end
        end
        if self.Menu.OrbModeR.UseRangedHelper:Value() and target and self.Menu.Draw.RangedHelperSpot:Value() then
            local RangedSpot = self:DrawRangedHelper()
            if RangedSpot then
                Draw.Circle(RangedSpot, 25, 1, Draw.Color(255, 0, 100, 255))
                Draw.Circle(RangedSpot, 35, 1, Draw.Color(255, 0, 100, 255))
                Draw.Circle(RangedSpot, 45, 1, Draw.Color(255, 0, 100, 255))
            end
        end

        if self.Menu.Draw.MeleeHelperText:Value() then
            if self.Menu.MeleeKey:Value() and self.Menu.OrbMode.UseMeleeHelper:Value() then
                Draw.Text("Melee Helper On", 10, myHero.pos:To2D().x, myHero.pos:To2D().y-130, Draw.Color(255, 0, 255, 0))
                --InfoBarSprite:Draw(myHero.pos:To2D().x,myHero.pos:To2D().y)
            else
                Draw.Text("Melee Helper On", 10, myHero.pos:To2D().x, myHero.pos:To2D().y-130, Draw.Color(255, 255, 0, 0))
                --InfoBarSprite:Draw(myHero.pos:To2D().x,myHero.pos:To2D().y)
            end
        end
        if self.Menu.Draw.RangedHelperText:Value() then
            if self.Menu.RangedKey:Value() and self.Menu.OrbModeR.UseRangedHelper:Value() then
                Draw.Text("Ranged Helper On", 10, myHero.pos:To2D().x, myHero.pos:To2D().y-130, Draw.Color(255, 0, 255, 0))
                --InfoBarSprite:Draw(myHero.pos:To2D().x,myHero.pos:To2D().y)
            else
                Draw.Text("Ranged Helper On", 10, myHero.pos:To2D().x, myHero.pos:To2D().y-130, Draw.Color(255, 255, 0, 0))
                --InfoBarSprite:Draw(myHero.pos:To2D().x,myHero.pos:To2D().y)
            end
        end
    end
end

function Utility:DrawMeleeHelper()
    local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
    local MoveSpot = nil


    local ModeCheck = Mode() == "Combo" or (Mode() == "Harass" and self.Menu.OrbMode.UseMeleeHelperHarass:Value())
    if self.Menu.MeleeKey:Value() and self.Menu.OrbMode.UseMeleeHelper:Value() and target and ModeCheck and GetDistance(mousePos, target.pos) < self.Menu.OrbMode.MeleeHelperMouseDistance:Value() and GetDistance(target.pos) <= AARange + self.Menu.OrbMode.MeleeHelperExtraDistance:Value() then
        local MouseDirection = Vector((target.pos-mousePos):Normalized())
        local MouseDistance = GetDistance(mousePos, target.pos)
        local MouseSpotDistance = AARange - target.boundingRadius
        if IsFacing(target) then
            MouseSpotDistance = AARange - (target.boundingRadius/2)
            --PrintChat("Facing")
        end
        local MouseSpot = target.pos - MouseDirection * (MouseSpotDistance)
        if MouseSpot and MapPosition:inWall(MouseSpot) then

        end
        MoveSpot = MouseSpot
        return MoveSpot
        --PrintChat("Forcing")
    else
        return nil
    end
end

function Utility:DrawRangedHelper()
    local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
    local MoveSpot = nil
    local RangedMenuMouseDistance = self.Menu.OrbModeR.RangedHelperMouseDistance:Value()
    local ModeCheck = Mode() == "Combo" or (Mode() == "Harass" and self.Menu.OrbModeR.UseRangedHelperHarass:Value())
    local RangedSkillsOnly = self.Menu.OrbModeR.RangedHelperSkillsOnly:Value()
    local OrbWalkSpot = nil
    local MouseInWall = false
    if target and ValidTarget(target) then
        local EAArange = _G.SDK.Data:GetAutoAttackRange(target)

        local MouseDirection = Vector((myHero.pos-mousePos):Normalized())
        local MouseDistance = GetDistance(mousePos, myHero.pos) * 0.2
        local MouseSpot = myHero.pos - MouseDirection * (MouseDistance + 100)


        local TargetMouseDirection = Vector((target.pos-MouseSpot):Normalized())
        local RangeDifference = AARange - EAArange
        if RangeDifference > 0 then
            RangeDifference = RangeDifference/2
        else
            RangeDifference = RangeDifference
        end
        local TargetDistance = EAArange + RangeDifference
        local TargetMouseSpot = target.pos - TargetMouseDirection * TargetDistance

        if GetDistance(TargetMouseSpot) > 60 and (Flipped == false or GetDistance(TargetMouseSpot) > 120) or self.Menu.OrbModeR.RangedHelperStandStill:Value() then
            OrbWalkSpot = TargetMouseSpot
            Flipped = false
        else
            if Flipped == false then
                SavedSpot = TargetMouseSpot
            end
            if GetDistance(SavedSpot) > 100 and GetDistance(TargetMouseSpot) > 60 then
                Flipped = false
            else
                Flipped = true
                MouseDirection = Vector((myHero.pos-mousePos):Normalized())
                MouseDistance = GetDistance(mousePos, myHero.pos) * 0.2
                MouseSpot = myHero.pos + MouseDirection * (MouseDistance + 100)

                TargetMouseDirection = Vector((target.pos-MouseSpot):Normalized())
                RangeDifference = AARange - EAArange
                if RangeDifference > 0 then
                    RangeDifference = RangeDifference/2
                else
                    RangeDifference = RangeDifference
                end
                TargetDistance = EAArange + RangeDifference
                TargetMouseSpot = target.pos - TargetMouseDirection * TargetDistance
                OrbWalkSpot = TargetMouseSpot
            end
        end
        return OrbWalkSpot
    else
        return nil
    end
end



function Utility:RangedHelper()
    local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
    local MoveSpot = nil
    local RangedMenuMouseDistance = self.Menu.OrbModeR.RangedHelperMouseDistance:Value()
    local ModeCheck = Mode() == "Combo" or (Mode() == "Harass" and self.Menu.OrbModeR.UseRangedHelperHarass:Value())
    local RangedSkillsOnly = self.Menu.OrbModeR.RangedHelperSkillsOnly:Value()
    local OrbWalkSpot = nil
    local MouseInWall = false
    if target and ValidTarget(target) then
        local EAArange = _G.SDK.Data:GetAutoAttackRange(target)

        local MouseDirection = Vector((myHero.pos-mousePos):Normalized())
        local MouseDistance = GetDistance(mousePos, myHero.pos) * 0.2
        local MouseSpot = myHero.pos - MouseDirection * (MouseDistance + 100)


        local TargetMouseDirection = Vector((target.pos-MouseSpot):Normalized())
        local RangeDifference = AARange - EAArange
        if RangeDifference > 0 then
            RangeDifference = RangeDifference/2
        else
            RangeDifference = RangeDifference
        end
        local TargetDistance = EAArange + RangeDifference
        local TargetMouseSpot = target.pos - TargetMouseDirection * TargetDistance

        if GetDistance(TargetMouseSpot) > 60 and (Flipped == false or GetDistance(TargetMouseSpot) > 120) or self.Menu.OrbModeR.RangedHelperStandStill:Value() then
            OrbWalkSpot = TargetMouseSpot
            Flipped = false
        else
            if Flipped == false then
                SavedSpot = TargetMouseSpot
            end
            if GetDistance(SavedSpot) > 100 and GetDistance(TargetMouseSpot) > 60 then
                Flipped = false
            else
                Flipped = true
                MouseDirection = Vector((myHero.pos-mousePos):Normalized())
                MouseDistance = GetDistance(mousePos, myHero.pos) * 0.2
                MouseSpot = myHero.pos + MouseDirection * (MouseDistance + 100)

                TargetMouseDirection = Vector((target.pos-MouseSpot):Normalized())
                RangeDifference = AARange - EAArange
                if RangeDifference > 0 then
                    RangeDifference = RangeDifference/2
                else
                    RangeDifference = RangeDifference
                end
                TargetDistance = EAArange + RangeDifference
                TargetMouseSpot = target.pos - TargetMouseDirection * TargetDistance
                OrbWalkSpot = TargetMouseSpot
            end
        end
        if OrbWalkSpot  then
            MouseInWall = MapPosition:inWall(OrbWalkSpot)
        end


    end
    if MouseInWall then
        --PrintChat("Mouse in wall")
    else
        --PrintChat("Mouse n")
    end
    if OrbWalkSpot ~= nil and GetDistance(OrbWalkSpot) > 0 and not MouseInWall and not RangedSkillsOnly and 
    not _G.SDK.Attack:IsActive() and self:CanClick() and self.Menu.RangedKey:Value() and self.Menu.OrbModeR.UseRangedHelper:Value() 
    and target and ValidTarget(target) and ModeCheck and GetDistance(mousePos, target.pos) < RangedMenuMouseDistance 
    and GetDistance(target.pos) <= AARange + self.Menu.OrbModeR.RangedHelperExtraDistance:Value() then
        --PrintChat("Ranged Helper FOrce")
        _G.SDK.Orbwalker.ForceMovement = OrbWalkSpot
    elseif not _G.SDK.Attack:IsActive() then
        _G.SDK.Orbwalker.ForceMovement = nil
        RangedHelperActive = false
    end
    if OrbWalkSpot and GetDistance(OrbWalkSpot) < 60 and self.Menu.OrbModeR.RangedHelperStandStill:Value() and self:CanClick() then
        _G.SDK.Orbwalker:SetMovement(false)
        MovementSet = "False" 
    else
        _G.SDK.Orbwalker:SetMovement(true)
    end
end

function Utility:MeleeHelper()
    local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
    local MoveSpot = nil


    local DariusCheck = _G.QHelperActive
    local AatroxQCheck = 0
    local MeleeMenuMouseDistance = self.Menu.OrbMode.MeleeHelperMouseDistance:Value()
    if _G.AatroxQType then
        AatroxQCheck = _G.AatroxQType
        MeleeMenuMouseDistance = 700 
    end
    local AatroxQCasting = myHero.activeSpell.name == "AatroxQWrapperCast"
    local ModeCheck = Mode() == "Combo" or (Mode() == "Harass" and self.Menu.OrbMode.UseMeleeHelperHarass:Value())
    local SkillsOrAttack = (AatroxQCheck > 0 or not self.Menu.OrbMode.MeleeHelperSkillsOnly:Value())
    local OrbWalkSpot = nil
    local MouseInWall = false
    if target and ValidTarget(target) then
        local MouseDirection = Vector((target.pos-mousePos):Normalized())
        local MouseDistance = GetDistance(mousePos, target.pos)
        local MouseSpotDistance = AARange - (target.boundingRadius+30)
        local MouseSpot = target.pos - MouseDirection * (MouseSpotDistance)
        OrbWalkSpot  = MouseSpot
        if OrbWalkSpot  then
            MouseInWall = MapPosition:inWall(OrbWalkSpot)
        end
    end
    if MouseInWall then
        --PrintChat("Mouse in wall")
    else
        --PrintChat("Mouse n")
    end
    if not MouseInWall and SkillsOrAttack and not AatroxQCasting and not _G.SDK.Attack:IsActive() and not DariusCheck and self:CanClick() and self.Menu.MeleeKey:Value() and self.Menu.OrbMode.UseMeleeHelper:Value() and target and ValidTarget(target) and ModeCheck and GetDistance(mousePos, target.pos) < MeleeMenuMouseDistance and (GetDistance(target.pos) <= AARange + self.Menu.OrbMode.MeleeHelperExtraDistance:Value() or AatroxQCheck > 0) then
        local MouseDirection = Vector((target.pos-mousePos):Normalized())
        local MouseDistance = GetDistance(mousePos, target.pos)
        local MouseSpotDistance = AARange - (target.boundingRadius+30)
        if IsFacing(target) then
            MouseSpotDistance = AARange - (target.boundingRadius/2)
            --PrintChat("Facing")
        end
        if AatroxQCheck > 0 then
            if AatroxQCheck == 1 then
                MouseSpotDistance = 545
            elseif AatroxQCheck == 2 then
                MouseSpotDistance = 355
            elseif AatroxQCheck == 3 then
                MouseSpotDistance = 280
            end
            MouseDirection = Vector((target.pos-myHero.pos):Normalized())
        end
        local MouseSpot = target.pos - MouseDirection * (MouseSpotDistance)
        MoveSpot = MouseSpot
        if MoveSpot and GetDistance(MoveSpot) > 55 then
            _G.SDK.Orbwalker.ForceMovement = MoveSpot
        end
        --PrintChat("Forcing")
    elseif not _G.SDK.Attack:IsActive() then
        if not DariusCheck then
            _G.SDK.Orbwalker.ForceMovement = nil
        end
        MeleeHelperActive = false
    end
    if MoveSpot and GetDistance(MoveSpot) < 55 and (GetDistance(target.pos) <= AARange or AatroxQCheck > 0) then
        _G.SDK.Orbwalker:SetMovement(false)
        MovementSet = "False"
        --PrintChat("False")
    elseif self.Menu.OrbMode.UseMeleeHelper:Value() then
        _G.SDK.Orbwalker:SetMovement(true)
    end
end




function Utility:Exhaust()
    local TargetEnemy = nil
    if target and ValidTarget(target, Range) then
        TargetEnemy = target
    else
        for i, enemy in pairs(EnemyHeroes) do
            if enemy and not enemy.dead and ValidTarget(enemy, Range) then
                if not TargetEnemy or enemy.ap >= TargetEnemy.ap then
                    TargetEnemy = enemy
                end
            end
        end
    end
    if TargetEnemy and Exhaust and IsReady(Exhaust) then
        Control.CastSpell(ExhaustSpell, TargetEnemy)
    end
end




function OnLoad()
    Loader()
end
