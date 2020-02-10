local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local rand, tinsert = math.random, table.insert

local RBG = R.bgFrames

local fullnames = {Rat = T.RatBlue.displayText.."Rat|r-Faerlina"}
local names = {"Graphima","Pixstewart","Harrigrin","Parbroom","Wepower","Harilda","Kreejhom","Ra","Morclop","Jaendoyle","Quinnfoot","Dip","Dirt","Dink","Egg","Anticipating","Dorc", "Stnu", "Drexxor", "Amilcar", "Daisy", "Cocoa", "Ghost", "Ffion", "Andy"}
local servers = {"Anathema","Bigglesworth","Benediction","Blaumeux","Faerlina","Fairbanks","Herrod","Incendius","Kirtonos","Kurinaxx","Kromcrush","Netherwind","Rattlegore","Skeram","Smolderweb","Stalagg","Sulfuras","Thalnos","Thunderfury","Whitemane"}
local forceWarlock,forcePriest,forceDruid,forcePaladin,forceHunter = {Rat=true},{Egg=true, Dip=true, Dirt=true, Dink=true},{Stnu=true,Drexxor=true},{Anticipating=true,Andy=true},{Dorc=true}
local classes = {"Warrior","Paladin","Hunter","Rogue","Priest","Shaman","Mage","Warlock","Druid"}
local powerTypes = {"Mana","Energy","Rage"}

--make some full names
do 
    for i=1,100 do
        local name = names[rand(#names)]
        local server = servers[rand(#servers)]
        fullnames[name] =  name.."-"..server
    end
end

function RBG:GenerateEnemy()
    local name, fullname = next (fullnames)
    local class = (forceWarlock[name] and "Warlock") or (forcePriest[name] and "Priest") or (forceDruid[name] and "Druid") or (forcePaladin[name] and "Paladin") or (forceHunter[name] and "Hunter") or classes[rand(#classes)]
    local enemy = 
    {
        name = name,
        fullname = fullname,
        class = class,
        maxHealth = 100,
        currentHealth = rand(0,100),
        maxPower = 100,
        currentPower = rand(0,100),
        powerType = powerType[rand(3)],
        rank = rand(0,14)
    }
    return enemy
end
