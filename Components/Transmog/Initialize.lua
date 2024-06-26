local TMOGFrame = CreateFrame("Frame")
TMOGFrame:RegisterEvent("UNIT_MODEL_CHANGED")
TMOGFrame:SetScript(
    "OnEvent",
    function(_, event)
        if (event == UNIT_MODEL_CHANGED) then
            LoadSlotIcons()
        end
    end
)

function InitializeTransmog()
    createTransmogWindow()

    SubscribeToForgeTopic(
        ForgeTopic.LOAD_XMOG,
        function(msg)
            if tonumber(msg) == 1 then
                PushForgeMessage(ForgeTopic.COLLECTION_INIT, "-1")
                PushForgeMessage(ForgeTopic.LOAD_XMOG_SET, tostring(MAX_SETS))
                PushForgeMessage(ForgeTopic.GET_XMOG_SETS, "-1")

                TransmogWindow:Show()
            else
                TransmogWindow:Hide()
            end
        end
    )
end

SubscribeToForgeTopic(
    ForgeTopic.COLLECTION_INIT,
    function(msg)
        SLOTS_AS_PAGES = {}
        for _, entry in ipairs(DeserializeMessage(DeserializerDefinitions.GET_COLLECTION, msg)) do
            local page = 1
            SLOTS_AS_PAGES[entry["slotId"]] = {}

            if entry["META"] then
                if entry["slotId"] == 15 or entry["slotId"] == 16 then
                    print(entry["slotId"] .. " : " .. entry["META"])
                end

                local count = 0
                for _, meta in ipairs(entry["META"]) do
                    if not SLOTS_AS_PAGES[entry["slotId"]][page] then
                        SLOTS_AS_PAGES[entry["slotId"]][page] = {}
                    end

                    table.insert(SLOTS_AS_PAGES[entry["slotId"]][page], meta)

                    count = count + 1
                    if count == 36 then
                        page = page + 1
                    end
                end
            end
        end
        SelectSlotFilter()
        SetPageNumber(CURRENT_PAGE)
    end
)

SubscribeToForgeTopic(
    ForgeTopic.XMOG_OK,
    function(msg)
        --print(msg) -- slot ^ target item ^ appearance
        local item = DeserializeMessage(DeserializerDefinitions.XMOG_OK, msg)[1]
        if item then
            local _, _, _, _, _, _, _, _, _, icon = GetItemInfo(tonumber(item.tmog))
            SetSlotIcon(tonumber(item.slot), icon, tonumber(item.target))
        end
    end
)

SubscribeToForgeTopic(
    ForgeTopic.LOAD_XMOG_SET,
    function(msg)
        local item = DeserializeMessage(DeserializerDefinitions.LOAD_XMOG_SET, msg)[1]
        if item then
            TransmogWindow.modelhub.setSelect = item.setid
            TransmogWindow.modelhub.slots[0].appearance = tonumber(item.head)
            TransmogWindow.modelhub.slots[2].appearance = tonumber(item.shoulders)
            TransmogWindow.modelhub.slots[3].appearance = tonumber(item.shirt)
            TransmogWindow.modelhub.slots[4].appearance = tonumber(item.chest)
            TransmogWindow.modelhub.slots[5].appearance = tonumber(item.waist)
            TransmogWindow.modelhub.slots[6].appearance = tonumber(item.legs)
            TransmogWindow.modelhub.slots[7].appearance = tonumber(item.feet)
            TransmogWindow.modelhub.slots[8].appearance = tonumber(item.wrists)
            TransmogWindow.modelhub.slots[9].appearance = tonumber(item.hands)
            TransmogWindow.modelhub.slots[14].appearance = tonumber(item.back)
            TransmogWindow.modelhub.slots[15].appearance = tonumber(item.mh)
            TransmogWindow.modelhub.slots[16].appearance = tonumber(item.oh)
            TransmogWindow.modelhub.slots[17].appearance = tonumber(item.ranged)
            TransmogWindow.modelhub.slots[18].appearance = tonumber(item.tabard)
            LoadSlotIcons()
        end
        RedrawModel()
    end
)

SubscribeToForgeTopic(
    ForgeTopic.SAVE_XMOG_SET,
    function(msg)
        CURRENT_SET = tonumber(msg)
        PushForgeMessage(ForgeTopic.GET_XMOG_SETS, "-1")
        PushForgeMessage(ForgeTopic.LOAD_XMOG_SET, CURRENT_SET)

        PENDING_CHANGES = {}
        ShowAcceptIfPending()
    end
)

SubscribeToForgeTopic(
    ForgeTopic.GET_XMOG_SETS,
    function(msg)
        CHARACTER_XMOG_SETS = {}
        if msg ~= "empty" then
            for _, entry in ipairs(DeserializeMessage(DeserializerDefinitions.LOAD_XMOG_SET, msg)) do
                table.insert(CHARACTER_XMOG_SETS, entry)
            end
        end

        if #CHARACTER_XMOG_SETS < MAX_SETS then
            table.insert(CHARACTER_XMOG_SETS, ADD_NEW_SET)
        end
        InitSetDropdown()
    end
)
