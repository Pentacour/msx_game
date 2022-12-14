init_tileset
        ld      hl, sea_tileset_patterns
        ld      de, sea_tileset_colors
        call    load_tileset_one_bank
        ret
        
/*
init_level_0
        ld      hl, sea_tileset_patterns
        ld      de, sea_tileset_colors
        call    load_tileset_one_bank

        ld      hl, sea_screen_0
        call    build_level
        call    reset_entities
        
        call    init_entities_level

        ret

init_level_1
        ld      hl, sea_tileset_patterns
        ld      de, sea_tileset_colors
        call    load_tileset_one_bank

        ld      hl, sea_screen_1
        call    build_level
        call    reset_entities

        call    init_entities_level

        ret
*/
