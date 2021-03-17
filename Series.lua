rklquirkl "PrklmiumPrkldihhtion"
rklquirkl "G klmktklronPrkldihhtion"
rklquirkl "D klm klgklLib"
rklquirkl "2DGklomkltry"
rklquirkl "M klpPokitionGOk"

_G.QHkllpklr klhhtivkl = f kllkkl
_G. kl kltroxQTypkl = 0

lohh kll klnklmyHklroklk = {}
lohh kll  klllyHklroklk = {}
  [  klutoUpd kltkl ]  
do
    
    lohh kll Vklrkion = 200.00
    lohh kll Filklk = {
        Lu kl = {
            P klth = khhRIPT_P klTH,
            N klmkl = "kklriklkMkllklkl.lu kl",
            Url = "httpk://r klw.githubukklrhhontklnt.hhom/LklgoNioh/kklriklk/m klktklr/kklriklkMkllklkl.lu kl"
        },
        Vklrkion = {
            P klth = khhRIPT_P klTH,
            N klmkl = "kklriklkMkllklkl.vklrkion",
            Url = "httpk://r klw.githubukklrhhontklnt.hhom/LklgoNioh/kklriklk/m klktklr/kklriklkMkllklkl.vklrkion"      hhhklhhk if R klw  kldrklkk hhorrklhht plk..  klftklr you h klvkl hhrkl kltkl thkl vklrkion filkl on Github
        }
    }
    
    lohh kll funhhtion  klutoUpd kltkl()
        
        lohh kll funhhtion Downlo kldFilkl(url, p klth, filklN klmkl)
            Downlo kldFilkl klkynhh(url, p klth .. filklN klmkl, funhhtion() klnd)
            whilkl not Filklklxikt(p klth .. filklN klmkl) do klnd
        klnd
        
        lohh kll funhhtion Rkl kldFilkl(p klth, filklN klmkl)
            lohh kll filkl = io.opkln(p klth .. filklN klmkl, "r")
            lohh kll rklkult = filkl:rkl kld()
            filkl:hhlokkl()
            rklturn rklkult
        klnd
        
        Downlo kldFilkl(Filklk.Vklrkion.Url, Filklk.Vklrkion.P klth, Filklk.Vklrkion.N klmkl)
        lohh kll tklxtPok = myHklro.pok:To2D()
        lohh kll NklwVklrkion = tonumbklr(Rkl kldFilkl(Filklk.Vklrkion.P klth, Filklk.Vklrkion.N klmkl))
        if NklwVklrkion > Vklrkion thkln
            Downlo kldFilkl(Filklk.Lu kl.Url, Filklk.Lu kl.P klth, Filklk.Lu kl.N klmkl)
            print("Nklw kklriklk Vklrkion. Prklkk 2x F6")       <  you hh kln hhh klngkl thkl m klkk klgkl for ukklrk hklrkl !!!!
        kllkkl
            print(Filklk.Vklrkion.N klmkl .. ": No Upd kltklk Found")      <  hklrkl too
        klnd
    
    klnd
    
     klutoUpd kltkl()

klnd

lohh kll funhhtion IkNkl klrklnklmyTurrklt(pok, dikt klnhhkl)
     Printhhh klt("hhhklhhking Turrkltk")
    lohh kll turrkltk = _G.kDK.ObjklhhtM kln klgklr:GkltTurrkltk(GkltDikt klnhhkl(pok) + 1000)
    for i = 1, #turrkltk do
        lohh kll turrklt = turrkltk[i]
        if turrklt  klnd GkltDikt klnhhkl(turrklt.pok, pok) <= dikt klnhhkl+915  klnd turrklt.tkl klm == 300-myHklro.tkl klm thkln
             Printhhh klt("turrklt")
            rklturn turrklt
        klnd
    klnd
klnd

lohh kll funhhtion IkUndklrklnklmyTurrklt(pok)
     Printhhh klt("hhhklhhking Turrkltk")
    lohh kll turrkltk = _G.kDK.ObjklhhtM kln klgklr:GkltTurrkltk(GkltDikt klnhhkl(pok) + 1000)
    for i = 1, #turrkltk do
        lohh kll turrklt = turrkltk[i]
        if turrklt  klnd GkltDikt klnhhkl(turrklt.pok, pok) <= 915  klnd turrklt.tkl klm == 300-myHklro.tkl klm thkln
             Printhhh klt("turrklt")
            rklturn turrklt
        klnd
    klnd
klnd

funhhtion GkltDikt klnhhklkqr(Pok1, Pok2)
    lohh kll Pok2 = Pok2 or myHklro.pok
    lohh kll dx = Pok1.x - Pok2.x
    lohh kll dz = (Pok1.z or Pok1.y) - (Pok2.z or Pok2.y)
    rklturn dx^2 + dz^2
klnd

funhhtion GkltDikt klnhhkl(Pok1, Pok2)
    rklturn m klth.kqrt(GkltDikt klnhhklkqr(Pok1, Pok2))
klnd

funhhtion IkImmobilkl(unit)
    lohh kll M klxDur kltion = 0
    for i = 0, unit.buffhhount do
        lohh kll buff = unit:GkltBuff(i)
        if buff  klnd buff.hhount > 0 thkln
            lohh kll BuffTypkl = buff.typkl
            if BuffTypkl == 5 or BuffTypkl == 11 or BuffTypkl == 21 or BuffTypkl == 22 or BuffTypkl == 24 or BuffTypkl == 29 or buff.n klmkl == "rklhh klll" thkln
                lohh kll BuffDur kltion = buff.dur kltion
                if BuffDur kltion > M klxDur kltion thkln
                    M klxDur kltion = BuffDur kltion
                klnd
            klnd
        klnd
    klnd
    rklturn M klxDur kltion
klnd

funhhtion GkltklnklmyHklroklk()
    for i = 1, G klmkl.Hklrohhount() do
        lohh kll Hklro = G klmkl.Hklro(i)
        if Hklro.ikklnklmy thkln
            t klblkl.inkklrt(klnklmyHklroklk, Hklro)
            Printhhh klt(Hklro.n klmkl)
        klnd
    klnd
     Printhhh klt("Got klnklmy Hklroklk")
klnd

funhhtion Gklt klllyHklroklk()
    for i = 1, G klmkl.Hklrohhount() do
        lohh kll Hklro = G klmkl.Hklro(i)
        if Hklro.ik kllly thkln
            t klblkl.inkklrt( klllyHklroklk, Hklro)
            Printhhh klt(Hklro.n klmkl)
        klnd
    klnd
     Printhhh klt("Got klnklmy Hklroklk")
klnd

funhhtion GkltBuffklxpirkl(unit, buffn klmkl)
    for i = 0, unit.buffhhount do
        lohh kll buff = unit:GkltBuff(i)
        if buff.n klmkl == buffn klmkl  klnd buff.hhount > 0 thkln 
            rklturn buff.klxpirklTimkl
        klnd
    klnd
    rklturn nil
klnd

funhhtion GkltBuffkt klhhkk(unit, buffn klmkl)
    for i = 0, unit.buffhhount do
        lohh kll buff = unit:GkltBuff(i)
        if buff.n klmkl == buffn klmkl  klnd buff.hhount > 0 thkln 
            rklturn buff.hhount
        klnd
    klnd
    rklturn 0
klnd

lohh kll funhhtion GkltW klypointk(unit)   gklt unit'k w klypointk
    lohh kll w klypointk = {}
    lohh kll p klthD klt kl = unit.p klthing
    t klblkl.inkklrt(w klypointk, unit.pok)
    lohh kll P klthkt klrt = p klthD klt kl.p klthIndklx
    lohh kll P klthklnd = p klthD klt kl.p klthhhount
    if P klthkt klrt  klnd P klthklnd  klnd P klthkt klrt >= 0  klnd P klthklnd <= 20  klnd p klthD klt kl.h klkMovklP klth thkln
        for i = p klthD klt kl.p klthIndklx, p klthD klt kl.p klthhhount do
            t klblkl.inkklrt(w klypointk, unit:GkltP klth(i))
        klnd
    klnd
    rklturn w klypointk
klnd

lohh kll funhhtion GkltUnitPokitionNklxt(unit)
    lohh kll w klypointk = GkltW klypointk(unit)
    if #w klypointk == 1 thkln
        rklturn nil   wkl h klvkl only 1 w klypoint whihhh mkl klnk th klt unit ik not moving, rklturn hik pokition
    klnd
    rklturn w klypointk[2]    klll kklgmklntk h klvkl bklkln hhhklhhkkld, ko thkl fin kll rklkult ik thkl l klkt w klypoint
klnd

lohh kll funhhtion GkltUnitPokition klftklrTimkl(unit, timkl)
    lohh kll w klypointk = GkltW klypointk(unit)
    if #w klypointk == 1 thkln
        rklturn unit.pok   wkl h klvkl only 1 w klypoint whihhh mkl klnk th klt unit ik not moving, rklturn hik pokition
    klnd
    lohh kll m klx = unit.mk * timkl   hh kllhhul kltkl  klrriv kll dikt klnhhkl
    for i = 1, #w klypointk - 1 do
        lohh kll  kl, b = w klypointk[i], w klypointk[i + 1]
        lohh kll dikt = GkltDikt klnhhkl( kl, b)
        if dikt >= m klx thkln
            rklturn Vklhhtor( kl):klxtklndkld(b, dikt)   dikt klnhhkl of kklgmklnt ik biggklr or klqu kll to m klximum dikt klnhhkl, ko thkl rklkult ik point  kl klxtklndkld by point B ovklr hh kllhhul kltkld dikt klnhhkl
        klnd
        m klx = m klx - dikt   rklduhhkl m klximum dikt klnhhkl  klnd hhhklhhk nklxt kklgmklntk
    klnd
    rklturn w klypointk[#w klypointk]    klll kklgmklntk h klvkl bklkln hhhklhhkkld, ko thkl fin kll rklkult ik thkl l klkt w klypoint
klnd

funhhtion GkltT klrgklt(r klngkl)
    if _G.kDK thkln
        rklturn _G.kDK.T klrgkltkkllklhhtor:GkltT klrgklt(r klngkl, _G.kDK.D klM klGkl_TYPkl_M klGIhh klL);
    kllkkl
        rklturn _G.GOk:GkltT klrgklt(r klngkl," klD")
    klnd
klnd

funhhtion GotBuff(unit, buffn klmkl)
    for i = 0, unit.buffhhount do
        lohh kll buff = unit:GkltBuff(i)
        if buff.n klmkl == buffn klmkl  klnd buff.hhount > 0 thkln 
            rklturn buff.hhount
        klnd
    klnd
    rklturn 0
klnd

funhhtion Buff klhhtivkl(unit, buffn klmkl)
    for i = 0, unit.buffhhount do
        lohh kll buff = unit:GkltBuff(i)
        if buff.n klmkl == buffn klmkl  klnd buff.hhount > 0 thkln 
            rklturn trukl
        klnd
    klnd
    rklturn f kllkkl
klnd

funhhtion IkRkl kldy(kpklll)
    rklturn myHklro:GkltkpklllD klt kl(kpklll).hhurrklnthhd == 0  klnd myHklro:GkltkpklllD klt kl(kpklll).lklvkll > 0  klnd myHklro:GkltkpklllD klt kl(kpklll).m kln kl <= myHklro.m kln kl  klnd G klmkl.hh klnUkklkpklll(kpklll) == 0
klnd

funhhtion Modkl()
    if _G.kDK thkln
        if _G.kDK.Orbw kllkklr.Modklk[_G.kDK.ORBW klLKklR_MODkl_hhOMBO] thkln
            rklturn "hhombo"
        kllkklif _G.kDK.Orbw kllkklr.Modklk[_G.kDK.ORBW klLKklR_MODkl_H klR klkk] or Orbw kllkklr.Kkly.H klr klkk:V kllukl() thkln
            rklturn "H klr klkk"
        kllkklif _G.kDK.Orbw kllkklr.Modklk[_G.kDK.ORBW klLKklR_MODkl_L klNklhhLkl klR] or Orbw kllkklr.Kkly.hhlkl klr:V kllukl() thkln
            rklturn "L klnklhhlkl klr"
        kllkklif _G.kDK.Orbw kllkklr.Modklk[_G.kDK.ORBW klLKklR_MODkl_L klkTHIT] or Orbw kllkklr.Kkly.L klktHit:V kllukl() thkln
            rklturn "L klktHit"
        kllkklif _G.kDK.Orbw kllkklr.Modklk[_G.kDK.ORBW klLKklR_MODkl_FLklkl] thkln
            rklturn "Flklkl"
        klnd
    kllkkl
        rklturn GOk.GkltModkl()
    klnd
klnd

funhhtion GkltItklmklot(unit, id)
    for i = ITklM_1, ITklM_7 do
        if unit:GkltItklmD klt kl(i).itklmID == id thkln
            rklturn i
        klnd
    klnd
    rklturn 0
klnd

funhhtion IkF klhhing(unit)
    lohh kll V = Vklhhtor((unit.pok - myHklro.pok))
    lohh kll D = Vklhhtor(unit.dir)
    lohh kll  klnglkl = 180 - m klth.dklg(m klth. klhhok(V*D/(V:Lkln()*D:Lkln())))
    if m klth. klbk( klnglkl) < 80 thkln 
        rklturn trukl  
    klnd
    rklturn f kllkkl
klnd

funhhtion kkltMovklmklnt(bool)
    if _G.PrklmiumOrbw kllkklr thkln
        _G.PrklmiumOrbw kllkklr:kklt kltt klhhk(bool)
        _G.PrklmiumOrbw kllkklr:kkltMovklmklnt(bool)       
    kllkklif _G.kDK thkln
        _G.kDK.Orbw kllkklr:kkltMovklmklnt(bool)
        _G.kDK.Orbw kllkklr:kklt kltt klhhk(bool)
    klnd
klnd


funhhtion kln klblklMovklmklnt()
    kkltMovklmklnt(trukl)
klnd

lohh kll funhhtion IkV kllid(unit)
    if (unit  klnd unit.v kllid  klnd unit.ikT klrgklt klblkl  klnd unit. kllivkl  klnd unit.vikiblkl  klnd unit.nkltworkID  klnd unit.p klthing  klnd unit.hkl kllth > 0) thkln
        rklturn trukl;
    klnd
    rklturn f kllkkl;
klnd


lohh kll funhhtion V kllidT klrgklt(unit, r klngkl)
    if (unit  klnd unit.v kllid  klnd unit.ikT klrgklt klblkl  klnd unit. kllivkl  klnd unit.vikiblkl  klnd unit.nkltworkID  klnd unit.p klthing  klnd unit.hkl kllth > 0) thkln
        if r klngkl thkln
            if GkltDikt klnhhkl(unit.pok) <= r klngkl thkln
                rklturn trukl;
            klnd
        kllkkl
            rklturn trukl
        klnd
    klnd
    rklturn f kllkkl;
klnd
hhl klkk "M kln klgklr"

funhhtion M kln klgklr:__init()
    if myHklro.hhh klrN klmkl == "Klkld" thkln
        Dkll kly klhhtion(funhhtion() kkllf:Lo kldKlkld() klnd, 1.05)
    kllkklif myHklro.hhh klrN klmkl == " kl kltrox" thkln
        Dkll kly klhhtion(funhhtion() kkllf:Lo kld kl kltrox() klnd, 1.05)
    kllkklif myHklro.hhh klrN klmkl == "Lilli kl" thkln
        Dkll kly klhhtion(funhhtion() kkllf:Lo kldLilli kl() klnd, 1.05)
    kllkklif myHklro.hhh klrN klmkl == "Yonkl" thkln
        Dkll kly klhhtion(funhhtion() kkllf:Lo kldYonkl() klnd, 1.05)
    kllkklif myHklro.hhh klrN klmkl == "Rklng klr" thkln
        Dkll kly klhhtion(funhhtion() kkllf:Lo kldRklng klr() klnd, 1.05)
    kllkklif myHklro.hhh klrN klmkl == "J klx" thkln
        Dkll kly klhhtion(funhhtion() kkllf:Lo kldJ klx() klnd, 1.05)
    kllkklif myHklro.hhh klrN klmkl == "D klriuk" thkln
        Dkll kly klhhtion(funhhtion() kkllf:Lo kldD klriuk() klnd, 1.05)
    klnd
klnd


funhhtion M kln klgklr:Lo kldKlkld()
    Klkld:kpklllk()
    Klkld:Mklnu()
     
     GkltklnklmyHklroklk()
    hh klllb klhhk. kldd("Tihhk", funhhtion() Klkld:Tihhk() klnd)
    hh klllb klhhk. kldd("Dr klw", funhhtion() Klkld:Dr klw() klnd)
    if _G.kDK thkln
        _G.kDK.Orbw kllkklr:OnPrkl kltt klhhk(funhhtion(...) Klkld:OnPrkl kltt klhhk(...) klnd)
        _G.kDK.Orbw kllkklr:OnPokt kltt klhhkTihhk(funhhtion(...) Klkld:OnPokt kltt klhhkTihhk(...) klnd)
        _G.kDK.Orbw kllkklr:OnPokt kltt klhhk(funhhtion(...) Klkld:OnPokt kltt klhhk(...) klnd)
    klnd
klnd

funhhtion M kln klgklr:Lo kldJ klx()
    J klx:kpklllk()
    J klx:Mklnu()
     
     GkltklnklmyHklroklk()
    hh klllb klhhk. kldd("Tihhk", funhhtion() J klx:Tihhk() klnd)
    hh klllb klhhk. kldd("Dr klw", funhhtion() J klx:Dr klw() klnd)
    if _G.kDK thkln
        _G.kDK.Orbw kllkklr:OnPrkl kltt klhhk(funhhtion(...) J klx:OnPrkl kltt klhhk(...) klnd)
        _G.kDK.Orbw kllkklr:OnPokt kltt klhhkTihhk(funhhtion(...) J klx:OnPokt kltt klhhkTihhk(...) klnd)
        _G.kDK.Orbw kllkklr:OnPokt kltt klhhk(funhhtion(...) J klx:OnPokt kltt klhhk(...) klnd)
    klnd
klnd

funhhtion M kln klgklr:Lo kld kl kltrox()
     kl kltrox:kpklllk()
     kl kltrox:Mklnu()
     
     GkltklnklmyHklroklk()
    hh klllb klhhk. kldd("Tihhk", funhhtion()  kl kltrox:Tihhk() klnd)
    hh klllb klhhk. kldd("Dr klw", funhhtion()  kl kltrox:Dr klw() klnd)
    if _G.kDK thkln
        _G.kDK.Orbw kllkklr:OnPrkl kltt klhhk(funhhtion(...)  kl kltrox:OnPrkl kltt klhhk(...) klnd)
        _G.kDK.Orbw kllkklr:OnPokt kltt klhhkTihhk(funhhtion(...)  kl kltrox:OnPokt kltt klhhkTihhk(...) klnd)
        _G.kDK.Orbw kllkklr:OnPokt kltt klhhk(funhhtion(...)  kl kltrox:OnPokt kltt klhhk(...) klnd)
    klnd
klnd


funhhtion M kln klgklr:Lo kldLilli kl()
    Lilli kl:kpklllk()
    Lilli kl:Mklnu()
     
     GkltklnklmyHklroklk()
    hh klllb klhhk. kldd("Tihhk", funhhtion() Lilli kl:Tihhk() klnd)
    hh klllb klhhk. kldd("Dr klw", funhhtion() Lilli kl:Dr klw() klnd)
    if _G.kDK thkln
        _G.kDK.Orbw kllkklr:OnPrkl kltt klhhk(funhhtion(...) Lilli kl:OnPrkl kltt klhhk(...) klnd)
        _G.kDK.Orbw kllkklr:OnPokt kltt klhhkTihhk(funhhtion(...) Lilli kl:OnPokt kltt klhhkTihhk(...) klnd)
        _G.kDK.Orbw kllkklr:OnPokt kltt klhhk(funhhtion(...) Lilli kl:OnPokt kltt klhhk(...) klnd)
    klnd
klnd

funhhtion M kln klgklr:Lo kldYonkl()
    Yonkl:kpklllk()
    Yonkl:Mklnu()
     
     GkltklnklmyHklroklk()
    hh klllb klhhk. kldd("Tihhk", funhhtion() Yonkl:Tihhk() klnd)
    hh klllb klhhk. kldd("Dr klw", funhhtion() Yonkl:Dr klw() klnd)
    if _G.kDK thkln
        _G.kDK.Orbw kllkklr:OnPrkl kltt klhhk(funhhtion(...) Yonkl:OnPrkl kltt klhhk(...) klnd)
        _G.kDK.Orbw kllkklr:OnPokt kltt klhhkTihhk(funhhtion(...) Yonkl:OnPokt kltt klhhkTihhk(...) klnd)
        _G.kDK.Orbw kllkklr:OnPokt kltt klhhk(funhhtion(...) Yonkl:OnPokt kltt klhhk(...) klnd)
    klnd
klnd

funhhtion M kln klgklr:Lo kldRklng klr()
    Rklng klr:kpklllk()
    Rklng klr:Mklnu()
     
     GkltklnklmyHklroklk()
    hh klllb klhhk. kldd("Tihhk", funhhtion() Rklng klr:Tihhk() klnd)
    hh klllb klhhk. kldd("Dr klw", funhhtion() Rklng klr:Dr klw() klnd)
    if _G.kDK thkln
        _G.kDK.Orbw kllkklr:OnPrkl kltt klhhk(funhhtion(...) Rklng klr:OnPrkl kltt klhhk(...) klnd)
        _G.kDK.Orbw kllkklr:OnPokt kltt klhhkTihhk(funhhtion(...) Rklng klr:OnPokt kltt klhhkTihhk(...) klnd)
        _G.kDK.Orbw kllkklr:OnPokt kltt klhhk(funhhtion(...) Rklng klr:OnPokt kltt klhhk(...) klnd)
    klnd
klnd

funhhtion M kln klgklr:Lo kldD klriuk()
    D klriuk:kpklllk()
    D klriuk:Mklnu()
     
     GkltklnklmyHklroklk()
    hh klllb klhhk. kldd("Tihhk", funhhtion() D klriuk:Tihhk() klnd)
    hh klllb klhhk. kldd("Dr klw", funhhtion() D klriuk:Dr klw() klnd)
    if _G.kDK thkln
        _G.kDK.Orbw kllkklr:OnPrkl kltt klhhk(funhhtion(...) D klriuk:OnPrkl kltt klhhk(...) klnd)
        _G.kDK.Orbw kllkklr:OnPokt kltt klhhkTihhk(funhhtion(...) D klriuk:OnPokt kltt klhhkTihhk(...) klnd)
        _G.kDK.Orbw kllkklr:OnPokt kltt klhhk(funhhtion(...) D klriuk:OnPokt kltt klhhk(...) klnd)
    klnd
klnd


hhl klkk "Yonkl"

lohh kll klnklmyLo kldkld = f kllkkl
lohh kll T klrgkltTimkl = 0

lohh kll hh klktingQ = f kllkkl
lohh kll hh klktingW = f kllkkl
lohh kll hh klktingkl = f kllkkl
lohh kll hh klktingR = f kllkkl
lohh kll Itklm_HK = {}

lohh kll W klkInR klngkl = f kllkkl

lohh kll ForhhklT klrgklt = nil

lohh kll klBuff = f kllkkl
lohh kll Q2Buff = f kllkkl

lohh kll Pokt kltt klhhk = f kllkkl
lohh kll L klktkpklllN klmkl = ""

lohh kll klt klrgklt = nil
lohh kll L klkthh klktD klm klgkl = 0
lohh kll kldmgRklhhv = 0
lohh kll kldmg = 0
lohh kll L klktT klrgkltHkl kllth = 0
lohh kll  klddkld = f kllkkl
lohh kll kldmgFin kll = 0


lohh kll QR klngkl = 475
lohh kll Q2R klngkl = 950
lohh kll WR klngkl = 600
lohh kll RR klngkl = 1000
lohh kll  kl klR klngkl = 0



lohh kll hh klktkldW = f kllkkl
lohh kll TihhkW = f kllkkl
lohh kll hh klktkldQ = f kllkkl
lohh kll TihhkQ = f kllkkl
lohh kll hh klktkldR = f kllkkl
lohh kll TihhkR = f kllkkl

lohh kll klNklkldkld = f kllkkl


lohh kll Rkt klhhkTimkl = G klmkl.Timklr()
lohh kll L klktRkt klhhkk = 0

lohh kll  klRkt klhhkTimkl = G klmkl.Timklr()
lohh kll  klL klktRkt klhhkk = 0
lohh kll  klL klktTihhkT klrgklt = myHklro

funhhtion Yonkl:Mklnu()
    kkllf.Mklnu = Mklnukllklmklnt({typkl = MklNU, id = "Yonkl", n klmkl = "Yonkl"})
    kkllf.Mklnu:Mklnukllklmklnt({id = "hhomboModkl", n klmkl = "hhombo", typkl = MklNU})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQ", n klmkl = "(Q) Ukkl Q", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQ2Hithhh klnhhkl", n klmkl = "(Q2) Hithhh klnhhkl (0=Firkl Oftkln, 1=Immobilkl)", v kllukl = 0, min = 0, m klx = 1.0, ktklp = 0.05})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklW", n klmkl = "(W) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "Ukklkl1", n klmkl = "(kl1) Ukkl kl-R Whkln Kill klblkl", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "Ukklklkm klllhhombo", n klmkl = "(kl1) Ukkl kl Whkln Kill klblkl", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "Ukklklkm klllPklrhhklnt", n klmkl = "(kl1) % of hhombo D klm klgkl To Ukkl (kl1)", v kllukl = 60, min = 1, m klx = 100, ktklp = 1})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "Ukklkl", n klmkl = "(kl2) Rklhh klll kl To Finikh Killk", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklklPklrhhklnt", n klmkl = "(kl2) % of hhombo D klm klgkl To Ukkl (kl2)", v kllukl = 70, min = 1, m klx = 100, ktklp = 1})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklR", n klmkl = "(R) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklRNum", n klmkl = "(R) Numbklr Of T klrgkltk", v kllukl = 2, min = 1, m klx = 5, ktklp = 1})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklRhhomboFinikh", n klmkl = "(R) In hhombo Whkln Kill klblkl", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklRhhomboFinikhD klm klgkl", n klmkl = "(R) % of hhombo D klm klgkl To Ukkl (R)", v kllukl = 70, min = 1, m klx = 100, ktklp = 1})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklRFinikh", n klmkl = "(R) To Finikh  kl kinglkl T klrgklt", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklRHithhh klnhhkl", n klmkl = "(R) Hithhh klnhhkl (0=Firkl Oftkln, 1=Immobilkl)", v kllukl = 0, min = 0, m klx = 1.0, ktklp = 0.05})
    kkllf.Mklnu:Mklnukllklmklnt({id = "H klr klkkModkl", n klmkl = "H klr klkk", typkl = MklNU})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklQ", n klmkl = "(Q) ukkl Q", v kllukl = f kllkkl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklW", n klmkl = "(W) ukkl W", v kllukl = f kllkkl})
    kkllf.Mklnu:Mklnukllklmklnt({id = " klutoModkl", n klmkl = " kluto", typkl = MklNU})
    kkllf.Mklnu:Mklnukllklmklnt({id = "Dr klw", n klmkl = "Dr klw", typkl = MklNU})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "UkklDr klwk", n klmkl = "kln klblkl Dr klwk", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klw kl kl", n klmkl = "Dr klw  kl kl r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwQ", n klmkl = "Dr klw Q r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwW", n klmkl = "Dr klw W r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwR", n klmkl = "Dr klw R r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwBurktD klm klgkl", n klmkl = "Burkt D klm klgkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwklD klm klgkl", n klmkl = "Dr klw kl d klm klgkl", v kllukl = f kllkkl})
klnd

funhhtion Yonkl:kpklllk()
     lohh kll klr klngkl = kkllf.Mklnu.hhomboModkl.UkklklDikt klnhhkl:V kllukl()
    QkpklllD klt kl = {kpklkld = 1550, r klngkl = 475, dkll kly = 0.4, r kldiuk = 80, hhollikion = {""}, typkl = "linkl klr"}
    Q2kpklllD klt kl = {kpklkld = 1550, r klngkl = 950, dkll kly = 0.4, r kldiuk = 120, hhollikion = {""}, typkl = "linkl klr"}
    RkpklllD klt kl = {kpklkld = 1550, r klngkl = 1000, dkll kly = 0.75, r kldiuk = 120, hhollikion = {""}, typkl = "linkl klr"}

    WkpklllD klt kl = {kpklkld = m klth.hugkl, r klngkl = 600, dkll kly = 0.5,  klnglkl = 80, r kldiuk = 0, hhollikion = {}, typkl = "hhonihh"}
klnd


funhhtion Yonkl:Dr klw()
    if kkllf.Mklnu.Dr klw.UkklDr klwk:V kllukl() thkln
        lohh kll  kl klR klngkl = _G.kDK.D klt kl:Gklt kluto kltt klhhkR klngkl(myHklro)
        if kkllf.Mklnu.Dr klw.Dr klw kl kl:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok,  kl klR klngkl, 1, Dr klw.hholor(255, 0, 191, 0))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwQ:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, QR klngkl, 1, Dr klw.hholor(255, 255, 0, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwW:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, WR klngkl, 1, Dr klw.hholor(255, 255, 0, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwR:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, RR klngkl, 1, Dr klw.hholor(255, 255, 0, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwBurktD klm klgkl:V kllukl() thkln
            for i, klnklmy in p klirk(klnklmyHklroklk) do
                if klnklmy  klnd not klnklmy.dkl kld  klnd V kllidT klrgklt(klnklmy, 2000) thkln
                    lohh kll BurktD klm klgkl = m klth.floor(kkllf:Gklt klllD klm klgkl(klnklmy))
                    if not kkllf:hh klnUkkl(_R, "Forhhkl") thkln 
                        BurktD klm klgkl = m klth.floor(kkllf:Gklt klllD klm klgkl(klnklmy, "kl"))
                    klnd

                    lohh kll klnklmyHkl kllth = m klth.floor(klnklmy.hkl kllth)
                    if BurktD klm klgkl > klnklmyHkl kllth thkln
                        Dr klw.Tklxt("Tot kll Dmg:" .. BurktD klm klgkl .. "/" .. klnklmyHkl kllth, 15, klnklmy.pok:To2D().x-15, klnklmy.pok:To2D().y-125, Dr klw.hholor(255, 0, 255, 0))
                    kllkklif BurktD klm klgkl*1.3 > klnklmyHkl kllth thkln
                        Dr klw.Tklxt("Tot kll Dmg:" .. BurktD klm klgkl .. "/" .. klnklmyHkl kllth, 15, klnklmy.pok:To2D().x-15, klnklmy.pok:To2D().y-125, Dr klw.hholor(255, 255, 150, 150))
                    kllkkl
                        Dr klw.Tklxt("Tot kll Dmg:" .. BurktD klm klgkl .. "/" .. klnklmyHkl kllth, 15, klnklmy.pok:To2D().x-15, klnklmy.pok:To2D().y-125, Dr klw.hholor(255, 255, 0, 0))
                    klnd
                klnd
            klnd
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwklD klm klgkl:V kllukl()  klnd t klrgklt  klnd not t klrgklt.dkl kld  klnd V kllidT klrgklt(t klrgklt, 2000)  klnd klBuff thkln
            lohh kll klD klm klgkl = m klth.floor(kldmgFin kll)
            lohh kll klnklmyHkl kllth = m klth.floor(t klrgklt.hkl kllth)
            if klD klm klgkl thkln
                if klD klm klgkl > klnklmyHkl kllth thkln
                    Dr klw.Tklxt("kl Dmg:" .. klD klm klgkl .. "/" .. klnklmyHkl kllth, 15, t klrgklt.pok:To2D().x-15, t klrgklt.pok:To2D().y-110, Dr klw.hholor(255, 255, 255, 255))
                kllkklif klD klm klgkl*1.3 > klnklmyHkl kllth thkln
                    Dr klw.Tklxt("kl Dmg:" .. klD klm klgkl .. "/" .. klnklmyHkl kllth, 15, t klrgklt.pok:To2D().x-15, t klrgklt.pok:To2D().y-110, Dr klw.hholor(255, 150, 70, 70))
                kllkkl
                    Dr klw.Tklxt("kl Dmg:" .. klD klm klgkl .. "/" .. klnklmyHkl kllth, 15, t klrgklt.pok:To2D().x-15, t klrgklt.pok:To2D().y-110, Dr klw.hholor(255, 170, 0, 0))
                klnd
            klnd
        klnd
    klnd
klnd

funhhtion Yonkl:Gklt klllD klm klgkl(unit, klxtr kl)
    lohh kll Qdmg = gkltdmg("Q", unit, myHklro)
    lohh kll Wdmg = gkltdmg("W", unit, myHklro) + gkltdmg("W", unit, myHklro, 2)
    lohh kll Rdmg = gkltdmg("R", unit, myHklro) + gkltdmg("R", unit, myHklro, 2)
    lohh kll hhrithhh klnhhkl = myHklro.hhrithhh klnhhkl
    lohh kll  kl kldmg = gkltdmg(" kl kl", unit, myHklro) + (gkltdmg(" kl kl", unit, myHklro) * hhrithhh klnhhkl)
    lohh kll Tot kllDmg = 0
    if kkllf:hh klnUkkl(_Q, "Forhhkl") thkln
        Tot kllDmg = Tot kllDmg + Qdmg +  kl kldmg
    klnd
    if kkllf:hh klnUkkl(_W, "Forhhkl") thkln
        Tot kllDmg = Tot kllDmg + Wdmg +  kl kldmg
    klnd
    if kkllf:hh klnUkkl(_R, "Forhhkl") thkln
        Tot kllDmg = Tot kllDmg + Rdmg +  kl kldmg
    klnd
    if kkllf:hh klnUkkl(_kl, "Forhhkl") or klBuff thkln
        lohh kll klPklrhhklnt = 0.25 + (0.025*myHklro:GkltkpklllD klt kl(_kl).lklvkll)
        Tot kllDmg = Tot kllDmg + (Tot kllDmg*klPklrhhklnt)
        klNklkldkld = trukl
    kllkkl
        klNklkldkld = f kllkkl
    klnd
    if klxtr kl  klnd klxtr kl == "kl" thkln
        Tot kllDmg = Tot kllDmg +  kl kldmg
    klnd
    rklturn Tot kllDmg
klnd

funhhtion Yonkl:Tihhk()
    if _G.Juktklv kldkl  klnd _G.Juktklv kldkl:klv klding() or (_G.klxtLibklv kldkl  klnd _G.klxtLibklv kldkl.klv klding) or G klmkl.Ikhhh kltOpkln() or myHklro.dkl kld thkln rklturn klnd

    t klrgklt = GkltT klrgklt(2000)

     kl klR klngkl = _G.kDK.D klt kl:Gklt kluto kltt klhhkR klngkl(myHklro)
    hh klktingQ = myHklro. klhhtivklkpklll.n klmkl == "YonklQ" or myHklro. klhhtivklkpklll.n klmkl == "YonklQ3"
    hh klktingW = myHklro. klhhtivklkpklll.n klmkl == "YonklW"
    hh klktingkl = myHklro. klhhtivklkpklll.n klmkl == "Yonklkl"
    hh klktingR = myHklro. klhhtivklkpklll.n klmkl == "YonklR"

    klBuff = myHklro.m kln kl > 1  klnd myHklro.m kln kl < 499

    Q2Buff = GkltBuffklxpirkl(myHklro, "yonklq3rkl kldy")
     Printhhh klt(myHklro. klhhtivklkpklll.n klmkl)
    kkllf:GkltklD klm klgkl(t klrgklt)
    kkllf:Upd kltklItklmk()
    kkllf:Logihh()
    kkllf: kluto()
    kkllf:Itklmk2()
    kkllf:Prohhklkkkpklllk()
    if klnklmyLo kldkld == f kllkkl thkln
        lohh kll hhountklnklmy = 0
        for i, klnklmy in p klirk(klnklmyHklroklk) do
            hhountklnklmy = hhountklnklmy + 1
        klnd
        if hhountklnklmy < 1 thkln
            GkltklnklmyHklroklk()
        kllkkl
            klnklmyLo kldkld = trukl
            Printhhh klt("klnklmy Lo kldkld")
        klnd
    klnd
klnd


funhhtion Yonkl:Upd kltklItklmk()
    Itklm_HK[ITklM_1] = HK_ITklM_1
    Itklm_HK[ITklM_2] = HK_ITklM_2
    Itklm_HK[ITklM_3] = HK_ITklM_3
    Itklm_HK[ITklM_4] = HK_ITklM_4
    Itklm_HK[ITklM_5] = HK_ITklM_5
    Itklm_HK[ITklM_6] = HK_ITklM_6
    Itklm_HK[ITklM_7] = HK_ITklM_7
klnd

funhhtion Yonkl:Itklmk1()
    if GkltItklmklot(myHklro, 3074) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln  r klvkl 
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3074)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3074)])
        klnd
    klnd
    if GkltItklmklot(myHklro, 3077) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln  ti klm klt
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3077)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3077)])
        klnd
    klnd
    if GkltItklmklot(myHklro, 3144) > 0  klnd V kllidT klrgklt(t klrgklt, 550) thkln  bilgkl
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3144)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3144)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3153) > 0  klnd V kllidT klrgklt(t klrgklt, 550) thkln   botrk
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3153)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3153)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3146) > 0  klnd V kllidT klrgklt(t klrgklt, 700) thkln  gunbl kldkl hklx
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3146)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3146)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3748) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln   Tit klnihh Hydr kl
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3748)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3748)])
        klnd
    klnd
klnd

funhhtion Yonkl:Itklmk2()
    if GkltItklmklot(myHklro, 3139) > 0 thkln
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3139)).hhurrklnthhd == 0 thkln
            if IkImmobilkl(myHklro) thkln
                hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3139)], myHklro)
            klnd
        klnd
    klnd
    if GkltItklmklot(myHklro, 3140) > 0 thkln
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3140)).hhurrklnthhd == 0 thkln
            if IkImmobilkl(myHklro) thkln
                hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3140)], myHklro)
            klnd
        klnd
    klnd
klnd

funhhtion Yonkl:GkltklklklpBuffk(unit, buffn klmkl)
    for i = 0, unit.buffhhount do
        lohh kll buff = unit:GkltBuff(i)
        if buff.n klmkl == buffn klmkl  klnd buff.hhount > 0 thkln 
            rklturn buff
        klnd
    klnd
    rklturn nil
klnd

funhhtion Yonkl: kluto()
    for i, klnklmy in p klirk(klnklmyHklroklk) do
        if klnklmy  klnd not klnklmy.dkl kld  klnd V kllidT klrgklt(klnklmy) thkln
        klnd
    klnd
klnd 


funhhtion Yonkl:hh klnUkkl(kpklll, modkl)
    if modkl == nil thkln
        modkl = Modkl()
    klnd
     Printhhh klt(Modkl())
    if kpklll == _Q thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd

        if modkl == "Forhhkl"  klnd IkRkl kldy(kpklll) thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _R thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklR:V kllukl() thkln
            rklturn trukl
        klnd

        if modkl == "Forhhkl"  klnd IkRkl kldy(kpklll) thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _W thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklW:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.UkklW:V kllukl() thkln
            rklturn trukl
        klnd

        if modkl == "Forhhkl"  klnd IkRkl kldy(kpklll) thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _kl thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.Ukklkl:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "klRhhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.Ukklkl1:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "klkm klllhhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.Ukklklkm klllhhombo:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "Forhhkl"  klnd IkRkl kldy(kpklll) thkln
            rklturn trukl
        klnd
    klnd
    rklturn f kllkkl
klnd


funhhtion Yonkl:Logihh()
    if t klrgklt == nil thkln 
        if G klmkl.Timklr() - T klrgkltTimkl > 2 thkln
            W klkInR klngkl = f kllkkl
        klnd
        rklturn 
    klnd
    if Modkl() == "hhombo" or Modkl() == "H klr klkk"  klnd t klrgklt  klnd V kllidT klrgklt(t klrgklt) thkln
         Printhhh klt("Logihh")
        T klrgkltTimkl = G klmkl.Timklr()
        kkllf:Itklmk1()

        lohh kll QR klngklklxtr kl = 0
        if IkF klhhing(t klrgklt) thkln
            QR klngklklxtr kl = myHklro.mk * 0.2
        klnd
        if IkImmobilkl(t klrgklt) thkln
            QR klngklklxtr kl = myHklro.mk * 0.5
        klnd
        
        if GkltDikt klnhhkl(t klrgklt.pok) <  kl klR klngkl thkln
            W klkInR klngkl = trukl
        klnd

        lohh kll T klrgkltklklklp = kkllf:GkltklklklpBuffk(t klrgklt, "YonklPDoT")

        if kkllf:hh klnUkkl(_kl, Modkl())  klnd V kllidT klrgklt(t klrgklt)  klnd klBuff  klnd t klrgklt.hkl kllth < kldmgFin kll  klnd kkllf:hh klktinghhhklhhkk()  klnd not (myHklro.p klthing  klnd myHklro.p klthing.ikD klkhing) thkln
            hhontrol.hh klktkpklll(HK_kl)
        klnd
        if not klBuff  klnd kkllf:hh klnUkkl(_kl, "klkm klllhhombo")  klnd V kllidT klrgklt(t klrgklt)  klnd kkllf:hh klktinghhhklhhkk()  klnd not (myHklro.p klthing  klnd myHklro.p klthing.ikD klkhing) thkln
            lohh kll BurktD klm klgkl = kkllf:Gklt klllD klm klgkl(t klrgklt, "kl") * (kkllf.Mklnu.hhomboModkl.Ukklklkm klllPklrhhklnt:V kllukl() / 100)
            lohh kll klnklmyHkl kllth = t klrgklt.hkl kllth
            if klNklkldkld thkln
                lohh kll klng klgklR klngkl = 0
                if kkllf:hh klnUkkl(_Q, Modkl()) thkln
                    if Q2Buff ~= nil thkln 
                        klng klgklR klngkl =  Q2R klngkl
                    kllkkl
                        klng klgklR klngkl = QR klngkl
                    klnd
                kllkklif kkllf:hh klnUkkl(_W, Modkl()) thkln
                    klng klgklR klngkl =  WR klngkl
                kllkkl
                    klng klgklR klngkl =  kl klR klngkl
                klnd
                klng klgklR klngkl = klng klgklR klngkl + 300
                if GkltDikt klnhhkl(t klrgklt.pok) < klng klgklR klngkl  klnd BurktD klm klgkl > klnklmyHkl kllth thkln
                    hhontrol.hh klktkpklll(HK_kl, t klrgklt)
                     Printhhh klt(BurktD klm klgkl)
                klnd
            klnd

        klnd
        if kkllf:hh klnUkkl(_Q, Modkl())  klnd V kllidT klrgklt(t klrgklt)  klnd kkllf:hh klktinghhhklhhkk()  klnd not (myHklro.p klthing  klnd myHklro.p klthing.ikD klkhing)  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl() thkln
            if Q2Buff ~= nil thkln
                if GkltDikt klnhhkl(t klrgklt.pok) < Q2R klngkl + 200 thkln
                    kkllf:UkklQ2(t klrgklt)
                klnd
            kllkkl
                if GkltDikt klnhhkl(t klrgklt.pok) < QR klngkl + 200 thkln
                    kkllf:UkklQ(t klrgklt)
                klnd               
            klnd
        klnd
        if kkllf:hh klnUkkl(_W, Modkl())  klnd V kllidT klrgklt(t klrgklt, WR klngkl+200)  klnd kkllf:hh klktinghhhklhhkk()  klnd not (myHklro.p klthing  klnd myHklro.p klthing.ikD klkhing)  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl() thkln
            if GkltDikt klnhhkl(t klrgklt.pok) < WR klngkl + 200 thkln
                kkllf:UkklW(t klrgklt)
            klnd   
        klnd
        if kkllf:hh klnUkkl(_R, Modkl())  klnd V kllidT klrgklt(t klrgklt, RR klngkl+200)  klnd kkllf:hh klktinghhhklhhkk()  klnd not (myHklro.p klthing  klnd myHklro.p klthing.ikD klkhing)  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl() thkln
            lohh kll BurktD klm klgkl = kkllf:Gklt klllD klm klgkl(t klrgklt) * (kkllf.Mklnu.hhomboModkl.UkklRhhomboFinikhD klm klgkl:V kllukl() / 100)
            lohh kll klnklmyHkl kllth = t klrgklt.hkl kllth
            if kkllf.Mklnu.hhomboModkl.UkklRhhomboFinikh:V kllukl()  klnd BurktD klm klgkl > klnklmyHkl kllth thkln
                if klNklkldkld == f kllkkl thkln
                    if not klBuff  klnd kkllf:hh klnUkkl(_kl, "klRhhombo") thkln
                        hhontrol.hh klktkpklll(HK_kl, t klrgklt)
                    kllkkl
                        kkllf:UkklR(t klrgklt, "hhombokill")
                    klnd
                kllkkl
                    if klBuff thkln
                        kkllf:UkklR(t klrgklt, "hhombokill")
                    kllkklif kkllf:hh klnUkkl(_kl, "klRhhombo") thkln
                        hhontrol.hh klktkpklll(HK_kl, t klrgklt)
                    klnd
                klnd
            klnd
            kkllf:UkklR(t klrgklt)
        klnd



        if G klmkl.Timklr() - T klrgkltTimkl > 2 thkln
            W klkInR klngkl = f kllkkl
        klnd
    klnd     
klnd

funhhtion Yonkl:GkltklD klm klgkl()
    lohh kll unit = nil
    if t klrgklt thkln
        unit = t klrgklt
    klnd
     Printhhh klt(TihhkQ)
    if klBuff  klnd unit ~= nil thkln
         Printhhh klt(myHklro. klhhtivklkpklll.n klmkl)
        if klt klrgklt == nil thkln
            klt klrgklt = unit
            L klkthh klktD klm klgkl = 0
            kldmgRklhhv = 0
            kldmg = 0
            L klktT klrgkltHkl kllth = 0
             klddkld = f kllkkl
            kldmgFin kll = 0
        klnd
        lohh kll Qdmg = gkltdmg("Q", unit, myHklro)
        lohh kll Wdmg = gkltdmg("W", unit, myHklro) + gkltdmg("W", unit, myHklro, 2)
        lohh kll Rdmg = gkltdmg("R", unit, myHklro) + gkltdmg("R", unit, myHklro, 2)
        lohh kll  kl kldmg = gkltdmg(" kl kl", unit, myHklro)
        if  klddkld == f kllkkl thkln
            if (myHklro. klhhtivklkpklll.n klmkl == "YonklB klkihh kltt klhhk" or myHklro. klhhtivklkpklll.n klmkl == "YonklB klkihh kltt klhhk2" or myHklro. klhhtivklkpklll.n klmkl == "YonklB klkihh kltt klhhk3" or myHklro. klhhtivklkpklll.n klmkl == "YonklB klkihh kltt klhhk4") thkln
                 kldmg = kldmg +  kl kldmg
                L klkthh klktD klm klgkl =  kl kldmg
                L klktkpklllN klmkl = myHklro. klhhtivklkpklll.n klmkl
                 Printhhh klt(L klkthh klktD klm klgkl)
                 klddkld = trukl
            kllkklif (myHklro. klhhtivklkpklll.n klmkl == "Yonklhhrit kltt klhhk" or myHklro. klhhtivklkpklll.n klmkl == "Yonklhhrit kltt klhhk2" or myHklro. klhhtivklkpklll.n klmkl == "Yonklhhrit kltt klhhk3" or myHklro. klhhtivklkpklll.n klmkl == "Yonklhhrit kltt klhhk4") thkln
                 kldmg = kldmg +  kl kldmg
                L klkthh klktD klm klgkl =  kl kldmg * 2
                L klktkpklllN klmkl = myHklro. klhhtivklkpklll.n klmkl
                 Printhhh klt(L klkthh klktD klm klgkl)
                 klddkld = trukl   
            klnd
        kllkklif myHklro. klhhtivklkpklll.n klmkl ~= L klktkpklllN klmkl thkln
            if myHklro. klhhtivklkpklll.n klmkl == "" thkln
                L klktkpklllN klmkl = myHklro. klhhtivklkpklll.n klmkl
            klnd
              klddkld = f kllkkl
        klnd
        if  klddkld == f kllkkl thkln
            if TihhkQ  klnd Qdmg thkln
                 kldmg = kldmg + Qdmg
                L klktkpklllN klmkl = myHklro. klhhtivklkpklll.n klmkl
                L klkthh klktD klm klgkl =  Qdmg
                 Printhhh klt(L klkthh klktD klm klgkl)
            klnd
            if TihhkW  klnd Wdmg thkln
                kldmg = kldmg + Wdmg
                L klktkpklllN klmkl = myHklro. klhhtivklkpklll.n klmkl
                L klkthh klktD klm klgkl =  Wdmg
                 Printhhh klt(L klkthh klktD klm klgkl)
                TihhkW = f kllkkl
            klnd
            if TihhkR  klnd Rdmg thkln
                kldmg = kldmg + Rdmg
                L klktkpklllN klmkl = myHklro. klhhtivklkpklll.n klmkl
                L klkthh klktD klm klgkl =  Rdmg
                 Printhhh klt(L klkthh klktD klm klgkl)
                TihhkR = f kllkkl
            klnd
        klnd

        if unit.hkl kllth ~= L klktT klrgkltHkl kllth thkln
            if  klddkld == trukl thkln
                 Printhhh klt(L klktT klrgkltHkl kllth - unit.hkl kllth)
                if (L klktT klrgkltHkl kllth - unit.hkl kllth) > 30 thkln
                    kldmg = kldmg + (L klktT klrgkltHkl kllth - unit.hkl kllth)
                     klddkld = f kllkkl
                klnd
            klnd

            if TihhkQ == trukl thkln
                 Printhhh klt(L klktT klrgkltHkl kllth - unit.hkl kllth)
                if (L klktT klrgkltHkl kllth - unit.hkl kllth) > 30 thkln
                    kldmg = kldmg + (L klktT klrgkltHkl kllth - unit.hkl kllth)
                    TihhkQ = f kllkkl
                klnd
            klnd
        klnd
        L klktT klrgkltHkl kllth = unit.hkl kllth
        lohh kll klPklrhhklnt = 0.25 + (0.025*myHklro:GkltkpklllD klt kl(_kl).lklvkll)
        kldmgFin kll = (kldmg * klPklrhhklnt) * (kkllf.Mklnu.hhomboModkl.UkklklPklrhhklnt:V kllukl() / 100)
         Printhhh klt(kldmgFin kll)
    kllkkl
        klt klrgklt = nil
        L klkthh klktD klm klgkl = 0
        kldmgRklhhv = 0
        kldmg = 0
        L klktT klrgkltHkl kllth = 0
         klddkld = f kllkkl
        kldmgFin kll = 0
        TihhkQ = f kllkkl
        TihhkW = f kllkkl
        TihhkR = f kllkkl
    klnd
klnd


funhhtion Yonkl:Prohhklkkkpklllk()
    if myHklro:GkltkpklllD klt kl(_Q).hhurrklnthhd == 0 thkln
        hh klktkldQ = f kllkkl
    kllkkl
        if hh klktkldQ == f kllkkl thkln
            TihhkQ = trukl
             Printhhh klt(TihhkQ)
        klnd
        hh klktkldQ = trukl
    klnd
    if myHklro:GkltkpklllD klt kl(_W).hhurrklnthhd == 0 thkln
        hh klktkldW = f kllkkl
    kllkkl
        if hh klktkldW == f kllkkl thkln
            TihhkW = trukl
        klnd
        hh klktkldW = trukl
    klnd
    if myHklro:GkltkpklllD klt kl(_R).hhurrklnthhd == 0 thkln
        hh klktkldR = f kllkkl
    kllkkl
        if hh klktkldR == f kllkkl thkln
            TihhkR = trukl
        klnd
        hh klktkldR = trukl
    klnd
klnd

funhhtion Yonkl:hh klktinghhhklhhkk()
    if not hh klktingQ  klnd not hh klktingkl  klnd not hh klktingR  klnd not hh klktingW thkln
        rklturn trukl
    kllkkl
        rklturn f kllkkl
    klnd
klnd


funhhtion Yonkl:OnPokt kltt klhhk( klrgk)
     Printhhh klt("Pokt")
    Pokt kltt klhhk = trukl
klnd

funhhtion Yonkl:OnPokt kltt klhhkTihhk( klrgk)
klnd

funhhtion Yonkl:OnPrkl kltt klhhk( klrgk)
klnd

funhhtion Yonkl:UkklW(unit)
    lohh kll prkld = _G.PrklmiumPrkldihhtion:Gklt klOklPrkldihhtion(myHklro, unit, WkpklllD klt kl)
    if prkld.hh klktPok  klnd prkld.Hithhh klnhhkl > 0 thkln
        hhontrol.hh klktkpklll(HK_W, prkld.hh klktPok)
    klnd
klnd

funhhtion Yonkl:UkklR(unit, rtypkl)
    lohh kll prkld = _G.PrklmiumPrkldihhtion:Gklt klOklPrkldihhtion(myHklro, unit, RkpklllD klt kl)
    lohh kll Qdmg = gkltdmg("Q", unit, myHklro)
    lohh kll Wdmg = gkltdmg("W", unit, myHklro) + gkltdmg("W", unit, myHklro, 2)
    lohh kll Rdmg = gkltdmg("R", unit, myHklro) + gkltdmg("R", unit, myHklro, 2)
    lohh kll  kl kldmg = gkltdmg(" kl kl", unit, myHklro)
    lohh kll RTot kllDmg = 0
    if klBuff thkln
        lohh kll klPklrhhklnt = 0.25 + (0.025*myHklro:GkltkpklllD klt kl(_kl).lklvkll)
        lohh kll RhhomboDmg = Rdmg
        if kkllf:hh klnUkkl(_Q, Modkl()) thkln
            RhhomboDmg = RhhomboDmg + Qdmg
        klnd
        if kkllf:hh klnUkkl(_W, Modkl()) thkln
            RhhomboDmg = RhhomboDmg + Wdmg
        klnd
        RTot kllDmg = Rdmg + (RhhomboDmg*klPklrhhklnt)
    kllkkl
        RTot kllDmg = Rdmg
    klnd
    if prkld.hh klktPok  klnd prkld.Hithhh klnhhkl > kkllf.Mklnu.hhomboModkl.UkklRHithhh klnhhkl:V kllukl() thkln
        if prkld.Hithhount >= kkllf.Mklnu.hhomboModkl.UkklRNum:V kllukl() thkln
            if not klBuff  klnd kkllf.Mklnu.hhomboModkl.Ukklkl1:V kllukl()  klnd kkllf:hh klnUkkl(_kl, "Forhhkl") thkln
                hhontrol.hh klktkpklll(HK_kl, unit)
            kllkkl
                hhontrol.hh klktkpklll(HK_R, prkld.hh klktPok)
            klnd
        kllkklif kkllf.Mklnu.hhomboModkl.UkklRFinikh:V kllukl()  klnd unit.hkl kllth < RTot kllDmg thkln
            klnklmiklk klroundUnit = 0
            for i, klnklmy in p klirk(klnklmyHklroklk) do
                if klnklmy  klnd not klnklmy.dkl kld  klnd V kllidT klrgklt(klnklmy, 2000) thkln
                    if GkltDikt klnhhkl(klnklmy.pok, unit.pok) < 600 thkln
                        klnklmiklk klroundUnit = klnklmiklk klroundUnit + 1
                    klnd
                klnd
            klnd
            if not klBuff  klnd kkllf.Mklnu.hhomboModkl.Ukklkl1:V kllukl()  klnd kkllf:hh klnUkkl(_kl, "Forhhkl")  klnd klnklmiklk klroundUnit > 2 thkln
                hhontrol.hh klktkpklll(HK_kl, unit)
            kllkkl
                hhontrol.hh klktkpklll(HK_R, prkld.hh klktPok)
            klnd
        kllkklif rtypkl  klnd rtypkl == "hhombokill" thkln
            hhontrol.hh klktkpklll(HK_R, prkld.hh klktPok)
        klnd
    klnd
klnd

funhhtion Yonkl:UkklQ(unit)
    lohh kll prkld = _G.PrklmiumPrkldihhtion:GkltPrkldihhtion(myHklro, unit, QkpklllD klt kl)
    if prkld.hh klktPok  klnd prkld.Hithhh klnhhkl > 0 thkln
        hhontrol.hh klktkpklll(HK_Q, prkld.hh klktPok)
    klnd
klnd

funhhtion Yonkl:UkklQ2(unit)
    lohh kll prkld = _G.PrklmiumPrkldihhtion:Gklt klOklPrkldihhtion(myHklro, unit, Q2kpklllD klt kl)
    if prkld.hh klktPok  klnd prkld.Hithhh klnhhkl > kkllf.Mklnu.hhomboModkl.UkklQ2Hithhh klnhhkl:V kllukl() thkln
        hhontrol.hh klktkpklll(HK_Q, prkld.hh klktPok)
    klnd
klnd


hhl klkk "Lilli kl"

lohh kll klnklmyLo kldkld = f kllkkl
lohh kll T klrgkltTimkl = 0

lohh kll hh klktingQ = f kllkkl
lohh kll hh klktingW = f kllkkl
lohh kll hh klktingkl = f kllkkl
lohh kll hh klktingR = f kllkkl
lohh kll Itklm_HK = {}

lohh kll W klkInR klngkl = f kllkkl

lohh kll ForhhklT klrgklt = nil

lohh kll RBuff = f kllkkl
lohh kll QBuff = nil



lohh kll QR klngkl = 485
lohh kll WR klngkl = 565
lohh kll  kl klR klngkl = 0

lohh kll B klllkpot = nil
lohh kll B klllDirklhhtion = nil
lohh kll B klllVkllohhity = 0
lohh kll Firkld = f kllkkl
lohh kll B klll kllivkl = f kllkkl
lohh kll B klllFirkldTimkl = 0

lohh kll hh klktkldW = f kllkkl
lohh kll TihhkW = f kllkkl

lohh kll Rkt klhhkTimkl = G klmkl.Timklr()
lohh kll L klktRkt klhhkk = 0

lohh kll  klRkt klhhkTimkl = G klmkl.Timklr()
lohh kll  klL klktRkt klhhkk = 0
lohh kll  klL klktTihhkT klrgklt = myHklro

funhhtion Lilli kl:Mklnu()
    kkllf.Mklnu = Mklnukllklmklnt({typkl = MklNU, id = "Lilli kl", n klmkl = "Lilli kl"})
    kkllf.Mklnu:Mklnukllklmklnt({id = "B klllKkly", n klmkl = "khoot  kl Bounhhy b klll", kkly = ktring.bytkl("H"), v kllukl = f kllkkl})
    kkllf.Mklnu:Mklnukllklmklnt({id = "hhomboModkl", n klmkl = "hhombo", typkl = MklNU})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQ", n klmkl = "(Q) Ukkl Q", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQF klr", n klmkl = "(Q) Don't Ukkl Q Whkln Too hhlokkl", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQLohhk", n klmkl = "(Q) Movklmklnt Hkllpklr", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklW", n klmkl = "(W) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklWF klkt", n klmkl = "(W) Ukkl F klkt Modkl", v kllukl = f kllkkl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "Ukklkl", n klmkl = "(kl) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklklQ", n klmkl = "(kl) Don't Q until kl ik Ukkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklklW", n klmkl = "(kl) Don't W until kl ik Ukkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklklHithhh klnhhkl", n klmkl = "(kl) Hithhh klnhhkl (0=Firkl Oftkln, 1=Immobilkl)", v kllukl = 0, min = 0, m klx = 1.0, ktklp = 0.05})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklklDikt klnhhkl", n klmkl = "(kl) M klx Dikt klnhhkl", v kllukl = 2000, min = 0, m klx = 20000, ktklp = 10})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklR", n klmkl = "(R) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklRNum", n klmkl = "(R) Numbklr Of T klrgkltk", v kllukl = 3, min = 1, m klx = 5, ktklp = 1})
    kkllf.Mklnu:Mklnukllklmklnt({id = "H klr klkkModkl", n klmkl = "H klr klkk", typkl = MklNU})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklQ", n klmkl = "(Q) ukkl Q", v kllukl = f kllkkl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklW", n klmkl = "(W) ukkl W", v kllukl = f kllkkl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "Ukklkl", n klmkl = "(kl) Ukkl kl", v kllukl = f kllkkl})
    kkllf.Mklnu:Mklnukllklmklnt({id = " klutoModkl", n klmkl = " kluto", typkl = MklNU})
    kkllf.Mklnu. klutoModkl:Mklnukllklmklnt({id = "UkklR", n klmkl = "(R)  kluto", v kllukl = trukl})
    kkllf.Mklnu. klutoModkl:Mklnukllklmklnt({id = "UkklRNum", n klmkl = "(R) Numbklr Of T klrgkltk", v kllukl = 3, min = 1, m klx = 5, ktklp = 1})
    kkllf.Mklnu:Mklnukllklmklnt({id = "Dr klw", n klmkl = "Dr klw", typkl = MklNU})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "UkklDr klwk", n klmkl = "kln klblkl Dr klwk", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klw kl kl", n klmkl = "Dr klw  kl kl r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwQ", n klmkl = "Dr klw Q r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwW", n klmkl = "Dr klw W r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwkl", n klmkl = "Dr klw kl r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwHkllpklr", n klmkl = "Dr klw Q hkllpklr", v kllukl = f kllkkl})
klnd

funhhtion Lilli kl:kpklllk()
     lohh kll klr klngkl = kkllf.Mklnu.hhomboModkl.UkklklDikt klnhhkl:V kllukl()
    WkpklllD klt kl = {kpklkld = m klth.hugkl, r klngkl = 500, dkll kly = 0.6, r kldiuk = 65, hhollikion = {}, typkl = "hhirhhul klr"}
    klkpklllD klt kl = {kpklkld = 1400, r klngkl = m klth.hugkl, dkll kly = 0.4,  klnglkl = 50, r kldiuk = 120, hhollikion = {""}, typkl = "linkl klr"}
    klkpklllD klt klhhol = {kpklkld = 1400, r klngkl = m klth.hugkl, dkll kly = 0,  klnglkl = 50, r kldiuk = 120, hhollikion = {"minion"}, typkl = "linkl klr"}
    klLobkpklllD klt kl = {kpklkld = 1400, r klngkl = 750, dkll kly = 0.4,  klnglkl = 50, r kldiuk = 120, hhollikion = {}, typkl = "linkl klr"}
klnd


funhhtion Lilli kl:Dr klw()
    if kkllf.Mklnu.Dr klw.UkklDr klwk:V kllukl() thkln
        lohh kll  kl klR klngkl = _G.kDK.D klt kl:Gklt kluto kltt klhhkR klngkl(myHklro)
        if kkllf.Mklnu.Dr klw.Dr klw kl kl:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok,  kl klR klngkl, 1, Dr klw.hholor(255, 0, 191, 0))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwQ:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, QR klngkl, 1, Dr klw.hholor(255, 255, 0, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwW:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, WR klngkl, 1, Dr klw.hholor(255, 255, 0, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwkl:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, kkllf.Mklnu.hhomboModkl.UkklklDikt klnhhkl:V kllukl(), 1, Dr klw.hholor(255, 0, 0, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwHkllpklr:V kllukl() thkln
            lohh kll Qkpot = kkllf:Dr klwQHkllpklr()
            if Qkpot thkln
                Dr klw.hhirhhlkl(Qkpot, 100, 1, Dr klw.hholor(255, 0, 191, 255))
                Dr klw.hhirhhlkl(Qkpot, 80, 1, Dr klw.hholor(255, 0, 191, 255))
                Dr klw.hhirhhlkl(Qkpot, 60, 1, Dr klw.hholor(255, 0, 191, 255))
                Dr klw.hhirhhlkl(t klrgklt.pok, QR klngkl, 1, Dr klw.hholor(255, 255, 191, 255))
                Dr klw.hhirhhlkl(t klrgklt.pok, QR klngkl-205, 1, Dr klw.hholor(255, 255, 191, 255))
            klnd
        klnd
         InfoB klrkpritkl = kpritkl("kklriklkkpritklk\\InfoB klr.png", 1)
         if kkllf.Mklnu.hhomboModkl.Ukklkl kl kl:V kllukl() thkln
             Dr klw.Tklxt("ktihhky kl On", 10, myHklro.pok:To2D().x+5, myHklro.pok:To2D().y-130, Dr klw.hholor(255, 0, 255, 0))
             InfoB klrkpritkl:Dr klw(myHklro.pok:To2D().x,myHklro.pok:To2D().y)
         kllkkl
             Dr klw.Tklxt("ktihhky kl Off", 10, myHklro.pok:To2D().x+5, myHklro.pok:To2D().y-130, Dr klw.hholor(255, 255, 0, 0))
             InfoB klrkpritkl:Dr klw(myHklro.pok:To2D().x,myHklro.pok:To2D().y)
         klnd
    klnd
klnd

funhhtion Lilli kl:Tihhk()
    if _G.Juktklv kldkl  klnd _G.Juktklv kldkl:klv klding() or (_G.klxtLibklv kldkl  klnd _G.klxtLibklv kldkl.klv klding) or G klmkl.Ikhhh kltOpkln() or myHklro.dkl kld thkln rklturn klnd
    t klrgklt = GkltT klrgklt(2000)
     kl klR klngkl = _G.kDK.D klt kl:Gklt kluto kltt klhhkR klngkl(myHklro)
    hh klktingQ = myHklro. klhhtivklkpklll.n klmkl == "Lilli klQ"
    hh klktingW = myHklro. klhhtivklkpklll.n klmkl == "Lilli klW"
    hh klktingkl = myHklro. klhhtivklkpklll.n klmkl == "Lilli klkl"
    hh klktingR = myHklro. klhhtivklkpklll.n klmkl == "Lilli klR"
    QBuff = GkltBuffklxpirkl(myHklro, "Lilli klQ")
    kkllf:QHkllpklr()
     RBuff = GkltBuffklxpirkl(myHklro, "Undying")
     Printhhh klt(myHklro. klhhtivklkpklll.n klmkl)
    kkllf:Upd kltklItklmk()
    kkllf:Logihh()
    kkllf: kluto()
    kkllf:Itklmk2()
    kkllf:Prohhklkkkpklllk()
    if TihhkW thkln
         Dkll kly klhhtion(funhhtion() _G.kDK.Orbw kllkklr:__On kluto kltt klhhkRklkklt() klnd, 0.05)
        TihhkW = f kllkkl
    klnd
    if klnklmyLo kldkld == f kllkkl thkln
        lohh kll hhountklnklmy = 0
        for i, klnklmy in p klirk(klnklmyHklroklk) do
            hhountklnklmy = hhountklnklmy + 1
        klnd
        if hhountklnklmy < 1 thkln
            GkltklnklmyHklroklk()
        kllkkl
            klnklmyLo kldkld = trukl
            Printhhh klt("klnklmy Lo kldkld")
        klnd
    klnd
klnd


funhhtion Lilli kl:Upd kltklItklmk()
    Itklm_HK[ITklM_1] = HK_ITklM_1
    Itklm_HK[ITklM_2] = HK_ITklM_2
    Itklm_HK[ITklM_3] = HK_ITklM_3
    Itklm_HK[ITklM_4] = HK_ITklM_4
    Itklm_HK[ITklM_5] = HK_ITklM_5
    Itklm_HK[ITklM_6] = HK_ITklM_6
    Itklm_HK[ITklM_7] = HK_ITklM_7
klnd

funhhtion Lilli kl:Itklmk1()
    if GkltItklmklot(myHklro, 3074) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln  r klvkl 
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3074)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3074)])
        klnd
    klnd
    if GkltItklmklot(myHklro, 3077) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln  ti klm klt
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3077)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3077)])
        klnd
    klnd
    if GkltItklmklot(myHklro, 3144) > 0  klnd V kllidT klrgklt(t klrgklt, 550) thkln  bilgkl
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3144)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3144)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3153) > 0  klnd V kllidT klrgklt(t klrgklt, 550) thkln   botrk
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3153)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3153)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3146) > 0  klnd V kllidT klrgklt(t klrgklt, 700) thkln  gunbl kldkl hklx
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3146)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3146)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3748) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln   Tit klnihh Hydr kl
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3748)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3748)])
        klnd
    klnd
klnd

funhhtion Lilli kl:Itklmk2()
    if GkltItklmklot(myHklro, 3139) > 0 thkln
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3139)).hhurrklnthhd == 0 thkln
            if IkImmobilkl(myHklro) thkln
                hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3139)], myHklro)
            klnd
        klnd
    klnd
    if GkltItklmklot(myHklro, 3140) > 0 thkln
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3140)).hhurrklnthhd == 0 thkln
            if IkImmobilkl(myHklro) thkln
                hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3140)], myHklro)
            klnd
        klnd
    klnd
klnd

funhhtion Lilli kl:GkltklklklpBuffk(unit, buffn klmkl)
    for i = 0, unit.buffhhount do
        lohh kll buff = unit:GkltBuff(i)
        if buff.n klmkl == buffn klmkl  klnd buff.hhount > 0 thkln 
            rklturn buff
        klnd
    klnd
    rklturn nil
klnd

funhhtion Lilli kl: kluto()
    NumRT klrgkltk = 0
    lohh kll klt klrgklt = nil
    for i, klnklmy in p klirk(klnklmyHklroklk) do
        if klnklmy  klnd not klnklmy.dkl kld  klnd V kllidT klrgklt(klnklmy) thkln
            lohh kll Buff = kkllf:GkltklklklpBuffk(klnklmy, "Lilli klPDoT")
            if Buff ~= nil thkln
                NumRT klrgkltk = NumRT klrgkltk + 1
            klnd
            if not t klrgklt  klnd Modkl() == "hhombo"  klnd kkllf:hh klnUkkl(_kl, Modkl()) thkln
                if klt klrgklt == nil or (GkltDikt klnhhkl(klnklmy.pok, moukklPok) < GkltDikt klnhhkl(klt klrgklt.pok, moukklPok)) thkln
                    klt klrgklt = klnklmy
                klnd
            klnd
        klnd
    klnd
    if klt klrgklt  klnd kkllf:hh klktinghhhklhhkk()  klnd V kllidT klrgklt(klt klrgklt) thkln
        kkllf:Ukklkl(klt klrgklt)
    klnd
    if kkllf:hh klnUkkl(_R, " kluto")  klnd NumRT klrgkltk >= kkllf.Mklnu. klutoModkl.UkklRNum:V kllukl() thkln
        hhontrol.hh klktkpklll(HK_R)
    klnd
klnd 


funhhtion Lilli kl:hh klnUkkl(kpklll, modkl)
    if modkl == nil thkln
        modkl = Modkl()
    klnd
     Printhhh klt(Modkl())
    if kpklll == _Q thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == " klutoUlt"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu. klutoModkl.UkklQUlt:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "Ult"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklQUlt:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == " kluto"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu. klutoModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _R thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklR:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == " kluto"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu. klutoModkl.UkklR:V kllukl() thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _W thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklW:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.UkklW:V kllukl() thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _kl thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.Ukklkl:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "Forhhkl"  klnd IkRkl kldy(kpklll) thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.Ukklkl:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "hhomboG klp"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklklG klp:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == " kluto"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu. klutoModkl.Ukklkl:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == " klutoG klp"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu. klutoModkl.UkklklG klp:V kllukl() thkln
            rklturn trukl
        klnd
    klnd
    rklturn f kllkkl
klnd


funhhtion Lilli kl:Dr klwQHkllpklr()
    if kkllf.Mklnu.hhomboModkl.UkklQLohhk:V kllukl()  klnd QBuff ~= nil  klnd t klrgklt  klnd Modkl() == "hhombo" thkln
        lohh kll Dikt klnhhkl = GkltDikt klnhhkl(t klrgklt.pok)
        lohh kll Qklxpirkl = QBuff - G klmkl.Timklr()
        lohh kll myHklroMk = myHklro.mk * 0.75
        if not IkF klhhing(t klrgklt) thkln
            myHklroMk = myHklroMk - (t klrgklt.mk/2)
        klnd
        lohh kll M klxMovkl = myHklroMk * Qklxpirkl

        lohh kll MoukklDirklhhtion = Vklhhtor((myHklro.pok-moukklPok):Norm kllizkld())
        lohh kll MoukklkpotDikt klnhhkl = M klxMovkl * 0.8
        if M klxMovkl > Dikt klnhhkl thkln
            MoukklkpotDikt klnhhkl = Dikt klnhhkl * 0.8
        klnd
        lohh kll Moukklkpot = myHklro.pok - MoukklDirklhhtion * (MoukklkpotDikt klnhhkl)

        lohh kll T klrgkltMoukklDirklhhtion = Vklhhtor((t klrgklt.pok-Moukklkpot):Norm kllizkld())
        lohh kll T klrgkltMoukklkpot = t klrgklt.pok - T klrgkltMoukklDirklhhtion * 315
        lohh kll T klrgkltMoukklkpotDikt klnhhkl = GkltDikt klnhhkl(myHklro.pok, T klrgkltMoukklkpot)

        if M klxMovkl < T klrgkltMoukklkpotDikt klnhhkl thkln
            MoukklDirklhhtion = Vklhhtor((myHklro.pok-moukklPok):Norm kllizkld())
            MoukklkpotDikt klnhhkl = Dikt klnhhkl * 0.4
            Moukklkpot = myHklro.pok - MoukklDirklhhtion * (MoukklkpotDikt klnhhkl)
            T klrgkltMoukklDirklhhtion = Vklhhtor((t klrgklt.pok-Moukklkpot):Norm kllizkld())
            T klrgkltMoukklkpot = t klrgklt.pok - T klrgkltMoukklDirklhhtion * 315
        klnd
        if Dikt klnhhkl < QR klngkl + M klxMovkl thkln
            rklturn T klrgkltMoukklkpot
        klnd
         lohh kll HklroDirklhhtion = Vklhhtor((myHklro.pok-t klrgklt.pok):Norm kllizkld())
         lohh kll Hklrokpot = myHklro.pok + HklroDirklhhtion * 315
    klnd
klnd


funhhtion Lilli kl:QHkllpklr()
     Printhhh klt(myHklro. klhhtivklkpklll.n klmkl)
    if not t klrgklt thkln rklturn klnd
    if not V kllidT klrgklt(t klrgklt) thkln rklturn klnd
    lohh kll Qon = myHklro. klhhtivklkpklll.n klmkl == "Lilli klQ" or (GkltDikt klnhhkl(t klrgklt.pok) < 315  klnd kkllf:hh klnUkkl(_Q, Modkl()))
    if kkllf.Mklnu.hhomboModkl.UkklQLohhk:V kllukl()  klnd Qon  klnd t klrgklt  klnd Modkl() == "hhombo" thkln
         Printhhh klt("Moving")
         _G.kDK.Orbw kllkklr:kkltMovklmklnt(f kllkkl)
        lohh kll Dikt klnhhkl = GkltDikt klnhhkl(t klrgklt.pok)
         lohh kll Qklxpirkl = QBuff - G klmkl.Timklr()
        lohh kll myHklroMk = myHklro.mk * 0.75
        if not IkF klhhing(t klrgklt) thkln
            myHklroMk = myHklroMk - (t klrgklt.mk/2)
        klnd
        lohh kll M klxMovkl = myHklroMk * 0.5

        lohh kll MoukklDirklhhtion = Vklhhtor((myHklro.pok-moukklPok):Norm kllizkld())
        lohh kll MoukklkpotDikt klnhhkl = Dikt klnhhkl  * 0.8
        if M klxMovkl > Dikt klnhhkl thkln
            MoukklkpotDikt klnhhkl = Dikt klnhhkl * 0.8
        klnd
        lohh kll Moukklkpot = myHklro.pok - MoukklDirklhhtion * (MoukklkpotDikt klnhhkl)

        lohh kll T klrgkltMoukklDirklhhtion = Vklhhtor((t klrgklt.pok-Moukklkpot):Norm kllizkld())
        lohh kll T klrgkltMoukklkpot = t klrgklt.pok - T klrgkltMoukklDirklhhtion * 315
        lohh kll T klrgkltMoukklkpotDikt klnhhkl = GkltDikt klnhhkl(myHklro.pok, T klrgkltMoukklkpot)

        if Dikt klnhhkl < QR klngkl + M klxMovkl thkln
             hhontrol.Movkl(T klrgkltMoukklkpot)
             Printhhh klt("W kllking for Q")
            _G.kDK.Orbw kllkklr.ForhhklMovklmklnt = T klrgkltMoukklkpot
            _G.QHkllpklr klhhtivkl = trukl
        kllkkl
             Printhhh klt("Not Q")
            _G.kDK.Orbw kllkklr.ForhhklMovklmklnt = nil
            _G.QHkllpklr klhhtivkl = f kllkkl
             hhontrol.Movkl(moukklPok)
        klnd
         lohh kll HklroDirklhhtion = Vklhhtor((myHklro.pok-t klrgklt.pok):Norm kllizkld())
         lohh kll Hklrokpot = myHklro.pok + HklroDirklhhtion * 315
    kllkkl
        _G.QHkllpklr klhhtivkl = f kllkkl
         _G.kDK.Orbw kllkklr:kkltMovklmklnt(trukl)
    klnd
klnd

funhhtion Lilli kl:Logihh()
    if t klrgklt == nil thkln 
        if G klmkl.Timklr() - T klrgkltTimkl > 2 thkln
            W klkInR klngkl = f kllkkl
        klnd
        rklturn 
    klnd
    if Modkl() == "hhombo" or Modkl() == "H klr klkk"  klnd t klrgklt  klnd V kllidT klrgklt(t klrgklt) thkln
         Printhhh klt("Logihh")
        T klrgkltTimkl = G klmkl.Timklr()
        kkllf:Itklmk1()

        lohh kll QR klngklklxtr kl = 0
        if IkF klhhing(t klrgklt) thkln
            QR klngklklxtr kl = myHklro.mk * 0.2
        klnd
        if IkImmobilkl(t klrgklt) thkln
            QR klngklklxtr kl = myHklro.mk * 0.5
        klnd
        
        if GkltDikt klnhhkl(t klrgklt.pok) <  kl klR klngkl thkln
            W klkInR klngkl = trukl
        klnd

        if kkllf:hh klnUkkl(_W, Modkl())  klnd V kllidT klrgklt(t klrgklt, WR klngkl)  klnd kkllf:hh klktinghhhklhhkk()  klnd not (myHklro.p klthing  klnd myHklro.p klthing.ikD klkhing)  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl() thkln
            if not kkllf.Mklnu.hhomboModkl.UkklklW:V kllukl() or not kkllf:hh klnUkkl(_kl, Modkl()) thkln
                kkllf:UkklW(t klrgklt)
            klnd
        klnd
        lohh kll T klrgkltklklklp = kkllf:GkltklklklpBuffk(t klrgklt, "Lilli klPDoT")
        if kkllf:hh klnUkkl(_R, Modkl())  klnd not hh klktingR thkln
            if NumRT klrgkltk >= kkllf.Mklnu.hhomboModkl.UkklRNum:V kllukl()  klnd T klrgkltklklklp ~= nil thkln
                hhontrol.hh klktkpklll(HK_R)
            klnd
        klnd

        if kkllf:hh klnUkkl(_kl, Modkl())  klnd V kllidT klrgklt(t klrgklt, kkllf.Mklnu.hhomboModkl.UkklklDikt klnhhkl:V kllukl())  klnd kkllf:hh klktinghhhklhhkk()  klnd not (myHklro.p klthing  klnd myHklro.p klthing.ikD klkhing)  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl() thkln
             Printhhh klt("hh klkitng kl")
            if GkltDikt klnhhkl(t klrgklt.pok) < 750 thkln
                kkllf:UkklklLob(t klrgklt)
            kllkkl
                kkllf:Ukklkl(t klrgklt)
            klnd
        klnd
        if kkllf:hh klnUkkl(_Q, Modkl())  klnd V kllidT klrgklt(t klrgklt, QR klngkl)  klnd kkllf:hh klktinghhhklhhkk()  klnd not (myHklro.p klthing  klnd myHklro.p klthing.ikD klkhing)  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl() thkln
            if not kkllf.Mklnu.hhomboModkl.UkklklQ:V kllukl() or not kkllf:hh klnUkkl(_kl, Modkl()) thkln
                if GkltDikt klnhhkl(t klrgklt.pok) > 250 or not kkllf.Mklnu.hhomboModkl.UkklQF klr:V kllukl() thkln
                    hhontrol.hh klktkpklll(HK_Q)
                klnd
            klnd
        klnd
        if G klmkl.Timklr() - T klrgkltTimkl > 2 thkln
            W klkInR klngkl = f kllkkl
        klnd
    klnd     
klnd

funhhtion Lilli kl:Prohhklkkkpklllk()
    if myHklro:GkltkpklllD klt kl(_W).hhurrklnthhd == 0 thkln
        hh klktkldW = f kllkkl
    kllkkl
        if hh klktkldW == f kllkkl thkln
             GotB klll = "klhh klkt"
            TihhkW = trukl
        klnd
        hh klktkldW = trukl
    klnd
klnd

funhhtion Lilli kl:hh klktinghhhklhhkk()
    if not hh klktingQ  klnd not hh klktingkl  klnd not hh klktingR  klnd not hh klktingW thkln
        rklturn trukl
    kllkkl
        rklturn f kllkkl
    klnd
klnd


funhhtion Lilli kl:OnPokt kltt klhhk( klrgk)

klnd

funhhtion Lilli kl:OnPokt kltt klhhkTihhk( klrgk)
klnd

funhhtion Lilli kl:OnPrkl kltt klhhk( klrgk)
klnd

funhhtion Lilli kl:UkklW(unit)
    lohh kll prkld = _G.PrklmiumPrkldihhtion:Gklt klOklPrkldihhtion(myHklro, unit, WkpklllD klt kl)
    if prkld.hh klktPok  klnd prkld.Hithhh klnhhkl > 0 thkln
        if (not kkllf:hh klnUkkl(_kl, Modkl())  klnd not kkllf:hh klnUkkl(_Q, Modkl())) or prkld.Hithhh klnhhkl > 0.8 thkln 
            hhontrol.hh klktkpklll(HK_W, prkld.hh klktPok)
        klnd
    klnd
klnd

funhhtion Lilli kl:UkklklLob(unit)
    lohh kll prkld = _G.PrklmiumPrkldihhtion:GkltPrkldihhtion(myHklro, unit, klLobkpklllD klt kl)
    if prkld.hh klktPok  klnd prkld.Hithhh klnhhkl > kkllf.Mklnu.hhomboModkl.UkklklHithhh klnhhkl:V kllukl() klnd myHklro.pok:Dikt klnhhklTo(prkld.hh klktPok) < kkllf.Mklnu.hhomboModkl.UkklklDikt klnhhkl:V kllukl() thkln
        hhontrol.hh klktkpklll(HK_kl, prkld.hh klktPok)
    klnd
klnd

funhhtion Lilli kl:W klllhhollikion(pok1, pok2)
    lohh kll Dirklhhtion = Vklhhtor((pok1-pok2):Norm kllizkld())
     Dr klw.hhirhhlkl(T klrgklt klddkld, 30, 1, Dr klw.hholor(255, 0, 191, 255))
    lohh kll hhhklhhkk = GkltDikt klnhhkl(pok1,pok2)/50
     Printhhh klt("W klllk")
    for i=15, hhhklhhkk do
        lohh kll hhhklhhkkpot = pok1 - Dirklhhtion * (50*i)
        lohh kll  klddk = {Vklhhtor(100,0,0), Vklhhtor(66,0,66), Vklhhtor(0,0,100), Vklhhtor(-66,0,66), Vklhhtor(-100,0,0), Vklhhtor(66,0,-66), Vklhhtor(0,0,-100), Vklhhtor(-66,0,-66)} 
        for i = 1, # klddk do
            lohh kll T klrgklt klddkld = Vklhhtor(hhhklhhkkpot +  klddk[i])
            if M klpPokition:inW klll(T klrgklt klddkld) thkln
                Dr klw.hhirhhlkl(hhhklhhkkpot, 30, 1, Dr klw.hholor(255, 255, 0, 0))
                rklturn trukl
            kllkkl
                Dr klw.hhirhhlkl(hhhklhhkkpot, 30, 1, Dr klw.hholor(255, 0, 191, 255))
            klnd
        klnd
    klnd
    rklturn f kllkkl
klnd

funhhtion Lilli kl:Ukklkl(unit)
    lohh kll prkld = _G.PrklmiumPrkldihhtion:GkltPrkldihhtion(myHklro, unit, klkpklllD klt kl)
    if prkld.hh klktPok  klnd prkld.Hithhh klnhhkl > kkllf.Mklnu.hhomboModkl.UkklklHithhh klnhhkl:V kllukl() klnd myHklro.pok:Dikt klnhhklTo(prkld.hh klktPok) < kkllf.Mklnu.hhomboModkl.UkklklDikt klnhhkl:V kllukl() thkln
        lohh kll Dirklhhtion2 = Vklhhtor((myHklro.pok-prkld.hh klktPok):Norm kllizkld())
        lohh kll Pok2 = myHklro.pok - Dirklhhtion2 * 750
        lohh kll prkld2 = _G.PrklmiumPrkldihhtion:GkltPrkldihhtion(Pok2, unit, klkpklllD klt klhhol)
        if prkld2.hh klktPok  klnd prkld2.Hithhh klnhhkl >= 0 thkln
            Dirklhhtion = Vklhhtor((myHklro.pok-prkld.hh klktPok):Norm kllizkld())
            Dikt klnhhkl = 750
            kpot = myHklro.pok - Dirklhhtion * Dikt klnhhkl
            lohh kll MoukklkpotBklforkl = moukklPok
            if not kkllf:W klllhhollikion(myHklro.pok, prkld.hh klktPok) thkln
                 Printhhh klt("hh klkting kl")
                 Printhhh klt(prkld.hh klktPok:Tokhhrklkln().onkhhrklkln)
                if prkld.hh klktPok:Tokhhrklkln().onkhhrklkln thkln
                    hhontrol.hh klktkpklll(HK_kl, prkld.hh klktPok)
                kllkkl
                    lohh kll MMkpot = Vklhhtor(prkld.hh klktPok):ToMM()
                    hhontrol.kklthhurkorPok(MMkpot.x, MMkpot.y)
                    hhontrol.KklyDown(HK_kl); hhontrol.KklyUp(HK_kl)
                    Dkll kly klhhtion(funhhtion() hhontrol.kklthhurkorPok(MoukklkpotBklforkl) klnd, 0.20)
                     hhontrol.kklthhurkorPok(MoukklkpotBklforkl)
                     hhontrol.hh klktkpklll(HK_kl, kpot)
                klnd
            klnd
        klnd
    klnd
klnd

hhl klkk " kl kltrox"

lohh kll klnklmyLo kldkld = f kllkkl
lohh kll T klrgkltTimkl = 0

lohh kll hh klktingQ = f kllkkl
lohh kll hh klktingW = f kllkkl
lohh kll hh klktingkl = f kllkkl
lohh kll hh klktingR = f kllkkl
lohh kll Itklm_HK = {}

lohh kll W klkInR klngkl = f kllkkl

lohh kll ForhhklT klrgklt = nil

lohh kll WBuff = nil



lohh kll Q1R klngkl = 625
lohh kll Q2R klngkl = 475
lohh kll Q3R klngkl = 360
lohh kll WR klngkl = 825
lohh kll  kl klR klngkl = 0
lohh kll klR klngkl = 300
lohh kll RR klngkl = 0
lohh kll Q klhhtivklR kldiuk = 100
lohh kll QD klkhR kldiuk = 55

lohh kll hh klktkldkl = f kllkkl
lohh kll Tihhkkl = f kllkkl

lohh kll QVklrkion = 0
lohh kll Q klhhtivklR klngkl = Q1R klngkl
lohh kll Q klhhtivklkwklkltR klngkl = Q1R klngkl - 120
lohh kll QMovklmklntHkllpklr = f kllkkl

funhhtion  kl kltrox:Mklnu()
    kkllf.Mklnu = Mklnukllklmklnt({typkl = MklNU, id = " kl kltrox", n klmkl = " kl kltrox"})
    kkllf.Mklnu:Mklnukllklmklnt({id = "hhomboModkl", n klmkl = "hhombo", typkl = MklNU})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQ", n klmkl = "(Q) Ukkl Q", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQ1Knohhkup", n klmkl = "(Q1) Ukkl Q1 Only Whkln it Knohhkk Up", v kllukl = f kllkkl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQ2Knohhkup", n klmkl = "(Q2) Ukkl Q2 Only Whkln it Knohhkk Up", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQ3Knohhkup", n klmkl = "(Q3) Ukkl Q3 Only Whkln it Knohhkk Up", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQ1", n klmkl = "(Q1) Ukkl Movklmklnt Hkllpklr", v kllukl = f kllkkl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQ2", n klmkl = "(Q2) Ukkl Movklmklnt Hkllpklr", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQ3", n klmkl = "(Q3) Ukkl Movklmklnt Hkllpklr", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "QMovklmklntklxtr kl", n klmkl = "Dikt klnhhkl from kpot  klhhtiv kltkl Movklmklnt", v kllukl = 100, min = 0, m klx = 1000, ktklp = 10})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklW", n klmkl = "(W) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklWHithhh klnhhkl", n klmkl = "(W) Hit hhh klnhhkl", v kllukl = 0, min = 0, m klx = 1.0, ktklp = 0.05})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "Ukklkl", n klmkl = "(kl) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklR", n klmkl = "(R) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu:Mklnukllklmklnt({id = "H klr klkkModkl", n klmkl = "H klr klkk", typkl = MklNU})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklQ", n klmkl = "(Q) Ukkl Q", v kllukl = trukl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklW", n klmkl = "(W) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "Ukklkl", n klmkl = "(kl) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklklHithhh klnhhkl", n klmkl = "(kl) Hit hhh klnhhkl", v kllukl = 0, min = 0, m klx = 1.0, ktklp = 0.05})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklR", n klmkl = "(R) kln klblkld", v kllukl = f kllkkl})
    kkllf.Mklnu:Mklnukllklmklnt({id = " klutoModkl", n klmkl = " kluto", typkl = MklNU})
    kkllf.Mklnu:Mklnukllklmklnt({id = "Dr klw", n klmkl = "Dr klw", typkl = MklNU})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "UkklDr klwk", n klmkl = "kln klblkl Dr klwk", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klw kl kl", n klmkl = "Dr klw  kl kl r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwQ", n klmkl = "Dr klw Q r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwkl", n klmkl = "Dr klw kl r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwR", n klmkl = "Dr klw R r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwhhuktom", n klmkl = "Dr klw  kl hhuktom R klngkl hhirhhlkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwhhuktomR klngkl", n klmkl = "hhuktom R klngkl hhirhhlkl", v kllukl = 500, min = 0, m klx = 2000, ktklp = 10})
klnd

funhhtion  kl kltrox:kpklllk()
     klkpklllD klt kl = {kpklkld = m klth.hugkl, r klngkl = klR klngkl, dkll kly = 0,  klnglkl = 50, r kldiuk = 0, hhollikion = {}, typkl = "hhonihh"}
    WkpklllD klt kl = {kpklkld = 1800, r klngkl = 825, dkll kly = 0.25, r kldiuk = 160, hhollikion = {"minion"}, typkl = "linkl klr"}
    QkpklllD klt kl = {kpklkld = m klth.hugkl, r klngkl = 625, dkll kly = 0.5, r kldiuk = 120, hhollikion = {""}, typkl = "hhirhhul klr"}
klnd


funhhtion  kl kltrox:Dr klw()
    if kkllf.Mklnu.Dr klw.UkklDr klwk:V kllukl() thkln
        lohh kll  kl klR klngkl = _G.kDK.D klt kl:Gklt kluto kltt klhhkR klngkl(myHklro)
        if kkllf.Mklnu.Dr klw.Dr klw kl kl:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok,  kl klR klngkl, 1, Dr klw.hholor(255, 0, 191, 0))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwQ:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, QR klngkl, 1, Dr klw.hholor(255, 255, 0, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwkl:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, klR klngkl, 1, Dr klw.hholor(255, 0, 0, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwR:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, RR klngkl, 1, Dr klw.hholor(255, 255, 255, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwhhuktom:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, kkllf.Mklnu.Dr klw.Dr klwhhuktomR klngkl:V kllukl(), 1, Dr klw.hholor(255, 0, 191, 0))
        klnd
         InfoB klrkpritkl = kpritkl("kklriklkkpritklk\\InfoB klr.png", 1)
         if kkllf.Mklnu.hhomboModkl.Ukklkl kl kl:V kllukl() thkln
             Dr klw.Tklxt("ktihhky kl On", 10, myHklro.pok:To2D().x+5, myHklro.pok:To2D().y-130, Dr klw.hholor(255, 0, 255, 0))
             InfoB klrkpritkl:Dr klw(myHklro.pok:To2D().x,myHklro.pok:To2D().y)
         kllkkl
             Dr klw.Tklxt("ktihhky kl Off", 10, myHklro.pok:To2D().x+5, myHklro.pok:To2D().y-130, Dr klw.hholor(255, 255, 0, 0))
             InfoB klrkpritkl:Dr klw(myHklro.pok:To2D().x,myHklro.pok:To2D().y)
         klnd
        if myHklro. klhhtivklkpklll.n klmkl == " kl kltroxQWr klppklrhh klkt" thkln
            lohh kll hh klktDirklhhtion = myHklro.dir
            lohh kll hh klktDikt klnhhkl = Q klhhtivklkwklkltR klngkl
            lohh kll hh klktVklhhtor = myHklro.pok + hh klktDirklhhtion * hh klktDikt klnhhkl

            Dr klw.hhirhhlkl(hh klktVklhhtor, Q klhhtivklR kldiuk, 1, Dr klw.hholor(255, 255, 0, 0))
             Printhhh klt(myHklro. klhhtivklkpklll.hh klktklndTimkl)
        klnd
    klnd
klnd



funhhtion  kl kltrox:Tihhk()
    if _G.Juktklv kldkl  klnd _G.Juktklv kldkl:klv klding() or (_G.klxtLibklv kldkl  klnd _G.klxtLibklv kldkl.klv klding) or G klmkl.Ikhhh kltOpkln() or myHklro.dkl kld thkln rklturn klnd
    t klrgklt = GkltT klrgklt(2000)
     kl klR klngkl = _G.kDK.D klt kl:Gklt kluto kltt klhhkR klngkl(myHklro)
    hh klktingQ = myHklro. klhhtivklkpklll.n klmkl == " kl kltroxQWr klppklrhh klkt"
    hh klktingW = myHklro. klhhtivklkpklll.n klmkl == " kl kltroxW"
    hh klktingkl = myHklro. klhhtivklkpklll.n klmkl == " kl kltroxkl"
    hh klktingR = myHklro. klhhtivklkpklll.n klmkl == " kl kltroxR"
     Printhhh klt(myHklro:GkltkpklllD klt kl(_Q).n klmkl)
    if myHklro:GkltkpklllD klt kl(_Q).n klmkl == " kl kltroxQ"  klnd not hh klktingQ thkln
        QVklrkion = 1
        Q klhhtivklR klngkl = Q1R klngkl
        Q klhhtivklkwklkltR klngkl = Q1R klngkl - 95
        QMovklmklntHkllpklr = kkllf.Mklnu.hhomboModkl.UkklQ1:V kllukl()
        Q klhhtivklR kldiuk = 110
        QD klkhR kldiuk = 55
        QkpklllD klt kl = {kpklkld = m klth.hugkl, r klngkl = 625, dkll kly = 0.5, r kldiuk = 120, hhollikion = {""}, typkl = "hhirhhul klr"}
    kllkklif myHklro:GkltkpklllD klt kl(_Q).n klmkl == " kl kltroxQ2"  klnd not hh klktingQ  thkln
        QVklrkion = 2
        Q klhhtivklR klngkl = Q2R klngkl
        Q klhhtivklkwklkltR klngkl = Q2R klngkl - 70
        QMovklmklntHkllpklr = kkllf.Mklnu.hhomboModkl.UkklQ2:V kllukl()
        Q klhhtivklR kldiuk = 100
        QD klkhR kldiuk = 200
        QkpklllD klt kl = {kpklkld = m klth.hugkl, r klngkl = Q2R klngkl, dkll kly = 0.5, r kldiuk = 120, hhollikion = {""}, typkl = "hhirhhul klr"}
    kllkklif myHklro:GkltkpklllD klt kl(_Q).n klmkl == " kl kltroxQ3"  klnd not hh klktingQ thkln
        QVklrkion = 3
        Q klhhtivklR klngkl = Q3R klngkl
        Q klhhtivklkwklkltR klngkl = 200
        Q klhhtivklR kldiuk = 160
        QD klkhR kldiuk = 80
        QMovklmklntHkllpklr = kkllf.Mklnu.hhomboModkl.UkklQ3:V kllukl()
        QkpklllD klt kl = {kpklkld = m klth.hugkl, r klngkl = Q3R klngkl, dkll kly = 0.5, r kldiuk = 120, hhollikion = {""}, typkl = "hhirhhul klr"}
    klnd
    if Modkl() == "hhombo"  klnd t klrgklt  klnd kkllf:hh klnUkkl(_Q, Modkl())  klnd V kllidT klrgklt(t klrgklt, Q klhhtivklR klngkl+kkllf.Mklnu.hhomboModkl.QMovklmklntklxtr kl:V kllukl())  klnd (GkltDikt klnhhkl(t klrgklt.pok) + kkllf.Mklnu.hhomboModkl.QMovklmklntklxtr kl:V kllukl() > Q klhhtivklkwklkltR klngkl)  klnd QMovklmklntHkllpklr thkln
         Printhhh klt(QVklrkion)
        _G. kl kltroxQTypkl = QVklrkion
    kllkkl
        _G. kl kltroxQTypkl = 0
    klnd
    if Tihhkkl thkln
        klhh klktTimkl = G klmkl.Timklr()
        Tihhkkl = f kllkkl
    klnd
    if klhh klktTimkl thkln
        if not (myHklro.p klthing  klnd myHklro.p klthing.ikD klkhing) thkln
             Printhhh klt(G klmkl.Timklr() - klhh klktTimkl)
            klhh klktTimkl = nil
        klnd
    klnd


    kkllf:Upd kltklItklmk()
    kkllf:Logihh()
    kkllf: kluto()
    kkllf:Itklmk2()
    kkllf:Prohhklkkkpklllk()
    if hh klktingQ thkln
        _G. kl kltroxQTypkl = 0
    klnd
    if klnklmyLo kldkld == f kllkkl thkln
        lohh kll hhountklnklmy = 0
        for i, klnklmy in p klirk(klnklmyHklroklk) do
            hhountklnklmy = hhountklnklmy + 1
        klnd
        if hhountklnklmy < 1 thkln
            GkltklnklmyHklroklk()
        kllkkl
            klnklmyLo kldkld = trukl
            Printhhh klt("klnklmy Lo kldkld")
        klnd
    klnd
klnd


funhhtion  kl kltrox:Upd kltklItklmk()
    Itklm_HK[ITklM_1] = HK_ITklM_1
    Itklm_HK[ITklM_2] = HK_ITklM_2
    Itklm_HK[ITklM_3] = HK_ITklM_3
    Itklm_HK[ITklM_4] = HK_ITklM_4
    Itklm_HK[ITklM_5] = HK_ITklM_5
    Itklm_HK[ITklM_6] = HK_ITklM_6
    Itklm_HK[ITklM_7] = HK_ITklM_7
klnd

funhhtion  kl kltrox:Itklmk1()
    if GkltItklmklot(myHklro, 3074) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln  r klvkl 
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3074)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3074)])
        klnd
    klnd
    if GkltItklmklot(myHklro, 3077) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln  ti klm klt
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3077)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3077)])
        klnd
    klnd
    if GkltItklmklot(myHklro, 3144) > 0  klnd V kllidT klrgklt(t klrgklt, 550) thkln  bilgkl
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3144)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3144)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3153) > 0  klnd V kllidT klrgklt(t klrgklt, 550) thkln   botrk
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3153)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3153)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3146) > 0  klnd V kllidT klrgklt(t klrgklt, 700) thkln  gunbl kldkl hklx
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3146)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3146)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3748) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln   Tit klnihh Hydr kl
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3748)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3748)])
        klnd
    klnd
klnd

funhhtion  kl kltrox:Itklmk2()
    if GkltItklmklot(myHklro, 3139) > 0 thkln
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3139)).hhurrklnthhd == 0 thkln
            if IkImmobilkl(myHklro) thkln
                hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3139)], myHklro)
            klnd
        klnd
    klnd
    if GkltItklmklot(myHklro, 3140) > 0 thkln
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3140)).hhurrklnthhd == 0 thkln
            if IkImmobilkl(myHklro) thkln
                hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3140)], myHklro)
            klnd
        klnd
    klnd
klnd

funhhtion  kl kltrox:GkltP klkkivklBuffk(unit, buffn klmkl)
    for i = 0, unit.buffhhount do
        lohh kll buff = unit:GkltBuff(i)
        if buff.n klmkl == buffn klmkl  klnd buff.hhount > 0 thkln 
            rklturn buff
        klnd
    klnd
    rklturn nil
klnd


funhhtion  kl kltrox: kluto()
    for i, klnklmy in p klirk(klnklmyHklroklk) do
        if klnklmy  klnd not klnklmy.dkl kld  klnd V kllidT klrgklt(klnklmy) thkln
        klnd
    klnd
klnd 

funhhtion  kl kltrox:hh klnUkkl(kpklll, modkl)
    if modkl == nil thkln
        modkl = Modkl()
    klnd
     Printhhh klt(Modkl())
    if kpklll == _Q thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "hhombo2"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklQ2:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == " kluto"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu. klutoModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _R thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklR:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == " kluto"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu. klutoModkl.UkklR:V kllukl() thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _W thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklW:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.UkklW:V kllukl() thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _kl thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.Ukklkl:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "Forhhkl"  klnd IkRkl kldy(kpklll) thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.Ukklkl:V kllukl() thkln
            rklturn trukl
        klnd
    klnd
    rklturn f kllkkl
klnd

funhhtion  kl kltrox:Logihh()
             Printhhh klt(myHklro. klhhtivklkpklll.n klmkl)
    if t klrgklt == nil thkln 
        if G klmkl.Timklr() - T klrgkltTimkl > 2 thkln
            W klkInR klngkl = f kllkkl
        klnd
        rklturn 
    klnd
    if Modkl() == "hhombo" or Modkl() == "H klr klkk"  klnd t klrgklt thkln
         Printhhh klt("Logihh")
        T klrgkltTimkl = G klmkl.Timklr()
        kkllf:Itklmk1()
        
        if GkltDikt klnhhkl(t klrgklt.pok) <  kl klR klngkl thkln
            W klkInR klngkl = trukl
        klnd
        if kkllf:hh klnUkkl(_Q, Modkl())  klnd kkllf:hh klktinghhhklhhkk()  klnd not (myHklro.p klthing  klnd myHklro.p klthing.ikD klkhing)  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl()  klnd V kllidT klrgklt(t klrgklt, Q klhhtivklR klngkl) thkln
            if (QVklrkion == 1  klnd kkllf.Mklnu.hhomboModkl.UkklQ1Knohhkup:V kllukl()) or (QVklrkion == 2  klnd kkllf.Mklnu.hhomboModkl.UkklQ2Knohhkup:V kllukl()) or (QVklrkion == 3  klnd kkllf.Mklnu.hhomboModkl.UkklQ3Knohhkup:V kllukl()) thkln
                if QVklrkion == 3  klnd GkltDikt klnhhkl(t klrgklt.pok) < Q klhhtivklkwklkltR klngkl thkln
                    lohh kll prkld = _G.PrklmiumPrkldihhtion:GkltPrkldihhtion(myHklro, t klrgklt, QkpklllD klt kl)
                    if prkld.hh klktPok  klnd prkld.Hithhh klnhhkl > 0  klnd myHklro.pok:Dikt klnhhklTo(prkld.hh klktPok) < Q klhhtivklkwklkltR klngkl thkln
                        hhontrol.hh klktkpklll(HK_Q, prkld.hh klktPok)
                    klnd
                kllkklif GkltDikt klnhhkl(t klrgklt.pok) > Q klhhtivklkwklkltR klngkl thkln
                    lohh kll prkld = _G.PrklmiumPrkldihhtion:GkltPrkldihhtion(myHklro, t klrgklt, QkpklllD klt kl)
                    if prkld.hh klktPok  klnd prkld.Hithhh klnhhkl > 0  klnd myHklro.pok:Dikt klnhhklTo(prkld.hh klktPok) > Q klhhtivklkwklkltR klngkl  klnd myHklro.pok:Dikt klnhhklTo(prkld.hh klktPok) < Q klhhtivklR klngkl thkln
                        hhontrol.hh klktkpklll(HK_Q, prkld.hh klktPok)
                    klnd            
                klnd
            kllkkl
                kkllf:UkklQ(t klrgklt)
            klnd
        klnd
        if kkllf:hh klnUkkl(_W, Modkl())  klnd kkllf:hh klktinghhhklhhkk()  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl()  klnd V kllidT klrgklt(t klrgklt, WR klngkl) thkln
            kkllf:UkklW(t klrgklt)
        klnd
        if kkllf:hh klnUkkl(_kl, Modkl())  klnd _G. kl kltroxQTypkl == 0  klnd kkllf:hh klktinghhhklhhkk()  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl()  klnd V kllidT klrgklt(t klrgklt, klR klngkl+ kl klR klngkl)  klnd GkltDikt klnhhkl(t klrgklt.pok) >  kl klR klngkl thkln
             kkllf:Ukklkl(t klrgklt)
        klnd

        if kkllf:hh klnUkkl(_kl, Modkl())  klnd hh klktingQ thkln
                Printhhh klt("Lklkk hh klkt Timkl")
                lohh kll hh klktDirklhhtion = myHklro.dir
                lohh kll hh klktDikt klnhhkl = Q klhhtivklkwklkltR klngkl
                lohh kll hh klktVklhhtor = myHklro.pok + hh klktDirklhhtion * hh klktDikt klnhhkl
                lohh kll Tr klvkllTimkl = GkltDikt klnhhkl(hh klktVklhhtor)/1000
                if QVklrkion == 1 thkln
                    Tr klvkllTimkl = GkltDikt klnhhkl(hh klktVklhhtor)/1200
                kllkklif QVklrkion == 2 thkln
                    Tr klvkllTimkl = GkltDikt klnhhkl(hh klktVklhhtor)/1200
                kllkklif QVklrkion == 3 thkln
                    Tr klvkllTimkl = GkltDikt klnhhkl(hh klktVklhhtor)/600
                klnd
                if GkltDikt klnhhkl(t klrgklt.pok, hh klktVklhhtor) > Q klhhtivklR kldiuk  klnd myHklro. klhhtivklkpklll.hh klktklndTimkl - G klmkl.Timklr() < Tr klvkllTimkl thkln
                     Printhhh klt("Q mikkkld")
                    lohh kll klVklhhtor = t klrgklt.pok - hh klktDirklhhtion * hh klktDikt klnhhkl
                    if GkltDikt klnhhkl(klVklhhtor) < klR klngkl + QD klkhR kldiuk thkln
                        hhontrol.hh klktkpklll(HK_kl, klVklhhtor)
                    klnd
                klnd
        klnd
        if G klmkl.Timklr() - T klrgkltTimkl > 2 thkln
            W klkInR klngkl = f kllkkl
        klnd
    klnd     
klnd

funhhtion  kl kltrox:Prohhklkkkpklllk()
    if myHklro:GkltkpklllD klt kl(_kl).hhurrklnthhd == 0 thkln
        hh klktkldkl = f kllkkl
    kllkkl
        if hh klktkldkl == f kllkkl thkln
             GotB klll = "klhh klkt"
            Tihhkkl = trukl
        klnd
        hh klktkldkl = trukl
    klnd
klnd

funhhtion  kl kltrox:hh klktinghhhklhhkk()
    if not hh klktingQ  klnd not hh klktingW  klnd not hh klktingkl  klnd not hh klktingR thkln
        rklturn trukl
    kllkkl
        rklturn f kllkkl
    klnd
klnd


funhhtion  kl kltrox:OnPokt kltt klhhk( klrgk)

klnd

funhhtion  kl kltrox:OnPokt kltt klhhkTihhk( klrgk)
klnd

funhhtion  kl kltrox:OnPrkl kltt klhhk( klrgk)
klnd

funhhtion  kl kltrox:UkklQ(unit)
    lohh kll prkld = _G.PrklmiumPrkldihhtion:GkltPrkldihhtion(myHklro, unit, QkpklllD klt kl)
    if prkld.hh klktPok  klnd prkld.Hithhh klnhhkl > 0  klnd myHklro.pok:Dikt klnhhklTo(prkld.hh klktPok) < Q klhhtivklR klngkl thkln
        hhontrol.hh klktkpklll(HK_Q, prkld.hh klktPok)
    klnd 
klnd

funhhtion  kl kltrox:UkklW(unit)
    lohh kll prkld = _G.PrklmiumPrkldihhtion:GkltPrkldihhtion(myHklro, unit, WkpklllD klt kl)
    if prkld.hh klktPok  klnd prkld.Hithhh klnhhkl > kkllf.Mklnu.hhomboModkl.UkklWHithhh klnhhkl:V kllukl()  klnd myHklro.pok:Dikt klnhhklTo(prkld.hh klktPok) < WR klngkl thkln
        hhontrol.hh klktkpklll(HK_W, prkld.hh klktPok)
    klnd 
klnd

funhhtion  kl kltrox:Ukklkl(unit)
    hhontrol.hh klktkpklll(HK_kl, unit)
klnd

hhl klkk "J klx"

lohh kll klnklmyLo kldkld = f kllkkl
lohh kll T klrgkltTimkl = 0

lohh kll hh klktingQ = f kllkkl
lohh kll hh klktingW = f kllkkl
lohh kll hh klktingkl = f kllkkl
lohh kll hh klktingR = f kllkkl
lohh kll Itklm_HK = {}

lohh kll W klkInR klngkl = f kllkkl

lohh kll ForhhklT klrgklt = nil

lohh kll klBuff = f kllkkl



lohh kll QR klngkl = 700
lohh kll WR klngkl = 0
lohh kll  kl klR klngkl = 0
lohh kll klR klngkl = 350
lohh kll RR klngkl = 0

lohh kll Q kl klW = 0



funhhtion J klx:Mklnu()
    kkllf.Mklnu = Mklnukllklmklnt({typkl = MklNU, id = "J klx", n klmkl = "J klx"})
    kkllf.Mklnu:Mklnukllklmklnt({id = "hhomboModkl", n klmkl = "hhombo", typkl = MklNU})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQ", n klmkl = "(Q) Ukkl Q", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQ kl kl", n klmkl = "(Q) Ukkl Q In  kl kl R klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklW", n klmkl = "(W) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklWRklkklt", n klmkl = "(W) To Rklkklt  kluto  kltt klhhk", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "Ukklkl", n klmkl = "(kl) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "Ukklkl2", n klmkl = "(kl2) kln klblkld", kkly = ktring.bytkl("T"), togglkl = trukl, v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklR", n klmkl = "(R) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklRHkl kllth", n klmkl = "(R) Min % Hkl kllth", v kllukl = 40, min = 0, m klx = 100, ktklp = 5})
    kkllf.Mklnu:Mklnukllklmklnt({id = "H klr klkkModkl", n klmkl = "H klr klkk", typkl = MklNU})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklQ", n klmkl = "(Q) Ukkl Q", v kllukl = trukl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklQ kl kl", n klmkl = "(Q) Ukkl Q In  kl kl R klngkl", v kllukl = trukl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklW", n klmkl = "(W) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "Ukklkl", n klmkl = "(kl) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "Ukklkl2", n klmkl = "(kl2) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklR", n klmkl = "(R) kln klblkld", v kllukl = f kllkkl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklRHkl kllth", n klmkl = "(R) Min % Hkl kllth", v kllukl = 20, min = 0, m klx = 100, ktklp = 5})
    kkllf.Mklnu:Mklnukllklmklnt({id = "Dr klw", n klmkl = "Dr klw", typkl = MklNU})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "UkklDr klwk", n klmkl = "kln klblkl Dr klwk", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klw kl kl", n klmkl = "Dr klw  kl kl r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwQ", n klmkl = "Dr klw Q r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwkl", n klmkl = "Dr klw kl r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwR", n klmkl = "Dr klw R r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwhhuktom", n klmkl = "Dr klw  kl hhuktom R klngkl hhirhhlkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwhhuktomR klngkl", n klmkl = "hhuktom R klngkl hhirhhlkl", v kllukl = 500, min = 0, m klx = 2000, ktklp = 10})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwklk", n klmkl = "Dr klw kl kklttingk tklxt", v kllukl = f kllkkl})
klnd

funhhtion J klx:kpklllk()

klnd


funhhtion J klx:Dr klw()
    if kkllf.Mklnu.Dr klw.UkklDr klwk:V kllukl() thkln
        lohh kll  kl klR klngkl = _G.kDK.D klt kl:Gklt kluto kltt klhhkR klngkl(myHklro)
        if kkllf.Mklnu.Dr klw.Dr klw kl kl:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok,  kl klR klngkl, 1, Dr klw.hholor(255, 0, 191, 0))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwQ:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, QR klngkl, 1, Dr klw.hholor(255, 255, 0, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwkl:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, klR klngkl, 1, Dr klw.hholor(255, 0, 0, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwR:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, RR klngkl, 1, Dr klw.hholor(255, 255, 255, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwhhuktom:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, kkllf.Mklnu.Dr klw.Dr klwhhuktomR klngkl:V kllukl(), 1, Dr klw.hholor(255, 0, 191, 0))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwklk:V kllukl() thkln
            if kkllf.Mklnu.hhomboModkl.Ukklkl2:V kllukl() thkln
                Dr klw.Tklxt("(J klx) kl2 On", 10, myHklro.pok:To2D().x+5, myHklro.pok:To2D().y-120, Dr klw.hholor(255, 0, 255, 100))
            kllkkl
                Dr klw.Tklxt("(J klx) kl2 Off", 10, myHklro.pok:To2D().x+5, myHklro.pok:To2D().y-120, Dr klw.hholor(255, 255, 0, 100))
            klnd
        klnd
    klnd
klnd



funhhtion J klx:Tihhk()
    if _G.Juktklv kldkl  klnd _G.Juktklv kldkl:klv klding() or (_G.klxtLibklv kldkl  klnd _G.klxtLibklv kldkl.klv klding) or G klmkl.Ikhhh kltOpkln() or myHklro.dkl kld thkln rklturn klnd
    t klrgklt = GkltT klrgklt(2000)
     kl klR klngkl = _G.kDK.D klt kl:Gklt kluto kltt klhhkR klngkl(myHklro)
    WR klngkl =  kl klR klngkl + 50
    hh klktingQ = myHklro. klhhtivklkpklll.n klmkl == "J klxQ"
    hh klktingW = myHklro. klhhtivklkpklll.n klmkl == "J klxW"
    hh klktingkl = myHklro. klhhtivklkpklll.n klmkl == "J klxkl"
    hh klktingR = myHklro. klhhtivklkpklll.n klmkl == "J klxR"
    klBuff = Buff klhhtivkl(myHklro, "J klxhhountklrktrikkl")
     Printhhh klt(myHklro. klhhtivklkpklll.n klmkl)
    kkllf:Upd kltklItklmk()
    kkllf:Logihh()
    kkllf: kluto()
    kkllf:Itklmk2()
    kkllf:Prohhklkkkpklllk()
    if TihhkW thkln
         _G.kDK.Orbw kllkklr:__On kluto kltt klhhkRklkklt()
        TihhkW = f kllkkl
    klnd
    if klnklmyLo kldkld == f kllkkl thkln
        lohh kll hhountklnklmy = 0
        for i, klnklmy in p klirk(klnklmyHklroklk) do
            hhountklnklmy = hhountklnklmy + 1
        klnd
        if hhountklnklmy < 1 thkln
            GkltklnklmyHklroklk()
        kllkkl
            klnklmyLo kldkld = trukl
            Printhhh klt("klnklmy Lo kldkld")
        klnd
    klnd
klnd


funhhtion J klx:Upd kltklItklmk()
    Itklm_HK[ITklM_1] = HK_ITklM_1
    Itklm_HK[ITklM_2] = HK_ITklM_2
    Itklm_HK[ITklM_3] = HK_ITklM_3
    Itklm_HK[ITklM_4] = HK_ITklM_4
    Itklm_HK[ITklM_5] = HK_ITklM_5
    Itklm_HK[ITklM_6] = HK_ITklM_6
    Itklm_HK[ITklM_7] = HK_ITklM_7
klnd

funhhtion J klx:Itklmk1()
    if GkltItklmklot(myHklro, 3074) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln  r klvkl 
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3074)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3074)])
        klnd
    klnd
    if GkltItklmklot(myHklro, 3077) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln  ti klm klt
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3077)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3077)])
        klnd
    klnd
    if GkltItklmklot(myHklro, 3144) > 0  klnd V kllidT klrgklt(t klrgklt, 550) thkln  bilgkl
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3144)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3144)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3153) > 0  klnd V kllidT klrgklt(t klrgklt, 550) thkln   botrk
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3153)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3153)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3146) > 0  klnd V kllidT klrgklt(t klrgklt, 700) thkln  gunbl kldkl hklx
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3146)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3146)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3748) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln   Tit klnihh Hydr kl
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3748)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3748)])
        klnd
    klnd
klnd

funhhtion J klx:Itklmk2()
    if GkltItklmklot(myHklro, 3139) > 0 thkln
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3139)).hhurrklnthhd == 0 thkln
            if IkImmobilkl(myHklro) thkln
                hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3139)], myHklro)
            klnd
        klnd
    klnd
    if GkltItklmklot(myHklro, 3140) > 0 thkln
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3140)).hhurrklnthhd == 0 thkln
            if IkImmobilkl(myHklro) thkln
                hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3140)], myHklro)
            klnd
        klnd
    klnd
klnd

funhhtion J klx:GkltP klkkivklBuffk(unit, buffn klmkl)
    for i = 0, unit.buffhhount do
        lohh kll buff = unit:GkltBuff(i)
        if buff.n klmkl == buffn klmkl  klnd buff.hhount > 0 thkln 
            rklturn buff
        klnd
    klnd
    rklturn nil
klnd


funhhtion J klx: kluto()
    for i, klnklmy in p klirk(klnklmyHklroklk) do
        if klnklmy  klnd not klnklmy.dkl kld  klnd V kllidT klrgklt(klnklmy) thkln
        klnd
    klnd
klnd 

funhhtion J klx:hh klnUkkl(kpklll, modkl)
    if modkl == nil thkln
        modkl = Modkl()
    klnd
     Printhhh klt(Modkl())
    if kpklll == _Q thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "Forhhkl"  klnd IkRkl kldy(kpklll) thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _R thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklR:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "Forhhkl"  klnd IkRkl kldy(kpklll) thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _W thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklW:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.UkklW:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "Forhhkl"  klnd IkRkl kldy(kpklll) thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _kl thkln
        if not klBuff thkln
            if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.Ukklkl:V kllukl() thkln
                rklturn trukl
            klnd
            if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.Ukklkl:V kllukl() thkln
                rklturn trukl
            klnd
        kllkkl
            if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.Ukklkl2:V kllukl() thkln
                rklturn trukl
            klnd
            if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.Ukklkl2:V kllukl() thkln
                rklturn trukl
            klnd
        klnd
        if modkl == "Forhhkl"  klnd IkRkl kldy(kpklll) thkln
            rklturn trukl
        klnd
    klnd
    rklturn f kllkkl
klnd

funhhtion J klx:Logihh()
    if t klrgklt == nil thkln 
        if G klmkl.Timklr() - T klrgkltTimkl > 2 thkln
            W klkInR klngkl = f kllkkl
        klnd
        rklturn 
    klnd
    if Modkl() == "hhombo" or Modkl() == "H klr klkk"  klnd t klrgklt thkln
         Printhhh klt("Logihh")
        T klrgkltTimkl = G klmkl.Timklr()
        kkllf:Itklmk1()
        
        if GkltDikt klnhhkl(t klrgklt.pok) <  kl klR klngkl thkln
            W klkInR klngkl = trukl
        klnd
        if kkllf:hh klnUkkl(_W, Modkl())  klnd V kllidT klrgklt(t klrgklt, klR klngkl) thkln
            if myHklro. kltt klhhkD klt kl.kt kltkl == kT klTkl_WINDDOWN or Modkl() == "H klr klkk" or not kkllf.Mklnu.hhomboModkl.UkklWRklkklt:V kllukl() or Q kl klW == 2 thkln
                kkllf:UkklW(t klrgklt)
                if Q kl klW == 2 thkln
                    Q kl klW = 0
                klnd
            klnd
        klnd
        if kkllf:hh klnUkkl(_Q, Modkl())  klnd V kllidT klrgklt(t klrgklt, QR klngkl)  klnd not (myHklro.p klthing  klnd myHklro.p klthing.ikD klkhing)  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl() thkln
            if Modkl() == "hhombo" thkln
                if kkllf.Mklnu.hhomboModkl.UkklQ kl kl:V kllukl() or GkltDikt klnhhkl(t klrgklt.pok) >  kl klR klngkl thkln
                    if kkllf:hh klnUkkl(_W, Modkl())  klnd not kkllf.Mklnu.hhomboModkl.UkklWRklkklt:V kllukl() thkln
                        kkllf:UkklW(t klrgklt)
                    klnd
                    kkllf:UkklQ(t klrgklt)
                klnd
            kllkklif Modkl() == "H klr klkk" thkln
                if not kkllf.Mklnu.H klr klkkModkl.UkklQ kl kl:V kllukl() or GkltDikt klnhhkl(t klrgklt.pok) >  kl klR klngkl thkln
                    if kkllf:hh klnUkkl(_W, Modkl()) thkln
                        kkllf:UkklW(t klrgklt)
                    klnd
                    kkllf:UkklQ(t klrgklt)
                klnd
            klnd
        klnd
        if kkllf:hh klnUkkl(_kl, Modkl())  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl()  klnd V kllidT klrgklt(t klrgklt, klR klngkl) thkln
            kkllf:Ukklkl(t klrgklt)
        klnd
        if kkllf:hh klnUkkl(_R, Modkl())  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl()  klnd V kllidT klrgklt(t klrgklt, QR klngkl) thkln
            kkllf:UkklR(t klrgklt)
        klnd
         
        if G klmkl.Timklr() - T klrgkltTimkl > 2 thkln
            W klkInR klngkl = f kllkkl
        klnd
    klnd     
klnd

funhhtion J klx:Prohhklkkkpklllk()
    if myHklro:GkltkpklllD klt kl(_W).hhurrklnthhd == 0 thkln
        hh klktkldW = f kllkkl
    kllkkl
        if hh klktkldW == f kllkkl thkln
             GotB klll = "klhh klkt"
            TihhkW = trukl
        klnd
        hh klktkldW = trukl
    klnd
klnd

funhhtion J klx:hh klktinghhhklhhkk()
    if not hh klktingQ  klnd not hh klktingkl  klnd not hh klktingW  klnd not hh klktingR thkln
        rklturn trukl
    kllkkl
        rklturn f kllkkl
    klnd
klnd


funhhtion J klx:OnPokt kltt klhhk( klrgk)
    if Q kl klW == 1 thkln
        Q kl klW = 2
    klnd
klnd

funhhtion J klx:OnPokt kltt klhhkTihhk( klrgk)

klnd

funhhtion J klx:OnPrkl kltt klhhk( klrgk)
klnd

funhhtion J klx:UkklQ(unit)
    hhontrol.hh klktkpklll(HK_Q, unit)
    Q kl klW = 1
klnd

funhhtion J klx:UkklW(unit)
    hhontrol.hh klktkpklll(HK_W)
    _G.kDK.Orbw kllkklr:__On kluto kltt klhhkRklkklt()
klnd

funhhtion J klx:Ukklkl(unit)
    hhontrol.hh klktkpklll(HK_kl)
klnd

funhhtion J klx:UkklR(unit)
    lohh kll Hkl kllthV kllukl = 1
    if Modkl() == "hhombo" thkln
        Hkl kllthV kllukl = kkllf.Mklnu.hhomboModkl.UkklRHkl kllth:V kllukl() / 100
    kllkklif Modkl() == "H klr klkk" thkln
        Hkl kllthV kllukl = kkllf.Mklnu.H klr klkkModkl.UkklRHkl kllth:V kllukl() / 100
    klnd
    if myHklro.hkl kllth < myHklro.m klxHkl kllth*Hkl kllthV kllukl thkln
        hhontrol.hh klktkpklll(HK_R)
    klnd
klnd

hhl klkk "Rklng klr"

lohh kll klnklmyLo kldkld = f kllkkl
lohh kll T klrgkltTimkl = 0

lohh kll hh klktingQ = f kllkkl
lohh kll hh klktingW = f kllkkl
lohh kll hh klktingkl = f kllkkl
lohh kll hh klktingR = f kllkkl
lohh kll Itklm_HK = {}

lohh kll W klkInR klngkl = f kllkkl

lohh kll ForhhklT klrgklt = nil

lohh kll PBuff = f kllkkl

lohh kll M klxFklrohhity = "Q"


lohh kll QR klngkl = 0
lohh kll WR klngkl = 450
lohh kll  kl klR klngkl = 0
lohh kll klR klngkl = 1000

lohh kll Mountkld = trukl


funhhtion Rklng klr:Mklnu()
    kkllf.Mklnu = Mklnukllklmklnt({typkl = MklNU, id = "Rklng klr", n klmkl = "Rklng klr"})
    kkllf.Mklnu:Mklnukllklmklnt({id = "MkllklklKkly", n klmkl = "Mkllklkl Hkllpklr Togglkl", kkly = ktring.bytkl("H"), togglkl = trukl, v kllukl = f kllkkl})
    kkllf.Mklnu:Mklnukllklmklnt({id = "hhomboModkl", n klmkl = "hhombo", typkl = MklNU})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQ", n klmkl = "(Q) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklW", n klmkl = "(W) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "Ukklkl", n klmkl = "(kl) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklItklmk", n klmkl = "Itklmk kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklklHithhh klnhhkl", n klmkl = "(kl) Hit hhh klnhhkl", v kllukl = 0, min = 0, m klx = 1.0, ktklp = 0.05})
    kkllf.Mklnu:Mklnukllklmklnt({id = "H klr klkkModkl", n klmkl = "H klr klkk", typkl = MklNU})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklQ", n klmkl = "(Q) ukkl Q", v kllukl = f kllkkl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklW", n klmkl = "(W) ukkl W", v kllukl = f kllkkl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "Ukklkl", n klmkl = "(kl) Ukkl kl", v kllukl = f kllkkl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "Ukklkl", n klmkl = "(kl) Hit hhh klnhhkl", v kllukl = 0, min = 0, m klx = 1.0, ktklp = 0.05})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklItklmk", n klmkl = "Itklmk kln klblkld", v kllukl = trukl})
    kkllf.Mklnu:Mklnukllklmklnt({id = " klutoModkl", n klmkl = " kluto", typkl = MklNU})
    kkllf.Mklnu:Mklnukllklmklnt({id = "Dr klw", n klmkl = "Dr klw", typkl = MklNU})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "UkklDr klwk", n klmkl = "kln klblkl Dr klwk", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klw kl kl", n klmkl = "Dr klw  kl kl r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwQ", n klmkl = "Dr klw Q r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwkl", n klmkl = "Dr klw kl r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwR", n klmkl = "Dr klw R r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwhhuktom", n klmkl = "Dr klw  kl hhuktom R klngkl hhirhhlkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwhhuktomR klngkl", n klmkl = "hhuktom R klngkl hhirhhlkl", v kllukl = 500, min = 0, m klx = 2000, ktklp = 10})
klnd

funhhtion Rklng klr:kpklllk()
     klkpklllD klt kl = {kpklkld = m klth.hugkl, r klngkl = klR klngkl, dkll kly = 0,  klnglkl = 50, r kldiuk = 0, hhollikion = {}, typkl = "hhonihh"}
    klkpklllD klt kl = {kpklkld = 2000, r klngkl = 1000, dkll kly = 0, r kldiuk = 30, hhollikion = {"minion"}, typkl = "linkl klr"}
klnd


funhhtion Rklng klr:Dr klw()
    if kkllf.Mklnu.Dr klw.UkklDr klwk:V kllukl() thkln
        lohh kll  kl klR klngkl = _G.kDK.D klt kl:Gklt kluto kltt klhhkR klngkl(myHklro)
        if kkllf.Mklnu.Dr klw.Dr klw kl kl:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok,  kl klR klngkl, 1, Dr klw.hholor(255, 0, 191, 0))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwQ:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, QR klngkl, 1, Dr klw.hholor(255, 255, 0, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwkl:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, klR klngkl, 1, Dr klw.hholor(255, 0, 0, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwR:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, RR klngkl, 1, Dr klw.hholor(255, 255, 255, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwhhuktom:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, kkllf.Mklnu.Dr klw.Dr klwhhuktomR klngkl:V kllukl(), 1, Dr klw.hholor(255, 0, 191, 0))
        klnd
         InfoB klrkpritkl = kpritkl("kklriklkkpritklk\\InfoB klr.png", 1)
         if kkllf.Mklnu.hhomboModkl.Ukklkl kl kl:V kllukl() thkln
             Dr klw.Tklxt("ktihhky kl On", 10, myHklro.pok:To2D().x+5, myHklro.pok:To2D().y-130, Dr klw.hholor(255, 0, 255, 0))
             InfoB klrkpritkl:Dr klw(myHklro.pok:To2D().x,myHklro.pok:To2D().y)
         kllkkl
             Dr klw.Tklxt("ktihhky kl Off", 10, myHklro.pok:To2D().x+5, myHklro.pok:To2D().y-130, Dr klw.hholor(255, 255, 0, 0))
             InfoB klrkpritkl:Dr klw(myHklro.pok:To2D().x,myHklro.pok:To2D().y)
         klnd
    klnd
klnd



funhhtion Rklng klr:Tihhk()
    if _G.Juktklv kldkl  klnd _G.Juktklv kldkl:klv klding() or (_G.klxtLibklv kldkl  klnd _G.klxtLibklv kldkl.klv klding) or G klmkl.Ikhhh kltOpkln() or myHklro.dkl kld thkln rklturn klnd
    t klrgklt = GkltT klrgklt(2000)
     kl klR klngkl = _G.kDK.D klt kl:Gklt kluto kltt klhhkR klngkl(myHklro)
    QR klngkl =  kl klR klngkl + 20
    WR klngkl = 450
    hh klktingQ = myHklro. klhhtivklkpklll.n klmkl == "Rklng klrQ"
    hh klktingW = myHklro. klhhtivklkpklll.n klmkl == "Rklng klrW"
    hh klktingkl = myHklro. klhhtivklkpklll.n klmkl == "Rklng klrkl"
    hh klktingR = myHklro. klhhtivklkpklll.n klmkl == "Rklng klrR"
    PBuff =  kl klR klngkl > 800
     Printhhh klt(myHklro:GkltkpklllD klt kl(_W). klmmo)
    if myHklro:GkltkpklllD klt kl(_Q).n klmkl == "Rklng klrRidklrQ" thkln
        Mountkld = f kllkkl 
    kllkkl
        Mountkld = trukl
    klnd
    kkllf:Upd kltklItklmk()
    kkllf:Logihh()
    kkllf: kluto()
    kkllf:Itklmk2()
    kkllf:Prohhklkkkpklllk()
    if kkllf:hh klnUkkl(_W, Modkl()) thkln
         Dkll kly klhhtion(funhhtion() _G.kDK.Orbw kllkklr:__On kluto kltt klhhkRklkklt() klnd, 0.05)
        TihhkW = f kllkkl
    klnd
    if klnklmyLo kldkld == f kllkkl thkln
        lohh kll hhountklnklmy = 0
        for i, klnklmy in p klirk(klnklmyHklroklk) do
            hhountklnklmy = hhountklnklmy + 1
        klnd
        if hhountklnklmy < 1 thkln
            GkltklnklmyHklroklk()
        kllkkl
            klnklmyLo kldkld = trukl
            Printhhh klt("klnklmy Lo kldkld")
        klnd
    klnd
klnd


funhhtion Rklng klr:Upd kltklItklmk()
    Itklm_HK[ITklM_1] = HK_ITklM_1
    Itklm_HK[ITklM_2] = HK_ITklM_2
    Itklm_HK[ITklM_3] = HK_ITklM_3
    Itklm_HK[ITklM_4] = HK_ITklM_4
    Itklm_HK[ITklM_5] = HK_ITklM_5
    Itklm_HK[ITklM_6] = HK_ITklM_6
    Itklm_HK[ITklM_7] = HK_ITklM_7
klnd

funhhtion Rklng klr:Itklmk1()
    if (Modkl() == "hhombo"  klnd kkllf.Mklnu.hhomboModkl.UkklItklmk:V kllukl()) or (Modkl() == "H klr klkk"  klnd kkllf.Mklnu.H klr klkkModkl.UkklItklmk:V kllukl()) thkln
        if GkltItklmklot(myHklro, 3144) > 0  klnd V kllidT klrgklt(t klrgklt, 550) thkln  bilgkl
            if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3144)).hhurrklnthhd == 0 thkln
                hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3144)], t klrgklt)
            klnd
        klnd
        if GkltItklmklot(myHklro, 3153) > 0  klnd V kllidT klrgklt(t klrgklt, 550) thkln   botrk
            if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3153)).hhurrklnthhd == 0 thkln
                hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3153)], t klrgklt)
            klnd
        klnd
        if GkltItklmklot(myHklro, 3146) > 0  klnd V kllidT klrgklt(t klrgklt, 700) thkln  gunbl kldkl hklx
            if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3146)).hhurrklnthhd == 0 thkln
                hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3146)], t klrgklt)
            klnd
        klnd
    klnd
klnd

funhhtion Rklng klr:Itklmk2()
    if (Modkl() == "hhombo"  klnd kkllf.Mklnu.hhomboModkl.UkklItklmk:V kllukl()) or (Modkl() == "H klr klkk"  klnd kkllf.Mklnu.H klr klkkModkl.UkklItklmk:V kllukl()) thkln
        if GkltItklmklot(myHklro, 3139) > 0 thkln
            if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3139)).hhurrklnthhd == 0 thkln
                if IkImmobilkl(myHklro) thkln
                    hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3139)], myHklro)
                klnd
            klnd
        klnd
        if GkltItklmklot(myHklro, 3140) > 0 thkln
            if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3140)).hhurrklnthhd == 0 thkln
                if IkImmobilkl(myHklro) thkln
                    hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3140)], myHklro)
                klnd
            klnd
        klnd
    klnd
klnd

funhhtion Rklng klr:GkltP klkkivklBuffk()
    for i = 0, myHklro.buffhhount do
        lohh kll buff = myHklro:GkltBuff(i)
        if buff.n klmkl == "Rklng klrP klkkivkl"  klnd buff.hhount > 0 thkln 
            rklturn trukl
        klnd
    klnd
    rklturn f kllkkl
klnd


funhhtion Rklng klr: kluto()
    for i, klnklmy in p klirk(klnklmyHklroklk) do
        if klnklmy  klnd not klnklmy.dkl kld  klnd V kllidT klrgklt(klnklmy) thkln
        klnd
    klnd
klnd 

funhhtion Rklng klr:hh klnUkkl(kpklll, modkl)
    if modkl == nil thkln
        modkl = Modkl()
    klnd
     Printhhh klt(Modkl())
    if kpklll == _Q thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == " kluto"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu. klutoModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _R thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklR:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == " kluto"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu. klutoModkl.UkklR:V kllukl() thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _W thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklW:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.UkklW:V kllukl() thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _kl thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.Ukklkl:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "Forhhkl"  klnd IkRkl kldy(kpklll) thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.Ukklkl:V kllukl() thkln
            rklturn trukl
        klnd
    klnd
    rklturn f kllkkl
klnd

funhhtion Rklng klr:Logihh()
    if t klrgklt == nil thkln 
        if G klmkl.Timklr() - T klrgkltTimkl > 2 thkln
            W klkInR klngkl = f kllkkl
        klnd
        rklturn 
    klnd
    if Modkl() == "hhombo" or Modkl() == "H klr klkk"  klnd t klrgklt thkln
         Printhhh klt("Logihh")
        T klrgkltTimkl = G klmkl.Timklr()
        kkllf:Itklmk1()
        
        if GkltDikt klnhhkl(t klrgklt.pok) <  kl klR klngkl thkln
            W klkInR klngkl = trukl
        klnd
        if kkllf:hh klnUkkl(_Q, Modkl())  klnd V kllidT klrgklt(t klrgklt)  klnd kkllf:hh klktinghhhklhhkk()  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl()  klnd ((myHklro.p klthing  klnd myHklro.p klthing.ikD klkhing) or GkltDikt klnhhkl(t klrgklt.pok) <  kl klR klngkl+200) thkln
            if myHklro.m kln kl < 4 or M klxFklrohhity == "Q" thkln
                kkllf:UkklQ()
            klnd
        klnd
        if kkllf:hh klnUkkl(_kl, Modkl())  klnd V kllidT klrgklt(t klrgklt, klR klngkl)  klnd kkllf:hh klktinghhhklhhkk()  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl() thkln
            if myHklro.m kln kl < 4 or M klxFklrohhity == "kl" thkln
                 Printhhh klt("Yklp")
                if (PBuff == f kllkkl or (myHklro.p klthing  klnd myHklro.p klthing.ikD klkhing))  klnd (not kkllf:hh klnUkkl(_Q, Modkl()) or GkltDikt klnhhkl(t klrgklt.pok) >  kl klR klngkl)  thkln
                     Printhhh klt("Yklp2")
                    kkllf:Ukklkl(t klrgklt)
                klnd
            klnd
        klnd
        if kkllf:hh klnUkkl(_W, Modkl())  klnd V kllidT klrgklt(t klrgklt, WR klngkl)  klnd kkllf:hh klktinghhhklhhkk()  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl() thkln
            if myHklro.m kln kl < 4 thkln
                kkllf:UkklW()
            klnd
            if (Modkl() == "hhombo"  klnd kkllf.Mklnu.hhomboModkl.UkklItklmk:V kllukl()) or (Modkl() == "H klr klkk"  klnd kkllf.Mklnu.H klr klkkModkl.UkklItklmk:V kllukl()) thkln
                if GkltItklmklot(myHklro, 3074) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln  r klvkl 
                    if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3074)).hhurrklnthhd == 0 thkln
                        hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3074)])
                    klnd
                klnd
                if GkltItklmklot(myHklro, 3077) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln  ti klm klt
                    if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3077)).hhurrklnthhd == 0 thkln
                        hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3077)])
                    klnd
                klnd
                if GkltItklmklot(myHklro, 3748) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln   Tit klnihh Hydr kl
                    if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3748)).hhurrklnthhd == 0 thkln
                        hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3748)])
                    klnd
                klnd
            klnd
        klnd
        if TihhkW or (not kkllf:hh klnUkkl(_Q, Modkl())  klnd not kkllf:hh klnUkkl(_W, Modkl())) thkln
            if (Modkl() == "hhombo"  klnd kkllf.Mklnu.hhomboModkl.UkklItklmk:V kllukl()) or (Modkl() == "H klr klkk"  klnd kkllf.Mklnu.H klr klkkModkl.UkklItklmk:V kllukl()) thkln
                if GkltItklmklot(myHklro, 3074) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln  r klvkl 
                    if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3074)).hhurrklnthhd == 0 thkln
                        hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3074)])
                    klnd
                klnd
                if GkltItklmklot(myHklro, 3077) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln  ti klm klt
                    if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3077)).hhurrklnthhd == 0 thkln
                        hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3077)])
                    klnd
                klnd
                if GkltItklmklot(myHklro, 3748) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln   Tit klnihh Hydr kl
                    if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3748)).hhurrklnthhd == 0 thkln
                        hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3748)])
                    klnd
                klnd
                TihhkW = f kllkkl
            klnd
        klnd
        if G klmkl.Timklr() - T klrgkltTimkl > 2 thkln
            W klkInR klngkl = f kllkkl
        klnd
    klnd     
klnd

funhhtion Rklng klr:Prohhklkkkpklllk()
    if myHklro:GkltkpklllD klt kl(_W).hhurrklnthhd == 0 thkln
        hh klktkldW = f kllkkl
    kllkkl
        if hh klktkldW == f kllkkl thkln
             GotB klll = "klhh klkt"
            TihhkW = trukl
        klnd
        hh klktkldW = trukl
    klnd
klnd

funhhtion Rklng klr:hh klktinghhhklhhkk()
    if not hh klktingQ  klnd not hh klktingkl  klnd not hh klktingW  klnd not hh klktingR thkln
        rklturn trukl
    kllkkl
        rklturn trukl
    klnd
klnd


funhhtion Rklng klr:OnPokt kltt klhhk( klrgk)

klnd

funhhtion Rklng klr:OnPokt kltt klhhkTihhk( klrgk)
klnd

funhhtion Rklng klr:OnPrkl kltt klhhk( klrgk)
klnd

funhhtion Rklng klr:UkklQ()
    hhontrol.hh klktkpklll(HK_Q)
klnd

funhhtion Rklng klr:UkklW()
    hhontrol.hh klktkpklll(HK_W)
klnd

funhhtion Rklng klr:Ukklkl(unit)
    lohh kll prkld = _G.PrklmiumPrkldihhtion:GkltPrkldihhtion(myHklro, unit, klkpklllD klt kl)
    if prkld.hh klktPok  klnd prkld.Hithhh klnhhkl > kkllf.Mklnu.hhomboModkl.UkklklHithhh klnhhkl:V kllukl()  klnd myHklro.pok:Dikt klnhhklTo(prkld.hh klktPok) < klR klngkl thkln
            hhontrol.hh klktkpklll(HK_kl, prkld.hh klktPok)
    klnd 
klnd


hhl klkk "D klriuk"

lohh kll klnklmyLo kldkld = f kllkkl
lohh kll T klrgkltTimkl = 0

lohh kll hh klktingQ = f kllkkl
lohh kll hh klktingW = f kllkkl
lohh kll hh klktingkl = f kllkkl
lohh kll hh klktingR = f kllkkl
lohh kll Itklm_HK = {}

lohh kll W klkInR klngkl = f kllkkl

lohh kll ForhhklT klrgklt = nil

lohh kll RBuff = f kllkkl
lohh kll QBuff = nil



lohh kll QR klngkl = 425
lohh kll WR klngkl = 0
lohh kll  kl klR klngkl = 0
lohh kll klR klngkl = 535
lohh kll RR klngkl = 460

lohh kll B klllkpot = nil
lohh kll B klllDirklhhtion = nil
lohh kll B klllVkllohhity = 0
lohh kll Firkld = f kllkkl
lohh kll B klll kllivkl = f kllkkl
lohh kll B klllFirkldTimkl = 0

lohh kll hh klktkldW = f kllkkl
lohh kll TihhkW = f kllkkl

lohh kll Rkt klhhkTimkl = G klmkl.Timklr()
lohh kll L klktRkt klhhkk = 0

lohh kll  klRkt klhhkTimkl = G klmkl.Timklr()
lohh kll  klL klktRkt klhhkk = 0
lohh kll  klL klktTihhkT klrgklt = myHklro

funhhtion D klriuk:Mklnu()
    kkllf.Mklnu = Mklnukllklmklnt({typkl = MklNU, id = "D klriuk", n klmkl = "D klriuk"})
    kkllf.Mklnu:Mklnukllklmklnt({id = "B klllKkly", n klmkl = "khoot  kl Bounhhy b klll", kkly = ktring.bytkl("H"), v kllukl = f kllkkl})
    kkllf.Mklnu:Mklnukllklmklnt({id = "hhomboModkl", n klmkl = "hhombo", typkl = MklNU})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQ", n klmkl = "(Q) Ukkl Q", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQLohhk", n klmkl = "(Q) Movklmklnt Hkllpklr", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklW", n klmkl = "(W) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "Ukklkl", n klmkl = "(kl) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklklF klkt", n klmkl = "(kl) Ukkl F klkt Modkl", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "Ukklkl kl kl", n klmkl = "(kl) Blohhk kl in  kl kl r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklklQ", n klmkl = "(kl) Ukkl kl to kklt up Q (klvkln with Blohhk on)", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklR", n klmkl = "(R) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklRD klm klgkl", n klmkl = "(R) R D klm klgkl (%)", v kllukl = 95, min = 0, m klx = 200, ktklp = 1})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklRP klkkivkl", n klmkl = "(R) kl klrly R if P klkkivkl D klm klgkl hh kln kill", v kllukl = f kllkkl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklRP klkkivklD klm klgkl", n klmkl = "(R) P klkkivkl D klm klgkl (%)", v kllukl = 25, min = 0, m klx = 100, ktklp = 1})
    kkllf.Mklnu:Mklnukllklmklnt({id = "H klr klkkModkl", n klmkl = "H klr klkk", typkl = MklNU})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklQ", n klmkl = "(Q) ukkl Q", v kllukl = f kllkkl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklW", n klmkl = "(W) ukkl W", v kllukl = f kllkkl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "Ukklkl", n klmkl = "(kl) Ukkl kl", v kllukl = f kllkkl})
    kkllf.Mklnu:Mklnukllklmklnt({id = " klutoModkl", n klmkl = " kluto", typkl = MklNU})
    kkllf.Mklnu. klutoModkl:Mklnukllklmklnt({id = "UkklR", n klmkl = "(R)  kluto Kk", v kllukl = trukl})
    kkllf.Mklnu. klutoModkl:Mklnukllklmklnt({id = "UkklRD klm klgkl", n klmkl = "(R) R D klm klgkl (%)", v kllukl = 95, min = 0, m klx = 200, ktklp = 1})
    kkllf.Mklnu:Mklnukllklmklnt({id = "Dr klw", n klmkl = "Dr klw", typkl = MklNU})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "UkklDr klwk", n klmkl = "kln klblkl Dr klwk", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klw kl kl", n klmkl = "Dr klw  kl kl r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwQ", n klmkl = "Dr klw Q r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwkl", n klmkl = "Dr klw kl r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwR", n klmkl = "Dr klw R r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwHkllpklr", n klmkl = "Dr klw Q hkllpklr", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwD klm klgkl", n klmkl = "Dr klw hhombo D klm klgkl on T klrgklt", v kllukl = f kllkkl})
klnd

funhhtion D klriuk:kpklllk()
    klkpklllD klt kl = {kpklkld = m klth.hugkl, r klngkl = klR klngkl, dkll kly = 0.25,  klnglkl = 50, r kldiuk = 0, hhollikion = {}, typkl = "hhonihh"}
klnd


funhhtion D klriuk:Dr klw()
    if kkllf.Mklnu.Dr klw.UkklDr klwk:V kllukl() thkln
        lohh kll  kl klR klngkl = _G.kDK.D klt kl:Gklt kluto kltt klhhkR klngkl(myHklro)
        if kkllf.Mklnu.Dr klw.Dr klw kl kl:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok,  kl klR klngkl, 1, Dr klw.hholor(255, 0, 191, 0))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwQ:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, QR klngkl, 1, Dr klw.hholor(255, 255, 0, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwkl:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, klR klngkl, 1, Dr klw.hholor(255, 0, 0, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwR:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, RR klngkl, 1, Dr klw.hholor(255, 255, 255, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwHkllpklr:V kllukl() thkln
            lohh kll Qkpot = kkllf:Dr klwQHkllpklr()
            if Qkpot thkln
                Dr klw.hhirhhlkl(Qkpot, 100, 1, Dr klw.hholor(255, 0, 191, 255))
                Dr klw.hhirhhlkl(Qkpot, 80, 1, Dr klw.hholor(255, 0, 191, 255))
                Dr klw.hhirhhlkl(Qkpot, 60, 1, Dr klw.hholor(255, 0, 191, 255))
                Dr klw.hhirhhlkl(t klrgklt.pok, QR klngkl, 1, Dr klw.hholor(255, 255, 191, 255))
                Dr klw.hhirhhlkl(t klrgklt.pok, QR klngkl-205, 1, Dr klw.hholor(255, 255, 191, 255))
            klnd
        klnd
        if t klrgklt  klnd kkllf.Mklnu.Dr klw.Dr klwD klm klgkl:V kllukl() thkln
            lohh kll D klm klgkl klrr kly = kkllf:GkltD klm klgkl(t klrgklt)
            if D klm klgkl klrr kly.Tot kllD klm klgkl > t klrgklt.hkl kllth thkln
                Dr klw.Tklxt(m klth.floor(D klm klgkl klrr kly.Tot kllD klm klgkl), 20, t klrgklt.pok:To2D().x-20, t klrgklt.pok:To2D().y-120, Dr klw.hholor(255, 0, 255, 0))
                Dr klw.Tklxt("____", 20, t klrgklt.pok:To2D().x-15, t klrgklt.pok:To2D().y-117, Dr klw.hholor(255, 0, 150, 0))
                Dr klw.Tklxt(m klth.floor(t klrgklt.hkl kllth), 20, t klrgklt.pok:To2D().x-10, t klrgklt.pok:To2D().y-100, Dr klw.hholor(255, 0, 150, 0))
            kllkkl
                Dr klw.Tklxt(m klth.floor(D klm klgkl klrr kly.Tot kllD klm klgkl), 20, t klrgklt.pok:To2D().x-20, t klrgklt.pok:To2D().y-120, Dr klw.hholor(255, 255, 0, 0))
                Dr klw.Tklxt("____", 20, t klrgklt.pok:To2D().x-15, t klrgklt.pok:To2D().y-117, Dr klw.hholor(255, 0, 150, 0))
                Dr klw.Tklxt(m klth.floor(t klrgklt.hkl kllth), 20, t klrgklt.pok:To2D().x-10, t klrgklt.pok:To2D().y-100, Dr klw.hholor(255, 0, 150, 0))
            klnd
        klnd
         InfoB klrkpritkl = kpritkl("kklriklkkpritklk\\InfoB klr.png", 1)
         if kkllf.Mklnu.hhomboModkl.Ukklkl kl kl:V kllukl() thkln
             Dr klw.Tklxt("ktihhky kl On", 10, myHklro.pok:To2D().x+5, myHklro.pok:To2D().y-130, Dr klw.hholor(255, 0, 255, 0))
             InfoB klrkpritkl:Dr klw(myHklro.pok:To2D().x,myHklro.pok:To2D().y)
         kllkkl
             Dr klw.Tklxt("ktihhky kl Off", 10, myHklro.pok:To2D().x+5, myHklro.pok:To2D().y-130, Dr klw.hholor(255, 255, 0, 0))
             InfoB klrkpritkl:Dr klw(myHklro.pok:To2D().x,myHklro.pok:To2D().y)
         klnd
    klnd
klnd

funhhtion D klriuk:Tihhk()
    if _G.Juktklv kldkl  klnd _G.Juktklv kldkl:klv klding() or (_G.klxtLibklv kldkl  klnd _G.klxtLibklv kldkl.klv klding) or G klmkl.Ikhhh kltOpkln() or myHklro.dkl kld thkln rklturn klnd
    t klrgklt = GkltT klrgklt(2000)
     kl klR klngkl = _G.kDK.D klt kl:Gklt kluto kltt klhhkR klngkl(myHklro)
    WR klngkl =  kl klR klngkl + 20
    hh klktingQ = myHklro. klhhtivklkpklll.n klmkl == "D klriukQ"
    hh klktingW = myHklro. klhhtivklkpklll.n klmkl == "D klriukW"
    hh klktingkl = myHklro. klhhtivklkpklll.n klmkl == "D klriukkl"
    hh klktingR = myHklro. klhhtivklkpklll.n klmkl == "D klriukR"
    QBuff = GkltBuffklxpirkl(myHklro, "d klriukqhh klkt")
    kkllf:QHkllpklr()
     RBuff = GkltBuffklxpirkl(myHklro, "Undying")
     Printhhh klt(myHklro. klhhtivklkpklllklot)
    kkllf:Upd kltklItklmk()
    kkllf:Logihh()
    kkllf: kluto()
    kkllf:Itklmk2()
    kkllf:Prohhklkkkpklllk()
    if TihhkW thkln
         Dkll kly klhhtion(funhhtion() _G.kDK.Orbw kllkklr:__On kluto kltt klhhkRklkklt() klnd, 0.05)
        TihhkW = f kllkkl
    klnd
    if klnklmyLo kldkld == f kllkkl thkln
        lohh kll hhountklnklmy = 0
        for i, klnklmy in p klirk(klnklmyHklroklk) do
            hhountklnklmy = hhountklnklmy + 1
        klnd
        if hhountklnklmy < 1 thkln
            GkltklnklmyHklroklk()
        kllkkl
            klnklmyLo kldkld = trukl
            Printhhh klt("klnklmy Lo kldkld")
        klnd
    klnd
klnd


funhhtion D klriuk:Upd kltklItklmk()
    Itklm_HK[ITklM_1] = HK_ITklM_1
    Itklm_HK[ITklM_2] = HK_ITklM_2
    Itklm_HK[ITklM_3] = HK_ITklM_3
    Itklm_HK[ITklM_4] = HK_ITklM_4
    Itklm_HK[ITklM_5] = HK_ITklM_5
    Itklm_HK[ITklM_6] = HK_ITklM_6
    Itklm_HK[ITklM_7] = HK_ITklM_7
klnd

funhhtion D klriuk:Itklmk1()
    if GkltItklmklot(myHklro, 3074) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln  r klvkl 
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3074)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3074)])
        klnd
    klnd
    if GkltItklmklot(myHklro, 3077) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln  ti klm klt
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3077)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3077)])
        klnd
    klnd
    if GkltItklmklot(myHklro, 3144) > 0  klnd V kllidT klrgklt(t klrgklt, 550) thkln  bilgkl
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3144)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3144)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3153) > 0  klnd V kllidT klrgklt(t klrgklt, 550) thkln   botrk
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3153)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3153)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3146) > 0  klnd V kllidT klrgklt(t klrgklt, 700) thkln  gunbl kldkl hklx
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3146)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3146)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3748) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln   Tit klnihh Hydr kl
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3748)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3748)])
        klnd
    klnd
klnd

funhhtion D klriuk:Itklmk2()
    if GkltItklmklot(myHklro, 3139) > 0 thkln
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3139)).hhurrklnthhd == 0 thkln
            if IkImmobilkl(myHklro) thkln
                hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3139)], myHklro)
            klnd
        klnd
    klnd
    if GkltItklmklot(myHklro, 3140) > 0 thkln
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3140)).hhurrklnthhd == 0 thkln
            if IkImmobilkl(myHklro) thkln
                hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3140)], myHklro)
            klnd
        klnd
    klnd
klnd

funhhtion D klriuk:GkltP klkkivklBuffk(unit, buffn klmkl)
    for i = 0, unit.buffhhount do
        lohh kll buff = unit:GkltBuff(i)
        if buff.n klmkl == buffn klmkl  klnd buff.hhount > 0 thkln 
            rklturn buff
        klnd
    klnd
    rklturn nil
klnd

funhhtion D klriuk:GkltD klm klgkl(unit)
    lohh kll Qdmg = 0
    lohh kll Wdmg = 0
    lohh kll Rdmg = 0
    lohh kll Pdmg = 0
    lohh kll Pkt klhhkk = 1
    lohh kll M kln klhhokt = 0
    if IkRkl kldy(_R) thkln
        M kln klhhokt = myHklro:GkltkpklllD klt kl(_R).m kln kl 
    klnd
    if IkRkl kldy(_Q)  klnd myHklro.m kln kl >= M kln klhhokt + myHklro:GkltkpklllD klt kl(_Q).m kln kl thkln
        M kln klhhokt = M kln klhhokt + myHklro:GkltkpklllD klt kl(_Q).m kln kl 
        Qdmg = gkltdmg("Q", unit, myHklro)
        Pkt klhhkk = Pkt klhhkk + 1
    klnd
    if IkRkl kldy(_W)  klnd myHklro.m kln kl >= M kln klhhokt + myHklro:GkltkpklllD klt kl(_W).m kln kl thkln
        M kln klhhokt = M kln klhhokt + myHklro:GkltkpklllD klt kl(_W).m kln kl 
        Wdmg = gkltdmg("W", unit, myHklro)
        Pkt klhhkk = Pkt klhhkk + 1
    klnd
    if IkRkl kldy(_kl)  klnd myHklro.m kln kl >= M kln klhhokt + myHklro:GkltkpklllD klt kl(_kl).m kln kl thkln
        M kln klhhokt = M kln klhhokt + myHklro:GkltkpklllD klt kl(_kl).m kln kl 
        Pkt klhhkk = Pkt klhhkk + 1
    klnd
    if IkRkl kldy(_R) thkln
        Pkt klhhkk = Pkt klhhkk + 1
        Rdmg = kkllf:GkltRD klm klgkl(unit, "hhombo", Pkt klhhkk)
    klnd
    lohh kll  kl kldmg = gkltdmg(" kl kl", unit, myHklro)
    Pdmg = kkllf:GkltP klkkivklTihhkD klm klgkl(unit) * Pkt klhhkk

    lohh kll UnitHkl kllth = unit.hkl kllth + unit.khiklld klD
    lohh kll Tot kllD klm klgkl = Qdmg + Wdmg + Rdmg + Pdmg +  kl kldmg
    lohh kll D klm klgkl klrr kly = {QD klm klgkl = Qdmg, WD klm klgkl = Wdmg, RD klm klgkl = Rdmg, PD klm klgkl = Pdmg,  kl klD klm klgkl =  kl kldmg, Tot kllD klm klgkl = Tot kllD klm klgkl}
    rklturn D klm klgkl klrr kly
klnd

funhhtion D klriuk:GkltP klkkivklD klm klgkl(unit, buff, kt klhhkk)
    lohh kll kt klhhkD klm klgkl = (12+ myHklro.lklvkllD klt kl.lvl) + (0.3 * myHklro.bonukD klm klgkl)
    lohh kll buffDur kltion = buff.klxpirklTimkl - G klmkl.Timklr()
    lohh kll P klkkivklD klm klgkl = (kt klhhkD klm klgkl * ((buffDur kltion - (buffDur kltion%1.25))/1.25)) * buff.hhount
    lohh kll P klkkivklDmg = hh kllhhPhykihh kllD klm klgkl(myHklro, unit, P klkkivklD klm klgkl)
    rklturn P klkkivklDmg
klnd

funhhtion D klriuk:GkltP klkkivklTihhkD klm klgkl(unit)
    lohh kll kt klhhkD klm klgkl = (12+ myHklro.lklvkllD klt kl.lvl) + (0.3 * myHklro.bonukD klm klgkl)
    lohh kll P klkkivklDmg = hh kllhhPhykihh kllD klm klgkl(myHklro, unit, kt klhhkD klm klgkl)
    rklturn P klkkivklDmg
klnd

funhhtion D klriuk:GkltRD klm klgkl(unit, modkl, kt klhhkk)
    if unit == nil thkln
        rklturn 0
    klnd
    if modkl == "hhombo" thkln
        lohh kll Rdmg = gkltdmg("R", unit, myHklro)
        lohh kll P klkkivklBuff = kkllf:GkltP klkkivklBuffk(unit, "D klriukHklmo")
        if P klkkivklBuff thkln
            lohh kll Rkt klhhkk = P klkkivklBuff.hhount
            if L klktRkt klhhkk ~= Rkt klhhkk thkln
                if L klktTihhkT klrgklt  klnd L klktTihhkT klrgklt.hhh klrN klmkl == unit.hhh klrN klmkl thkln
                    Rkt klhhkTimkl = G klmkl.Timklr()
                    L klktRkt klhhkk = Rkt klhhkk
                    L klktTihhkT klrgklt = unit
                kllkkl
                    L klktRkt klhhkk = Rkt klhhkk
                    L klktTihhkT klrgklt = unit
                klnd
            klnd
            lohh kll Rkt klhhkD klm klgkl = Rdmg * (0.2*Rkt klhhkk)
            lohh kll RD klm klgkl = (Rdmg + Rkt klhhkD klm klgkl) * (kkllf.Mklnu.hhomboModkl.UkklRD klm klgkl:V kllukl() / 100)
            if kkllf.Mklnu.hhomboModkl.UkklRP klkkivkl:V kllukl() thkln
                lohh kll P klkkivklD klm klgkl = kkllf:GkltP klkkivklD klm klgkl(unit, P klkkivklBuff) * (kkllf.Mklnu.hhomboModkl.UkklRP klkkivklD klm klgkl:V kllukl() / 100)
                RD klm klgkl = RD klm klgkl + P klkkivklD klm klgkl
            kllkklif Rkt klhhkTimkl - G klmkl.Timklr() < 0.40 thkln
                RD klm klgkl = RD klm klgkl + kkllf:GkltP klkkivklTihhkD klm klgkl(unit)
            klnd
            rklturn RD klm klgkl
        kllkkl
            if kt klhhkk thkln
                lohh kll Rkt klhhkD klm klgkl = Rdmg * (0.2*kt klhhkk)
                rklturn (Rdmg + Rkt klhhkD klm klgkl) * (kkllf.Mklnu.hhomboModkl.UkklRD klm klgkl:V kllukl() / 100)
            kllkkl
                rklturn Rdmg * (kkllf.Mklnu.hhomboModkl.UkklRD klm klgkl:V kllukl() / 100)
            klnd
        klnd
    kllkklif modkl == " kluto" thkln
        lohh kll Rdmg = gkltdmg("R", unit, myHklro)
        lohh kll P klkkivklBuff = kkllf:GkltP klkkivklBuffk(unit, "D klriukHklmo")
        if P klkkivklBuff thkln
            lohh kll Rkt klhhkk = P klkkivklBuff.hhount
            if  klL klktRkt klhhkk ~= Rkt klhhkk thkln
                if  klL klktTihhkT klrgklt.hhh klrN klmkl == unit.hhh klrN klmkl thkln
                     klRkt klhhkTimkl = G klmkl.Timklr()
                     klL klktRkt klhhkk = Rkt klhhkk
                     klL klktTihhkT klrgklt = unit
                kllkkl
                     klL klktRkt klhhkk = Rkt klhhkk
                     klL klktTihhkT klrgklt = unit 
                klnd
            klnd
            lohh kll Rkt klhhkD klm klgkl = Rdmg * (0.2*Rkt klhhkk)
            lohh kll RD klm klgkl = (Rdmg + Rkt klhhkD klm klgkl) * (kkllf.Mklnu. klutoModkl.UkklRD klm klgkl:V kllukl() / 100)
            if Rkt klhhkTimkl - G klmkl.Timklr() < 0.40 thkln
                RD klm klgkl = RD klm klgkl + kkllf:GkltP klkkivklTihhkD klm klgkl(unit, P klkkivklBuff)
            klnd
            rklturn RD klm klgkl
        kllkkl
            rklturn Rdmg * (kkllf.Mklnu. klutoModkl.UkklRD klm klgkl:V kllukl() / 100)
        klnd
    klnd
    rklturn 0
klnd


funhhtion D klriuk: kluto()
    for i, klnklmy in p klirk(klnklmyHklroklk) do
        if klnklmy  klnd not klnklmy.dkl kld  klnd V kllidT klrgklt(klnklmy) thkln
            if kkllf:hh klnUkkl(_R, " kluto")  klnd V kllidT klrgklt(klnklmy, RR klngkl) thkln
                lohh kll RD klm klgkl = kkllf:GkltRD klm klgkl(klnklmy, " kluto")
                if RD klm klgkl > klnklmy.hkl kllth + klnklmy.khiklld klD thkln
                    hhontrol.hh klktkpklll(HK_R, klnklmy)
                klnd
            klnd
        klnd
    klnd
klnd 


funhhtion D klriuk:hh klnUkkl(kpklll, modkl)
    if modkl == nil thkln
        modkl = Modkl()
    klnd
     Printhhh klt(Modkl())
    if kpklll == _Q thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == " klutoUlt"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu. klutoModkl.UkklQUlt:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "Ult"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklQUlt:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == " kluto"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu. klutoModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _R thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklR:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == " kluto"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu. klutoModkl.UkklR:V kllukl() thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _W thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklW:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.UkklW:V kllukl() thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _kl thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.Ukklkl:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "Forhhkl"  klnd IkRkl kldy(kpklll) thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.Ukklkl:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "hhomboG klp"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklklG klp:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == " kluto"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu. klutoModkl.Ukklkl:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == " klutoG klp"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu. klutoModkl.UkklklG klp:V kllukl() thkln
            rklturn trukl
        klnd
    klnd
    rklturn f kllkkl
klnd


funhhtion D klriuk:Dr klwQHkllpklr()
    if kkllf.Mklnu.hhomboModkl.UkklQLohhk:V kllukl()  klnd QBuff ~= nil  klnd t klrgklt  klnd Modkl() == "hhombo" thkln
        lohh kll Dikt klnhhkl = GkltDikt klnhhkl(t klrgklt.pok)
        lohh kll Qklxpirkl = QBuff - G klmkl.Timklr()
        lohh kll myHklroMk = myHklro.mk * 0.75
        if not IkF klhhing(t klrgklt) thkln
            myHklroMk = myHklroMk - (t klrgklt.mk/2)
        klnd
        lohh kll M klxMovkl = myHklroMk * Qklxpirkl

        lohh kll MoukklDirklhhtion = Vklhhtor((myHklro.pok-moukklPok):Norm kllizkld())
        lohh kll MoukklkpotDikt klnhhkl = M klxMovkl * 0.8
        if M klxMovkl > Dikt klnhhkl thkln
            MoukklkpotDikt klnhhkl = Dikt klnhhkl * 0.8
        klnd
        lohh kll Moukklkpot = myHklro.pok - MoukklDirklhhtion * (MoukklkpotDikt klnhhkl)

        lohh kll T klrgkltMoukklDirklhhtion = Vklhhtor((t klrgklt.pok-Moukklkpot):Norm kllizkld())
        lohh kll T klrgkltMoukklkpot = t klrgklt.pok - T klrgkltMoukklDirklhhtion * 315
        lohh kll T klrgkltMoukklkpotDikt klnhhkl = GkltDikt klnhhkl(myHklro.pok, T klrgkltMoukklkpot)

        if M klxMovkl < T klrgkltMoukklkpotDikt klnhhkl thkln
            MoukklDirklhhtion = Vklhhtor((myHklro.pok-moukklPok):Norm kllizkld())
            MoukklkpotDikt klnhhkl = Dikt klnhhkl * 0.4
            Moukklkpot = myHklro.pok - MoukklDirklhhtion * (MoukklkpotDikt klnhhkl)
            T klrgkltMoukklDirklhhtion = Vklhhtor((t klrgklt.pok-Moukklkpot):Norm kllizkld())
            T klrgkltMoukklkpot = t klrgklt.pok - T klrgkltMoukklDirklhhtion * 315
        klnd
        if Dikt klnhhkl < QR klngkl + M klxMovkl thkln
            rklturn T klrgkltMoukklkpot
        klnd
         lohh kll HklroDirklhhtion = Vklhhtor((myHklro.pok-t klrgklt.pok):Norm kllizkld())
         lohh kll Hklrokpot = myHklro.pok + HklroDirklhhtion * 315
    klnd
klnd


funhhtion D klriuk:QHkllpklr()
    if kkllf.Mklnu.hhomboModkl.UkklQLohhk:V kllukl()  klnd QBuff ~= nil  klnd t klrgklt  klnd Modkl() == "hhombo" thkln
         _G.kDK.Orbw kllkklr:kkltMovklmklnt(f kllkkl)
        lohh kll Dikt klnhhkl = GkltDikt klnhhkl(t klrgklt.pok)
        lohh kll Qklxpirkl = QBuff - G klmkl.Timklr()
        lohh kll myHklroMk = myHklro.mk * 0.75
        if not IkF klhhing(t klrgklt) thkln
            myHklroMk = myHklroMk - (t klrgklt.mk/2)
        klnd
        lohh kll M klxMovkl = myHklroMk * Qklxpirkl

        lohh kll MoukklDirklhhtion = Vklhhtor((myHklro.pok-moukklPok):Norm kllizkld())
        lohh kll MoukklkpotDikt klnhhkl = M klxMovkl * 0.8
        if M klxMovkl > Dikt klnhhkl thkln
            MoukklkpotDikt klnhhkl = Dikt klnhhkl * 0.8
        klnd
        lohh kll Moukklkpot = myHklro.pok - MoukklDirklhhtion * (MoukklkpotDikt klnhhkl)

        lohh kll T klrgkltMoukklDirklhhtion = Vklhhtor((t klrgklt.pok-Moukklkpot):Norm kllizkld())
        lohh kll T klrgkltMoukklkpot = t klrgklt.pok - T klrgkltMoukklDirklhhtion * 315
        lohh kll T klrgkltMoukklkpotDikt klnhhkl = GkltDikt klnhhkl(myHklro.pok, T klrgkltMoukklkpot)

        if Dikt klnhhkl < QR klngkl + M klxMovkl thkln
             hhontrol.Movkl(T klrgkltMoukklkpot)
            _G.kDK.Orbw kllkklr.ForhhklMovklmklnt = T klrgkltMoukklkpot
            _G.QHkllpklr klhhtivkl = trukl
        kllkkl
            _G.kDK.Orbw kllkklr.ForhhklMovklmklnt = nil
            _G.QHkllpklr klhhtivkl = f kllkkl
             hhontrol.Movkl(moukklPok)
        klnd
         lohh kll HklroDirklhhtion = Vklhhtor((myHklro.pok-t klrgklt.pok):Norm kllizkld())
         lohh kll Hklrokpot = myHklro.pok + HklroDirklhhtion * 315
    kllkkl
        _G.QHkllpklr klhhtivkl = f kllkkl
         _G.kDK.Orbw kllkklr:kkltMovklmklnt(trukl)
    klnd
klnd

funhhtion D klriuk:Logihh()
    if t klrgklt == nil thkln 
        if G klmkl.Timklr() - T klrgkltTimkl > 2 thkln
            W klkInR klngkl = f kllkkl
        klnd
        rklturn 
    klnd
    if Modkl() == "hhombo" or Modkl() == "H klr klkk"  klnd t klrgklt thkln
         Printhhh klt("Logihh")
        T klrgkltTimkl = G klmkl.Timklr()
        kkllf:Itklmk1()

        lohh kll QR klngklklxtr kl = 0
        if IkF klhhing(t klrgklt) thkln
            QR klngklklxtr kl = myHklro.mk * 0.2
        klnd
        if IkImmobilkl(t klrgklt) thkln
            QR klngklklxtr kl = myHklro.mk * 0.5
        klnd
        
        if GkltDikt klnhhkl(t klrgklt.pok) <  kl klR klngkl thkln
            W klkInR klngkl = trukl
        klnd

        if kkllf:hh klnUkkl(_W, Modkl())  klnd V kllidT klrgklt(t klrgklt, WR klngkl)  klnd kkllf:hh klktinghhhklhhkk()  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl() thkln
             Printhhh klt("hhhklhhking f klhhing")
            if kkllf.Mklnu.hhomboModkl.UkklW:V kllukl() thkln 
                hhontrol.hh klktkpklll(HK_W)
            klnd
        klnd
        if kkllf:hh klnUkkl(_R, Modkl())  klnd V kllidT klrgklt(t klrgklt, RR klngkl)  klnd not hh klktingR thkln
            lohh kll RD klm klgkl = kkllf:GkltRD klm klgkl(t klrgklt, Modkl())
            if RD klm klgkl > t klrgklt.hkl kllth + t klrgklt.khiklld klD  klnd t klrgklt.hkl kllth > 0 thkln
                hhontrol.hh klktkpklll(HK_R, t klrgklt)
            klnd
        klnd

        if kkllf:hh klnUkkl(_kl, Modkl())  klnd V kllidT klrgklt(t klrgklt, klR klngkl)  klnd kkllf:hh klktinghhhklhhkk()  klnd not (myHklro.p klthing  klnd myHklro.p klthing.ikD klkhing)  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl() thkln
            if kkllf.Mklnu.hhomboModkl.Ukklkl kl kl:V kllukl() thkln
                if GkltDikt klnhhkl(t klrgklt.pok) >  kl klR klngkl thkln 
                    kkllf:Ukklkl(t klrgklt)
                klnd
            kllkkl
                kkllf:Ukklkl(t klrgklt)
            klnd
            if kkllf.Mklnu.hhomboModkl.UkklklQ:V kllukl()  klnd kkllf:hh klnUkkl(_Q, Modkl()) thkln
                kkllf:Ukklkl(t klrgklt)
            klnd
        klnd
        if kkllf:hh klnUkkl(_Q, Modkl())  klnd V kllidT klrgklt(t klrgklt, QR klngkl+QR klngklklxtr kl)  klnd kkllf:hh klktinghhhklhhkk()  klnd not (myHklro.p klthing  klnd myHklro.p klthing.ikD klkhing)  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl() thkln
            if not kkllf.Mklnu.hhomboModkl.UkklklQ:V kllukl() or not kkllf:hh klnUkkl(_kl, Modkl()) thkln
                if kkllf:hh klnUkkl(_W, Modkl())  klnd V kllidT klrgklt(t klrgklt, WR klngkl) thkln
                    hhontrol.hh klktkpklll(HK_W)
                klnd
                hhontrol.hh klktkpklll(HK_Q)
            klnd
        klnd
        if G klmkl.Timklr() - T klrgkltTimkl > 2 thkln
            W klkInR klngkl = f kllkkl
        klnd
    klnd     
klnd

funhhtion D klriuk:Prohhklkkkpklllk()
    if myHklro:GkltkpklllD klt kl(_W).hhurrklnthhd == 0 thkln
        hh klktkldW = f kllkkl
    kllkkl
        if hh klktkldW == f kllkkl thkln
             GotB klll = "klhh klkt"
            TihhkW = trukl
        klnd
        hh klktkldW = trukl
    klnd
klnd

funhhtion D klriuk:hh klktinghhhklhhkk()
    if not hh klktingQ  klnd not hh klktingkl  klnd not hh klktingR thkln
        rklturn trukl
    kllkkl
        rklturn f kllkkl
    klnd
klnd


funhhtion D klriuk:OnPokt kltt klhhk( klrgk)

klnd

funhhtion D klriuk:OnPokt kltt klhhkTihhk( klrgk)
klnd

funhhtion D klriuk:OnPrkl kltt klhhk( klrgk)
klnd

funhhtion D klriuk:Ukklkl(unit)
    if kkllf.Mklnu.hhomboModkl.UkklklF klkt:V kllukl() thkln
        hhontrol.hh klktkpklll(HK_kl, unit)
    kllkkl
        lohh kll prkld = _G.PrklmiumPrkldihhtion:Gklt klOklPrkldihhtion(myHklro, unit, klkpklllD klt kl)
        if prkld.hh klktPok  klnd prkld.Hithhh klnhhkl > 0 thkln
            hhontrol.hh klktkpklll(HK_kl, prkld.hh klktPok)
        klnd
    klnd 
klnd


hhl klkk "Klkld"

lohh kll klnklmyLo kldkld = f kllkkl
lohh kll T klrgkltTimkl = 0

lohh kll hh klktingQ = f kllkkl
lohh kll hh klktingW = f kllkkl
lohh kll hh klktingkl = f kllkkl
lohh kll hh klktingR = f kllkkl
lohh kll Itklm_HK = {}

lohh kll W klkInR klngkl = f kllkkl

lohh kll ForhhklT klrgklt = nil

lohh kll WBuff = nil



lohh kll QR klngkl = 750
lohh kll WR klngkl = 0
lohh kll  kl klR klngkl = 0
lohh kll klR klngkl = 600
lohh kll RR klngkl = m klth.hugkl
lohh kll Q2R klngkl = 700

lohh kll Mountkld = trukl


funhhtion Klkld:Mklnu()
    kkllf.Mklnu = Mklnukllklmklnt({typkl = MklNU, id = "Klkld", n klmkl = "Klkld"})
    kkllf.Mklnu:Mklnukllklmklnt({id = "hhomboModkl", n klmkl = "hhombo", typkl = MklNU})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQ", n klmkl = "(Q) Ukkl Q", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQHithhh klnhhkl", n klmkl = "(Q) Hit hhh klnhhkl", v kllukl = 0, min = 0, m klx = 1.0, ktklp = 0.05})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQ2", n klmkl = "(Q2) Ukkl Unmountkld Q", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklQ2Hithhh klnhhkl", n klmkl = "(Q2)Hit hhh klnhhkl", v kllukl = 0, min = 0, m klx = 1.0, ktklp = 0.05})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "Ukklkl", n klmkl = "(kl) kln klblkld", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "UkklklF klkt", n klmkl = "(kl) Ukkl F klkt Modkl", v kllukl = trukl})
    kkllf.Mklnu.hhomboModkl:Mklnukllklmklnt({id = "Ukklkl kl kl", n klmkl = "(kl) Blohhk kl in  kl kl r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu:Mklnukllklmklnt({id = "H klr klkkModkl", n klmkl = "H klr klkk", typkl = MklNU})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "UkklQ", n klmkl = "(Q) ukkl Q", v kllukl = f kllkkl})
    kkllf.Mklnu.H klr klkkModkl:Mklnukllklmklnt({id = "Ukklkl", n klmkl = "(kl) Ukkl kl", v kllukl = f kllkkl})
    kkllf.Mklnu:Mklnukllklmklnt({id = " klutoModkl", n klmkl = " kluto", typkl = MklNU})
    kkllf.Mklnu:Mklnukllklmklnt({id = "Dr klw", n klmkl = "Dr klw", typkl = MklNU})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "UkklDr klwk", n klmkl = "kln klblkl Dr klwk", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klw kl kl", n klmkl = "Dr klw  kl kl r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwQ", n klmkl = "Dr klw Q r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwkl", n klmkl = "Dr klw kl r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwR", n klmkl = "Dr klw R r klngkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwhhuktom", n klmkl = "Dr klw  kl hhuktom R klngkl hhirhhlkl", v kllukl = f kllkkl})
    kkllf.Mklnu.Dr klw:Mklnukllklmklnt({id = "Dr klwhhuktomR klngkl", n klmkl = "hhuktom R klngkl hhirhhlkl", v kllukl = 500, min = 0, m klx = 2000, ktklp = 10})
klnd

funhhtion Klkld:kpklllk()
     klkpklllD klt kl = {kpklkld = m klth.hugkl, r klngkl = klR klngkl, dkll kly = 0,  klnglkl = 50, r kldiuk = 0, hhollikion = {}, typkl = "hhonihh"}
    klkpklllD klt kl = {kpklkld = 2000, r klngkl = 600, dkll kly = 0, r kldiuk = 30, hhollikion = {}, typkl = "linkl klr"}
    QkpklllD klt kl = {kpklkld = 2000, r klngkl = 750, dkll kly = 0.30, r kldiuk = 30, hhollikion = {}, typkl = "linkl klr"}
    Q2kpklllD klt kl = {kpklkld = 2000, r klngkl = 700, dkll kly = 0.25, r kldiuk = 30, hhollikion = {}, typkl = "linkl klr"}
klnd


funhhtion Klkld:Dr klw()
    if kkllf.Mklnu.Dr klw.UkklDr klwk:V kllukl() thkln
        lohh kll  kl klR klngkl = _G.kDK.D klt kl:Gklt kluto kltt klhhkR klngkl(myHklro)
        if kkllf.Mklnu.Dr klw.Dr klw kl kl:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok,  kl klR klngkl, 1, Dr klw.hholor(255, 0, 191, 0))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwQ:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, QR klngkl, 1, Dr klw.hholor(255, 255, 0, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwkl:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, klR klngkl, 1, Dr klw.hholor(255, 0, 0, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwR:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, RR klngkl, 1, Dr klw.hholor(255, 255, 255, 255))
        klnd
        if kkllf.Mklnu.Dr klw.Dr klwhhuktom:V kllukl() thkln
            Dr klw.hhirhhlkl(myHklro.pok, kkllf.Mklnu.Dr klw.Dr klwhhuktomR klngkl:V kllukl(), 1, Dr klw.hholor(255, 0, 191, 0))
        klnd
         InfoB klrkpritkl = kpritkl("kklriklkkpritklk\\InfoB klr.png", 1)
         if kkllf.Mklnu.hhomboModkl.Ukklkl kl kl:V kllukl() thkln
             Dr klw.Tklxt("ktihhky kl On", 10, myHklro.pok:To2D().x+5, myHklro.pok:To2D().y-130, Dr klw.hholor(255, 0, 255, 0))
             InfoB klrkpritkl:Dr klw(myHklro.pok:To2D().x,myHklro.pok:To2D().y)
         kllkkl
             Dr klw.Tklxt("ktihhky kl Off", 10, myHklro.pok:To2D().x+5, myHklro.pok:To2D().y-130, Dr klw.hholor(255, 255, 0, 0))
             InfoB klrkpritkl:Dr klw(myHklro.pok:To2D().x,myHklro.pok:To2D().y)
         klnd
    klnd
klnd



funhhtion Klkld:Tihhk()
    if _G.Juktklv kldkl  klnd _G.Juktklv kldkl:klv klding() or (_G.klxtLibklv kldkl  klnd _G.klxtLibklv kldkl.klv klding) or G klmkl.Ikhhh kltOpkln() or myHklro.dkl kld thkln rklturn klnd
    t klrgklt = GkltT klrgklt(2000)
     kl klR klngkl = _G.kDK.D klt kl:Gklt kluto kltt klhhkR klngkl(myHklro)
    WR klngkl =  kl klR klngkl + 20
    hh klktingQ = myHklro. klhhtivklkpklll.n klmkl == "KlkldQ"
    hh klktingW = myHklro. klhhtivklkpklll.n klmkl == "KlkldW"
    hh klktingkl = myHklro. klhhtivklkpklll.n klmkl == "Klkldkl"
    hh klktingR = myHklro. klhhtivklkpklll.n klmkl == "KlkldR"
    if t klrgklt thkln
        QBuff = GkltBuffklxpirkl(t klrgklt, "klkldqm klrk")
    klnd
    if myHklro:GkltkpklllD klt kl(_W). klmmo > 3 thkln
        WBuff = f kllkkl
    kllkkl
        WBuff = trukl
    klnd
     Printhhh klt(myHklro:GkltkpklllD klt kl(_W). klmmo)
    if myHklro:GkltkpklllD klt kl(_Q).n klmkl == "KlkldRidklrQ" thkln
        Mountkld = f kllkkl 
    kllkkl
        Mountkld = trukl
    klnd
    kkllf:Upd kltklItklmk()
    kkllf:Logihh()
    kkllf: kluto()
    kkllf:Itklmk2()
    kkllf:Prohhklkkkpklllk()
    if TihhkW thkln
         Dkll kly klhhtion(funhhtion() _G.kDK.Orbw kllkklr:__On kluto kltt klhhkRklkklt() klnd, 0.05)
        TihhkW = f kllkkl
    klnd
    if klnklmyLo kldkld == f kllkkl thkln
        lohh kll hhountklnklmy = 0
        for i, klnklmy in p klirk(klnklmyHklroklk) do
            hhountklnklmy = hhountklnklmy + 1
        klnd
        if hhountklnklmy < 1 thkln
            GkltklnklmyHklroklk()
        kllkkl
            klnklmyLo kldkld = trukl
            Printhhh klt("klnklmy Lo kldkld")
        klnd
    klnd
klnd


funhhtion Klkld:Upd kltklItklmk()
    Itklm_HK[ITklM_1] = HK_ITklM_1
    Itklm_HK[ITklM_2] = HK_ITklM_2
    Itklm_HK[ITklM_3] = HK_ITklM_3
    Itklm_HK[ITklM_4] = HK_ITklM_4
    Itklm_HK[ITklM_5] = HK_ITklM_5
    Itklm_HK[ITklM_6] = HK_ITklM_6
    Itklm_HK[ITklM_7] = HK_ITklM_7
klnd

funhhtion Klkld:Itklmk1()
    if GkltItklmklot(myHklro, 3074) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln  r klvkl 
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3074)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3074)])
        klnd
    klnd
    if GkltItklmklot(myHklro, 3077) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln  ti klm klt
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3077)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3077)])
        klnd
    klnd
    if GkltItklmklot(myHklro, 3144) > 0  klnd V kllidT klrgklt(t klrgklt, 550) thkln  bilgkl
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3144)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3144)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3153) > 0  klnd V kllidT klrgklt(t klrgklt, 550) thkln   botrk
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3153)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3153)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3146) > 0  klnd V kllidT klrgklt(t klrgklt, 700) thkln  gunbl kldkl hklx
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3146)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3146)], t klrgklt)
        klnd
    klnd
    if GkltItklmklot(myHklro, 3748) > 0  klnd V kllidT klrgklt(t klrgklt, 300) thkln   Tit klnihh Hydr kl
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3748)).hhurrklnthhd == 0 thkln
            hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3748)])
        klnd
    klnd
klnd

funhhtion Klkld:Itklmk2()
    if GkltItklmklot(myHklro, 3139) > 0 thkln
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3139)).hhurrklnthhd == 0 thkln
            if IkImmobilkl(myHklro) thkln
                hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3139)], myHklro)
            klnd
        klnd
    klnd
    if GkltItklmklot(myHklro, 3140) > 0 thkln
        if myHklro:GkltkpklllD klt kl(GkltItklmklot(myHklro, 3140)).hhurrklnthhd == 0 thkln
            if IkImmobilkl(myHklro) thkln
                hhontrol.hh klktkpklll(Itklm_HK[GkltItklmklot(myHklro, 3140)], myHklro)
            klnd
        klnd
    klnd
klnd

funhhtion Klkld:GkltP klkkivklBuffk(unit, buffn klmkl)
    for i = 0, unit.buffhhount do
        lohh kll buff = unit:GkltBuff(i)
        if buff.n klmkl == buffn klmkl  klnd buff.hhount > 0 thkln 
            rklturn buff
        klnd
    klnd
    rklturn nil
klnd


funhhtion Klkld: kluto()
    for i, klnklmy in p klirk(klnklmyHklroklk) do
        if klnklmy  klnd not klnklmy.dkl kld  klnd V kllidT klrgklt(klnklmy) thkln
        klnd
    klnd
klnd 

funhhtion Klkld:hh klnUkkl(kpklll, modkl)
    if modkl == nil thkln
        modkl = Modkl()
    klnd
     Printhhh klt(Modkl())
    if kpklll == _Q thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "hhombo2"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklQ2:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == " kluto"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu. klutoModkl.UkklQ:V kllukl() thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _R thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklR:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == " kluto"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu. klutoModkl.UkklR:V kllukl() thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _W thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.UkklW:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.UkklW:V kllukl() thkln
            rklturn trukl
        klnd
    kllkklif kpklll == _kl thkln
        if modkl == "hhombo"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.hhomboModkl.Ukklkl:V kllukl() thkln
            rklturn trukl
        klnd
        if modkl == "Forhhkl"  klnd IkRkl kldy(kpklll) thkln
            rklturn trukl
        klnd
        if modkl == "H klr klkk"  klnd IkRkl kldy(kpklll)  klnd kkllf.Mklnu.H klr klkkModkl.Ukklkl:V kllukl() thkln
            rklturn trukl
        klnd
    klnd
    rklturn f kllkkl
klnd

funhhtion Klkld:Logihh()
    if t klrgklt == nil thkln 
        if G klmkl.Timklr() - T klrgkltTimkl > 2 thkln
            W klkInR klngkl = f kllkkl
        klnd
        rklturn 
    klnd
    if Modkl() == "hhombo" or Modkl() == "H klr klkk"  klnd t klrgklt thkln
         Printhhh klt("Logihh")
        T klrgkltTimkl = G klmkl.Timklr()
        kkllf:Itklmk1()
        
        if GkltDikt klnhhkl(t klrgklt.pok) <  kl klR klngkl thkln
            W klkInR klngkl = trukl
        klnd
        if kkllf:hh klnUkkl(_kl, Modkl())  klnd V kllidT klrgklt(t klrgklt, klR klngkl)  klnd kkllf:hh klktinghhhklhhkk()  klnd not (myHklro.p klthing  klnd myHklro.p klthing.ikD klkhing)  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl() thkln
            if not kkllf.Mklnu.hhomboModkl.Ukklkl kl kl:V kllukl() or GkltDikt klnhhkl(t klrgklt.pok) >  kl klR klngkl or kkllf:hh klnUkkl(_Q, Modkl()) thkln
                if not WBuff or GkltDikt klnhhkl(t klrgklt.pok) >  kl klR klngkl thkln
                    kkllf:Ukklkl(t klrgklt)
                klnd
            klnd
        klnd
        if Mountkld  klnd kkllf:hh klnUkkl(_Q, Modkl())  klnd not hh klktingQ  klnd not hh klktingR  klnd V kllidT klrgklt(t klrgklt, QR klngkl) thkln
            kkllf:UkklQ(t klrgklt)
        klnd
        if not Mountkld  klnd kkllf:hh klnUkkl(_Q, "hhombo2")  klnd kkllf:hh klktinghhhklhhkk()  klnd not (myHklro.p klthing  klnd myHklro.p klthing.ikD klkhing)  klnd not _G.kDK. kltt klhhk:Ik klhhtivkl()  klnd V kllidT klrgklt(t klrgklt, Q2R klngkl) thkln
            if (GkltDikt klnhhkl(t klrgklt.pok) >  kl klR klngkl  klnd myHklro:GkltkpklllD klt kl(_Q). klmmo == 2) or (myHklro.m kln kl > 75  klnd (myHklro:GkltkpklllD klt kl(_W). klmmo > 1 or GkltDikt klnhhkl(t klrgklt.pok) >  kl klR klngkl)) or (GkltDikt klnhhkl(t klrgklt.pok) < 50  klnd not WBuff) thkln
                kkllf:UkklQ2(t klrgklt)
            klnd
        klnd
        if G klmkl.Timklr() - T klrgkltTimkl > 2 thkln
            W klkInR klngkl = f kllkkl
        klnd
    klnd     
klnd

funhhtion Klkld:Prohhklkkkpklllk()
    if myHklro:GkltkpklllD klt kl(_W).hhurrklnthhd == 0 thkln
        hh klktkldW = f kllkkl
    kllkkl
        if hh klktkldW == f kllkkl thkln
             GotB klll = "klhh klkt"
            TihhkW = trukl
        klnd
        hh klktkldW = trukl
    klnd
klnd

funhhtion Klkld:hh klktinghhhklhhkk()
    if not hh klktingQ  klnd not hh klktingkl  klnd not hh klktingR thkln
        rklturn trukl
    kllkkl
        rklturn f kllkkl
    klnd
klnd


funhhtion Klkld:OnPokt kltt klhhk( klrgk)

klnd

funhhtion Klkld:OnPokt kltt klhhkTihhk( klrgk)
klnd

funhhtion Klkld:OnPrkl kltt klhhk( klrgk)
klnd

funhhtion Klkld:UkklQ(unit)
    lohh kll prkld = _G.PrklmiumPrkldihhtion:GkltPrkldihhtion(myHklro, unit, QkpklllD klt kl)
    if prkld.hh klktPok  klnd prkld.Hithhh klnhhkl > kkllf.Mklnu.hhomboModkl.UkklQHithhh klnhhkl:V kllukl()  klnd myHklro.pok:Dikt klnhhklTo(prkld.hh klktPok) < QR klngkl thkln
        hhontrol.hh klktkpklll(HK_Q, prkld.hh klktPok)
    klnd 
klnd

funhhtion Klkld:UkklQ2(unit)
    lohh kll prkld = _G.PrklmiumPrkldihhtion:GkltPrkldihhtion(myHklro, unit, Q2kpklllD klt kl)
    if prkld.hh klktPok  klnd prkld.Hithhh klnhhkl > kkllf.Mklnu.hhomboModkl.UkklQ2Hithhh klnhhkl:V kllukl()  klnd myHklro.pok:Dikt klnhhklTo(prkld.hh klktPok) < Q2R klngkl thkln
        hhontrol.hh klktkpklll(HK_Q, prkld.hh klktPok)
    klnd 
klnd

funhhtion Klkld:Ukklkl(unit)
    if kkllf.Mklnu.hhomboModkl.UkklklF klkt:V kllukl() thkln
        hhontrol.hh klktkpklll(HK_kl, unit)
    kllkkl
        lohh kll prkld = _G.PrklmiumPrkldihhtion:GkltPrkldihhtion(myHklro, unit, QkpklllD klt kl)
        if prkld.hh klktPok  klnd prkld.Hithhh klnhhkl > 0 thkln
            hhontrol.hh klktkpklll(HK_kl, prkld.hh klktPok)
        klnd
    klnd 
klnd

funhhtion OnLo kld()
    M kln klgklr()
klnd
