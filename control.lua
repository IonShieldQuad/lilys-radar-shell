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
                            storage.shells[shell] = {radar = radar, light = light}
                            storage.radars_flight[radar] = {shell = shell}
                            storage.lights_flight[light] = {shell = shell}
                        end
                    end
                end
            end
        end
    end


    if event.effect_id == "radar-shell-hit" then
        local source = event.source_entity 
        if source and storage.shells[source] then
            if (storage.shells[source] == nil) then
                game.print("Warning: unregistered shell hit")
            else
                local shell = storage.shells[source]
                -- destroy flight entities
                if (shell.radar and shell.radar.valid) then
                    shell.radar.destroy()
                end
                if (shell.light and shell.light.valid) then
                    shell.light.destroy()  
                end

                --create landed entities
                --creating dummy radar
                local radar = shell.surface.create_entity{
                    name = "radar-shell-dummy-radar-2",
                    position = shell.position,
                    force = shell.force,
                    quality = shell.quality
                }
                --creating dummy light
                local light = shell.surface.create_entity{
                    name = "radar-shell-dummy-light-2",
                    position = shell.position,
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



script.on_nth_tick(60, function(event)

-- validation
for shell, data in pairs(storage.shells) do
    if not shell.valid then 
        storage.shells[shell] = nil
    end
    if not (data and data.radar and data.radar.valid) then
        data.radar.destroy()
        data.radar = nil
    end      
    if not (data and data.light and data.light.valid) then
        data.light.destroy()
        data.light = nil
    end
end

--sync
for shell, data in pairs(storage.shells) do
    if data.radar and data.radar.valid then
            data.radar.position = shell.position
    end
    if data.light and data.light.valid then
        data.light.position = shell.position
        data.light.orientation = shell.orientation
        data.light.speed = shell.speed
    end

end

--timeout
for radar, tick in pairs(storage.radars_landed) do
    if radar.valid then
        if event.tick > tick + settings.startup["radar_landed_lifetime"].value then
            radar.destroy()
        end
    end
end
for light, tick in pairs(storage.lights_landed) do
    if light.valid then
        if event.tick > tick + settings.startup["radar_landed_lifetime"].value then
            light.destroy()
        end
    end
end

end
)