-- LUALOCALS < ---------------------------------------------------------
local nodecore, minetest
    = nodecore, minetest
-- LUALOCALS < ---------------------------------------------------------

local modname = minetest.get_current_modname()

local mats = {
  {suffix=""},
  {
    suffix="_lodey",tile="nc_lode_ore.png^[mask:nc_lode_mask_ore.png",def={
      groups={
        snake_poop=1,
      },
      snake_poop = "nc_lode:ore"
    }
  }
}

for n=1,#mats do
  local mat = mats[n]
  local tile = "nc_terrain_grass_top.png^nc_terrain_cobble.png"
  if mat.tile then
    tile = "nc_terrain_grass_top.png^("..mat.tile..")^nc_terrain_cobble.png"
  end
  local headname = modname..":head"..mat.suffix
  local bodyname = modname..":body"..mat.suffix
  
  local def = nodecore.underride({
      tiles = {tile,tile,tile, tile,tile,tile},
      groups = {
        cobble = 1,
        rock = 1,
        cracky = 1,
        snake_body = 1
      },
      drop_in_place = "nc_terrain:cobble_loose",
      silktouch=false,
      crush_damage = 2,
      sounds = nodecore.sounds("nc_terrain_stony"),
      alternative_head = headname,
      alternative_body = bodyname
    },mat.def or {})

  if mat.group then
    def.groups[mat.group] = 1
  end
  
  local def_h = nodecore.underride({
    paramtype2="facedir",
    description = "Snake Head",
    tiles = {[5]=tile.."^(nc_sponge.png^[mask:nc_lode_mask_ore.png)"},
    groups = {snake_head = 1},
    after_place_node = nodecore.snake_construct
  },def)

  local def_b = nodecore.underride({
    description = "Snake Body",
    groups = {snake_body = 1}
  },def)

  minetest.register_node(headname,def_h)
  minetest.register_node(bodyname,def_b)
end

nodecore.register_dnt({
	name=modname..":snekstep",
	nodenames={modname..":head",modname.."head_lodey"},
	action=nodecore.snake_step,
	time=0.5,
	loop=true,
})
