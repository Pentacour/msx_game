;=======================================
;::trate_entities
;========================================
trate_entities
        ld      b, MAX_NUMBER_OF_ENTITIES
        ld      ix, list_entities_data

trate_entities_loop             
        push    bc
        ld      a, [ix] ;type
        cp      0
        jp      z, next_entity
        sla     a
        ld      c, a
        ld      b, 0
        ld      hl, TRATE_ENTITIES_TABLE
        add     hl, bc
        ld      e, [hl]
        inc     hl
        ld      d, [hl]
        ex      de, hl
        jp      hl

next_entity
        ld      bc, DATA_SIZE_PER_ENTITY
        add     ix, bc
        pop     bc
        djnz    trate_entities_loop

trate_entities_finish 
        ret

;==========================================
;::get_next_empty_entity_hl
;   out->hl
;===========================================
get_next_empty_entity_hl
        ld      hl, list_entities_data
.loop
        ld      a, [hl]
        cp      0
        ret     z
        cp      EOF
        jp      z, .overflow_assert
        ld      bc, DATA_SIZE_PER_ENTITY
        add     hl, bc
        jp      .loop

.overflow_assert                
        jr      .overflow_assert

;==========================================
;::get_next_empty_entity_ix
;   out->ix
;===========================================
get_next_empty_entity_ix
        call    get_next_empty_entity_hl
        push    hl
        pop     ix
        ret

;====================================
;::reset_entities
;======================================
reset_entities
        ld      de, list_entities_data
        ld      bc, MAX_NUMBER_OF_ENTITIES*DATA_SIZE_PER_ENTITY
        call    reset_big_ram
        ret


;=======================================
;::check_if_valid_position_entity
;       in: IX entity data.
;       out: True if valid position.
;========================================
check_if_valid_position_entity
        
        ld      b, [ix+OFFSET_X]
        ld      c, [ix+OFFSET_Y]
        call    YXToOffset
        ld      hl, camera_view
        add     hl, de
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, .ret_no
        dec     hl
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, .ret_no
        ld      bc, -32
        add     hl, bc
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, .ret_no
        inc     hl
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, .ret_no

        xor     a
        cp      0
        ret
.ret_no
        xor     a
        cp      1
        ret

;=========================================
;::set_not_is_visible
;       IN-> ix: PNC data.
;=========================================
set_not_is_visible
        ld      [ix+OFFSET_IS_VISIBLE], 0
        jp      next_entity

;=========================================
;::scroll_entities
;       IN-> scroll_entities_direction: Player's direction (KEY_RIGHT, ...)
;=========================================
scroll_entities
        push    ix
        ld      ix, list_entities_data

.loop_scroll_entity

        ld      a, [ix]
        cp      0
        jp      z, .next_entity
        cp      EOF
        jp      z, .ret

        ld      a, [ix+OFFSET_IS_VISIBLE]
        cp      0
        jp      z, .trate_not_visible_entity

        ld      a, [scroll_entities_direction]
        cp      KEY_RIGHT
        jp      z, .scroll_entity_right
        cp      KEY_LEFT
        jp      z, .scroll_entity_left
        cp      KEY_DOWN
        jp      z, .scroll_entity_down
        cp      KEY_UP
        jp      z, .scroll_entity_up

.assert jr .assert

.trate_not_visible_entity
                ; checks if becomes visible

        ld      a, [camera_tile_x_left]
        ld      b, [ix+OFFSET_MAP_X]
        cp      b
        jp      nc, .next_entity
        ld      a, [camera_tile_x_left]
        add     CAMERA_WIDTH-1
        cp      b
        jp      c, .next_entity
        ld      a, [camera_tile_y_top]
        ld      b, [ix+OFFSET_MAP_Y]
        cp      b
        jp      nc, .next_entity
        ld      a, [camera_tile_y_top]
        add     CAMERA_HEIGHT-1
        cp      b
        jp      c, .next_entity

                ; sets visible

        ld      [ix+OFFSET_IS_VISIBLE], 1
        ld      a, [camera_tile_x_left]
        ld      b, a
        ld      a, [ix+OFFSET_MAP_X]
        sub     b
        sla     a
        sla     a
        sla     a
        ld      [ix+OFFSET_X], a
        ld      a, [camera_tile_y_top]
        ld      b, a
        ld      a, [ix+OFFSET_MAP_Y]
        sub     b
        sla     a
        sla     a
        sla     a
        add     CAMERA_LINES_OFFSET_UP*8
        ld      [ix+OFFSET_Y], a
        jp      .next_entity


.scroll_entity_right
        ld      a, [ix+OFFSET_X]
        cp      8*2
        jp      c, .set_not_visible_by_left
        sub     8
        ld      [ix+OFFSET_X], a
        jp      .next_entity

.scroll_entity_left
        ld      a, [ix+OFFSET_X]
        cp      30*8+1
        jp      nc, .set_not_visible_by_right
        add     8
        ld      [ix+OFFSET_X], a
        jp      .next_entity

.scroll_entity_down
        ld      a, [ix+OFFSET_Y]
        cp      CAMERA_LINES_OFFSET_UP*8+8*2
        jp      c, .set_not_visible_by_up
        sub     8
        ld      [ix+OFFSET_Y], a
        jp      .next_entity

.scroll_entity_up
        ld      a, [ix+OFFSET_Y]
        cp      22*8+1
        jp      nc, .set_not_visible_by_down
        add     8
        ld      [ix+OFFSET_Y], a
        jp      .next_entity


.next_entity
        ld      bc, DATA_SIZE_PER_ENTITY
        add     ix, bc
        ld      a, [ix]
        cp      EOF
        jp      z, .ret
        jp      .loop_scroll_entity

.set_not_visible_by_left
        ld      [ix+OFFSET_IS_VISIBLE], 0
        ld      [ix+OFFSET_NO_VISIBLE_COUNTER], 0
        ld      a, [camera_tile_x_left]
        ld      [ix+OFFSET_MAP_X], a
        ld      a, [ix+OFFSET_Y]
        srl     a
        srl     a
        srl     a
        sub     CAMERA_LINES_OFFSET_UP
        ld      b, a
        ld      a, [camera_tile_y_top]
        add     b
        ld      [ix+OFFSET_MAP_Y], a
        jp      .next_entity

.set_not_visible_by_right
        ld      [ix+OFFSET_IS_VISIBLE], 0
        ld      [ix+OFFSET_NO_VISIBLE_COUNTER], 0
        ld      a, [camera_tile_x_left]
        add     CAMERA_WIDTH
        ld      [ix+OFFSET_MAP_X], a
        ld      a, [ix+OFFSET_Y]
        srl     a
        srl     a
        srl     a
        sub     CAMERA_LINES_OFFSET_UP
        ld      b, a
        ld      a, [camera_tile_y_top]
        add     b
        ld      [ix+OFFSET_MAP_Y], a
        jp      .next_entity


.set_not_visible_by_up
        ld      [ix+OFFSET_IS_VISIBLE], 0
        ld      [ix+OFFSET_NO_VISIBLE_COUNTER], 0
        ld      a, [ix+OFFSET_X]
        srl     a
        srl     a
        srl     a
        ld      b, a
        ld      a, [camera_tile_x_left]
        add     b
        ld      [ix+OFFSET_MAP_X], a
        ld      a, [camera_tile_y_top]
        ld      [ix+OFFSET_MAP_Y], a
        jp      .next_entity

.set_not_visible_by_down
        ld      [ix+OFFSET_IS_VISIBLE], 0
        ld      [ix+OFFSET_NO_VISIBLE_COUNTER], 0
        ld      a, [camera_tile_y_top]
        add     CAMERA_HEIGHT
        ld      [ix+OFFSET_MAP_Y], a
        ld      a, [ix+OFFSET_X]
        srl     a
        srl     a
        srl     a
        ld      b, a
        ld      a, [camera_tile_x_left]
        add     b
        ld      [ix+OFFSET_MAP_X], a
        jp      .next_entity



.ret
    pop   ix
    ret



