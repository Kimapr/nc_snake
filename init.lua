-- LUALOCALS < ---------------------------------------------------------
local nodecore, minetest, include
    = nodecore, minetest, include
-- LUALOCALS < ---------------------------------------------------------

local modname = minetest.get_current_modname()

function nodecore.is_snake_eatable(pos)
  local node = minetest.get_node(pos)
  if nodecore.buildable_to(pos) then
    return 0,0.01
  end
  if node.name == "nc_tree:leaves" or node.name == "nc_tree:leaves_loose" then
    return 1/8,1/32
  end
  if node.name == "nc_tree:peat" then
    return 1,0.4
  end
end

local function snake_step(pos,node)
  local meta = minetest.get_meta(pos)
  local len = meta:get_int("snake_len")
  local body = {{pos=pos,node=node}}
  local head = body[1]
  local cut = false
  for n=1,len do
    local rpos = pos
    local pos = minetest.string_to_pos(meta:get_string("snake_body"..n))
    if pos then
      local node = minetest.get_node(pos)
      if node.name == "ignore" then
        return rpos
      end
      if minetest.get_item_group(node.name,"snake_body") == 0 then
        len = n-1
        meta:set_int("snake_len",len)
        cut = true
      end
      if not cut then
        table.insert(body,{pos=pos,node=node})
      elseif minetest.get_item_group(node.name,"snake_body") > 0 then
        minetest.set_node(pos,{name="nc_terrain:cobble_loose"})
      end
    end
  end
  local tail = body[#body]
  local poop = meta:get_float("snake_poop")
  local food = meta:get_float("snake_food")
  local dir = minetest.facedir_to_dir(head.node.param2)
  local fpos = vector.add(pos,dir)
  local dpos = vector.add(pos,{x=0,y=-1,z=0})
  local upos = vector.add(pos,{x=0,y=1,z=0})
  local df,dp = nodecore.is_snake_eatable(dpos)
  local ff,fp = nodecore.is_snake_eatable(fpos)
  local uf,up = nodecore.is_snake_eatable(upos)
  aposes = {}
  for n=0,3 do
    local d = vector.add(pos,minetest.facedir_to_dir(n))
    local f,p = nodecore.is_snake_eatable(d)
    if f then
      table.insert(aposes,{n,d,f,p})
    end
  end
  local rnpos
  if df then
    food = food + df
    poop = poop + dp
    rnpos = dpos
  elseif ff then
    food = food + ff
    poop = poop + fp
    rnpos = fpos
  elseif uf then
    food = food + uf
    poop = poop + up
    rnpos = upos
  elseif #aposes > 0 then
    local k = math.random(1,#aposes)
    local n,d,f,p = unpack(aposes[k])
    food = food + f
    poop = poop + p
    head.node.param2 = n
    rnpos = d
  end
  if rnpos then
    local bodyname = minetest.registered_items[head.node.name].alternative_body
    local ohnode = head.node
    head.node = {name=bodyname}
    minetest.set_node(head.pos,head.node)
    --[[if math.random(1000) then
      head.node.param2 = math.random(0,3)
    end]]
    minetest.set_node(rnpos,{name=modname..":head",param2=ohnode.param2})
    local metb = minetest.get_meta(rnpos)
    local bodyb = {}
    for k,v in ipairs(body) do
      table.insert(bodyb,minetest.pos_to_string(v.pos))
    end
    table.insert(body,1,{pos=rnpos,node=minetest.get_node(rnpos)})
    head = body[1]
    tail = body[#body]
    for n=1,#bodyb do
      metb:set_string("snake_body"..n,bodyb[n])
    end
    if #body-1 >= len then
      len = #body-1
    end
    metb:set_int("snake_len",len)
    metb:set_float("snake_food",food)
    metb:set_float("snake_poop",poop)
    meta = metb
    pos = rnpos
    local tailmoved = false
    if len == (#body-1) then
      if poop > 1 and body[2] and minetest.get_item_group(body[2].node.name,"snake_poop") == 0 then
        poop = poop-1
        meta:set_float("snake_poop",poop)
        body[2].node.name = modname..":body_lodey"
        minetest.set_node(body[2].pos,body[2].node)
      end
      if food < 1 then
        minetest.set_node(tail.pos,{name = "air"})
        len = len - 1
        meta:set_int("snake_len",len)
        body[#body] = nil
        tailmoved = true
        if minetest.get_item_group(tail.node.name,"snake_poop") > 0 then
          nodecore.item_eject(tail.pos,{name=minetest.registered_items[tail.node.name].snake_poop})
          tail = body[#body]
          minetest.set_node(tail.pos,{name = "air"})
          if #body > 1 then
            len = len - 1
            meta:set_int("snake_len",len)
          end
        end
      else
        food = food - 1
        meta:set_float("snake_food",food)
      end
    end
  end
  return pos
end

local DEFAULT_TIMER = 0.2

function nodecore.snake_step(pos,elapsed)
  local ts = minetest.get_us_time()
  pos = snake_step(pos,minetest.get_node(pos))
  print("snake step took " .. (minetest.get_us_time()-ts)/1000 .. " sec")
  local timer = minetest.get_node_timer(pos)
  local t = DEFAULT_TIMER
  timer:set(t,timer:get_elapsed()-t)
end

function nodecore.snake_construct(pos)
  local timer = minetest.get_node_timer(pos)
  local t = DEFAULT_TIMER
  timer:set(t,timer:get_elapsed()-t)
  local meta = minetest.get_meta(pos)
  meta:set_int("snake_len",5)
end

include("node.lua")
