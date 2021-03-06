local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local rand, tinsert, tremove = math.random, table.insert, table.remove

local RBG = R.bgFrames
local Rat = T.RatBlue.displayText.."Rat"
local shortnames, fullnames = {}, {}; 
local names = {"Graphima","Pixstewart","Harrigrin","Parbroom","Wepower","Harilda","Kreejhom","Dog","Morclop","Juised","Jaendoyle","Quinnfoot","Dip","Dirt","Dink","Egg","Anticipating","Dorc", "Stnu", "Drexxor", "Amilcar", "Daisy", "Cocoa", "Ghost", "Ffion", "Andy"}
local servers = {"Anathema","Bigglesworth","Benediction","Blaumeux","Faerlina","Fairbanks","Herrod","Incendius","Kirtonos","Kurinaxx","Kromcrush","Netherwind","Rattlegore","Skeram","Smolderweb","Stalagg","Sulfuras","Thalnos","Thunderfury","Whitemane"}
local forceWarlock,forcePriest,forceDruid,forcePaladin,forceHunter = {Juised=true},{Egg=true, Dip=true, Dirt=true, Dink=true},{Stnu=true,Drexxor=true},{Anticipating=true,Andy=true},{Dorc=true}
forceWarlock[Rat] = true
local classes = {"WARRIOR","PALADIN","HUNTER","ROGUE","PRIEST","SHAMAN","MAGE","WARLOCK","DRUID"}
local powerTypes = {"Mana","Energy","Rage"}

--make some full names
local function buildNames()
    for i=1,#names do
        local server = servers[rand(1, #servers)]
        fullnames[names[i]] =  names[i].."-"..server
        shortnames[i] = names[i]
    end
    tinsert(shortnames, Rat)
    fullnames[Rat] = T.RatBlue.displayText.."Rat|r-Faerlina"
end

do 
    buildNames()
end



function RBG:GenerateEnemy()
    --ensure names only get picked once
    if #shortnames <= 1 then buildNames() end
    local ndx = rand(1, #shortnames)
    local rname = shortnames[ndx]
    local rfullname = fullnames[rname]
    fullnames[rname] = nil
    tremove(shortnames, ndx)
    --R:Print(rname, rfullname)
    local rclass = forceWarlock[rname] and "WARLOCK" or forcePriest[rname] and "PRIEST" or forceDruid[rname] and "DRUID" or forcePaladin[rname] and "PALADIN" or forceHunter[rname] and "HUNTER" or classes[rand(1,#classes)]
    local enemy = 
    {
        name = rname,
        fullname = rfullname,
        class = rclass,
        maxHealth = 100,
        currentHealth = rand(0,100),
        maxPower = 100,
        currentPower = rand(0,100),
        maxMana = 100,
        currentMana = rand(0,100),
        powerType = powerTypes[rand(1,3)],
        rank = rand(0,14),
        flag = false
    }                                               --currentMana only used as a backup for druids that are in form with Mana Only selected
    return enemy
end
