-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, tostring, vector
    = math, minetest, nodecore, tostring, vector
local math_ceil, math_cos, math_pi, math_random
    = math.ceil, math.cos, math.pi, math.random
-- LUALOCALS > ---------------------------------------------------------

-- Automatically disable this if this newish API is not available yet
if not nodecore.spongesurvive then return end

local modname = minetest.get_current_modname()

local cobble = nodecore.tmod("nc_terrain_gravel.png")
:add("nc_terrain_cobble.png")
local base = (nodecore.tmod("nc_sponge.png")
	:resize(16, 16))
local liv1 = (nodecore.tmod("nc_sponge_living.png")
	:resize(16, 16)
	:mask("nc_sponge_mask1.png"))
local liv2 = (nodecore.tmod("nc_sponge_living.png")
	:resize(16, 16)
	:mask(nodecore.tmod("nc_sponge_mask1.png")
		:invert("a")))
local h = 32
local txr = nodecore.tmod:combine(16, h * 16)
for i = 0, h - 1 do
	local a1 = math_ceil(math_cos(i * math_pi * 2 / h) * 63 + 192)
	local a2 = math_ceil(-math_cos(i * math_pi * 2 / h) * 63 + 192)
	local face = base
	:add(liv1:opacity(a1))
	:add(liv2:opacity(a2))
	txr = txr:layer(0, 16 * i, cobble
		:add(face:mask("nc_lode_mask_ore.png"):opacity(128)))
end

minetest.register_node(modname .. ":spore", {
		description = "Snake Spore",
		tiles = {
			{
				name = tostring(txr),
				animation = {
					["type"] = "vertical_frames",
					aspect_w = 16,
					aspect_h = 16,
					length = 2
				}
			}
		},
		stack_max = 1,
		paramtype = "light",
		groups = {cracky = 2},
		sounds = nodecore.sounds("nc_terrain_stony")
	})

nodecore.register_dnt({
		name = modname .. ":sporedie",
		nodenames = {modname .. ":spore"},
		time = 2,
		action = function(pos, node)
			if nodecore.spongesurvive({pos = pos, node = node}) then return end
			nodecore.set_loud(pos, {name = "nc_sponge:sponge_wet"})
			nodecore.item_eject(pos, "nc_stonework:chip", 5, 4)
			return nodecore.fallcheck(pos)
		end
	})
minetest.register_abm({
		label = "snake spore death/birth",
		interval = 2,
		chance = 5,
		nodenames = {modname .. ":spore"},
		arealoaded = 1,
		action = function(pos, node)
			if not nodecore.spongesurvive({pos = pos, node = node}) then
				return nodecore.dnt_set(pos, modname .. ":sporedie")
			end
			if math_random(1, 6) ~= 1 then return end
			local dirs = nodecore.dirs()
			local p = vector.add(pos, dirs[math_random(1, #dirs)])
			local n = minetest.get_node(p)
			if n.name ~= "nc_tree:peat" then return end
			nodecore.set_loud(pos, {name = "nc_terrain:sand_loose"})
			if math_random(1, 10) ~= 1 then return end
			nodecore.set_loud(pos, {name = modname .. ":head"})
			nodecore.snake_construct(pos)
		end
	})

nodecore.register_aism({
		label = "snake spore stack death",
		interval = 2,
		chance = 1,
		arealoaded = 1,
		itemnames = {modname .. ":spore"},
		action = function(stack, data)
			if nodecore.spongesurvive(data) then return end
			nodecore.sound_play("nc_terrain_swishy", {gain = 1, pos = data.pos})
			local nofit = data.inv:add_item("main", "nc_stonework:chip 4")
			if not nofit:is_empty() then nodecore.item_eject(data.pos, nofit) end
			stack:set_name("nc_sponge:sponge_wet")
			return stack
		end
	})

nodecore.register_craft({
		label = "mix snake spore",
		action = "pummel",
		toolgroups = {thumpy = 3},
		normal = {y = 1},
		indexkeys = {"nc_terrain:cobble"},
		nodes = {
			{
				match = "nc_terrain:cobble",
				replace = "nc_terrain:gravel_loose"
			},
			{
				y = -1,
				match = modname .. "spore",
				replace = basename
			}
		}
	})
