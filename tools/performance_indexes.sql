USE vmangos;
CREATE INDEX IF NOT EXISTS idx_guid_map_position ON creature(guid, map, position_x, position_y);
CREATE INDEX IF NOT EXISTS idx_got_data1 ON gameobject_template(data1);
CREATE INDEX IF NOT EXISTS idx_golt_entry ON gameobject_loot_template(entry);
CREATE INDEX IF NOT EXISTS idx_npcvt_entry ON npc_vendor_template(entry);
CREATE INDEX IF NOT EXISTS idx_ct_entry ON creature_template(entry);

USE pfquest;
CREATE INDEX IF NOT EXISTS idx_wma_vanilla_sizes ON WorldMapArea_vanilla(x_min, x_max, y_min, y_max);
CREATE INDEX IF NOT EXISTS idx_wma_vanilla_mapid ON WorldMapArea_vanilla(mapID);
CREATE INDEX IF NOT EXISTS idx_wma_vanilla_area ON WorldMapArea_vanilla(areatableID);
