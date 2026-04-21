local TalentLite = CreateFrame("Frame", "TalentLiteFrame", UIParent)
TalentLite:SetFrameStrata("FULLSCREEN_DIALOG")
TalentLite:SetFrameLevel(200)
TalentLite:SetSize(1080, 720)
TalentLite:SetPoint("CENTER")
TalentLite:SetMovable(true)
TalentLite:EnableMouse(true)
TalentLite:RegisterForDrag("LeftButton")
TalentLite:SetScript("OnDragStart", TalentLite.StartMoving)
TalentLite:SetScript("OnDragStop", TalentLite.StopMovingOrSizing)
TalentLite:Hide()

-------------------------------------------------
-- Safe Resolution Scaling
-------------------------------------------------

local baseWidth = 1080
local baseHeight = 720
local defaultScale = 0.90

local screenWidth = UIParent:GetWidth()
local screenHeight = UIParent:GetHeight()

local maxWidth = screenWidth * 0.95
local maxHeight = screenHeight * 0.90

local scaleX = maxWidth / baseWidth
local scaleY = maxHeight / baseHeight

local safeScale = math.min(scaleX, scaleY, 1) * defaultScale
TalentLite:SetScale(safeScale)

table.insert(UISpecialFrames, "TalentLiteFrame")

-------------------------------------------------
-- Layout
-------------------------------------------------
local TREE_WIDTH   = 330
local TREE_HEIGHT  = 603
local TREE_SPACING = 17
local BUTTON_SIZE  = 38
local BUTTON_XPAD  = 18
local BUTTON_YPAD  = 24

local trees = {}
local TAB_ORDER = { 2, 5, 6, 1, 3, 4 }

local currentPage = 1
local TREES_PER_PAGE = 3
-------------------------------------------------
-- Background
-------------------------------------------------
local bg = TalentLite:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
bg:SetVertexColor(0, 0, 0, 0.85)

-------------------------------------------------
-- Close Button
-------------------------------------------------
local close = CreateFrame("Button", nil, TalentLite, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -5, -5)
close:SetFrameStrata("FULLSCREEN_DIALOG")
close:SetFrameLevel(500)

-------------------------------------------------
-- Pages
-------------------------------------------------

local prevBtn = CreateFrame("Button", nil, TalentLite, "UIPanelButtonTemplate")
prevBtn:SetSize(80, 22)
prevBtn:SetPoint("BOTTOMRIGHT", -100, 33)
prevBtn:SetText("Prev")
prevBtn:SetFrameLevel(500)

local nextBtn = CreateFrame("Button", nil, TalentLite, "UIPanelButtonTemplate")
nextBtn:SetSize(80, 22)
nextBtn:SetPoint("BOTTOMRIGHT", -10, 33)
nextBtn:SetText("Next")
nextBtn:SetFrameLevel(500)

local pageText = TalentLite:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
pageText:SetPoint("BOTTOM", 0, 10)

local function UpdatePageText()
    local maxPages = math.ceil(#TAB_ORDER / TREES_PER_PAGE)
    pageText:SetText("Page " .. currentPage .. " / " .. maxPages)
end

prevBtn:SetScript("OnClick", function()
    if currentPage > 1 then
        currentPage = currentPage - 1
        TalentLite:Hide()
        TalentLite:Show()
        UpdatePageText()
    end
end)

nextBtn:SetScript("OnClick", function()
    local maxPages = math.ceil(#TAB_ORDER / TREES_PER_PAGE)
    if currentPage < maxPages then
        currentPage = currentPage + 1
        TalentLite:Hide()
        TalentLite:Show()
        UpdatePageText()
    end
end)

-------------------------------------------------
-- Draw Arrows
-------------------------------------------------
local function DrawArrows(tabIndex)
    local treeFrame = trees[tabIndex]
    if not treeFrame or not treeFrame.buttons then return end

    treeFrame.arrows = treeFrame.arrows or {}

    for i = 1, GetNumTalents(tabIndex) do
        local prereqTier, prereqColumn = GetTalentPrereqs(tabIndex, i)

        if prereqTier and prereqColumn then
            local prereqIndex = nil
            for j = 1, GetNumTalents(tabIndex) do
                local _, _, tier, column = GetTalentInfo(tabIndex, j)
                if tier == prereqTier and column == prereqColumn then
                    prereqIndex = j
                    break
                end
            end

            if prereqIndex then
                local destBtn = treeFrame.buttons[i]
                local srcBtn  = treeFrame.buttons[prereqIndex]

                if destBtn and srcBtn then
                    local tierDiff = destBtn.tier - srcBtn.tier
                    local colDiff  = destBtn.column - srcBtn.column

		    if tierDiff > 0 then
    		        -- Vertical line (supports multi-tier)
			local lineHeight = tierDiff * (BUTTON_SIZE + BUTTON_YPAD) - BUTTON_SIZE
    		        local line = treeFrame:CreateTexture(nil, "ARTWORK")
    		        line:SetTexture("Interface\\Buttons\\WHITE8X8")
    		        line:SetVertexColor(0.5, 0.5, 0.5, 0.8)
    		        line:SetSize(2, lineHeight)
   	                line:SetPoint("TOP", srcBtn, "BOTTOM", 0, 0)
    		        table.insert(treeFrame.arrows, line)

                    elseif colDiff > 0 and tierDiff == 0 then
                        -- Horizontal line right
                        local line = treeFrame:CreateTexture(nil, "ARTWORK")
                        line:SetTexture("Interface\\Buttons\\WHITE8X8")
                        line:SetVertexColor(0.5, 0.5, 0.5, 0.8)
                        line:SetSize(BUTTON_XPAD, 2)
                        line:SetPoint("LEFT", srcBtn, "RIGHT", 0, 0)
                        table.insert(treeFrame.arrows, line)

                    elseif colDiff < 0 and tierDiff == 0 then
                        -- Horizontal line left
                        local line = treeFrame:CreateTexture(nil, "ARTWORK")
                        line:SetTexture("Interface\\Buttons\\WHITE8X8")
                        line:SetVertexColor(0.5, 0.5, 0.5, 0.8)
                        line:SetSize(BUTTON_XPAD, 2)
                        line:SetPoint("RIGHT", srcBtn, "LEFT", 0, 0)
                        table.insert(treeFrame.arrows, line)
                    end
                end
            end
        end
    end
end

-------------------------------------------------
-- Custom Pet Talent Frame
-------------------------------------------------
local PetTalentFrame = nil

local function CreatePetTalentFrame()
    if PetTalentFrame then
        return PetTalentFrame
    end

    local frame = CreateFrame("Frame", "TalentLitePetFrame", UIParent)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetFrameLevel(200)
    frame:SetScale(safeScale)
    frame:SetSize(760, 680)
    frame:SetPoint("CENTER", 200, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
    bg:SetVertexColor(0, 0, 0, 0.85)

    local pointsText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    pointsText:SetPoint("BOTTOMRIGHT", -30, 10)
    frame.pointsText = pointsText

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)
    close:SetFrameStrata("FULLSCREEN_DIALOG")
    close:SetFrameLevel(500)

    -------------------------------------------------
    -- LEFT SIDE: PET SPELLS
    -------------------------------------------------
    local spellContainer = CreateFrame("Frame", nil, frame)
    spellContainer:SetPoint("TOPLEFT", 15, -40)
    spellContainer:SetSize(TREE_WIDTH, TREE_HEIGHT)
    spellContainer:SetFrameLevel(205)
    spellContainer.buttons = {}
    frame.spellContainer = spellContainer

    local spellBg = spellContainer:CreateTexture(nil, "BACKGROUND")
    spellBg:SetAllPoints()
    spellBg:SetTexture("Interface\\TalentFrame\\HunterBeastMastery-TopLeft")
    spellBg:SetTexCoord(0, 0.78, 0, 1)
    spellBg:SetAlpha(0.65)

    local spellTitle = spellContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    spellTitle:SetPoint("TOP", 0, 30)
    spellTitle:SetText("Pet Spells")

    -------------------------------------------------
    -- RIGHT SIDE: PET TALENTS
    -------------------------------------------------
    local container = CreateFrame("Frame", nil, frame)
    container:SetPoint("TOPLEFT", 380, -40)
    container:SetSize(TREE_WIDTH, TREE_HEIGHT)
    container.talents = {}
    frame.treeContainer = container

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", container, "TOP", 0, 30)
    title:SetText("Pet Talents")

    local _, _, _, background = GetTalentTabInfo(1, nil, true)
    if background then
        local bg2 = container:CreateTexture(nil, "BACKGROUND")
        bg2:SetAllPoints()
        bg2:SetTexture("Interface\\TalentFrame\\" .. background .. "-TopLeft")
        bg2:SetTexCoord(0.2, 0.98, 0, 1)
        bg2:SetAlpha(0.65)
    end

    table.insert(UISpecialFrames, "TalentLitePetFrame")
    PetTalentFrame = frame
    return frame
end

local function UpdatePetTalentFrame(frame)
    local talentGroup = GetActiveTalentGroup(nil, true)
    if not talentGroup then return end

    local petPoints = GetUnspentTalentPoints(nil, true, talentGroup)
    frame.pointsText:SetText("Pet Points: " .. (petPoints or 0))

    local container = frame.treeContainer
    local pointsSpent = select(3, GetTalentTabInfo(1, nil, true))

    for _, btn in pairs(container.talents) do
        btn:Hide()
    end

    local numTalents = GetNumTalents(1, nil, true)

    for i = 1, numTalents do
        local name, icon, tier, column, rank, maxRank = GetTalentInfo(1, i, nil, true, talentGroup)

        if name then
            local btn = container.talents[i]

            if not btn then
                btn = CreateFrame("Button", nil, container)
                btn:SetSize(32 / safeScale, 32 / safeScale)
                btn:SetFrameLevel(190)

                btn.texture = btn:CreateTexture(nil, "ARTWORK")
                btn.texture:SetAllPoints()

                btn.rankText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                btn.rankText:SetPoint("BOTTOMRIGHT", -2, 2)

                btn:SetScript("OnClick", function(self)
                    LearnTalent(1, i, true)
                end)

                btn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetTalent(1, i, nil, true, talentGroup)
                end)

                btn:SetScript("OnLeave", GameTooltip_Hide)

                container.talents[i] = btn
            end

            local x = (column - 1) * (BUTTON_SIZE + 30) + 43
            local y = -((tier - 1) * (BUTTON_SIZE + 40)) - 15
            btn:SetPoint("TOPLEFT", x, y)

            btn.texture:SetTexture(icon)
            btn.rankText:SetText(rank .. "/" .. maxRank)

            local requiredPoints = (tier - 1) * 5
            local tierMet  = pointsSpent >= requiredPoints
            local hasPoints = rank > 0

            if not tierMet and not hasPoints then
                btn.texture:SetDesaturated(true)
                btn.texture:SetAlpha(0.35)
                btn.rankText:SetAlpha(0.5)
            elseif tierMet and not hasPoints then
                btn.texture:SetDesaturated(false)
                btn.texture:SetAlpha(0.6)
                btn.rankText:SetAlpha(0.8)
            else
                btn.texture:SetDesaturated(false)
                btn.texture:SetAlpha(1)
                btn.rankText:SetAlpha(1)
            end

            btn:Show()
        end
    end
end

local function UpdatePetSpellPage(frame)
    if not UnitExists("pet") then return end

    local container = frame.spellContainer
    if not container then return end

    for _, btn in pairs(container.buttons) do
        btn:Hide()
    end

    local numSpells = select(1, HasPetSpells())
    if not numSpells or numSpells == 0 then return end

    local colWidth  = 150
    local rowHeight = 54
    local iconSize  = 36
    local cols      = 2
    local index     = 1

    for i = 1, numSpells do
        local name    = GetSpellName(i, BOOKTYPE_PET)
        local texture = GetSpellTexture(i, BOOKTYPE_PET)

        if name and texture and not IsPassiveSpell(i, BOOKTYPE_PET) then
            local btn = container.buttons[index]

            if not btn then
                btn = CreateFrame("Button", nil, container)
                btn:SetSize(colWidth, rowHeight)
                btn:SetFrameLevel(210)

                btn.icon = btn:CreateTexture(nil, "ARTWORK")
                btn.icon:SetSize(iconSize, iconSize)
                btn.icon:SetPoint("LEFT", 0, 0)

                btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                btn.text:SetPoint("LEFT", btn.icon, "RIGHT", 10, 0)
                btn.text:SetWidth(colWidth - iconSize - 20)
                btn.text:SetJustifyH("LEFT")
                btn.text:SetJustifyV("MIDDLE")
                btn.text:SetWordWrap(true)

                btn:RegisterForDrag("LeftButton")

                btn:SetScript("OnClick", function(self)
                    CastSpell(self.spellIndex, BOOKTYPE_PET)
                end)

                btn:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetSpell(self.spellIndex, BOOKTYPE_PET)
                end)

                btn:SetScript("OnLeave", GameTooltip_Hide)

                btn:SetScript("OnDragStart", function(self)
                    PickupSpell(self.spellIndex, BOOKTYPE_PET)
                end)

                container.buttons[index] = btn
            end

            local row = math.floor((index - 1) / cols)
            local col = (index - 1) % cols

            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", col * colWidth + 20, -row * rowHeight - 25)

            btn.icon:SetTexture(texture)
            btn.text:SetText(name)
            btn.spellIndex = i

            btn:Show()
            index = index + 1
        end
    end
end

-------------------------------------------------
-- Custom Demon Spell Frame
-------------------------------------------------
local DemonSpellFrame = nil

local function CreateDemonSpellFrame()
    if DemonSpellFrame then
        return DemonSpellFrame
    end

    local frame = CreateFrame("Frame", "TalentLiteDemonFrame", UIParent)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetFrameLevel(200)
    frame:SetScale(safeScale)
    frame:SetSize(400, 680)
    frame:SetPoint("CENTER", 0, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
    bg:SetVertexColor(0, 0, 0, 0.85)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -15)
    title:SetText("Demon Spells")

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)
    close:SetFrameStrata("FULLSCREEN_DIALOG")
    close:SetFrameLevel(500)

    local spellContainer = CreateFrame("Frame", nil, frame)
    spellContainer:SetPoint("TOPLEFT", 15, -40)
    spellContainer:SetSize(370, TREE_HEIGHT)
    spellContainer:SetFrameLevel(205)
    spellContainer.buttons = {}
    frame.spellContainer = spellContainer

    local spellBg = spellContainer:CreateTexture(nil, "BACKGROUND")
    spellBg:SetAllPoints()
    spellBg:SetTexture("Interface\\TalentFrame\\WarlockSummoning-TopLeft")
    spellBg:SetTexCoord(0, 0.78, 0, 1)
    spellBg:SetAlpha(0.65)

    table.insert(UISpecialFrames, "TalentLiteDemonFrame")
    DemonSpellFrame = frame
    return frame
end

local function UpdateDemonSpellFrame(frame)
    if not UnitExists("pet") then return end

    local container = frame.spellContainer
    if not container then return end

    for _, btn in pairs(container.buttons) do
        btn:Hide()
    end

    local colWidth  = 180
    local rowHeight = 54
    local iconSize  = 36
    local cols      = 2
    local index     = 1

    for i = 1, 10 do
        local name, _, texture, isToken = GetPetActionInfo(i)
        if name and texture and not isToken then
            local btn = container.buttons[index]

            if not btn then
                btn = CreateFrame("Button", nil, container)
                btn:SetSize(colWidth, rowHeight)
                btn:SetFrameLevel(210)

                btn.icon = btn:CreateTexture(nil, "ARTWORK")
                btn.icon:SetSize(iconSize, iconSize)
                btn.icon:SetPoint("LEFT", 0, 0)

                btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                btn.text:SetPoint("LEFT", btn.icon, "RIGHT", 10, 0)
                btn.text:SetWidth(colWidth - iconSize - 20)
                btn.text:SetJustifyH("LEFT")
                btn.text:SetJustifyV("MIDDLE")
                btn.text:SetWordWrap(true)

                btn:RegisterForDrag("LeftButton")

                btn:SetScript("OnClick", function(self)
                    if self.actionIndex then
                        CastPetAction(self.actionIndex)
                    end
                end)

                btn:SetScript("OnEnter", function(self)
                    if self.actionIndex then
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetPetAction(self.actionIndex)
                    end
                end)

                btn:SetScript("OnLeave", GameTooltip_Hide)

                btn:SetScript("OnDragStart", function(self)
                    if self.actionIndex then
                        PickupPetAction(self.actionIndex)
                    end
                end)

                container.buttons[index] = btn
            end

            local row = math.floor((index - 1) / cols)
            local col = (index - 1) % cols

            btn:ClearAllPoints()
            btn:SetPoint("TOPLEFT", col * colWidth + 10, -row * rowHeight - 15)

            btn.icon:SetTexture(texture)
            btn.text:SetText(name)
            btn.actionIndex = i

            btn:Show()
            index = index + 1
        end
    end
end
-------------------------------------------------
-- Pet Talent Button
-------------------------------------------------
local petTalentBtn = CreateFrame("Button", nil, TalentLite, "UIPanelButtonTemplate")
petTalentBtn:SetSize(100, 20)
petTalentBtn:SetPoint("RIGHT", close, "LEFT", -5, 0)
petTalentBtn:SetText("Pet Talents")
petTalentBtn:SetFrameLevel(500)

petTalentBtn:SetScript("OnClick", function()
    if not UnitExists("pet") then
        print("No pet found")
        return
    end

    local isDemon = UnitCreatureType("pet") == "Demon"

    if isDemon then
        local demonFrame = CreateDemonSpellFrame()
        demonFrame:SetShown(not demonFrame:IsShown())
        if demonFrame:IsShown() then
            TalentLite:Hide()
            UpdateDemonSpellFrame(demonFrame)
        end
        return
    end

    local talentGroup = GetActiveTalentGroup(nil, true)
    if not talentGroup then
        print("Pet has no talent group")
        return
    end

    local petFrame = CreatePetTalentFrame()
    petFrame:SetShown(not petFrame:IsShown())

    if petFrame:IsShown() then
        TalentLite:Hide()
        UpdatePetTalentFrame(petFrame)
        UpdatePetSpellPage(petFrame)
    end
end)
-------------------------------------------------
-- Points Remaining
-------------------------------------------------
local pointsText = TalentLite:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
pointsText:SetPoint("BOTTOMRIGHT", -30, 15)

local function UpdatePoints()
    local points = GetUnspentTalentPoints()
    if points then
        pointsText:SetText("Remaining: " .. points)
    end
end

-------------------------------------------------
-- Create Tree Frame
-------------------------------------------------
local function CreateTree(tabIndex, visualIndex, totalTabs)
    local treeFrame = CreateFrame("Frame", nil, TalentLite)
    treeFrame:SetFrameLevel(210)
    treeFrame:SetSize(TREE_WIDTH, TREE_HEIGHT)

    local totalWidth = totalTabs * TREE_WIDTH + (totalTabs - 1) * TREE_SPACING
    local startX = (TalentLite:GetWidth() - totalWidth) / 2

    treeFrame:SetPoint(
        "TOPLEFT",
        startX + (visualIndex - 1) * (TREE_WIDTH + TREE_SPACING),
        -45
    )

    local name, icon, pointsSpent, background = GetTalentTabInfo(tabIndex)

    local bg = treeFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\TalentFrame\\" .. background .. "-TopLeft")
    bg:SetAlpha(0.65)

    local title = treeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, 30)
    title:SetText(name)

    treeFrame.title = title
    trees[tabIndex] = treeFrame
end

-------------------------------------------------
-- Create Talents
-------------------------------------------------
local function CreateTalents(tabIndex)
    local treeFrame = trees[tabIndex]
    local numTalents = GetNumTalents(tabIndex)
    treeFrame.buttons = {}

    for i = 1, numTalents do
        local name, icon, tier, column, rank, maxRank = GetTalentInfo(tabIndex, i)

        local btn = CreateFrame("Button", nil, treeFrame)
        btn:SetFrameLevel(220)
        btn:SetSize(BUTTON_SIZE, BUTTON_SIZE)

        local x = (column - 1) * (BUTTON_SIZE + BUTTON_XPAD) + 33
        local y = -((tier - 1) * (BUTTON_SIZE + BUTTON_YPAD)) - 15
        btn:SetPoint("TOPLEFT", x, y)

        local tex = btn:CreateTexture(nil, "ARTWORK")
        tex:SetAllPoints()
        tex:SetTexture(icon)
        btn.texture = tex

        local rankText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        rankText:SetPoint("CENTER", 0, -15)
        btn.rankText = rankText

local rankBg = btn:CreateTexture(nil, "OVERLAY")
rankBg:SetTexture("Interface\\Buttons\\WHITE8X8")
rankBg:SetVertexColor(0, 0, 0, 0.75)
rankBg:SetSize(20, 12)
rankBg:SetPoint("CENTER", 0, -16)
btn.rankBg = rankBg

        btn.tabIndex    = tabIndex
        btn.talentIndex = i
        btn.tier        = tier
        btn.column      = column

        btn:SetScript("OnClick", function(self)
            LearnTalent(self.tabIndex, self.talentIndex)
        end)

        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetTalent(self.tabIndex, self.talentIndex)
        end)

        btn:SetScript("OnLeave", GameTooltip_Hide)

        treeFrame.buttons[i] = btn
    end
end

-------------------------------------------------
-- Refresh Talents
-------------------------------------------------
local function RefreshTalents()
    for visualIndex = 1, #TAB_ORDER do
        local tab       = TAB_ORDER[visualIndex]
        local treeFrame = trees[tab]
        local pointsSpent = select(3, GetTalentTabInfo(tab))

        if treeFrame and treeFrame.buttons then
            for _, btn in ipairs(treeFrame.buttons) do
                local forcedRank = 0
                local forcedMax  = 0

                for i = 1, GetNumTalents(tab) do
                    local name, icon, tier, col, rank, max = GetTalentInfo(tab, i)
                    if tier == btn.tier and col == btn.column then
                        forcedRank = rank or 0
                        forcedMax  = max or 0
                        break
                    end
                end

                btn.rankText:SetText(forcedRank .. "/" .. forcedMax)

                -- Drag from spellbook by name lookup
                if forcedRank > 0 then
                    local talentName = GetTalentInfo(tab, btn.talentIndex)
                    local spellIndex = nil

                    for s = 1, GetNumSpellTabs() do
                        local _, _, offset, count = GetSpellTabInfo(s)
                        for j = offset + 1, offset + count do
                            if GetSpellName(j, BOOKTYPE_SPELL) == talentName then
                                spellIndex = j
                                break
                            end
                        end
                        if spellIndex then break end
                    end

                    if spellIndex then
                        btn:RegisterForDrag("LeftButton")
                        btn:SetScript("OnDragStart", function(self)
                            PickupSpell(spellIndex, BOOKTYPE_SPELL)
                        end)
                        btn:SetScript("OnReceiveDrag", function(self)
                            PickupSpell(spellIndex, BOOKTYPE_SPELL)
                        end)
                    else
                        btn:RegisterForDrag(nil)
                        btn:SetScript("OnDragStart", nil)
                        btn:SetScript("OnReceiveDrag", nil)
                    end
                else
                    btn:RegisterForDrag(nil)
                    btn:SetScript("OnDragStart", nil)
                    btn:SetScript("OnReceiveDrag", nil)
                end

                local requiredPoints = (btn.tier - 1) * 5
                local tierMet   = pointsSpent >= requiredPoints
                local hasPoints = forcedRank > 0

                if not tierMet and not hasPoints then
                    btn.texture:SetDesaturated(true)
                    btn.texture:SetAlpha(0.35)
                    btn.rankText:SetAlpha(0.5)
                elseif tierMet and not hasPoints then
                    btn.texture:SetDesaturated(false)
                    btn.texture:SetAlpha(0.6)
                    btn.rankText:SetAlpha(0.8)
                else
                    btn.texture:SetDesaturated(false)
                    btn.texture:SetAlpha(1)
                    btn.rankText:SetAlpha(1)
                end
            end
        end
    end

    UpdatePoints()
-- Update points spent per tree
    for visualIndex = 1, #TAB_ORDER do
        local tab = TAB_ORDER[visualIndex]
        local treeFrame = trees[tab]
        if treeFrame then
            local pointsSpent = select(3, GetTalentTabInfo(tab))

            if not treeFrame.pointsSpentText then
                treeFrame.pointsSpentText = treeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                treeFrame.pointsSpentText:SetPoint("BOTTOMRIGHT", -5, 5)
            end

            treeFrame.pointsSpentText:SetText("Points: " .. (pointsSpent or 0))
        end
    end
end

-------------------------------------------------
-- Show/Hide Pet Button
-------------------------------------------------
local function UpdatePetTalentButton()
    if not UnitExists("pet") then
        petTalentBtn:Hide()
        return
    end
    petTalentBtn:Show()
    if UnitCreatureType("pet") == "Demon" then
        petTalentBtn:SetText("Pet Spells")
    else
        petTalentBtn:SetText("Pet Talents")
    end
end

-------------------------------------------------
-- Initialize
-------------------------------------------------
TalentLite:SetScript("OnShow", function()

    if PetTalentFrame and PetTalentFrame:IsShown() then
        PetTalentFrame:Hide()
    end

    -- Hide existing trees
    for _, frame in pairs(trees) do
        if frame then frame:Hide() end
    end

    local startIndex = (currentPage - 1) * TREES_PER_PAGE + 1
    local endIndex = math.min(startIndex + TREES_PER_PAGE - 1, #TAB_ORDER)

    local visualIndex = 1

    for i = startIndex, endIndex do
        local tab = TAB_ORDER[i]

        if not trees[tab] then
            CreateTree(tab, visualIndex, TREES_PER_PAGE)
            CreateTalents(tab)
            DrawArrows(tab)
        else
            trees[tab]:Show()
            trees[tab]:SetPoint(
                "TOPLEFT",
                ((TalentLite:GetWidth() - (TREES_PER_PAGE * TREE_WIDTH + (TREES_PER_PAGE - 1) * TREE_SPACING)) / 2)
                + (visualIndex - 1) * (TREE_WIDTH + TREE_SPACING),
                -45
            )
        end

        visualIndex = visualIndex + 1
    end

    RefreshTalents()
    UpdatePetTalentButton()

    if PetTalentFrame and PetTalentFrame:IsShown() then
        UpdatePetTalentFrame(PetTalentFrame)
        UpdatePetSpellPage(PetTalentFrame)
    end
UpdatePageText()
end)

TalentLite:RegisterEvent("CHARACTER_POINTS_CHANGED")
TalentLite:RegisterEvent("PLAYER_TALENT_UPDATE")
TalentLite:RegisterEvent("UNIT_PET")
TalentLite:RegisterEvent("PET_BAR_UPDATE")
TalentLite:RegisterEvent("PET_TALENT_UPDATE")

TalentLite:SetScript("OnEvent", function(self, event, ...)
    if event == "UNIT_PET" or event == "PET_BAR_UPDATE" then
        UpdatePetTalentButton()

        if PetTalentFrame and PetTalentFrame:IsShown() then
            UpdatePetTalentFrame(PetTalentFrame)
        end
        return
    end

    if event == "PET_TALENT_UPDATE" then
        if PetTalentFrame and PetTalentFrame:IsShown() then
            UpdatePetTalentFrame(PetTalentFrame)
            UpdatePetSpellPage(PetTalentFrame)
        end
        return
    end

    RefreshTalents()
end)

-------------------------------------------------
-- Slash
-------------------------------------------------
SLASH_TALENTLITE1 = "/tlite"
SlashCmdList["TALENTLITE"] = function()
    TalentLite:SetShown(not TalentLite:IsShown())
end

-- Unified toggle (single source of truth)
local function TalentLite_Toggle()
    TalentLite:SetShown(not TalentLite:IsShown())
end

-- Keybind (N) + anything calling this
function ToggleTalentFrame()
    TalentLite_Toggle()
end

-- UI panels (default buttons + many addons)
hooksecurefunc("ShowUIPanel", function(frame)
    if frame == PlayerTalentFrame then
        if PlayerTalentFrame:IsShown() then
            PlayerTalentFrame:Hide()
        end
        TalentLite_Toggle()
    end
end)

-- Direct frame Show() calls (covers more edge cases)
if PlayerTalentFrame then
    PlayerTalentFrame.Show = function()
        TalentLite_Toggle()
    end
end

-------------------------------------------------
-- Suppress Blizzard Talent Frame
-------------------------------------------------

-- Hide default frame if it appears
if PlayerTalentFrame then
    PlayerTalentFrame:UnregisterAllEvents()
    PlayerTalentFrame:Hide()
    PlayerTalentFrame:SetParent(nil)
end

-- Override respec confirmation
TalentLite:RegisterEvent("CONFIRM_TALENT_WIPE")

local originalOnEvent = TalentLite:GetScript("OnEvent")

TalentLite:SetScript("OnEvent", function(self, event, ...)
    if event == "CONFIRM_TALENT_WIPE" then
        StaticPopup_Show("CONFIRM_TALENT_WIPE")
        return
    end

    if originalOnEvent then
        originalOnEvent(self, event, ...)
    end
end)

-- Override Blizzard toggle completely
function ToggleTalentFrame()
    TalentLite:SetShown(not TalentLite:IsShown())
end