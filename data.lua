local item_sounds = require("__base__.prototypes.item_sounds")
local sounds = require("__base__.prototypes.entity.sounds")

-- dummy to reveal area in flight
local radar1 = {
    type = "radar",
    name = "radar-shell-dummy-radar-1",
    icon = "__base__/graphics/icons/radar.png",
    flags = { "not-on-map", "placeable-off-grid" },
    max_health = 2147483648,
    hidden = true,
    collision_box = { { 0, 0 }, { 0, 0 } },
    selection_box = { { 0, 0 }, { 0, 0 } },
    collision_mask = {layers = {}},
    connects_to_other_radars = false,
    energy_per_sector = "10MJ",
    max_distance_of_sector_revealed = 0,
    max_distance_of_nearby_sector_revealed = settings.startup["radar_flight_range"].value,
    energy_per_nearby_scan = "250kJ",
    energy_source =
    {
        type = "void",
    },
    energy_usage = "300kW",
    heating_energy = nil,
    working_sound =
    {
        sound = { filename = "__base__/sound/radar.ogg", volume = 0.8, modifiers = volume_multiplier("main-menu", 2.0)},
        max_sounds_per_prototype = 3,
        use_doppler_shift = false
    },
    radius_minimap_visualisation_color = { 0.059, 0.092, 0.235, 0.275 },
    rotation_speed = 0.01,
    is_military_target = false
}


-- dummy to persist after the shell has landed
local radar2 = {
    type = "radar",
    name = "radar-shell-dummy-radar-2",
    icon = "__base__/graphics/icons/radar.png",
    flags = { "not-on-map", "placeable-off-grid"},
    max_health = 10000,
    hidden = true,
    connects_to_other_radars = false,
    collision_mask = { layers = {} },
    collision_box = { { 0, 0 }, { 0, 0 } },
    selection_box = { { -0.1, -0.1 }, { 0.1, 0.1 } },
    energy_per_sector = "10MJ",
    max_distance_of_sector_revealed = 0,
    max_distance_of_nearby_sector_revealed = settings.startup["radar_landed_range"].value,
    energy_per_nearby_scan = "250kJ",
    energy_source =
    {
        type = "void",
    },
    energy_usage = "600kW",
    heating_energy = nil,
    pictures =
    {
        layers =
        {
            {
                filename = "__base__/graphics/entity/radar/radar.png",
                priority = "low",
                width = 196,
                height = 254,
                apply_projection = false,
                direction_count = 64,
                line_length = 8,
                shift = util.by_pixel(1.0, -16.0),
                scale = 0.1
            },
            {
                filename = "__base__/graphics/entity/radar/radar-shadow.png",
                priority = "low",
                width = 336,
                height = 170,
                apply_projection = false,
                direction_count = 64,
                line_length = 8,
                shift = util.by_pixel(39.0, 6.0),
                draw_as_shadow = true,
                scale = 0.1
            }
        }
    },
    working_sound =
    {
        sound = { filename = "__base__/sound/radar.ogg", volume = 0.8, modifiers = volume_multiplier("main-menu", 2.0) },
        max_sounds_per_prototype = 3,
        use_doppler_shift = false
    },
    radius_minimap_visualisation_color = { 0.059, 0.092, 0.235, 0.275 },
    rotation_speed = 0.01,
    is_military_target = false
}

--light in flight
local light1 = {
    type = "projectile",
    name = "radar-shell-dummy-light-1",
    collision_mask = { layers = {} },
    flags = { "not-on-map", "placeable-off-grid"},
    light = {
    intensity = 0.65,
    size = 80,
    color = {
      r = 1.000,
      g = 0.888,
      b = 0.419
    }
  },
    direction_only = true,
    collision_box = {{0, 0}, {0, 0}},
    acceleration = 0
}

--light landed
local light2 = {
    type = "lamp",
    name = "radar-shell-dummy-light-2",
    icon = table.deepcopy(data.raw["lamp"]["small-lamp"].icon),
    max_health = 100000,
    collision_mask = { layers = {} },
    flags = { "not-on-map", "placeable-off-grid"},
    light = {
    intensity = 2.65,
    size = 120,
    color = {
      r = 1.000,
      g = 0.888,
      b = 0.419
    }
  },
    energy_usage_per_tick = "1kJ",
    energy_source = {type = "void"},
    collision_box = {{0, 0}, {0, 0}},
    selection_box = {{0, 0}, {0, 0}},
    always_on = true
}


--item
local shell_item = {
    type = "ammo",
    name = "radar-artillery-shell",
    icon = "__lilys-radar-shell__/graphics/icons/radar-artillery-shell-icon.png",
    ammo_category = "artillery-shell",
    ammo_type =
    {
      target_type = "position",
      action =
      {
        type = "direct",
        action_delivery =
        {
            {
                type = "artillery",
                projectile = "radar-artillery-projectile",
                starting_speed = 1,
                direction_deviation = 0,
                range_deviation = 0,
                source_effects =
                {
                    {
                        type = "create-explosion",
                        entity_name = "artillery-cannon-muzzle-flash"
                    }
                }
            },
            {
            type = "instant",
                target_effects = {
                    {
                        type = "script",
                        effect_id = "radar-shell-fired"
                    }
                }
            }
        }

      }
    },
    subgroup = "ammo",
    order = "d[explosive-cannon-shell]-e[artillery]-radar",
    inventory_move_sound = item_sounds.artillery_large_inventory_move,
    pick_sound = item_sounds.artillery_large_inventory_pickup,
    drop_sound = item_sounds.artillery_large_inventory_move,
    stack_size = 1,
    weight = 100*kg
  }

-- projectile
local shell = {
    type = "artillery-projectile",
    name = "radar-artillery-projectile",
    flags = { "not-on-map" },
    hidden = true,
    reveal_map = true,
    map_color = { 0.25, 1, 0.5 },
    picture =
    {
        filename = "__lilys-radar-shell__/graphics/entity/radar-artillery-shell.png",
        draw_as_glow = true,
        width = 64,
        height = 64,
        scale = 0.5
    },
    shadow =
    {
        filename = "__lilys-radar-shell__/graphics/entity/shell-shadow.png",
        width = 64,
        height = 64,
        scale = 0.5
    },
    chart_picture =
    {
        filename = "__lilys-radar-shell__/graphics/entity/radar-artillery-shoot-map-visualization.png",
        flags = { "icon" },
        width = 64,
        height = 64,
        priority = "high",
        scale = 0.25
    },
    action =
    {
        type = "direct",
        action_delivery =
        {
            type = "instant",
            target_effects =
            {
                {
                    type = "nested-result",
                    action =
                    {
                        type = "area",
                        radius = 1.0,
                        action_delivery =
                        {
                            type = "instant",
                            target_effects =
                            {
                                {
                                    type = "damage",
                                    damage = { amount = 1000, type = "physical" }
                                }
                            }
                        }
                    }
                },
                {
                    type = "create-trivial-smoke",
                    smoke_name = "artillery-smoke",
                    initial_height = 0,
                    speed_from_center = 0.05,
                    speed_from_center_deviation = 0.005,
                    offset_deviation = { { -4, -4 }, { 4, 4 } },
                    max_radius = 3.5,
                    repeat_count = 4 * 4 * 15
                },
                {
                    type = "script",
                    effect_id = "radar-shell-hit"
                },
                {
                    type = "create-entity",
                    entity_name = "explosion"
                },
                {
                    type = "show-explosion-on-chart",
                    scale = 2 / 32
                }
            }
        }
    },
    final_action =
    {
        type = "direct",
        action_delivery =
        {
            type = "instant",
            target_effects =
            {
                {
                    type = "invoke-tile-trigger",
                    repeat_count = 1
                },
                {
                    type = "destroy-decoratives",
                    from_render_layer = "decorative",
                    to_render_layer = "object",
                    include_soft_decoratives = true, -- soft decoratives are decoratives with grows_through_rail_path = true
                    include_decals = false,
                    invoke_decorative_trigger = true,
                    decoratives_with_trigger_only = false, -- if true, destroys only decoratives that have trigger_effect set
                    radius = 1.5                           -- large radius for demostrative purposes
                }
            }
        }
    },
    height_from_ground = 400 / 64
}

data:extend({radar1, radar2, light1, light2, shell_item, shell})





--recipe basic
data:extend({
    {
        type = "recipe",
        name = "radar-artillery-shell",
        category = "advanced-crafting",
        allow_productivity = false,
        enabled = false,
        energy_required = 30,
        ingredients =
        {
            { type = "item", name = "steel-plate",   amount = 20 },
            { type = "item", name = "radar",   amount = 10 },
            { type = "item",  name = "battery", amount = 50 },
            { type = "item", name = "processing-unit",   amount = 10 },
            { type = "item",  name = "small-lamp",   amount = 10 }
        },
        results = { { type = "item", name = "radar-artillery-shell", amount = 1 } }
    }
})

tech = data.raw["technology"]["artillery"]
table.insert(tech.effects, {
    type = "unlock-recipe",
    recipe = "radar-artillery-shell"
})
