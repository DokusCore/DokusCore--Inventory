--------------------------------------------------------------------------------
---------------------------------- DokusCore -----------------------------------
--------------------------------------------------------------------------------
Drops = {}
BoxIDsTxt = {}
InvMenuOpen = false
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Register whenever the user opens the inventory
--------------------------------------------------------------------------------
CreateThread(function()
  while true do Wait(0)
    local Control = IsControlPressed(0, Keys['TAB'])
    if not InvMenuOpen and Control then
      InvMenuOpen = true
      local Items = {}
      local cData = TSC('DokusCore:S:Core:GetCoreUserData')
      local Table, Steam, CharID = DB.Banks.Get, cData.Steam, cData.CharID
      local Bank = TSC('DokusCore:S:Core:DB:GetViaSteamAndCharID', {Table, Steam, CharID})[1]
      TriggerEvent('DokusCore:Backpack:C:UpdateValutas', Bank)
      local InvData = TSC('DokusCore:S:Core:DB:GetInventory', {Steam, CharID})
      for k, v in pairs(InvData) do local Item, Amount = v.Item, v.Amount table.insert(Items, {Item, Amount}) end
      SendNUIMessage({ items = Items })
      OpenInv(cData.Steam, cData.CharID) Wait(500)
      Items = {}
    end
  end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Update the valuta values when the inventory opens
--------------------------------------------------------------------------------
RegisterNetEvent('DokusCore:Backpack:C:UpdateValutas')
AddEventHandler('DokusCore:Backpack:C:UpdateValutas', function(Bank)
  while InvMenuOpen do Wait(0)
    SendNUIMessage({ wallet = Bank.Money, gold = Bank.Gold,
      bank = Bank.BankMoney, label = 'CURRENT JOB',
    }) Wait(1000)
	end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- This triggers when ever the user closes the inventory
--------------------------------------------------------------------------------
RegisterNUICallback('NUIFocusOff', function()
  InvMenuOpen = false
  SetNuiFocus(false, false)
  SendNUIMessage({type = 'close'})
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- This triggers whenever the user drops an item
--------------------------------------------------------------------------------
RegisterNUICallback("drop", function(Data)
  local Stop = false
  local Item, Amount = Data.item, Data.count
  local Ped = PlayerPedId()
  local pCoords = GetEntityCoords(Ped)
  local x,y,z = pCoords[1], pCoords[2], (pCoords[3] + 2.0)
  local nCoords = vector3(x,y,z)
  local Hash = 'P_COTTONBOX01X'
  if (IsModelValid(Hash)) then LoadModel(Hash) end
  local cData = TSC('DokusCore:S:Core:GetCoreUserData')
  local Steam, CharID = cData.Steam, cData.CharID
  local NewBox, IsBoxMy, ExItem = true, false, false
  local _BoxID, _Item, _Amount, _Coords = nil, nil, nil, nil

  function CreateNewDrop()
    local Box = CreateObject(Hash, x,y,z, true, false, false)
    PlaceObjectOnGroundProperly(Box)
    FreezeEntityPosition(Box, true)
    SetEntityAsMissionEntity(Box)
    PlaySoundFrontend("show_info", "Study_Sounds", true, 0)
    local Index = { false, Box, Item, Amount, nCoords }
    AddToStorage(Steam, CharID, 'Drop', Index)
    TSC('DokusCore:S:Core:DB:DelInventoryItem', {Item, Amount, Steam, CharID})
    Animation(Ped)
  end

  local Data = TSC('DokusCore:S:Core:DB:GetAllStorages')
  for k,v in pairs(Data) do
    local Data = ConvertToCoords(v.Coords)
    local Data = SplitString(Data, " ")
    local x,y,z = tonumber(Data[1]), tonumber(Data[2]), tonumber(Data[3])
    local Coords = vector3(x,y,z)
    local Dist = Vdist(Coords, pCoords)
    local IsUser = (v.Steam == Steam)

    if (not (IsUser) and (Dist <= 5)) then Stop = true print("Not your Box") return end
    if ((IsUser) and ((Dist <= 5) and (Dist > 2.5))) then Stop = true print("Get Closer to your box") return end

    if (Dist <= 2.5) then
      if (v.Steam == Steam) then
        NewBox = false IsBoxMy = true _BoxID = v.BoxID
        if (v.Item == Item) then
          ExItem = true
          _BoxID, _Item, _Amount, _Coords = v.BoxID, Item, Amount, v.Coords
        end
      end
    end
  end

  if not (Stop) then
    if (NewBox) then CreateNewDrop() end
    if not (NewBox) then
      if ((IsBoxMy) and (ExItem)) then return AddToExistingItem(Ped, Steam, CharID, _BoxID, _Item, _Amount, nCoords) end
      if ((IsBoxMy) and not (ExItem)) then return InsertNewItemIntoBox(Ped, Steam, CharID, _BoxID, Item, Amount, nCoords) end
    end
  end
end)

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
CreateThread(function()
  while true do Wait(1000)
    local DropTxts = {}
    local Data = TSC('DokusCore:S:Core:DB:GetAllStorages')
    if (Data[1] ~= nil) then GrabData = true
      while GrabData do Wait(0)
        for k,v in pairs(Data) do
          table.insert(DropTxts, { v.BoxID, v.Coords })
        end GrabData = false
      end
      BoxIDsTxt = FilterTableFromDupes(DropTxts)
    end
  end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
CreateThread(function()
  while true do Wait(3000)
    if (BoxIDsTxt[1] ~= nil) then
      ShowBoxTxt = true
      while ShowBoxTxt do Wait(0)
        local Ped = PlayerPedId()
        local pCoords = GetEntityCoords(Ped)
        for k,v in pairs(BoxIDsTxt) do
          local BoxID, Coords = v[1], v[2]
          local Data = ConvertToCoords(Coords)
          local Data = SplitString(Data, " ")
          local x,y,z = tonumber(Data[1]), tonumber(Data[2]), tonumber(Data[3])
          local Coords = vector3(x,y,z)
          local Dist = Vdist(Coords, pCoords)
          local Control = IsControlJustReleased(1, Keys['LALT'])
          if (Dist <= 10) then DrawText3D(x,y,(z - 2.5), 150, 'Loot Drop') end
          if (Dist <= 2.5) then DrawText3D(x,y,(z - 2.4), 600, '~color_green~ALT') end
          if ((Dist <= 2.5) and Control) then
            local Data = TSC('DokusCore:S:Core:DB:GetStorageViaBoxID', { BoxID })
            for k,v in pairs(Data) do
              local Item, Amount = v.Item, v.Amount
              local Steam, CharID = v.Steam, v.CharID
              TSC('DokusCore:S:Core:DB:AddInventoryItem', { Steam, CharID, nil, { Item, Amount, nil }})
              TSC('DokusCore:S:Core:DB:DelStorageItemViaBoxID', { BoxID, Item })
              BoxIDsTxt = {}
            end
            Animation(Ped)
            DeleteEntity(BoxID)
          end
        end
      end
    end
  end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function CreateBox(Coords, BoxID)
  local Hash = 'P_COTTONBOX01X'
  local Box = CreateObject(Hash, Coords, true, false, false)
  PlaceObjectOnGroundProperly(Box)
  FreezeEntityPosition(Box, true)
  SetEntityAsMissionEntity(Box)
  PlaySoundFrontend("show_info", "Study_Sounds", true, 0)
  TSC('DokusCore:S:Core:DB:UpdateBoxIDs', {BoxID, Box})
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Delete all boxes on the map. Give all boxes a new ID
-- Then place all boxes back on the map.
--------------------------------------------------------------------------------
CreateThread(function()
  local IDs = {}
  -- Delete all boxes on the map
  local Data = TSC('DokusCore:S:Core:DB:GetAllStorages')
  for k,v in pairs(Data) do table.insert(IDs, { v.BoxID, v.Coords }) end
  local Filter = FilterTableFromDupes(IDs)
  for k,v in pairs(Filter) do DeleteEntity(v[1]) end
  Wait(2000)
  -- Add all existing boxes back on the map
  for k,v in pairs(Filter) do
    local Data = ConvertToCoords(v[2])
    local Data = SplitString(Data, " ")
    local x,y,z = tonumber(Data[1]), tonumber(Data[2]), (tonumber(Data[3] - 3))
    local Coords = vector3(x,y,z)
    CreateBox(Coords, v[1])
  end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



































--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
