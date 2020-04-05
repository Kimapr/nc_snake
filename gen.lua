-- LUALOCALS < ---------------------------------------------------------
local nodecore, minetest
    = nodecore, minetest
-- LUALOCALS < ---------------------------------------------------------

local modname = minetest.get_current_modname()

minetest.register_on_generated(function(p1,p2)
  local pl = minetest.find_nodes_in_area(p1,p2,{"nc_tree:leaves"})
  for k,pos in ipairs(pl) do
    if math.random(6000) == 1 then
      minetest.set_node(pos,{name=modname..":head",param2=math.random(0,3)})
      nodecore.snake_construct(pos)
    end
  end
end)
