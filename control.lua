function OnInit()
    storage = storage or {}
    storage.shells = storage.shells or {}
    storage.lights_flight = storage.lights_flight or {}
    storage.lights_landed = storage.lights_landed or {}
    storage.radars_flight = storage.radars_flight or {}
    storage.radars_landed = storage.radars_landed or {}
end

script.on_init(OnInit)
script.on_configuration_changed(OnInit)

script.on_event(defines.events.on_script_trigger_effect, function(event)
    
    --game.print("Event fired")
    if (event.effect_id == "radar-shell-fired") then
        local source = event.source_entity 
        
        if source then
            local shells = source.surface.find_entities_filtered {
                position = event.source_position,
                radius = 0.1,
                name = "radar-artillery-projectile"
            }
            if shells == nil or table_size(shells) == 0 then
                game.print("Warning: failed to detect radar shell")
            else
                for _, shell in ipairs(shells) do
                    --found fired shell
                    --should not be in table yet
                    if storage.shells[shell] == nil then
                        --creating dummy radar
                        local radar = shell.surface.create_entity{
                            name = "radar-shell-dummy-radar-1",
                            position = shell.position,
                            force = shell.force,
                            quality = shell.quality
                        }
                        --creating dummy light
                        local light = shell.surface.create_entity{
                            name = "radar-shell-dummy-light-1",
                            position = shell.position,
                            force = shell.force,
                            quality = shell.quality,
                            speed = shell.speed,
                            orientation = shell.orientation,
                            target = event.target_position
                        }

                        if radar == nil or light == nil then
                            game.print("Warning: failed to register radar shell")
                            storage.shells[shell] = {}
                        else
                            --writing to the table
                            storage.shells[shell] = {radar = radar, light = light, target = event.target_position}
                            storage.radars_flight[radar] = {shell = shell}
                            storage.lights_flight[light] = {shell = shell}
                        end
                    end
                end
            end
        end
    end


    if event.effect_id == "radar-shell-hit" then
        local shells = game.get_surface(event.surface_index).find_entities_filtered {
            position = event.target_position,
            radius = 1,
            name = "radar-artillery-projectile"
        }
        if shells == nil or table_size(shells) == 0 then
                game.print("Warning: failed to detect shells")
        else
            for _, shell in pairs(shells) do
                --if shell is registered

                -- remove in flight entities
                --[[if storage.shells[shell] ~= nil then
                    local data = storage.shells[shell]
                    if (data.radar and data.radar.valid) then
                        data.radar.destroy()
                    end
                    if (data.light and data.light.valid) then
                        data.light.destroy()  
                    end]]--


                --create landed entities
                --creating dummy radar
                local radar = shell.surface.create_entity{
                    name = "radar-shell-dummy-radar-2",
                    position = event.target_position,
                    force = shell.force,
                    quality = shell.quality
                }
                --creating dummy light
                local light = shell.surface.create_entity{
                    name = "radar-shell-dummy-light-2",
                    position = event.target_position,
                    force = shell.force,
                    quality = shell.quality
                }
                
                if radar == nil or light == nil then
                    game.print("Warning: failed to register shell landing entities")
                else
                    storage.radars_landed[radar] = event.tick
                    storage.lights_landed[light] = event.tick
                end



                --unregistering shell
                storage.shell = nil  
                
            end

        end
    end
end
)



script.on_nth_tick(30, function(event)

-- validation
for shell, data in pairs(storage.shells) do
    if not shell.valid then 
        storage.shells[shell] = nil
        if (data and data.radar and data.radar.valid) then
            data.radar.destroy()
            data.radar = nil
        end
        if (data and data.light and data.light.valid) then
            data.light.destroy()
            data.light = nil
        end
    else
        if data.light == nil or data.light.valid then
                data.light = shell.surface.create_entity {
                    name = "radar-shell-dummy-light-1",
                    position = shell.position,
                    force = shell.force,
                    quality = shell.quality,
                    speed = shell.speed,
                    orientation = shell.orientation,
                    target = data.target
                }
        end
    end
    if not (data and data.radar and data.radar.valid) then
        data.radar = nil
    end      
    if not (data and data.light and data.light.valid) then
        data.light = nil
    end
end

for radar, data in pairs(storage.radars_flight) do
    if not radar.valid then
        storage.radars_flight[radar] = nil
    elseif (data.shell == nil) or (not data.shell.valid) then
        radar.destroy()
        storage.radars_flight[radar] = nil
    end
end

for light, data in pairs(storage.lights_flight) do
    if not light.valid then
        storage.lights_flight[light] = nil
    elseif (data.shell == nil) or (not data.shell.valid) then
        light.destroy()
        storage.lights_flight[light] = nil
    end
end






--sync
for shell, data in pairs(storage.shells) do
    if data.radar and data.radar.valid then
            data.radar.teleport(shell.position)
    end
    if data.light and data.light.valid then
        data.light.teleport(shell.position)
        --data.light.orientation = shell.orientation
        data.light.speed = shell.speed
    end

end

--timeout
for radar, tick in pairs(storage.radars_landed) do
    if radar.valid then
        if event.tick > tick + settings.startup["radar_landed_lifetime"].value * 60 then
            radar.destroy()
        end
    end
end
for light, tick in pairs(storage.lights_landed) do
    if light.valid then
        if event.tick > tick + settings.startup["radar_landed_lifetime"].value * 60 then
            light.destroy()
        end
    end
end

end
)