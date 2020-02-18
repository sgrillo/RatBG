local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local tinsert = tinsert

local RBG = R.bgFrames

function RBG:BuildClassIcon(frame)

    local classIcon = CreateFrame("Frame", frame:GetName().."ClassIcon", frame)

    classIcon.bg = classIcon:CreateTexture(nil,"BORDER")
    classIcon.icon = classIcon:CreateTexture(nil,"ARTWORK")

    classIcon.bg:SetAllPoints()
    classIcon.icon:SetAllPoints()

    classIcon.staticUpdate = RBG.UpdateClassStatic

    --icon goes into container, not onto frame

    classIcon.container = frame.leftBox

    tinsert(classIcon.container.elements, classIcon)

    classIcon.IsActive = function() return RBG.db.icons.classIcon end

    RBG:RegisterUpdates(classIcon)

    classIcon:AddBorder()

end

function RBG:UpdateClassStatic(frame)
    if not RBG.db.icons.classIcon then self:Hide() return end
    local enemy = frame:GetEnemy()

    self.bg:SetColorTexture(rgb(RBG.db.bgColor))

    if self.container.attach == self.container then
        self:SetPoint("TOPLEFT", self.container, "TOPLEFT")
    else
        local attachpoint = self.container.attach
        self:SetPoint("TOPLEFT", attachpoint, "TOPRIGHT")
    end

    local dim = frame:GetHeight()
    self:SetSize(dim, dim)

    if enemy and enemy.class then
        self.icon:SetTexture(T.Media.classTextures)
        self.icon:SetTexCoord(unpack(T.Media.classTextureCoords[enemy.class]))
    end


end