CMX = nil
PlayerData = nil
s = 1000
Citizen.CreateThread(function()
    while CMX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) CMX = obj end)
        Citizen.Wait(s)
    end

    while CMX.GetPlayerData().job == nil do
        Citizen.Wait(s)
    end

    PlayerData = CMX.GetPlayerData()
end)

local hunger = 0
local thirst = 0
local stress = 0
local showHud = true  
local hud = true
local isOculto = false


RegisterNetEvent('esx_status:playerLoaded')
AddEventHandler('esx_status:playerLoaded', function(playerData)
    SendNUIMessage({
        active= hud,
    })
end)

function updateHungerThirstHUD(hunger, thirst,stress)
    local ped = PlayerPedId()
    local health = GetEntityHealth(ped) - 100
    local vehicle = GetVehiclePedIsIn(ped)
            
    if health < 1 then health = 0 end
    local o2 = false
    armor = GetPedArmour(ped)
    if armor > 100.0 then armor = 100.0 end
    if IsPedSwimmingUnderWater(ped) then
        o2 = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10
    end
    if IsPedInAnyVehicle(ped,true) then
        fuel = GetVehicleFuelLevel(vehicle)
    end
    SendNUIMessage({
        veh = IsPedInAnyVehicle(ped,true),
        o2 = o2,
        values = {
        health = health,
        shield = armor,
        hunger = hunger,
        thirst = thirst,
        stress = stress,
        id = GetPlayerServerId(PlayerId()),
        fuel = fuel,
        }
    })
end

function DrawText3D(x,y,z, text, r,g,b) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
        SetTextScale(0.0*scale, 0.55*scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(r, g, b, 150)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

function mostrarhud()
    SendNUIMessage({
        active= hud,
    })
end

RegisterCommand("nohud", function()
    isOculto = true
    print(isOculto)
end)

RegisterCommand("verhud", function()
    isOculto = false
    print(isOculto)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(s)
        mostrarhud()
        updateHungerThirstHUD(hunger, thirst, stress)
    end
end)

RegisterNetEvent("esx_status:onTick")
AddEventHandler("esx_status:onTick", function(status)
    hunger, thirst = status[1].percent, status[2].percent
end)

Citizen.CreateThread(function()
	Citizen.Wait(s)

	while true do
		local radarEnabled = IsRadarEnabled()

		if not IsPedInAnyVehicle(PlayerPedId()) and radarEnabled then
			DisplayRadar(false)
		elseif IsPedInAnyVehicle(PlayerPedId()) and not radarEnabled then
			DisplayRadar(true)
		end

		Citizen.Wait(s)
	end
end)

Citizen.CreateThread(function()
    while true do
      Citizen.Wait(s)
      if (IsPauseMenuActive()) and not isPaused then
            showHud = false
            hud = false
        else
            showHud = true
            hud = true
        end
    end
end)

Citizen.CreateThread(function()
    while false do
      Citizen.Wait(s)
      if isOculto then
            showHud = false
            hud = false
        else
            showHud = true
            hud = true
        end
    end
end)