local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local rand, tinsert, tremove = math.random, table.insert, table.remove

local RBG = R.bgFrames

local fullnames = {}; fullnames["Rat"] = T.RatBlue.displayText.."Rat|r-Faerlina"
local names = {"Graphima","Pixstewart","Harrigrin","Parbroom","Wepower","Harilda","Kreejhom","Dog","Morclop","Jaendoyle","Quinnfoot","Dip","Dirt","Dink","Egg","Anticipating","Dorc", "Stnu", "Drexxor", "Amilcar", "Daisy", "Cocoa", "Ghost", "Ffion", "Andy"}
local servers = {"Anathema","Bigglesworth","Benediction","Blaumeux","Faerlina","Fairbanks","Herrod","Incendius","Kirtonos","Kurinaxx","Kromcrush","Netherwind","Rattlegore","Skeram","Smolderweb","Stalagg","Sulfuras","Thalnos","Thunderfury","Whitemane"}
local forceWarlock,forcePriest,forceDruid,forcePaladin,forceHunter = {Rat=true},{Egg=true, Dip=true, Dirt=true, Dink=true},{Stnu=true,Drexxor=true},{Anticipating=true,Andy=true},{Dorc=true}
local classes = {"Warrior","Paladin","Hunter","Rogue","Priest","Shaman","Mage","Warlock","Druid"}
local powerTypes = {"Mana","Energy","Rage"}

--make some full names
do 
    for i=1,#names do
        local server = servers[rand(1, #servers)]
        fullnames[names[i]] =  names[i].."-"..server
    end
end

function RBG:GenerateEnemy()
    --ensure names only get picked once
    local ndx = rand(1, #names + 1)
    local rname = names[ndx] or "Rat"
    local rfullname = fullnames[rname]
    fullnames[rname] = nil
    if rname ~= "Rat" then tremove(names, ndx) end
    local rclass = forceWarlock[rname] and "Warlock" or forcePriest[rname] and "Priest" or forceDruid[rname] and "Druid" or forcePaladin[rname] and "Paladin" or forceHunter[rname] and "Hunter" or classes[rand(1,#classes)]
    local enemy = 
    {
        name = rname.." "..rclass,
        fullname = rfullname,
        class = rclass,
        maxHealth = 100,
        currentHealth = rand(0,100),
        maxPower = 100,
        currentPower = rand(0,100),
        powerType = powerTypes[rand(1,3)],
        rank = rand(0,14)
    }
    return enemy
end
