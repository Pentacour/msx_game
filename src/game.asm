

init_level_0
        ld      hl, sea_tileset_patterns
        ld      de, sea_tileset_colors
        call    load_tileset_one_bank

        ld      hl, SEA_SCREEN_0
        call    build_level

        ;TODO
        call    reset_entities

        ;call    get_next_empty_entity_ix
        ;ld      [ix+OFFSET_TYPE], 1
        ;ld      [ix+OFFSET_STATE], 0
        ;ld      [ix+OFFSET_STATE_COUNTER], 0
        ;ld      [ix+OFFSET_X], 4*8
        ;ld      [ix+OFFSET_Y], 8*8
        ;ld      [ix+OFFSET_IS_VISIBLE], 1
        
        call    get_next_empty_destructible_entity_ix
        ld      [ix+OFFSET_TYPE], 3
        ld      [ix+OFFSET_STATE], 0
        ld      [ix+OFFSET_STATE_COUNTER], 0
        ld      [ix+OFFSET_X], 4*8
        ld      [ix+OFFSET_Y], 8*8
        ld      [ix+OFFSET_IS_VISIBLE], 1

;        call    get_next_empty_entity_ix
        ;ld      [ix+OFFSET_TYPE], 2 ; Use constant
;        ld      [ix+OFFSET_STATE_COUNTER], 0
 ;       ld      [ix+OFFSET_IS_VISIBLE], 1
  ;      ld      [ix+OFFSET_MAP_X], 35
   ;     ld      [ix+OFFSET_MAP_Y], 25

        ;call    get_next_empty_entity_ix
        ;ld      [ix+OFFSET_TYPE], 1
        ;ld      [ix+OFFSET_STATE], 0
        ;ld      [ix+OFFSET_STATE_COUNTER], 0
        ;ld      [ix+OFFSET_X], 18*8
        ;ld      [ix+OFFSET_Y], 16*8
        ;ld      [ix+OFFSET_IS_VISIBLE], 1

        ;

        ret

init_level_1
        ld      hl, sea_tileset_patterns
        ld      de, sea_tileset_colors
        call    load_tileset_one_bank

        ld      hl, SEA_SCREEN_1
        call    build_level

        ret

