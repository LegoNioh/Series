require "PremiumPrediction"
require "DamageLib"
require "2DGeometry"
require "MapPositionGOS"

local EnemyHeroes = {}
local AllyHeroes = {}
-- [ AutoUpdate ] --
do
    
    local Version = 12.00
    
    local Files = {
        Lua = {
            Path = SCRIPT_PATH,
            Name = "SeriesV2.lua",
            Url = "https://raw.githubusercontent.com/LegoNioh/Series/master/SeriesV2.lua"
        },
        Version = {
            Path = SCRIPT_PATH,
            Name = "SeriesV2.version",
            Url = "https://raw.githubusercontent.com/LegoNioh/Series/master/SeriesV2.version"    -- check if Raw Adress correct pls.. after you have create the version file on Github
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
    elseif myHero.charName == "Viktor" then
        DelayAction(function() self:LoadViktor() end, 1.05)
    elseif myHero.charName == "Velkoz" then
        DelayAction(function() self:LoadVelkoz() end, 1.05)
    elseif myHero.charName == "Neeko" then
        DelayAction(function() self:LoadNeeko() end, 1.05)
    elseif myHero.charName == "Vayne" then
        DelayAction(function() self:LoadVayne() end, 1.05)
    elseif myHero.charName == "Orianna" then
        DelayAction(function() self:LoadOrianna() end, 1.05)
    end
end


function Manager:LoadVayne()
    Vayne:Spells()
    Vayne:Menu()
    --
    --GetEnemyHeroes()
    Callback.Add("Tick", function() Vayne:Tick() end)
    Callback.Add("Draw", function() Vayne:Draw() end)
    if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...) Vayne:OnPreAttack(...) end)
        _G.SDK.Orbwalker:OnPostAttackTick(function(...) Vayne:OnPostAttackTick(...) end)
        _G.SDK.Orbwalker:OnPostAttack(function(...) Vayne:OnPostAttack(...) end)
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

function Manager:LoadNeeko()
    Neeko:Spells()
    Neeko:Menu()
    --
    --GetEnemyHeroes()
    Callback.Add("Tick", function() Neeko:Tick() end)
    Callback.Add("Draw", function() Neeko:Draw() end)
    if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...) Neeko:OnPreAttack(...) end)
        _G.SDK.Orbwalker:OnPostAttackTick(function(...) Neeko:OnPostAttackTick(...) end)
    end
end

function Manager:LoadVelkoz()
    Velkoz:Spells()
    Velkoz:Menu()
    --
    --GetEnemyHeroes()
    Callback.Add("Tick", function() Velkoz:Tick() end)
    Callback.Add("Draw", function() Velkoz:Draw() end)
    if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...) Velkoz:OnPreAttack(...) end)
        _G.SDK.Orbwalker:OnPostAttackTick(function(...) Velkoz:OnPostAttackTick(...) end)
    end
end

function Manager:LoadOrianna()
    Orianna:Spells()
    Orianna:Menu()
    --
    --GetEnemyHeroes()
    Callback.Add("Tick", function() Orianna:Tick() end)
    Callback.Add("Draw", function() Orianna:Draw() end)
    if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...) Orianna:OnPreAttack(...) end)
        _G.SDK.Orbwalker:OnPostAttackTick(function(...) Orianna:OnPostAttackTick(...) end)
    end
end

function Manager:LoadViktor()
    Viktor:Spells()
    Viktor:Menu()
    --
    --GetEnemyHeroes()
    Callback.Add("Tick", function() Viktor:Tick() end)
    Callback.Add("Draw", function() Viktor:Draw() end)
    if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...) Viktor:OnPreAttack(...) end)
        _G.SDK.Orbwalker:OnPostAttackTick(function(...) Viktor:OnPostAttackTick(...) end)
    end
end

function Manager:LoadViktor()
    Viktor:Spells()
    Viktor:Menu()
    --
    --GetEnemyHeroes()
    Callback.Add("Tick", function() Viktor:Tick() end)
    Callback.Add("Draw", function() Viktor:Draw() end)
    if _G.SDK then
        _G.SDK.Orbwalker:OnPreAttack(function(...) Viktor:OnPreAttack(...) end)
        _G.SDK.Orbwalker:OnPostAttackTick(function(...) Viktor:OnPostAttackTick(...) end)
    end
end


class "Vayne"

local EnemyLoaded = false
local casted = 0
local LastCalledTime = 0
local LastESpot = myHero.pos
local LastE2Spot = myHero.pos
local PickingCard = false
local TargetAttacking = false
local attackedfirst = 0
local CastingQ = false
local LastDirect = 0
local CastingW = false
local LastHit = nil
local WStacks = 0
local HadStun = false
local StunTime = Game.Timer()
local CastingR = false
local ReturnMouse = mousePos
local Q = 1
local Edown = false
local R = 1
local WasInRange = false
local OneTick
local attacked = 0

function Vayne:Menu()
    self.Menu = MenuElement({type = MENU, id = "Vayne", name = "Vayne"})
    self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
    self.Menu.ComboMode:MenuElement({id = "UseQ", name = "Use Q in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseE", name = "Use E in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseEDelay", name = "E Delay", value = 50, min = 0, max = 200, step = 10})
    self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
    self.Menu.HarassMode:MenuElement({id = "UseQ", name = "Use Q in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseE", name = "Use E in Harass", value = false})
    self.Menu:MenuElement({id = "AutoMode", name = "Auto", type = MENU})
    self.Menu.AutoMode:MenuElement({id = "UseE", name = "Auto Use E", value = true})

    self.Menu:MenuElement({id = "KSMode", name = "KS", type = MENU})
    self.Menu.KSMode:MenuElement({id = "UseQ", name = "Use Q in KS", value = true})
    self.Menu.KSMode:MenuElement({id = "UseE", name = "Use E in KS", value = true})

    self.Menu:MenuElement({id = "Draw", name = "Draw", type = MENU})
    self.Menu.Draw:MenuElement({id = "UseDraws", name = "Enable Draws", value = false})
end

function Vayne:Spells()
end

function Vayne:__init()
    DelayAction(function() self:LoadScript() end, 1.05)
end

function Vayne:LoadScript()
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

function Vayne:Tick()
    if _G.JustEvade and _G.JustEvade:Evading() or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or Game.IsChatOpen() or myHero.dead then return end
    target = GetTarget(1400)
    CastingE = myHero.activeSpell.name == "VayneCondemn"
    if target then
        TwoStacks = _G.SDK.BuffManager:GetBuffCount(target, "VayneSilveredDebuff")
        --PrintChat(TwoStacks)
    else
        TwoStacks = 0
    end
    --PrintChat(myHero.activeSpell.name)
    self:Logic()
    self:Auto()
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

function Vayne:Draw()
    if self.Menu.Draw.UseDraws:Value() then
        Draw.Circle(myHero.pos, 225, 1, Draw.Color(255, 0, 191, 255))
        if target then
            local unit = target
            local NextSpot = GetUnitPositionNext(unit)
            local PredictedPos = unit.pos
            local Direction = Vector((PredictedPos-myHero.pos):Normalized())
            if NextSpot then
                local Time = (GetDistance(unit.pos, myHero.pos) / 2000) + 0.25
                local UnitDirection = Vector((unit.pos-NextSpot):Normalized())
                PredictedPos = unit.pos - UnitDirection * (unit.ms*Time)
                Direction = Vector((PredictedPos-myHero.pos):Normalized())
            end

            for i=1, 5 do
                ESpot = PredictedPos + Direction * (87*i)
                Draw.Circle(ESpot, 50, 1, Draw.Color(255, 0, 191, 255)) 
            end
        end
    end
end

function Vayne:Auto()
    --PrintChat("ksing")
    for i, enemy in pairs(EnemyHeroes) do
        if enemy and not enemy.dead and ValidTarget(enemy) then
            if self:CanUse(_E, "KS") and ValidTarget(enemy, ERange) and TwoStacks == 2 then
                local Edamage = getdmg("E", enemy, myHero)
                local Wdamage = getdmg("W", enemy, myHero)
                if enemy.health < Edamage + Wdamage then
                    Control.CastSpell(HK_E, enemy)
                end
            end
            local Wall = self:CheckWallStun(enemy)
            if self:CanUse(_E, "Auto")) and ValidTarget(enemy, ERange) and not CastingE and Wall ~= nil and not enemy.pathing.isDashing then
                if TwoStacks ~= 1 or GetDistance(myHero.pos, Wall) < AARange then
                    Control.CastSpell(HK_E, enemy)
                end
            end
        end
    end
end 

function Vayne:CanUse(spell, mode)
    if mode == nil then
        mode = Mode()
    end
    --PrintChat(Mode())
    if spell == _Q then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseQ:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseQ:Value() then
            return true
        end
        if mode == "Flee" and IsReady(spell) and self.Menu.FleeMode.UseQ:Value() then
            return true
        end
        if mode == "KS" and IsReady(spell) and self.Menu.KSMode.UseQ:Value() then
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
    elseif spell == _W then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseW:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseW:Value() then
            return true
        end
    elseif spell == _E then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseE:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseE:Value() then
            return true
        end
        if mode == "Auto" and IsReady(spell) and self.Menu.AutoMode.UseE:Value() then
            return true
        end
        if mode == "KS" and IsReady(spell) and self.Menu.KSMode.UseE:Value() then
            return true
        end
    end
    return false
end



function Vayne:Logic()
    if target == nil then return end
    if Mode() == "Combo" or Mode() == "Harass" and target then
        local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
        if GetDistance(target.pos) < AARange then
            WasInRange = true
        end
        local ERange = 550

        if self:CanUse(_E, Mode()) and ValidTarget(target, ERange) and TwoStacks == 2 then
            local Edamage = getdmg("E", enemy, myHero)
            local Wdamage = getdmg("W", enemy, myHero)
            if target.health < Edamage + Wdamage then
                Control.CastSpell(HK_E, target)
            end
        end

        local Wall = self:CheckWallStun(target)
        if self:CanUse(_E, Mode()) and ValidTarget(target, ERange) and not CastingE and Wall ~= nil and not target.pathing.isDashing then
            if TwoStacks ~= 1 or GetDistance(myHero.pos, Wall) < AARange then
                Control.CastSpell(HK_E, target)
            end
        end
    else
        WasInRange = false
    end     
end

function Vayne:CheckWallStun(unit)
    local NextSpot = GetUnitPositionNext(unit)
    local PredictedPos = unit.pos
    local Direction = Vector((PredictedPos-myHero.pos):Normalized())
    if NextSpot then
        local Time = (GetDistance(unit.pos, myHero.pos) / 2000) + 0.25
        local UnitDirection = Vector((unit.pos-NextSpot):Normalized())
        PredictedPos = unit.pos - UnitDirection * (unit.ms*Time)
        Direction = Vector((PredictedPos-myHero.pos):Normalized())
    end
    local FoundStun = false
    for i=1, 5 do
        ESpot = PredictedPos + Direction * (87*i) 
        if MapPosition:inWall(ESpot) then
            FoundStun = true
            if HadStun == false then
                StunTime = Game.Timer()
                HadStun = true
            elseif Game.Timer() - StunTime > (self.Menu.ComboMode.UseEDelay:Value()/1000) then
                HadStun = false
                return ESpot
            end
        end
    end
    if FoundStun == false then
        HadStun = false
    end
    return nil
end


function Vayne:OnPostAttack(args)
end

function Vayne:OnPostAttackTick(args)
    attackedfirst = 1
    attacked = 1
end

function Vayne:OnPreAttack(args)
    if target then
        --PrintChat(myHero.activeSpell.name)
        --PrintChat(target.charName)
    end
end

function Vayne:UseE(unit, hits)
    local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, ESpellData)
    if pred.CastPos and _G.PremiumPrediction.HitChance.Low(pred.HitChance) and myHero.pos:DistanceTo(pred.CastPos) < 1001 and pred.HitCount >= hits then
        Control.CastSpell(HK_E, pred.CastPos)
    end 
end

class "Orianna"

local EnemyLoaded = false
local Whits = 0
local Rhits = 0
local AllyLoaded = false

local GotBall = "None"
local BallUnit = myHero
local Ball = nil
local arrived = true
local CurrentSpot = myHero.pos
local LastSpot = myHero.pos
local StartSpot = myHero.pos

local CastedQ = false
local TickQ = false
local CastedE = false
local TickE = false
local CastTime = 0

local attackedfirst = 0
local WasInRange = false

function Orianna:Menu()
    self.Menu = MenuElement({type = MENU, id = "Orianna", name = "Orianna"})
    self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
    self.Menu.ComboMode:MenuElement({id = "UseQ", name = "Use Q in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseW", name = "Use W in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseWmin", name = "Number of Targets(W)", value = 1, min = 1, max = 5, step = 1})
    self.Menu.ComboMode:MenuElement({id = "UseE", name = "Use E in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseR", name = "Use R in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseRmin", name = "Number of Targets(R)", value = 2, min = 1, max = 5, step = 1})
    self.Menu:MenuElement({id = "KSMode", name = "KS", type = MENU})
    self.Menu.KSMode:MenuElement({id = "UseQ", name = "Use Q in KS", value = true})
    self.Menu.KSMode:MenuElement({id = "UseW", name = "Use W in KS", value = true})
    self.Menu.KSMode:MenuElement({id = "UseR", name = "Use R in KS", value = true})
    self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
    self.Menu.HarassMode:MenuElement({id = "UseQ", name = "Use Q in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseW", name = "Use W in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseWmin", name = "Number of Targets(W)", value = 1, min = 1, max = 5, step = 1})
    self.Menu.HarassMode:MenuElement({id = "UseE", name = "Use E in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseR", name = "Use R in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseRmin", name = "Number of Targets(R)", value = 3, min = 1, max = 5, step = 1})
    self.Menu:MenuElement({id = "AutoMode", name = "Auto", type = MENU})
    self.Menu.AutoMode:MenuElement({id = "UseQ", name = "Auto Use Q", value = false})
    self.Menu.AutoMode:MenuElement({id = "UseW", name = "Auto Use W", value = false})
    self.Menu.AutoMode:MenuElement({id = "UseWmin", name = "Number of Targets(W)", value = 1, min = 1, max = 5, step = 1})
    self.Menu.AutoMode:MenuElement({id = "UseE", name = "Auto Use E", value = false})
    self.Menu.AutoMode:MenuElement({id = "UseR", name = "Auto Use R", value = false})
    self.Menu.AutoMode:MenuElement({id = "UseRmin", name = "Number of Targets(R)", value = 3, min = 1, max = 5, step = 1})
    self.Menu:MenuElement({id = "FarmMode", name = "Farm", type = MENU})
    self.Menu.FarmMode:MenuElement({id = "UseQ", name = "Use Q to farm", value = false})
    self.Menu.FarmMode:MenuElement({id = "UseW", name = "Use W to farm", value = false})
    self.Menu.FarmMode:MenuElement({id = "UseWmin", name = "Number of Targets(W)", value = 2, min = 1, max = 10, step = 1})
    self.Menu.FarmMode:MenuElement({id = "UseE", name = "Use E to farm", value = false})
    self.Menu:MenuElement({id = "Draw", name = "Draw", type = MENU})
    self.Menu.Draw:MenuElement({id = "UseDraws", name = "Enable Draws", value = false})
end

function Orianna:Spells()
    QSpellData = {speed = 1400, range = 2000, delay = 0.10, radius = 100, collision = {}, type = "linear"}
end

function Orianna:__init()
    DelayAction(function() self:LoadScript() end, 1.05)
end

function Orianna:LoadScript()
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

function Orianna:Tick()
    if _G.JustEvade and _G.JustEvade:Evading() or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or Game.IsChatOpen() or myHero.dead then return end
    --PrintChat(myHero:GetSpellData(_W).name)
    --PrintChat(myHero:GetSpellData(_R).toggleState)
    target = GetTarget(1400)
    --PrintChat(myHero.activeSpell.name)
    --PrintChat(GotBall)
    self:ProcessSpells()
    if TickQ or TickE then
        Ball = self:ScanForBall()
        TickQ = false
        TickE = false
    end
    --self:KS()
    self:TrackBall()
    if Mode() == "LaneClear" then
        self:LaneClear()
    else
        self:Logic()
        self:Auto()
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
    if AllyLoaded == false then
        local CountAlly = 0
        for i, ally in pairs(AllyHeroes) do
            CountAlly = CountAlly + 1
        end
        if CountAlly < 1 then
            GetAllyHeroes()
        else
            AllyLoaded = true
            PrintChat("Ally Loaded")
        end
    end
end

function Orianna:LaneClear()
    local FarmWhits = 0
    --PrintChat("Farming")
    if self:CanUse(_Q, "Farm") or self:CanUse(_W, "Farm") or self:CanUse(_E, "Farm") then
        local Minions = _G.SDK.ObjectManager:GetEnemyMinions(850)
        for i = 1, #Minions do
            local minion = Minions[i]
            local Qrange = 825
            if CurrentSpot and arrived then
                --PrintChat("Current farm spot")
                local Qdamage = getdmg("Q", minion, myHero)
                if self:CanUse(_Q, "Farm") and ValidTarget(minion, Qrange) then
                    --PrintChat("Casting Q farm")
                    self:UseQ(minion, 1)
                end
                if GetDistance(minion.pos, CurrentSpot) < 250 then
                    FarmWhits = FarmWhits + 1
                    local Wdamage = getdmg("W", minion, myHero)
                    if self:CanUse(_W, "Farm") then
                        if FarmWhits >= self.Menu.FarmMode.UseWmin:Value() then
                            Control.CastSpell(HK_W)
                        end
                    end
                end
                if self:CanUse(_E, "Farm") then
                    if GotBall == "Q" then
                        local Direction = Vector((CurrentSpot-myHero.pos):Normalized())
                        local EDist = GetDistance(minion.pos, CurrentSpot)
                        ESpot = CurrentSpot - Direction * EDist
                        if GetDistance(ESpot, minion.pos) < 100 then
                            Control.CastSpell(HK_E, myHero)
                        end                    
                    end 
                end
            end
        end
    end
end

function Orianna:ProcessSpells()
    if myHero:GetSpellData(_Q).currentCd == 0 then
        CastedQ = false
    else
        if CastedQ == false then
            --GotBall = "QCast"
            TickQ = true
        end
        CastedQ = true
    end
    if myHero:GetSpellData(_E).currentCd == 0 then
        CastedE = false
    else
        if CastedE == false then
            --GotBall = "ECast"
            TickE = true
        end
        CastedE = true
    end
end

function Orianna:ScanForBall()
    local count = Game.MissileCount()
    for i = count, 1, -1 do
        local missile = Game.Missile(i)
        local data = missile.missileData
        if data and data.owner == myHero.handle then
            if data.name == "OrianaIzuna" then
                CastTime = Game.Timer()
                GotBall = "Q"
                return missile
            end
            if data.name == "OrianaRedact" then
                --PrintChat("Found E")
                if data.target then
                    --PrintChat(data.target)
                    --PrintChat(myHero.handle)
                    for i, ally in pairs(AllyHeroes) do
                        if ally and not ally.dead then
                            if ally.handle == data.target then
                                --PrintChat(ally.charName)
                                BallUnit = ally
                                GotBall = "Etarget"
                                CastTime = Game.Timer()
                                return missile
                            end
                        end
                    end
                end
                CastTime = Game.Timer()
                --GotBall = "E"
                return missile
            end
        end
    end
end

function Orianna:Draw()
    if self.Menu.Draw.UseDraws:Value() then

        Draw.Circle(myHero.pos, 100, 1, Draw.Color(255, 0, 0, 255))
        if Ball and (Ball.missileData.name == "OrianaIzuna" or Ball.missileData.name == "OrianaRedact") then
            Draw.Circle(Vector(Ball.missileData.placementPos), 100, 1, Draw.Color(255, 0, 191, 255))
        end
        if LastSpot and StartSpot then
            if GotBall == "Q" then
                Draw.Circle(LastSpot, 200, 1, Draw.Color(255, 0, 191, 255))
                Draw.Circle(StartSpot, 200, 1, Draw.Color(255, 0, 191, 255))
            elseif GotBall == "Etarget" then
                Draw.Circle(StartSpot, 200, 1, Draw.Color(255, 0, 191, 255))
                Draw.Circle(BallUnit.pos, 200, 1, Draw.Color(255, 0, 191, 255))
            end     
        end
        if CurrentSpot then
            Draw.Circle(CurrentSpot, 100, 1, Draw.Color(255, 255, 0, 100))
        end
        if target then
            AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
            Draw.Circle(myHero.pos, AARange, 1, Draw.Color(255, 0, 191, 255))
        end
    end
end

function Orianna:TrackBall()
    if Ball and (Ball.missileData.name == "OrianaIzuna" or Ball.missileData.name == "OrianaRedact") then
        --PrintChat(Ball.missileData.speed)
        LastSpot = Vector(Ball.missileData.endPos)
        StartSpot = Vector(Ball.missileData.startPos)
    end
    if LastSpot and StartSpot then
        --PrintChat("Last spot and start spot")
        if GotBall == "Q" then
            local TimeGone = Game.Timer() - CastTime
            local Traveldist = 1400*TimeGone
            local Direction = Vector((StartSpot-LastSpot):Normalized())
            CurrentSpot = StartSpot - Direction * Traveldist
            if GetDistance(StartSpot, LastSpot) < Traveldist then
                arrived = true
                CurrentSpot = LastSpot
                Traveldist = GetDistance(StartSpot, LastSpot) + 100
            else
                arrived = false
            end
        elseif GotBall == "Etarget" then
            --PrintChat("Got Etarget")
            local TimeGone = Game.Timer() - CastTime
            local Traveldist = 1850*TimeGone
            local Direction = Vector((StartSpot-BallUnit.pos):Normalized())
            CurrentSpot = StartSpot - Direction * Traveldist
            if GetDistance(StartSpot, BallUnit.pos) < Traveldist then
                arrived = true
                CurrentSpot = BallUnit.pos
                Traveldist = GetDistance(StartSpot, BallUnit.pos) + 100
            else
                arrived = false
            end
        elseif GotBall == "None" then
            --PrintChat("none")
            CurrentSpot = myHero.pos
        end
        if (GetDistance(CurrentSpot, myHero.pos) > 1250 or GetDistance(CurrentSpot, myHero.pos) < 100) and GotBall == "Q" and arrived == true then
            --PrintChat("Returning Q")
            CurrentSpot = myHero.pos
            GotBall = "Return"
        elseif GetDistance(CurrentSpot, myHero.pos) > 1350 and (GotBall == "Etarget" or GotBall == "E") and arrived == true then
            --PrintChat("Returning E")
            --PrintChat(GetDistance(CurrentSpot, myHero.pos))
            CurrentSpot = myHero.pos
            BallUnit = nil
            GotBall = "Return"
        end
        if GotBall == "Return" then
            CurrentSpot = myHero.pos
        end   
    end
end 

function Orianna:KS()
    --PrintChat("ksing")
    for i, enemy in pairs(EnemyHeroes) do
        if enemy and not enemy.dead and ValidTarget(enemy) then
            local Qrange = 600
            local Qdamage = getdmg("Q", enemy, myHero, myHero:GetSpellData(_Q).level)
            if CurrentSpot and arrived then
                if self:CanUse(_Q, "KS") and GetDistance(enemy.pos, CurrentSpot) < Qrange and enemy.health < Qdamage then
                    self:UseQ(enemy)
                end
            end
        end
    end
end 

function Orianna:Auto()
    Whits = 0
    Rhits = 0
    for i, enemy in pairs(EnemyHeroes) do
        if enemy and not enemy.dead and ValidTarget(enemy) then
            local Qrange = 825
            if CurrentSpot and arrived then
                local what = nil
                local Qdamage = getdmg("Q", enemy, myHero)
                if self:CanUse(_Q, "KS") and ValidTarget(enemy, Qrange) and Qdamage > enemy.health then
                    self:UseQ(enemy, 1)
                end
                if self:CanUse(_Q, "Auto") and ValidTarget(enemy, Qrange) then
                    self:UseQ(enemy, 1)
                end
                if GetDistance(enemy.pos, CurrentSpot) < 250 then
                    Whits = Whits + 1
                    local Wdamage = getdmg("W", enemy, myHero)
                    if self:CanUse(_W, "Auto") then
                        if Whits >= self.Menu.AutoMode.UseWmin:Value() then
                            Control.CastSpell(HK_W)
                        end
                    end
                    if self:CanUse(_W, "KS") then
                        if enemy.health < Wdamage then
                            Control.CastSpell(HK_W)
                        end
                    end
                end
                if GetDistance(enemy.pos, CurrentSpot) < 325 then
                    Rhits = Rhits + 1
                    local Rdamage = getdmg("R", enemy, myHero)
                    if self:CanUse(_R, "Auto") then
                        if Rhits >= self.Menu.AutoMode.UseRmin:Value() then
                            Control.CastSpell(HK_R)
                        end
                    end
                    if self:CanUse(_R, "KS") then
                        if enemy.health < Rdamage then
                            Control.CastSpell(HK_R)
                        end
                    end
                end
                if self:CanUse(_E, "Auto") then
                    if GotBall == "Q" then
                        if (GetDistance(enemy.pos, CurrentSpot) > 250 or not self:CanUse(_W, "Auto") or Whits < self.Menu.AutoMode.UseWmin:Value()) and (GetDistance(enemy.pos, CurrentSpot) > 325 or not self:CanUse(_R, "Auto") or Whits < self.Menu.AutoMode.UseRmin:Value()) then
                            local Direction = Vector((CurrentSpot-myHero.pos):Normalized())
                            local EDist = GetDistance(enemy.pos, CurrentSpot)
                            ESpot = CurrentSpot - Direction * EDist
                            if GetDistance(ESpot, enemy.pos) < 100 then
                                Control.CastSpell(HK_E, myHero)
                            end 
                        end                   
                    end 
                end
            end
        end
    end
end

function Orianna:CanUse(spell, mode)
    if mode == nil then
        mode = Mode()
    end
    --PrintChat(Mode())
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
        if mode == "Auto" and IsReady(spell) and self.Menu.AutoMode.UseQ:Value() then
            return true
        end
        if mode == "Farm" and IsReady(spell) and self.Menu.FarmMode.UseQ:Value() then
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
        if mode == "Auto" and IsReady(spell) and self.Menu.AutoMode.UseW:Value() then
            return true
        end
        if mode == "Farm" and IsReady(spell) and self.Menu.FarmMode.UseW:Value() then
            return true
        end
    elseif spell == _E then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseE:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseE:Value() then
            return true
        end
        if mode == "Auto" and IsReady(spell) and self.Menu.AutoMode.UseE:Value() then
            return true
        end
        if mode == "Farm" and IsReady(spell) and self.Menu.FarmMode.UseE:Value() then
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
        if mode == "Auto" and IsReady(spell) and self.Menu.AutoMode.UseR:Value() then
            return true
        end
    end
    return false
end

function Orianna:Logic()
    if target == nil then return end
    if Mode() == "Combo" or Mode() == "Harass" and target then
        local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
        if GetDistance(target.pos) < AARange then
            WasInRange = true
        end
        local Qrange = 825
        if CurrentSpot and arrived then
            if self:CanUse(_Q, Mode()) and ValidTarget(target, Qrange) then
                self:UseQ(target, 1)
            end
            if self:CanUse(_W, Mode()) and GetDistance(target.pos, CurrentSpot) < 250 then
                --PrintChat("Can use W")
                if Mode() == "Combo" and Whits >= self.Menu.ComboMode.UseWmin:Value() then
                    Control.CastSpell(HK_W)
                elseif Mode() == "Harass" and Whits >= self.Menu.HarassMode.UseWmin:Value() then
                    Control.CastSpell(HK_W)
                end
            end
            if self:CanUse(_R, Mode()) and GetDistance(target.pos, CurrentSpot) < 325 then
                if Mode() == "Combo" and Rhits >= self.Menu.ComboMode.UseRmin:Value() then
                    Control.CastSpell(HK_R)
                elseif Mode() == "Harass" and Rhits >= self.Menu.HarassMode.UseRmin:Value() then
                    Control.CastSpell(HK_R)
                end
            end
            if self:CanUse(_E, Mode()) then
                if GotBall == "Q" then
                    if (GetDistance(target.pos, CurrentSpot) > 250 or not self:CanUse(_W, Mode()) or Whits < self.Menu.ComboMode.UseWmin:Value()) and (GetDistance(target.pos, CurrentSpot) > 325 or not self:CanUse(_R, Mode()) or Rhits < self.Menu.ComboMode.UseRmin:Value()) then
                        local Direction = Vector((CurrentSpot-myHero.pos):Normalized())
                        local EDist = GetDistance(target.pos, CurrentSpot)
                        ESpot = CurrentSpot - Direction * EDist
                        if GetDistance(ESpot, target.pos) < 100 then
                            Control.CastSpell(HK_E, myHero)
                        end
                    end                    
                end 
            end
        end
    else
        WasInRange = false
    end     
end

function Orianna:OnPostAttackTick(args)
    attackedfirst = 1
    if target then
    end
end


function Orianna:GetRDmg(unit)
    return getdmg("R", unit, myHero, stage, myHero:GetSpellData(_R).level)
end

function Orianna:OnPreAttack(args)
    if self:CanUse(_E, Mode()) and target then
    end
end

function Orianna:UseQ(unit, hits)
    if arrived and CurrentSpot then
        if self:CanUse(_E, Mode()) then
            local ErouteDist = GetDistance(myHero.pos, unit.pos) + GetDistance(myHero.pos, CurrentSpot) * 0.75
            if GetDistance(CurrentSpot, unit.pos) > ErouteDist then
                Control.CastSpell(HK_E, myHero)
            else
                pred = _G.PremiumPrediction:GetAOEPrediction(CurrentSpot, unit, QSpellData)
                if pred.CastPos and _G.PremiumPrediction.HitChance.Low(pred.HitChance) and myHero.pos:DistanceTo(pred.CastPos) < 825 and pred.HitCount >= hits then
                    Control.CastSpell(HK_Q, pred.CastPos)
                end            
            end
        else
            pred = _G.PremiumPrediction:GetAOEPrediction(CurrentSpot, unit, QSpellData)
            if pred.CastPos and _G.PremiumPrediction.HitChance.Low(pred.HitChance) and myHero.pos:DistanceTo(pred.CastPos) < 825 and pred.HitCount >= hits then
                    Control.CastSpell(HK_Q, pred.CastPos)
            end
        end
    end
end

function Orianna:UseW(card)
    if card == "Gold" then
        card = "GoldCardLock"
    else
        card = "BlueCardLock"
    end
    if myHero:GetSpellData(_W).name == card then
        Control.CastSpell(HK_W)
        PickingCard = false
        LockGold = false
        LockBlue = false
        ComboCard = "Gold"
    elseif myHero:GetSpellData(_W).name == "PickACard" then
        if PickingCard == false then
            Control.CastSpell(HK_W)
            PickingCard = true
        end
    else
        PickingCard = false
    end
end


class "Velkoz"

local EnemyLoaded = false
local casted = 0
local LastCalledTime = 0
local LastESpot = myHero.pos
local LastE2Spot = myHero.pos
local PickingCard = false
local TargetAttacking = false
local attackedfirst = 0
local CastingQ = false
local LastDirect = 0
local CastingW = false
local CastingR = false
local ReturnMouse = mousePos
local Q = 1
local Edown = false
local R = 1
local WasInRange = false
local OneTick
local attacked = 0

function Velkoz:Menu()
    self.Menu = MenuElement({type = MENU, id = "Velkoz", name = "Velkoz"})
    self.Menu:MenuElement({id = "FleeKey", name = "Disengage Key", key = string.byte("T"), value = false})
    self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
    self.Menu.ComboMode:MenuElement({id = "UseQ", name = "Use Q in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseW", name = "Use W in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseE", name = "Use E in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseEDef", name = "Use Defensive E in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseEAtt", name = "Use Offensive E in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseEAttHits", name = "Min enemies for Offensive E", value = 1, min = 1, max = 5, step = 1})
    self.Menu.ComboMode:MenuElement({id = "UseR", name = "Use R in Combo", value = true})
    self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
    self.Menu.HarassMode:MenuElement({id = "UseQ", name = "Use Q in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseE", name = "Use E in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseW", name = "Use W in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseR", name = "Use R in Harass", value = false})

    self.Menu:MenuElement({id = "FleeMode", name = "Flee", type = MENU})
    self.Menu.FleeMode:MenuElement({id = "UseQ", name = "Use Q to Flee", value = true})
    self.Menu.FleeMode:MenuElement({id = "UseE", name = "Use E to Flee", value = true})

    self.Menu:MenuElement({id = "KSMode", name = "KS", type = MENU})
    self.Menu.KSMode:MenuElement({id = "UseQ", name = "Use Q in KS", value = true})

    self.Menu:MenuElement({id = "Draw", name = "Draw", type = MENU})
    self.Menu.Draw:MenuElement({id = "UseDraws", name = "Enable Draws", value = false})
end

function Velkoz:Spells()
    ESpellData = {speed = 1350, range = 500, delay = 0.25, radius = 70, collision = {}, type = "linear"}
    WSpellData = {speed = 3000, range = 800, delay = 0.5, radius = 300, collision = {}, type = "circular"}
    RSpellData = {speed = 3000, range = 700, delay = 0.25, radius = 300, collision = {}, type = "circular"}
end

function Velkoz:__init()
    DelayAction(function() self:LoadScript() end, 1.05)
end

function Velkoz:LoadScript()
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

function Velkoz:Tick()
    if _G.JustEvade and _G.JustEvade:Evading() or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or Game.IsChatOpen() or myHero.dead then return end
    target = GetTarget(1400)
    CastingQ = myHero.activeSpell.name == "VelkozPowerTransfer"
    CastingW = myHero.activeSpell.name == "VelkozGravitonField"
    CastingR = myHero.activeSpell.name == "VelkozChaosStorm"
    --PrintChat(myHero.activeSpell.name)
    --PrintChat(myHero:GetSpellData(_R).name)
    if Mode() == "LaneClear" then

    else
        self:Logic()
    end
    if not IsReady(_E) then
        Edown = false
    end
    if Edown == true then
        _G.SDK.Orbwalker:SetMovement(false)
    else
        _G.SDK.Orbwalker:SetMovement(true)
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

function Velkoz:Draw()
    if self.Menu.Draw.UseDraws:Value() then
        Draw.Circle(myHero.pos, 300, 1, Draw.Color(255, 0, 191, 255))
        if target then
        end
    end
end

function Velkoz:KS()
    --PrintChat("ksing")
    for i, enemy in pairs(EnemyHeroes) do
        if enemy and not enemy.dead and ValidTarget(enemy) then
        end
    end
end 

function Velkoz:CanUse(spell, mode)
    if mode == nil then
        mode = Mode()
    end
    --PrintChat(Mode())
    if spell == _Q then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseQ:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseQ:Value() then
            return true
        end
        if mode == "Flee" and IsReady(spell) and self.Menu.FleeMode.UseQ:Value() then
            return true
        end
        if mode == "KS" and IsReady(spell) and self.Menu.KSMode.UseQ:Value() then
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
    elseif spell == _W then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseW:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseW:Value() then
            return true
        end
    elseif spell == _E then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseE:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseE:Value() then
            return true
        end
        if mode == "Flee" and IsReady(spell) and self.Menu.FleeMode.UseE:Value() then
            return true
        end
    end
    return false
end


function Velkoz:DelayEscapeClick(delay)
    if Game.Timer() - LastCalledTime > delay then
        LastCalledTime = Game.Timer()
        Control.RightClick(mousePos:To2D())
    end
end


function Velkoz:Logic()
    if target == nil then return end
    if Mode() == "Combo" or Mode() == "Harass" and target then
        local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
        if GetDistance(target.pos) < AARange then
            WasInRange = true
        end
        local ERange = 1025
        local QRange = 600
        local WRange = 800
        local RRange = 700
        local TargetNextSpot = GetUnitPositionNext(target)
        if TargetNextSpot then
            TargetAttacking = GetDistance(myHero.pos, target.pos) > GetDistance(myHero.pos, TargetNextSpot)
        else
            TargetAttacking = false
        end

        if self:CanUse(_W, Mode()) and ValidTarget(target, WRange) and Edown == false and not CastingQ and not CastingW then
            if target.isDashing and TargetAttacking and self.Menu.ComboMode.UseEDef:Value() then
                Control.CastSpell(HK_W, myHero)
            elseif GetDistance(myHero.pos, target.pos) < 300 and self.Menu.ComboMode.UseEDef:Value() then
                Control.CastSpell(HK_W, myHero)
            elseif self.Menu.ComboMode.UseEAtt:Value() then
                self:UseW(target, self.Menu.ComboMode.UseEAttHits:Value(), TargetAttacking)
            end
        end
        if self:CanUse(_E, Mode()) and ValidTarget(target, ERange) and not CastingQ and not CastingW and not CastingR then
            self:UseE(target)
        end
        if self:CanUse(_Q, Mode()) and ValidTarget(target, QRange) and Edown == false and not CastingQ and not CastingW and not CastingR then
            Control.CastSpell(HK_Q, target)
        end
        local RDmg = getdmg("R", target, myHero, 1, myHero:GetSpellData(_R).level)
        local RDmgTick = getdmg("R", target, myHero, 2, myHero:GetSpellData(_R).level)
        local RDmgTotal = RDmg + RDmgTick*2
        if self:CanUse(_R, Mode()) and ValidTarget(target, RRange) and Edown == false and not CastingQ and not CastingW and not CastingR and target.health < RDmgTotal and myHero:GetSpellData(_R).name == "VelkozChaosStorm"then
            Control.CastSpell(HK_R, target)
            --LastDirect = Game.Timer() + 1
        end
        if self:CanUse(_R, Mode()) and ValidTarget(target) and Edown == false and not CastingQ and not CastingW and not CastingR and myHero:GetSpellData(_R).name == "VelkozChaosStormGuide" and (myHero.attackData.state == 3 or GetDistance(myHero.pos, target.pos) > AARange) then
            self:DirectR(target.pos)
        end
    else
        WasInRange = false
    end     
end

function Velkoz:DirectR(spot)
    if LastDirect - Game.Timer() < 0 then
        Control.CastSpell(HK_R, target)
        LastDirect = Game.Timer() + 1
    end
end

function Velkoz:UseE2(ECastPos, unit, pred)
            if Control.IsKeyDown(HK_E) then
                Control.SetCursorPos(pred.CastPos)
                Control.KeyUp(HK_E)
                DelayAction(function() Control.SetCursorPos(ReturnMouse) end, 0.01)
                DelayAction(function() Edown = false end, 0.50)   
            end
end

function Velkoz:OnPostAttackTick(args)
    if target then
    end
    attackedfirst = 1
    attacked = 1
end

function Velkoz:OnPreAttack(args)
    if self:CanUse(_E, Mode()) and target then
    end
end


function Velkoz:UseR1(unit, hits)
    local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, RSpellData)
    --PrintChat("trying E")
    if pred.CastPos and _G.PremiumPrediction.HitChance.Low(pred.HitChance) and myHero.pos:DistanceTo(pred.CastPos) < 701 and pred.HitCount >= hits then
            Control.CastSpell(HK_R, pred.CastPos)
            --Casted = 1
    end 
end

function Velkoz:UseW(unit, hits, attacking)
    local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, WSpellData)
    --PrintChat("trying E")
    if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and myHero.pos:DistanceTo(pred.CastPos) < 801 and pred.HitCount >= hits then
        if attacking == true then
            local Direction = Vector((pred.CastPos-myHero.pos):Normalized())
            local Wspot = pred.CastPos - Direction*100
            Control.CastSpell(HK_W, Wspot)
        else
            local Direction = Vector((pred.CastPos-myHero.pos):Normalized())
            local Wspot = pred.CastPos + Direction*100
            if GetDistance(myHero.pos, Wspot) > 800 then
                Control.CastSpell(HK_W, pred.CastPos)
            else
                Control.CastSpell(HK_W, Wspot)
            end
        end
            --Casted = 1
    end 
end

function Velkoz:UseE(unit)
    if GetDistance(unit.pos, myHero.pos) < 1025 then
        --PrintChat("Using E")
        local Direction = Vector((myHero.pos-unit.pos):Normalized())
        local Espot = myHero.pos - Direction*480
        if GetDistance(myHero.pos, unit.pos) < 480 then
            Espot = unit.pos
        end
        --Control.SetCursorPos(Espot)
        --Control.CastSpell(HK_E, unit)
        local pred = _G.PremiumPrediction:GetPrediction(Espot, unit, ESpellData)
        if pred.CastPos and _G.PremiumPrediction.HitChance.Low(pred.HitChance) and Espot:DistanceTo(pred.CastPos) < 501 then
            if Control.IsKeyDown(HK_E) and Edown == true then
                --_G.SDK.Orbwalker:SetMovement(false)
                --PrintChat("E down")
                self:UseE2(Espot, unit, pred)
            elseif Edown == false then
                --_G.SDK.Orbwalker:SetMovement(true)
                ReturnMouse = mousePos
                --PrintChat("Pressing E")
                Control.SetCursorPos(Espot)
                Control.KeyDown(HK_E)
                Edown = true
            end
        end
    end
end



class "Neeko"

local EnemyLoaded = false
local casted = 0
local LastCalledTime = 0
local LastESpot = myHero.pos
local LastE2Spot = myHero.pos
local PickingCard = false
local TargetAttacking = false
local attackedfirst = 0
local CastingQ = false
local LastDirect = 0
local CastingW = false
local CastingR = false
local ReturnMouse = mousePos
local Q = 1
local Edown = false
local R = 1
local WasInRange = false
local OneTick
local attacked = 0

function Neeko:Menu()
    self.Menu = MenuElement({type = MENU, id = "Neeko", name = "Neeko"})
    self.Menu:MenuElement({id = "FleeKey", name = "Disengage Key", key = string.byte("T"), value = false})
    self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
    self.Menu.ComboMode:MenuElement({id = "UseQ", name = "Use Q in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseE", name = "Use E in Combo", value = true})
    self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
    self.Menu.HarassMode:MenuElement({id = "UseQ", name = "Use Q in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseE", name = "Use E in Harass", value = false})

    self.Menu:MenuElement({id = "FleeMode", name = "Flee", type = MENU})
    self.Menu.FleeMode:MenuElement({id = "UseQ", name = "Use Q to Flee", value = true})
    self.Menu.FleeMode:MenuElement({id = "UseE", name = "Use E to Flee", value = true})

    self.Menu:MenuElement({id = "KSMode", name = "KS", type = MENU})
    self.Menu.KSMode:MenuElement({id = "UseQ", name = "Use Q in KS", value = true})
    self.Menu.KSMode:MenuElement({id = "UseE", name = "Use E in KS", value = true})

    self.Menu:MenuElement({id = "Draw", name = "Draw", type = MENU})
    self.Menu.Draw:MenuElement({id = "UseDraws", name = "Enable Draws", value = false})
end

function Neeko:Spells()
    ESpellData = {speed = 1300, range = 1000, delay = 0.25, radius = 70, collision = {}, type = "linear"}
    QSpellData = {speed = 1300, range = 800, delay = 0.10, radius = 225, collision = {}, type = "circular"}
end

function Neeko:__init()
    DelayAction(function() self:LoadScript() end, 1.05)
end

function Neeko:LoadScript()
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

function Neeko:Tick()
    if _G.JustEvade and _G.JustEvade:Evading() or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or Game.IsChatOpen() or myHero.dead then return end
    target = GetTarget(1400)
    CastingQ = myHero.activeSpell.name == "NeekoQ"
    CastingE = myHero.activeSpell.name == "NeekoE"
    --PrintChat(myHero.activeSpell.name)
    --PrintChat(myHero:GetSpellData(_R).name)
    self:Logic()
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

function Neeko:Draw()
    if self.Menu.Draw.UseDraws:Value() then
        Draw.Circle(myHero.pos, 225, 1, Draw.Color(255, 0, 191, 255))
        if target then
        end
    end
end

function Neeko:KS()
    --PrintChat("ksing")
    for i, enemy in pairs(EnemyHeroes) do
        if enemy and not enemy.dead and ValidTarget(enemy) then
        end
    end
end 

function Neeko:CanUse(spell, mode)
    if mode == nil then
        mode = Mode()
    end
    --PrintChat(Mode())
    if spell == _Q then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseQ:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseQ:Value() then
            return true
        end
        if mode == "Flee" and IsReady(spell) and self.Menu.FleeMode.UseQ:Value() then
            return true
        end
        if mode == "KS" and IsReady(spell) and self.Menu.KSMode.UseQ:Value() then
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
    elseif spell == _W then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseW:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseW:Value() then
            return true
        end
    elseif spell == _E then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseE:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseE:Value() then
            return true
        end
        if mode == "Flee" and IsReady(spell) and self.Menu.FleeMode.UseE:Value() then
            return true
        end
        if mode == "KS" and IsReady(spell) and self.Menu.KSMode.UseE:Value() then
            return true
        end
    end
    return false
end



function Neeko:Logic()
    if target == nil then return end
    if Mode() == "Combo" or Mode() == "Harass" and target then
        local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
        if GetDistance(target.pos) < AARange then
            WasInRange = true
        end
        local ERange = 1000
        local QRange = 800
        if self:CanUse(_E, Mode()) and ValidTarget(target, ERange) and not CastingQ and not CastingE then
            self:UseE(target, 1)
        end
        if self:CanUse(_Q, Mode()) and ValidTarget(target, QRange) and not CastingQ and not CastingE then
            self:UseQ(target, 1)
        end
    else
        WasInRange = false
    end     
end

function Neeko:OnPostAttackTick(args)
    if target then
    end
    attackedfirst = 1
    attacked = 1
end

function Neeko:OnPreAttack(args)
    if self:CanUse(_E, Mode()) and target then
    end
end

function Neeko:UseE(unit, hits)
    local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, ESpellData)
    if pred.CastPos and _G.PremiumPrediction.HitChance.Low(pred.HitChance) and myHero.pos:DistanceTo(pred.CastPos) < 1001 and pred.HitCount >= hits then
        Control.CastSpell(HK_E, pred.CastPos)
    end 
end

function Neeko:UseQ(unit, hits)
    local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, QSpellData)
    if pred.CastPos and _G.PremiumPrediction.HitChance.Low(pred.HitChance) and pred.HitCount >= hits then
        if myHero.pos:DistanceTo(pred.CastPos) < 801 then
            Control.CastSpell(HK_Q, pred.CastPos)
        else
            local Direction = Vector((myHero.pos-pred.CastPos):Normalized())
            local Espot = myhero.pos - Direction*800
            Control.CastSpell(HK_Q, pred.Espot)
        end
    end 
end

class "Viktor"

local EnemyLoaded = false
local casted = 0
local LastCalledTime = 0
local LastESpot = myHero.pos
local LastE2Spot = myHero.pos
local PickingCard = false
local TargetAttacking = false
local attackedfirst = 0
local CastingQ = false
local LastDirect = 0
local CastingW = false
local CastingR = false
local ReturnMouse = mousePos
local Q = 1
local Edown = false
local R = 1
local WasInRange = false
local OneTick
local attacked = 0

function Viktor:Menu()
    self.Menu = MenuElement({type = MENU, id = "Viktor", name = "Viktor"})
    self.Menu:MenuElement({id = "FleeKey", name = "Disengage Key", key = string.byte("T"), value = false})
    self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
    self.Menu.ComboMode:MenuElement({id = "UseQ", name = "Use Q in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseW", name = "Use W in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseE", name = "Use E in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseEDef", name = "Use Defensive E in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseEAtt", name = "Use Offensive E in Combo", value = true})
    self.Menu.ComboMode:MenuElement({id = "UseEAttHits", name = "Min enemies for Offensive E", value = 1, min = 1, max = 5, step = 1})
    self.Menu.ComboMode:MenuElement({id = "UseR", name = "Use R in Combo", value = true})
    self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
    self.Menu.HarassMode:MenuElement({id = "UseQ", name = "Use Q in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseE", name = "Use E in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseW", name = "Use W in Harass", value = false})
    self.Menu.HarassMode:MenuElement({id = "UseR", name = "Use R in Harass", value = false})

    self.Menu:MenuElement({id = "FleeMode", name = "Flee", type = MENU})
    self.Menu.FleeMode:MenuElement({id = "UseQ", name = "Use Q to Flee", value = true})
    self.Menu.FleeMode:MenuElement({id = "UseE", name = "Use E to Flee", value = true})

    self.Menu:MenuElement({id = "KSMode", name = "KS", type = MENU})
    self.Menu.KSMode:MenuElement({id = "UseQ", name = "Use Q in KS", value = true})

    self.Menu:MenuElement({id = "Draw", name = "Draw", type = MENU})
    self.Menu.Draw:MenuElement({id = "UseDraws", name = "Enable Draws", value = false})
end

function Viktor:Spells()
    ESpellData = {speed = 1350, range = 500, delay = 0.25, radius = 70, collision = {}, type = "linear"}
    WSpellData = {speed = 3000, range = 800, delay = 0.5, radius = 300, collision = {}, type = "circular"}
    RSpellData = {speed = 3000, range = 700, delay = 0.25, radius = 300, collision = {}, type = "circular"}
end

function Viktor:__init()
    DelayAction(function() self:LoadScript() end, 1.05)
end

function Viktor:LoadScript()
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

function Viktor:Tick()
    if _G.JustEvade and _G.JustEvade:Evading() or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or Game.IsChatOpen() or myHero.dead then return end
    target = GetTarget(1400)
    CastingQ = myHero.activeSpell.name == "ViktorPowerTransfer"
    CastingW = myHero.activeSpell.name == "ViktorGravitonField"
    CastingR = myHero.activeSpell.name == "ViktorChaosStorm"
    --PrintChat(myHero.activeSpell.name)
    --PrintChat(myHero:GetSpellData(_R).name)
    self:Logic()
    if not IsReady(_E) then
        Edown = false
    end
    if Edown == true then
        _G.SDK.Orbwalker:SetMovement(false)
    else
        _G.SDK.Orbwalker:SetMovement(true)
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

function Viktor:Draw()
    if self.Menu.Draw.UseDraws:Value() then
        Draw.Circle(myHero.pos, 300, 1, Draw.Color(255, 0, 191, 255))
        if target then
        end
    end
end

function Viktor:KS()
    --PrintChat("ksing")
    for i, enemy in pairs(EnemyHeroes) do
        if enemy and not enemy.dead and ValidTarget(enemy) then
        end
    end
end 

function Viktor:CanUse(spell, mode)
    if mode == nil then
        mode = Mode()
    end
    --PrintChat(Mode())
    if spell == _Q then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseQ:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseQ:Value() then
            return true
        end
        if mode == "Flee" and IsReady(spell) and self.Menu.FleeMode.UseQ:Value() then
            return true
        end
        if mode == "KS" and IsReady(spell) and self.Menu.KSMode.UseQ:Value() then
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
    elseif spell == _W then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseW:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseW:Value() then
            return true
        end
    elseif spell == _E then
        if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseE:Value() then
            return true
        end
        if mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseE:Value() then
            return true
        end
        if mode == "Flee" and IsReady(spell) and self.Menu.FleeMode.UseE:Value() then
            return true
        end
    end
    return false
end


function Viktor:DelayEscapeClick(delay)
    if Game.Timer() - LastCalledTime > delay then
        LastCalledTime = Game.Timer()
        Control.RightClick(mousePos:To2D())
    end
end


function Viktor:Logic()
    if target == nil then return end
    if Mode() == "Combo" or Mode() == "Harass" and target then
        local AARange = _G.SDK.Data:GetAutoAttackRange(myHero)
        if GetDistance(target.pos) < AARange then
            WasInRange = true
        end
        local ERange = 1025
        local QRange = 600
        local WRange = 800
        local RRange = 700
        local TargetNextSpot = GetUnitPositionNext(target)
        if TargetNextSpot then
            TargetAttacking = GetDistance(myHero.pos, target.pos) > GetDistance(myHero.pos, TargetNextSpot)
        else
            TargetAttacking = false
        end

        if self:CanUse(_W, Mode()) and ValidTarget(target, WRange) and Edown == false and not CastingQ and not CastingW then
            if target.isDashing and TargetAttacking and self.Menu.ComboMode.UseEDef:Value() then
                Control.CastSpell(HK_W, myHero)
            elseif GetDistance(myHero.pos, target.pos) < 300 and self.Menu.ComboMode.UseEDef:Value() then
                Control.CastSpell(HK_W, myHero)
            elseif self.Menu.ComboMode.UseEAtt:Value() then
                self:UseW(target, self.Menu.ComboMode.UseEAttHits:Value(), TargetAttacking)
            end
        end
        if self:CanUse(_E, Mode()) and ValidTarget(target, ERange) and not CastingQ and not CastingW and not CastingR then
            self:UseE(target)
        end
        if self:CanUse(_Q, Mode()) and ValidTarget(target, QRange) and Edown == false and not CastingQ and not CastingW and not CastingR then
            Control.CastSpell(HK_Q, target)
        end
        local RDmg = getdmg("R", target, myHero, 1, myHero:GetSpellData(_R).level)
        local RDmgTick = getdmg("R", target, myHero, 2, myHero:GetSpellData(_R).level)
        local RDmgTotal = RDmg + RDmgTick*2
        if self:CanUse(_R, Mode()) and ValidTarget(target, RRange) and Edown == false and not CastingQ and not CastingW and not CastingR and target.health < RDmgTotal and myHero:GetSpellData(_R).name == "ViktorChaosStorm"then
            Control.CastSpell(HK_R, target)
            --LastDirect = Game.Timer() + 1
        end
        if self:CanUse(_R, Mode()) and ValidTarget(target) and Edown == false and not CastingQ and not CastingW and not CastingR and myHero:GetSpellData(_R).name == "ViktorChaosStormGuide" and (myHero.attackData.state == 3 or GetDistance(myHero.pos, target.pos) > AARange) then
            self:DirectR(target.pos)
        end
    else
        WasInRange = false
    end     
end

function Viktor:DirectR(spot)
    if LastDirect - Game.Timer() < 0 then
        Control.CastSpell(HK_R, target)
        LastDirect = Game.Timer() + 1
    end
end

function Viktor:UseE2(ECastPos, unit, pred)
            if Control.IsKeyDown(HK_E) then
                Control.SetCursorPos(pred.CastPos)
                Control.KeyUp(HK_E)
                DelayAction(function() Control.SetCursorPos(ReturnMouse) end, 0.01)
                DelayAction(function() Edown = false end, 0.50)   
            end
end

function Viktor:OnPostAttackTick(args)
    if target then
    end
    attackedfirst = 1
    attacked = 1
end

function Viktor:OnPreAttack(args)
    if self:CanUse(_E, Mode()) and target then
    end
end


function Viktor:UseR1(unit, hits)
    local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, RSpellData)
    --PrintChat("trying E")
    if pred.CastPos and _G.PremiumPrediction.HitChance.Low(pred.HitChance) and myHero.pos:DistanceTo(pred.CastPos) < 701 and pred.HitCount >= hits then
            Control.CastSpell(HK_R, pred.CastPos)
            --Casted = 1
    end 
end

function Viktor:UseW(unit, hits, attacking)
    local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, WSpellData)
    --PrintChat("trying E")
    if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and myHero.pos:DistanceTo(pred.CastPos) < 801 and pred.HitCount >= hits then
        if attacking == true then
            local Direction = Vector((pred.CastPos-myHero.pos):Normalized())
            local Wspot = pred.CastPos - Direction*100
            Control.CastSpell(HK_W, Wspot)
        else
            local Direction = Vector((pred.CastPos-myHero.pos):Normalized())
            local Wspot = pred.CastPos + Direction*100
            if GetDistance(myHero.pos, Wspot) > 800 then
                Control.CastSpell(HK_W, pred.CastPos)
            else
                Control.CastSpell(HK_W, Wspot)
            end
        end
            --Casted = 1
    end 
end

function Viktor:UseE(unit)
    if GetDistance(unit.pos, myHero.pos) < 1025 then
        --PrintChat("Using E")
        local Direction = Vector((myHero.pos-unit.pos):Normalized())
        local Espot = myHero.pos - Direction*480
        if GetDistance(myHero.pos, unit.pos) < 480 then
            Espot = unit.pos
        end
        --Control.SetCursorPos(Espot)
        --Control.CastSpell(HK_E, unit)
        local pred = _G.PremiumPrediction:GetPrediction(Espot, unit, ESpellData)
        if pred.CastPos and _G.PremiumPrediction.HitChance.Low(pred.HitChance) and Espot:DistanceTo(pred.CastPos) < 501 then
            if Control.IsKeyDown(HK_E) and Edown == true then
                --_G.SDK.Orbwalker:SetMovement(false)
                --PrintChat("E down")
                self:UseE2(Espot, unit, pred)
            elseif Edown == false then
                --_G.SDK.Orbwalker:SetMovement(true)
                ReturnMouse = mousePos
                --PrintChat("Pressing E")
                Control.SetCursorPos(Espot)
                Control.KeyDown(HK_E)
                Edown = true
            end
        end
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
    if self.Menu.QE:Value() and Weapon == "Gun" then 
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
            local MeUnderTurret = IsUnderEnemyTurret(myHero.pos)
            local TargetUnderTurret = IsUnderEnemyTurret(target.pos)
            if self:CanUse(_Q, Mode(), Weapon) and ValidTarget(target, 600) and not myHero.pathing.isDashing then
                if not TargetUnderTurret or MeUnderTurret then
                    Control.CastSpell(HK_Q, target)
                end
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
            local MeUnderTurret = IsUnderEnemyTurret(myHero.pos)
            local TargetUnderTurret = IsUnderEnemyTurret(target.pos)
            if self:CanUse(_R, Mode(), Weapon) and (not TargetUnderTurret or MeUnderTurret) then
                if GetDistance(target.pos, myHero.pos) < 125 then
                    if self:CanUse(_W, Mode(), Weapon) then
                        Control.CastSpell(HK_W)
                    end
                    Control.CastSpell(HK_R)
                elseif GetDistance(target.pos, myHero.pos) < 240 and (Q1CD < Game.Timer() or W1CD < Game.Timer() or E1CD < Game.Timer() or Wbuff) and myHero.mana > 80 then
                    if self:CanUse(_W, Mode(), Weapon) then
                        Control.CastSpell(HK_W)
                    end
                    Control.CastSpell(HK_R)
                elseif GetDistance(target.pos, myHero.pos) < 600 and Q1CD < Game.Timer() and (W1CD < Game.Timer() or E1CD < Game.Timer() or Wbuff) and not self:CanUse(_Q, Mode(), Weapon) and myHero.mana > 80 then
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
                PrintChat("Got QETarget")
        	end
        end
    end
    if QETarget and  Weapon == "Gun" and IsReady(_Q) and IsReady(_E) and ValidTarget(QETarget, 1470) and self.Menu.AimQE:Value() then
    	self:UseQ2Man(QETarget)
    elseif IsReady(_Q) and IsReady(_E) then
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
	    		local Espot = Vector(myHero.pos):Extended(InsecTarget.pos, TargetDist-150)
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
