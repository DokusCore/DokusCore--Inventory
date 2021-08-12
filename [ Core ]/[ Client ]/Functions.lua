--------------------------------------------------------------------------------
---------------------------------- DokusCore -----------------------------------
--------------------------------------------------------------------------------
function OpenInv(Steam, CharID) InvMenuOpen = true SetNuiFocus(true, true) SendNUIMessage({ action = "open", array = source, Steam = Steam, CharID = CharID }) end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function CloseInv() InvMenuOpen = false SetNuiFocus(false, false) SendNUIMessage({ action = "close" }) end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function LoadModel(pHash)
  if not HasModelLoaded(pHash) then RequestModel(pHash)
    while not HasModelLoaded(pHash) do Wait(10) end
  end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function DrawText3D(x, y, z, f, text)
    local onScreen,_x,_y = GetScreenCoordFromWorldCoord(x, y, z)
    local px,py,pz=table.unpack(GetGameplayCamCoord())
    SetTextScale(0.35, 0.35)
    SetTextFontForCurrentCommand(1)
    SetTextColor(255, 255, 255, 215)
    local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
    SetTextCentre(1)
    DisplayText(str,_x,_y)
    local factor = (string.len(text)) / f
    DrawSprite("generic_textures", "hud_menu_4a", _x, _y+0.0125,0.015+ factor, 0.03, 0.1, 100, 1, 1, 190, 0)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function SplitString(s, d)
  result = {};
  for match in (s..d):gmatch("(.-)"..d) do table.insert(result, match); end
  return result;
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function ConvertToCoords(string)
  local Data = string.gsub(string, "{", "")
  local Data = string.gsub(Data, "}", "")
  local Data = string.gsub(Data, ",", "")
  return Data
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function DeleteFromTable(tab, val)
    for i, v in ipairs (tab) do
        if (v.BoxID == val) then
          tab[i] = nil
        end
    end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function TableContains (tab, val)
  for index, value in ipairs(tab) do
  if value == val then return true end end
  return false
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function FilterTableFromDupes(Table)
  local newArray = {}
  local checkerTbl = {}
  for _, element in ipairs(Table) do
    if not checkerTbl[element[1]] then
      checkerTbl[element[1]] = true
      table.insert(newArray, element)
    end
  end
  return newArray
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function AddToStorage(Steam, CharID, Type, I)
  local Index = { I[1], I[2], I[3], I[4], I[5] }
  TSC('DokusCore:S:Core:DB:AddToStorage', {Steam, CharID, Type, Index})
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function AddToExistingItem(Ped, xSteam, xCharID, xBoxID, xItem, xAmount, xCoords)
  local Index = { true, xBoxID, xItem, xAmount, xCoords }
  AddToStorage(xSteam, xCharID, 'Drop', Index)
  TSC('DokusCore:S:Core:DB:DelInventoryItem', {xItem, xAmount, xSteam, xCharID})
  Animation(Ped)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function InsertNewItemIntoBox(Ped, xSteam, xCharID, xBoxID, xItem, xAmount, xCoords)
  local Index = { false, xBoxID, xItem, xAmount, xCoords }
  AddToStorage(xSteam, xCharID, 'Drop', Index)
  TSC('DokusCore:S:Core:DB:DelInventoryItem', {xItem, xAmount, xSteam, xCharID})
  Animation(Ped)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Animation(Ped)
  local dict = "amb_work@world_human_box_pickup@1@male_a@stand_exit_withprop"
  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do Wait(10) end
  TaskPlayAnim(Ped, dict, "exit_front", 1.0, 8.0, -1, 1, 0, false, false, false)
  Wait(1200)
  PlaySoundFrontend("CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", true, 1)
  Wait(1000)
  ClearPedTasks(Ped)
end

















--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
