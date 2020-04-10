

require "PremiumPrediction"
require "DamageLib"
local EnemyHeroes = {}

-- [ AutoUpdate ] --
do
    
    local Version = 1.10
    
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
        end
    
    end
    
    AutoUpdate()

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
			--PrintChat(Hero.name)
		end
	end
	PrintChat("Got Enemy Heroes")
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
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS] then
			return "Harass"
		elseif _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_LANECLEAR] then
			return "LaneClear"
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
    if (unit and unit.valid and unit.isTargetable and unit.alive and unit.visible and unit.networkID and unit.pathing and unit.health > 0) and GetDistance(unit.pos) <= range then
        return true;
    end
    return false;
end
class "Manager"

function Manager:__init()
	if myHero.charName == "Aphelios" then
		DelayAction(function() self:LoadAphelios() end, 1.05)
	elseif myHero.charName == "Lucian" then
		DelayAction(function() self:LoadLucian() end, 1.05)
		elseif myHero.charName == "Pyke" then
		DelayAction(function() self:LoadPyke() end, 1.05)
	end
end

function Manager:LoadLucian()
	Lucian:Spells()
	Lucian:Menu()
	--
	--GetEnemyHeroes()
	Callback.Add("Tick", function() Lucian:Tick() end)
	Callback.Add("Draw", function() Lucian:Draw() end)
	if _G.SDK then
		_G.SDK.Orbwalker:OnPreAttack(function(...) Lucian:OnPreAttack(...) end)
		_G.SDK.Orbwalker:OnPostAttackTick(function(...) Lucian:OnPostAttackTick(...) end)
	end
end

function Manager:LoadPyke()
	Pyke:Spells()
	Pyke:Menu()
	--
	--GetEnemyHeroes()
	Callback.Add("Tick", function() Pyke:Tick() end)
	Callback.Add("Draw", function() Pyke:Draw() end)
end

function Manager:LoadAphelios()
	Aphelios:Spells()
	Aphelios:Menu()
	--
	--GetEnemyHeroes()
	Callback.Add("Tick", function() Aphelios:Tick() end)
	Callback.Add("Draw", function() Aphelios:Draw() end)
	if _G.SDK then
		_G.SDK.Orbwalker:OnPreAttack(function(...) Aphelios:OnPreAttack(...) end)
		_G.SDK.Orbwalker:OnPostAttackTick(function(...) Aphelios:OnPostAttackTick(...) end)
	end
end


class "Lucian"

local HeroIcon = "https://www.mobafire.com/images/avatars/yasuo-classic.png"
local IgniteIcon = "http://pm1.narvii.com/5792/0ce6cda7883a814a1a1e93efa05184543982a1e4_hq.jpg"
local QIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/e/e5/Steel_Tempest.png"
local Q3Icon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/4/4b/Steel_Tempest_3.png"
local WIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/6/61/Wind_Wall.png"
local EIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/f/f8/Sweeping_Blade.png"
local RIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/c/c6/Last_Breath.png"
local IS = {}
local EnemyLoaded = false
local QCastTime = Game:Timer()
local RCastTime = Game:Timer()
local Casted = 0
local WasInRange = false
local DoubleShot = false
local Direction = myHero.pos

function Lucian:Menu()
	self.Menu = MenuElement({type = MENU, id = "Lucian", name = "Lucian"})
	self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
	self.Menu.ComboMode:MenuElement({id = "UseQ", name = "Use Q in Combo", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseW", name = "Use W in Combo", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseE", name = "Use smart E in Combo", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseR", name = "Use R in Combo", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseQMinion", name = "Calc Q on Minions (May Drop FPS)", value = false})
	self.Menu.ComboMode:MenuElement({id = "UseRMagnet", name = "Magnet when R is active", value = false})
	self.Menu.ComboMode:MenuElement({id = "rMagnetMouseRange", name = "Magnet Mouse Range", value = 700, min = 100, max = 1200, step = 100})
	self.Menu.ComboMode:MenuElement({id = "rMagnetHeroRange", name = "Magnet Hero Range", value = 500, min = 100, max = 1200, step = 100})
	self.Menu.ComboMode:MenuElement({id = "rMagnetSmooth", name = "Smooth Magnet Mode", value = false})
	self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
	self.Menu.HarassMode:MenuElement({id = "UseQ", name = "Use Q in Harass", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseW", name = "Use W in Harass", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseE", name = "Use smart E in Harass", value = false})
	self.Menu:MenuElement({id = "Draw", name = "Draw", type = MENU})
	self.Menu.Draw:MenuElement({id = "UseDraws", name = "Enable Draws", value = false})
end

function Lucian:Spells()
	WSpellData = {speed = 1600, range = 900, delay = 0.25, radius = 40, collision = {}, type = "linear"}
	RSpellData = {speed = 2800, range = 1200, delay = 0, radius = 110, collision = {}, type = "linear"}
end

function Lucian:__init()
	DelayAction(function() self:LoadScript() end, 1.05)
end

function Lucian:LoadScript()
	self:Spells()
	self:Menu()
	--
	--GetEnemyHeroes()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	if _G.SDK then
		_G.SDK.Orbwalker:OnPreAttack(function(...) self:OnPreAttack(...) end)
		_G.SDK.Orbwalker:OnPostAttackTick(function(...) self:OnPostAttackTick(...) end)
	end
end


function Lucian:Tick()
	if _G.JustEvade and _G.JustEvade:Evading() or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or Game.IsChatOpen() or myHero.dead then return end
	target = GetTarget(1400)
	local hasPassive = _G.SDK.BuffManager:HasBuff(myHero, "LucianPassiveBuff")
	if hasPassive then
		DoubleShot = true
		Casted = 0
	else
		DoubleShot = false
	end	
	self:KS()
	self:Logic()
	if myHero:GetSpellData(_R).toggleState == 1 or not target then
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

function Lucian:Draw()
	if self.Menu.Draw.UseDraws:Value() then
	Draw.Circle(myHero.pos, 55, 1, Draw.Color(255, 0, 191, 255))
	if target then
		--PrintChat("drawing R spot")
		if myHero:GetSpellData(_R).toggleState == 1 then
			Direction = Vector((target.pos-myHero.pos):Normalized())
		end
		lhs = Vector(mousePos-myHero.pos)
		dotp = lhs:DotProduct(Direction)
		clicker = -GetDistance(target.pos)+100
		if dotp < 0 then
			clicker = -GetDistance(target.pos)-100
		end
		Location = target.pos + Direction * clicker
		--PrintChat(dotp)
		--Draw.Circle(Location, 55, 1, Draw.Color(255, 0, 191, 255))
	end
	end
end

function Lucian:KS()
	for i, enemy in pairs(EnemyHeroes) do
		if enemy and not enemy.dead and ValidTarget(enemy, 900) then
			if self:CanUse(_Q, Mode()) and GetDistance(enemy.pos, myHero.pos) > 500 and GetDistance(enemy.pos, myHero.pos) < 900 and self.Menu.ComboMode.UseQMinion:Value() then
				self:GetQMinion(enemy)
			end
		end
	end
end	

function Lucian:CanUse(spell, mode)
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
	elseif spell == _R then
		if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseR:Value() then
			return true
		end
	end
	return false
end

function Lucian:Logic()
	if target == nil then return end
	if Mode() == "Combo" or Mode() == "Harass" and target then
		if GetDistance(target.pos) < 500 then
			WasInRange = true
		end
		if self:CanUse(_Q, Mode()) and ValidTarget(target, 495) and not DoubleShot then
			if _G.SDK.Orbwalker:CanAttack() then
					DelayAction(function() _G.SDK.Orbwalker:__OnAutoAttackReset() end, 0.75)
			end
			Control.CastSpell(HK_Q, target)
			Casted = 1
		end
		if self:CanUse(_Q, Mode()) and GetDistance(target.pos, myHero.pos) > 500 and GetDistance(target.pos, myHero.pos) < 900 and self.Menu.ComboMode.UseQMinion:Value() then
			self:GetQMinion(target)
		end
		if self:CanUse(_E, Mode()) and myHero:GetSpellData(_R).toggleState == 1 then
			if GetDistance(target.pos) > 520 then
				if WasInRange == true and GetDistance(target.pos) < 1050 then
					if GetDistance(mousePos, target.pos) < 500 then
						Control.CastSpell(HK_E, mousePos)
						if _G.PremiumOrbwalker then
							DelayAction(function() _G.PremiumOrbwalker:ResetAutoAttack() end, 0.05)
						elseif _G.SDK then
							DelayAction(function() _G.SDK.Orbwalker:__OnAutoAttackReset() end, 0.05)
						end
					end
				end 
			else
				if myHero.attackData.state == STATE_WINDDOWN and not DoubleShot and not self:CanUse(_W, Mode()) and not self:CanUse(_Q, Mode()) then
					local CloseMouse = mousePos 
					CloseMouse = myHero.pos:Extended(mousePos, 100)
					Control.CastSpell(HK_E, CloseMouse)
					DoubleShot = true
					if _G.PremiumOrbwalker then
						DelayAction(function() _G.PremiumOrbwalker:ResetAutoAttack() end, 0.05)
					elseif _G.SDK then
						DelayAction(function() _G.SDK.Orbwalker:__OnAutoAttackReset() end, 0.05)
					end
				end
			end
		end
		if myHero.activeSpell.name == "LucianQ" then
			--PrintChat(myHero.activeSpell.name)
		elseif self:CanUse(_W, Mode()) and ValidTarget(target, 890) and not DoubleShot and Casted == 0 then
			self:UseW(target)
			_G.SDK.Orbwalker:SetMovement(true)
		end
		--PrintChat(self:GetRDmg(target))
		--PrintChat(target.health)
		if myHero:GetSpellData(_R).toggleState == 2 and target and self.Menu.ComboMode.UseRMagnet:Value() and Mode() == "Combo" then
			--PrintChat("Walking")
			_G.SDK.Orbwalker:SetMovement(false)
			lhs = Vector(mousePos-myHero.pos)
			dotp = lhs:DotProduct(Direction)
			clicker = -GetDistance(target.pos)+100
			if dotp < 0 then
				clicker = -GetDistance(target.pos)-100
			end
			Location = target.pos + Direction * clicker
			if GetDistance(myHero.pos, Location) < self.Menu.ComboMode.rMagnetHeroRange:Value() and GetDistance(mousePos, myHero.pos) < self.Menu.ComboMode.rMagnetMouseRange:Value() then
				Control.Move(Location)
			else
				_G.SDK.Orbwalker:SetMovement(true)
			end
		else
			_G.SDK.Orbwalker:SetMovement(true)
			Direction = Vector((target.pos-myHero.pos):Normalized())
		end
		if self:CanUse(_R, Mode()) and ValidTarget(target, 1200) and myHero:GetSpellData(_R).toggleState == 1 and target.health < self:GetRDmg(target)*0.8 and GetDistance(target.pos) > 650 then
			self:UseR(target)
		end
	else
		WasInRange = false
    end		
end

function Lucian:GetQMinion(unit)
	local minions = _G.SDK.ObjectManager:GetEnemyMinions(500)
 	for i = 1, #minions do
        local minion = minions[i]
    	--PrintChat(minion.team)
		if minion.team == 300 - myHero.team and IsValid(minion) then
			--PrintChat("minion")
			if GetDistance(minion.pos, myHero.pos) < 500 then
				if GetDistance(unit.pos, minion.pos) < GetDistance(unit.pos, myHero.pos) then
					CastDirection = Vector((minion.pos-myHero.pos):Normalized())
					enemydist = GetDistance(unit.pos, myHero.pos)
					EnemySpot = myHero.pos:Extended(minion.pos, enemydist)
					Location = EnemySpot
					--Draw.Circle(Location, 55, 1, Draw.Color(255, 0, 191, 255))
					if GetDistance(Location, unit.pos) < 50 then
						Control.CastSpell(HK_Q, minion)
					end
				end
			end
		end
	end
end

function Lucian:GetRDmg(unit, hits)
	local level = myHero:GetSpellData(_R).level
	local RDmg = getdmg("R", unit, myHero, myHero:GetSpellData(_R).level)
	if hits then
		return RDmg * hits
	else
		return  RDmg * (15 + 5*level)
	end
end


function Lucian:OnPreAttack(args)
end

function Lucian:OnPostAttackTick(args)
					Casted = 0
					--PrintChat("Casted 0")
end

function Lucian:UseW(unit)
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, WSpellData)
		if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and myHero.pos:DistanceTo(pred.CastPos) < 900 then
		    	Control.CastSpell(HK_W, pred.CastPos)
		    	Casted = 1
		end 
end

function Lucian:UseR(unit)
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, RSpellData)
		if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and myHero.pos:DistanceTo(pred.CastPos) < 1200  then
		    	Control.CastSpell(HK_R, pred.CastPos)
		end 
end

class "Aphelios"

local EnemyLoaded = false
local MainHand = "None"
local OffHand = "None"
local FlameQR = Game:Timer()
local SniperQR = Game:Timer()
local SlowQR = Game:Timer()
local BounceQR = Game:Timer()
local HealQR = Game:Timer()
local MainAtTime = MainHand
local CanRoot = false
local CanRange = false

function Aphelios:Menu()
	self.Menu = MenuElement({type = MENU, id = "Aphelios", name = "Aphelios"})
	self.Menu:MenuElement({id = "ComboMode", name = "Combo", type = MENU})
	self.Menu.ComboMode:MenuElement({id = "UseQ", name = "Use Q's in Combo", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseW", name = "Switch Weapons", value = true})
	self.Menu.ComboMode:MenuElement({id = "UseQPassive", name = "Range Attack Calibrum Marked Targets", value = true})
	self.Menu:MenuElement({id = "HarassMode", name = "Harass", type = MENU})
	self.Menu.HarassMode:MenuElement({id = "UseQ", name = "Use Q's in Harass", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseW", name = "Switch Weapons", value = true})
	self.Menu.HarassMode:MenuElement({id = "UseQPassive", name = "Range Attack Calibrum Marked Targets", value = true})
	self.Menu:MenuElement({id = "KSMode", name = "Kill Steal", type = MENU})
	self.Menu.KSMode:MenuElement({id = "UseQFlame", name = "Use Infernum Q to KS", value = true})
	self.Menu.KSMode:MenuElement({id = "UseQSniper", name = "Use Calibrum Q to KS", value = true})
	self.Menu.KSMode:MenuElement({id = "UseQPassive", name = "Killsteal Calibrum Marked Targets", value = true})
	self.Menu.KSMode:MenuElement({id = "UseW", name = "Switch Weapons to KS", value = true})
	self.Menu.KSMode:MenuElement({id = "UseR", name = "Use R to KS", value = true})
	self.Menu:MenuElement({id = "Draw", name = "Draw", type = MENU})
	self.Menu.Draw:MenuElement({id = "UseDraws", name = "Enable Draws", value = true})
end


function Aphelios:Spells()
	QSniperSpell = {speed = 1850, range = 1450, delay = 0.25, radius = 60, collision = {"minion"}, type = "linear"}
	QFlameSpell = {speed = 1850, range = 850, delay = 0.25, radius = 100, collision = {}, type = "linear"}
	RAllSpell = {speed = 1000, range = 1300, delay = 0.25, radius = 110, collision = {}, type = "linear"}
end

function Aphelios:__init()
	DelayAction(function() self:LoadScript() end, 1.05)
end


function Aphelios:LoadScript()
	self:Spells()
	self:Menu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	if _G.SDK then
		_G.SDK.Orbwalker:OnPreAttack(function(...) self:OnPreAttack(...) end)
		_G.SDK.Orbwalker:OnPostAttackTick(function(...) self:OnPostAttackTick(...) end)
	end
end

function Aphelios:Tick()
	if _G.JustEvade and _G.JustEvade:Evading() or (_G.ExtLibEvade and _G.ExtLibEvade.Evading) or Game.IsChatOpen() or myHero.dead then return end
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
	target = GetTarget(3000)
	if _G.SDK.BuffManager:HasBuff(myHero, "ApheliosSeverumQ") then
		SetAttack(false)
	else
		SetAttack(true)
	end
	OffHand = self:GetOffHand()
	MainHand = self:GetGun()
	self:GetTargetBuffs()
	self:KS()
	self:Combo()
end

function Aphelios:Draw()
	if self.Menu.Draw.UseDraws:Value() then
		Draw.Circle(myHero.pos, 225, 1, Draw.Color(255, 0, 191, 255))
		local endtime = Game.Timer()
		if myHero.activeSpell.valid then
			local attacktargetpos = myHero.activeSpell.placementPos
			local vectargetpos = Vector(attacktargetpos.x,attacktargetpos.y,attacktargetpos.z);
			Draw.Circle(vectargetpos, 225, 1, Draw.Color(255, 0, 191, 255))
		end
		Draw.Text(MainHand, 25, 770, 900, Draw.Color(0xFF32CD32))
		Draw.Text(OffHand, 25, 870, 900, Draw.Color(0xFF0000FF))
	end
	return 0
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

function SetAttack(bool)
	if _G.PremiumOrbwalker then
		_G.PremiumOrbwalker:SetAttack(bool)	
	elseif _G.SDK then
		_G.SDK.Orbwalker:SetAttack(bool)
	end
end

function EnableMovement()
	SetMovement(true)
end


function Aphelios:OnPreAttack(args)
	--("Attackedpre")
	Attacked = 0
end

function Aphelios:OnPostAttack()
	if Attacked == 0 then
		Attacked = 1
		Casted = 0
		--PrintChat("Attacked")
	end
	if target then
	end
end


function Aphelios:OnPostAttackTick(args)
	if Attacked == 0 then
		Attacked = 1
		Casted = 0
		--PrintChat("Attacked")
	end
	if target then
	end
end

function Aphelios:KS()
	local Qstage = 1
	local Rstage = 1
	local QspellType = QSniperSpell
	if MainHand == "Flame" then
		QspellType= QFlameSpell
		Qstage = 4
		Rstage = 2
	end
	for i, enemy in pairs(EnemyHeroes) do
		if enemy and not enemy.dead and ValidTarget(enemy, 1100) then
			if _G.SDK.BuffManager:HasBuff(target, "aphelioscalibrumbonusrangedebuff") and GetDistance(enemy.pos) > 650 then
				local AADmg = getdmg("AA", enemy, myHero)
				if _G.SDK.Orbwalker:CanAttack() and self.Menu.KSMode.UseQPassive:Value() and enemy.health < AADmg then
					Control.Attack(enemy)
				elseif _G.SDK.Orbwalker:CanAttack() and Mode() == "Combo" and self.Menu.ComboMode.UseQPassive:Value() and not ValidTarget(target, 650) then
					Control.Attack(enemy)
				elseif _G.SDK.Orbwalker:CanAttack() and Mode() == "Harass" and self.Menu.HarassMode.UseQPassive:Value() and not ValidTarget(target, 650) then
					Control.Attack(enemy)
				end
			end
			if self:CanUse(_Q, "KS") then
				local QDmg = getdmg("Q", enemy, myHero, Qstage, myHero:GetSpellData(_Q).level)
				if enemy.health < QDmg then
					local pred = _G.PremiumPrediction:GetPrediction(myHero, enemy, QspellType)
					if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) then
		    			Control.CastSpell(HK_Q, pred.CastPos)
					end 
				end
			end
			if self:CanUse(_R, "KS") and GetDistance(enemy.pos) > 650  then
				local RDmg = getdmg("R", enemy, myHero, Rstage, myHero:GetSpellData(_R).level)
				local AADmg = getdmg("AA", enemy, myHero)
				if enemy.health < RDmg + AADmg*0.8 then
					self:UseRAll(enemy)
				end
			end
		end
	end
end

function Aphelios:GetOffHand()
	if _G.SDK.BuffManager:HasBuff(myHero, "ApheliosOffHandBuffCalibrum") then
		return "Sniper" 
	elseif _G.SDK.BuffManager:HasBuff(myHero, "ApheliosOffHandBuffGravitum") then
		return "Slow" 
	elseif _G.SDK.BuffManager:HasBuff(myHero,  "ApheliosOffHandBuffSeverum") then
		return "Heal" 
	elseif _G.SDK.BuffManager:HasBuff(myHero, "ApheliosOffHandBuffCrescendum") then
		return "Bounce" 
	elseif _G.SDK.BuffManager:HasBuff(myHero,  "ApheliosOffHandBuffInfernum") then
		return "Flame" 
	end
end

function Aphelios:GetGun()
	if myHero:GetSpellData(_Q).name == "ApheliosCalibrumQ" then
		return "Sniper" 
	end
	if myHero:GetSpellData(_Q).name == "ApheliosGravitumQ" then
		return "Slow" 
	end
	if myHero:GetSpellData(_Q).name == "ApheliosSeverumQ" then
		return "Heal" 
	end
	if myHero:GetSpellData(_Q).name == "ApheliosCrescendumQ" then
		return "Bounce" 
	end
	if myHero:GetSpellData(_Q).name == "ApheliosInfernumQ" then
		return "Flame" 
	end
end

function Aphelios:UseQSniper(unit)
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QSniperSpell)
		if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) then
		    	Control.CastSpell(HK_Q, pred.CastPos)
		    	--DelayAction(RightClick,1.5,{target, mousePos})
		end 
end


function Aphelios:UseRAll(unit)
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, RAllSpell)
		if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) then
		    	if GetDistance(pred.CastPos) <= 1300 then
		    		Control.CastSpell(HK_R, pred.CastPos)
		    	end
		end 
end

function Aphelios:UseQFlame(unit)
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, QFlameSpell)
		if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) then
		    	Control.CastSpell(HK_Q, pred.CastPos)
		end 
end

function AmmoCheck(ammo)
	if myHero.hudAmmo > ammo or myHero.hudAmmo == 1 then
		return true
	else
		return false 
	end
end

function Aphelios:GetTargetBuffs()
	if target then
		CanRoot = _G.SDK.BuffManager:HasBuff(target, "ApheliosGravitumDebuff")
		CanRange = _G.SDK.BuffManager:HasBuff(target, "aphelioscalibrumbonusrangedebuff")
	end
end

function Aphelios:CanUse(spell, mode)
	if spell == _Q then
		if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseQ:Value() then
			return true
		elseif mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseQ:Value() then
			return true
		elseif mode == "KS" and IsReady(spell) and MainHand == "Flame" and self.Menu.KSMode.UseQFlame:Value() then
			return true
		elseif mode == "KS" and IsReady(spell) and MainHand == "Sniper" and self.Menu.KSMode.UseQSniper:Value() then
			return true
		end
	elseif spell == _W then
		if mode == "Combo" and IsReady(spell) and self.Menu.ComboMode.UseW:Value() then
			return true
		elseif mode == "Harass" and IsReady(spell) and self.Menu.HarassMode.UseW:Value() then
			return true
		elseif mode == "KS" and IsReady(spell) and self.Menu.KSMode.UseW:Value() then
			return true
		end
	elseif spell == _R then
		if mode == "KS" and IsReady(spell) and self.Menu.KSMode.UseR:Value() then
			return true
		end
	end
	return false
end

function Aphelios:Combo()
	if target == nil then return end
	if Mode() == "Combo" or Mode() == "Harass" and target then
--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ SNIPER SNIPER SNIPER SNIPER @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			if MainHand == "Sniper" then
				if not IsReady(_Q) then
					SniperQR = Game:Timer() + myHero:GetSpellData(0).currentCd
				end
				if OffHand == "Slow" then
					if self:CanUse(_Q, Mode()) and ValidTarget(target, 1450) then
						self:UseQSniper(target)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if not self:CanUse(_Q, Mode()) and GetDistance(target.pos) <= 500 then
							Control.CastSpell(HK_W)
						end
						if SlowQR < Game:Timer() and CanRoot and myHero.mana > 60 then
							Control.CastSpell(HK_W)
						end 
					end
					if IsReady(_R) then

					end
					-- if target has Q buff, switch to W
				end
				if OffHand == "Flame" then
					if self:CanUse(_Q, Mode()) and ValidTarget(target, 1450) then
						self:UseQSniper(target)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						--PrintChat("W REady")
						if GetDistance(target.pos) <= 500 then
							Control.CastSpell(HK_W)
						end 
						if FlameQR < Game:Timer() and GetDistance(target.pos) <= 650  and myHero.mana > 60 then
							Control.CastSpell(HK_W)
						end 
					end
					if IsReady(_R) then

					end
				end
				if OffHand == "Bounce" then
					if self:CanUse(_Q, Mode()) and ValidTarget(target, 1450) then
						self:UseQSniper(target)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if GetDistance(target.pos) < 350 then
							Control.CastSpell(HK_W)
						end
						if BounceQR < Game:Timer() and GetDistance(target.pos) <= 475 and myHero.mana > 60 then
							Control.CastSpell(HK_W)
						end  
					end
					if IsReady(_R) then

					end
				end
				if OffHand == "Heal" then
					if self:CanUse(_Q, Mode()) and ValidTarget(target, 1450) then
						self:UseQSniper(target)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if GetDistance(target.pos) <= 300 or myHero.health < myHero.maxHealth*0.3 then
							Control.CastSpell(HK_W)
						end
						if HealQR < Game:Timer() and GetDistance(target.pos) <= 550 and myHero.mana > 60 and myHero.levelData.lvl > 1 then
							Control.CastSpell(HK_W)
						end  
					end
					if IsReady(_R) then
					end
				end
			end

--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ SLOW SLOW SLOW SLOW @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


			if MainHand == "Slow" then
				if not IsReady(_Q) then
					SlowQR = Game:Timer() + myHero:GetSpellData(0).currentCd
				end
				if OffHand == "Sniper" then
					if self:CanUse(_Q, Mode()) and CanRoot then -- and target has Q buff 
						Control.CastSpell(HK_Q)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if GetDistance(target.pos) > 550 then
							Control.CastSpell(HK_W)
						end 
					end
					if IsReady(_R) then
					end
				end
				if OffHand == "Flame" then
					if self:CanUse(_Q, Mode()) and CanRoot then
						Control.CastSpell(HK_Q)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if FlameQR < Game:Timer() and myHero.mana > 60 and GetDistance(target.pos) <= 650 then
							Control.CastSpell(HK_W)
						end  
					end
					if IsReady(_R) then

					end
				end
				if OffHand == "Bounce" then
					if self:CanUse(_Q, Mode()) and CanRoot then
						Control.CastSpell(HK_Q)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if not self:CanUse(_Q, Mode()) and GetDistance(target.pos) < 350 then
							Control.CastSpell(HK_W)
						end 
						if BounceQR < Game:Timer() and myHero.mana > 60 and GetDistance(target.pos) <= 400 and not self:CanUse(_Q, Mode()) then
							Control.CastSpell(HK_W)
						end 
					end
					if IsReady(_R) then

					end
				end
				if OffHand == "Heal" then
					if self:CanUse(_Q, Mode()) and CanRoot then
						Control.CastSpell(HK_Q)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if not self:CanUse(_Q, Mode()) and myHero.health < myHero.maxHealth/2 then
							Control.CastSpell(HK_W)
						end
						if HealQR < Game:Timer() and myHero.mana > 60 and GetDistance(target.pos) <= 650 and not self:CanUse(_Q, Mode()) then
							Control.CastSpell(HK_W)
						end 
					end
					if IsReady(_R) then
					end
				end
			end


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ FLAME FLAME FLAME FLAME @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


			if MainHand == "Flame" then
				if not IsReady(_Q) then
					FlameQR = Game:Timer() + myHero:GetSpellData(0).currentCd
				end
				if OffHand == "Slow" then
					if self:CanUse(_Q, Mode()) and ValidTarget(target, 850) then
						self:UseQFlame(target)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if not self:CanUse(_Q, Mode()) and GetDistance(target.pos) > 350 then
							Control.CastSpell(HK_W)
						end
						if SlowQR < Game:Timer() and myHero.mana > 60 and GetDistance(target.pos) <= 650 then
							Control.CastSpell(HK_W)
						end 
					end
					if IsReady(_R) then
					end
				end
				if OffHand == "Sniper" then
					if self:CanUse(_Q, Mode()) and ValidTarget(target, 850) then
						self:UseQFlame(target)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if GetDistance(target.pos) > 550 then
							Control.CastSpell(HK_W)
						end 
					end
					if IsReady(_R) then
					end
				end
				if OffHand == "Bounce" then
					if self:CanUse(_Q, Mode()) and ValidTarget(target, 850) then
						self:UseQFlame(target)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if not self:CanUse(_Q, Mode()) and GetDistance(target.pos) < 550 then
							Control.CastSpell(HK_W)
						end
						if BounceQR < Game:Timer() and myHero.mana > 60 and GetDistance(target.pos) <= 400 then
							Control.CastSpell(HK_W)
						end  
					end
					if IsReady(_R) then
					end
				end
				if OffHand == "Heal" then
					if self:CanUse(_Q, Mode()) and ValidTarget(target, 850) then
						self:UseQFlame(target)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if HealQR < Game:Timer() and myHero.mana > 60 and GetDistance(target.pos) <= 650 then
							Control.CastSpell(HK_W)
						end  
					end
					if IsReady(_R) then
					end
				end
			end


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ BOUNCE BOUNCE BOUNCE BOUNCE @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
			--function Orbwalker:__OnAutoAttackReset()
    		--	Attack.Reset = true
			--end

			if MainHand == "Bounce" then
				if not IsReady(_Q) then
					BounceQR = Game:Timer() + myHero:GetSpellData(0).currentCd
				end
				if OffHand == "Slow" then
					if self:CanUse(_Q, Mode()) and ValidTarget(target, 475) then
						Control.CastSpell(HK_Q, target)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if self:CanUse(_Q, Mode()) then
							if GetDistance(target.pos) > 475 then
								Control.CastSpell(HK_W)
							end
						else
							if GetDistance(target.pos) > 400 then
								Control.CastSpell(HK_W)
							end
						end
						if SlowQR < Game:Timer() and myHero.mana > 60 and CanRoot then
							Control.CastSpell(HK_W)
						end 
					end
					if IsReady(_R) then
					end
				end
				if OffHand == "Flame" then
					if self:CanUse(_Q, Mode()) and ValidTarget(target, 475) then
						Control.CastSpell(HK_Q, target)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if FlameQR < Game:Timer() and myHero.mana > 60 and GetDistance(target.pos) <= 650 then
							Control.CastSpell(HK_W)
						end  
					end
					if IsReady(_R) then

					end
				end
				if OffHand == "Sniper" then
					if self:CanUse(_Q, Mode()) and ValidTarget(target, 475) then
						Control.CastSpell(HK_Q, target)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if self:CanUse(_Q, Mode()) then
							if GetDistance(target.pos) > 475 then
								Control.CastSpell(HK_W)
							end
						else
							if GetDistance(target.pos) > 350 then
								Control.CastSpell(HK_W)
							end
						end 
					end
					if IsReady(_R) then
					end
				end
				if OffHand == "Heal" then
					if self:CanUse(_Q, Mode()) and ValidTarget(target, 475) then
						Control.CastSpell(HK_Q, target)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if HealQR < Game:Timer() and myHero.mana > 60 and GetDistance(target.pos) <= 650 then
							Control.CastSpell(HK_W)
						end  
					end
					if IsReady(_R) then
					end
				end
			end


--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ HEAL HEAL HEAL HEAL @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


			if MainHand == "Heal" then
				if not IsReady(_Q) then
					HealQR = Game:Timer() + myHero:GetSpellData(0).currentCd
				end	
				--PrintChat("Heal")
				if OffHand == "Slow" then
					if self:CanUse(_Q, Mode()) and ValidTarget(target, 620) then
						Control.CastSpell(HK_Q)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if not self:CanUse(_Q, Mode()) and myHero.health > myHero.maxHealth*0.7 then
							Control.CastSpell(HK_W)
						end
						if SlowQR < Game:Timer() and myHero.mana > 60 and GetDistance(target.pos) <= 650 then
							Control.CastSpell(HK_W)
						end  
					end
					if IsReady(_R) then

					end
				end
				if OffHand == "Flame" then
					if self:CanUse(_Q, Mode()) and ValidTarget(target, 620) then
						Control.CastSpell(HK_Q)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if not self:CanUse(_Q, Mode()) and GetDistance(target.pos) < 550 and myHero.health > myHero.maxHealth*0.2 then
							Control.CastSpell(HK_W)
						end 
						if FlameQR < Game:Timer() and myHero.mana > 60 and GetDistance(target.pos) <= 650 then
							Control.CastSpell(HK_W)
						end  
					end
					if IsReady(_R) then

					end
				end
				if OffHand == "Bounce" then
					if self:CanUse(_Q, Mode()) and ValidTarget(target, 620) then
						Control.CastSpell(HK_Q)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if not self:CanUse(_Q, Mode()) and GetDistance(target.pos) < 550 and myHero.health > myHero.maxHealth*0.2 then
							Control.CastSpell(HK_W)
						end 
					end
					if IsReady(_R) then

					end
				end
				if OffHand == "Sniper" then
					if self:CanUse(_Q, Mode()) and ValidTarget(target, 620) then
						Control.CastSpell(HK_Q)
					end
					if IsReady(_E) then

					end
					if self:CanUse(_W, Mode()) then
						if GetDistance(target.pos) > 550 and myHero.health > myHero.maxHealth*0.3 then
							Control.CastSpell(HK_W)
						end 
					end
					if IsReady(_R) then

					end
				end
			end
	end
end

function Aphelios:Harass()
	if target == nil then return end
	if Mode() == "Harass" then
			
	end
end

class "Pyke"

local HeroIcon = "https://www.mobafire.com/images/avatars/yasuo-classic.png"
local IgniteIcon = "http://pm1.narvii.com/5792/0ce6cda7883a814a1a1e93efa05184543982a1e4_hq.jpg"
local QIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/e/e5/Steel_Tempest.png"
local Q3Icon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/4/4b/Steel_Tempest_3.png"
local WIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/6/61/Wind_Wall.png"
local EIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/f/f8/Sweeping_Blade.png"
local RIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/c/c6/Last_Breath.png"
local ETravel = true
local StunCharge = false
local IS = {}
local QDown = false
local EnemyLoaded = false
local QCastTime = Game:Timer()
local RCastTime = Game:Timer()

function Pyke:Menu()
	self.Menu = MenuElement({type = MENU, id = "Pyke", name = "Pyke"})
	self.Menu:MenuElement({id = "ComboKS", name = "Only KS in combo mode?", value = false})

end

function Pyke:Spells()
	PykeW = {range = 400}
	PykeE = {range = 1000, width = 80, speed = 1500, delay = 0.01,collision = true, aoe = false, type = "line"}
	self.e = {Type = _G.SPELLTYPE_LINE, Range = 1000, Radius = 40, Speed = 1500, Collision = true, MaxCollision = 1, CollisionTypes = {0, 2, 3}}
	spellData = {speed = 1500, range = 1000, delay = 0.51, radius = 75, collision = {"minion"}, type = "linear"}
	spellDataQ = {speed = 1700, range = 1100, delay = 0.25, radius = 55, collision = {"minion"}, type = "linear"}
	spellDataQ2 = {speed = 2700, range = 1100, delay = 0.10, radius = 25, collision = {"minion"}, type = "linear"}
	spellDataQ3 = {speed = 1700, range = 400, delay = 0.25, radius = 55, collision = {""}, type = "linear"}
	spellDataW = {speed = 2000, range = 1000, delay = 0.51, radius = 325, collision = {""}, type = "linear"}
	spellDataE = {speed = 1000, range = 550, delay = 0.25, radius = 100, collision = {""}, type = "linear"}
	spellDataE2 = {speed = 1000, range = 550, delay = 1.25, radius = 100, collision = {""}, type = "linear"}
	spellDataR = {speed = 3000, range = 750, delay = 0.75, radius = 250, collision = {""}, type = "circular"}
end

function Pyke:__init()
	DelayAction(function() self:LoadScript() end, 1.05)
end

function Pyke:LoadScript()
	self:Spells()
	self:Menu()
	--
	GetEnemyHeroes()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
end


function Pyke:Tick()
	if myHero.dead or Game.IsChatOpen() == true then return end
	target = GetTarget(1400)	
	self:KS()
	self:Combo()
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

function Pyke:Draw()
	if QDown == true then
				local CastedTime = Game:Timer() - QCastTime
				local DistanceCastTime = CastedTime-0.5
				local Qdistance = 400
				if DistanceCastTime > 0 then
					Qdistance = 400 + 150* (DistanceCastTime/0.1)
				end
				if Qdistance > 1100 then
					Qdistance = 1100
				end
				Draw.Circle(myHero.pos, Qdistance, 1, Draw.Color(255, 0, 191, 255))
	end
	Draw.Circle(myHero.pos, 55, 1, Draw.Color(255, 0, 191, 255))
	--local UltDamge = self:GetUltDamage()
	--for i, enemy in pairs(EnemyHeroes) do
		--if enemy and not enemy.dead then
			--if enemy.health < UltDamge then
				--Draw.Text("R Can Kill", 37, enemy.pos2D.x-45, enemy.pos2D.y+10, Draw.Color(0xFFA80505))
			--end
		--end
	--end
end

function Pyke:GetUltDamage()
	local LvL = myHero.levelData.lvl
	if not LvL then
		LvL = 1
	end
	local LevelDamage = ({250, 250, 250, 250, 250, 250, 290, 330, 370, 400, 430, 450, 470, 490, 510, 530, 540, 550})[LvL]
	local HeroDamage = myHero.bonusDamage * 0.8
	local HeroPen = myHero.armorPen * 1.5
	local TotalDamage = LevelDamage + HeroDamage + HeroPen
	return TotalDamage
end

function Pyke:KS()
	local UltDamge = self:GetUltDamage()
	for i, enemy in pairs(EnemyHeroes) do
		if enemy and not enemy.dead and ValidTarget(enemy, 1100) then
			if Mode() == "Combo" or not self.Menu.ComboKS:Value() then
				if enemy.health < UltDamge and IsReady(_R) and Game:Timer() - RCastTime > 0.75 and ValidTarget(enemy, 750) then
					self:UseR(enemy)
				end
			end
			if Mode() == "Combo" and QDown == true then
				local CastedTime = Game:Timer() - QCastTime
				local DistanceCastTime = CastedTime-0.5
				local Qdistance = 400
				local Qspeed = 1700
				if DistanceCastTime > 0.1 then
					Qdistance = 400 + 150 * (DistanceCastTime/0.1)
				end
				if Qdistance > 1100 then
					Qdistance = 1100
				end
				spellDataQ.range = Qdistance
				--PrintChat(Qradius)
				if target.health > UltDamge or not IsReady(_R) or GetDistance(target.pos) > 750 then
					if ValidTarget(target, 1100) then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, spellDataQ)
						if Qdistance <= 400 then
							local pred = _G.PremiumPrediction:GetPrediction(myHero, target, spellDataQ3)
						end
						--PrintChat("pred Target")
						--PrintChat(pred.HitChance)
						if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and GetDistance(pred.CastPos) < Qdistance then
			    			Control.CastSpell(HK_Q, pred.CastPos)
		    				--PrintChat("Fire Target")
		    			elseif enemy and ValidTarget(enemy, 1100) then
			    			--PrintChat("pred enemy")
		    				--PrintChat(pred.HitChance)
							local pred = _G.PremiumPrediction:GetPrediction(myHero, enemy, spellDataQ)
							if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and GetDistance(pred.CastPos) < Qdistance then
				    			Control.CastSpell(HK_Q, pred.CastPos)
			    				PrintChat("Fire enemy")
							end 
						end
					elseif enemy and ValidTarget(enemy, 1100) then
						if enemy.health > UltDamge or not IsReady(_R) or GetDistance(enemy.pos) > 750 then
							local pred = _G.PremiumPrediction:GetPrediction(myHero, enemy, spellDataQ3)
							if Qdistance <= 400 then
								local pred = _G.PremiumPrediction:GetPrediction(myHero, enemy, spellDataQ3)
							end
							--PrintChat("pred enemy")
							--PrintChat(pred.HitChance)
							if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and GetDistance(pred.CastPos) < Qdistance then
				    			Control.CastSpell(HK_Q, pred.CastPos)
			    				--PrintChat("Fire enemy")
							end 
						end
					end
				end
			end
		end
	end
end	
function Pyke:Combo()
	if target == nil then return end
	if Mode() == "Combo" and target and ValidTarget(target, 2000) then
			if IsReady(_Q) then
				if GetDistance(target.pos) < 1100 then
					if QDown == false then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, spellDataQ2)
						if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and GetDistance(pred.CastPos) < 1100 then
							Control.KeyDown(HK_Q)
							QCastTime = Game:Timer()
							QDown = true
						end
						--PrintChat(QCastTime)
						--PrintChat(myHero:GetSpellData(0).castTime)
					end
				end
				if GetDistance(target.pos) < 400 then
					if QDown == false then
						local pred = _G.PremiumPrediction:GetPrediction(myHero, target, spellDataQ3)
						if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and GetDistance(pred.CastPos) < 400 then
							Control.KeyDown(HK_Q)
							QCastTime = Game:Timer()
							QDown = true
						end
						--PrintChat(QCastTime)
						--PrintChat(myHero:GetSpellData(0).castTime)
					end
				end
			else
				if QDown == true then
					Control.KeyUp(HK_Q)
					QDown = false
				end
				if IsReady(_E) then
					if GetDistance(target.pos) < 300 then
						self:UseE2(target)
					elseif GetDistance(target.pos) < 550 then
						self:UseE(target)
					end
				end
			end
	end		
end

function Pyke:UseQ(unit)
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, spellDataQ)
		if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and GetDistance(pred.CastPos) < 1100 then
		    	Control.CastSpell(HK_Q, pred.CastPos)
		end 
end

function Pyke:UseR(unit)
		local pred = _G.PremiumPrediction:GetAOEPrediction(myHero, unit, spellDataR)
		if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and GetDistance(pred.CastPos) < 750 then
		    	Control.CastSpell(HK_R, pred.CastPos)
		    	RCastTime = Game:Timer()
		end 
end

function Pyke:UseE(unit)
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, spellDataE)
		if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and GetDistance(pred.CastPos) < 550 then
		    	Control.CastSpell(HK_E, pred.CastPos)
		end 
end

function Pyke:UseE2(unit)
		local pred = _G.PremiumPrediction:GetPrediction(myHero, unit, spellDataE2)
		if pred.CastPos and _G.PremiumPrediction.HitChance.Medium(pred.HitChance) and GetDistance(pred.CastPos) < 550 then
		    	Control.CastSpell(HK_E, pred.CastPos)
		end 
end

function OnLoad()
	Manager()
end
