-- LUALOCALS < ---------------------------------------------------------
local nodecore, minetest
    = nodecore, minetest
-- LUALOCALS < ---------------------------------------------------------

local modname = minetest.get_current_modname()

local c_leaves = minetest.get_content_id("nc_tree:leaves")
local c_snake = minetest.get_content_id(modname..":head")
nodecore.register_mapgen_shared({
  label = "snake spawn",
  func = function(minp, maxp, area, data, _, _, _, rng)
    local ai = area.index
    for z = minp.z, maxp.z do
      for y = minp.y, maxp.y do
        local offs = ai(area, 0, y, z)
        for x = minp.x, maxp.x do
          local i = offs + x
          if data[i] == c_leaves and rng(1, 6000) == 1 then
            data[i] = c_snake
          end
        end
      end
    end
  end
})
