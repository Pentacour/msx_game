init_tileset
        ld      hl, sea_tileset_patterns
        ld      de, sea_tileset_colors
        call    load_tileset_one_bank
        ret
      

