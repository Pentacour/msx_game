

init_level_0
        ld      hl, sea_tileset_patterns
        ld      de, sea_tileset_colors
        call    load_tileset_one_bank

        ld      hl, SEA_SCREEN_0
        call    build_level
        call    reset_entities
        
        call    init_entities_level

;        call    get_next_empty_destructible_entity_ix
 ;       ld      [ix+OFFSET_TYPE], ENTITY_STOPWALK
  ;      ld      [ix+OFFSET_STATE], 0
   ;     ld      [ix+OFFSET_STATE_COUNTER], 0
    ;    ld      [ix+OFFSET_X], 4*8
     ;;   ld      [ix+OFFSET_Y], 8*8
       ; ld      [ix+OFFSET_IS_VISIBLE], 1

        ret

init_level_1
        ld      hl, sea_tileset_patterns
        ld      de, sea_tileset_colors
        call    load_tileset_one_bank

        ld      hl, SEA_SCREEN_1
        call    build_level
        call    reset_entities

        ret

