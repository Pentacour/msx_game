CHARACTER_1     equ     1
CHARACTER_2     equ     2

CHARACTER_1_OFFSET_TILE equ 32

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

;TODO: Missing control when list is full.
;==========================================
;::get_next_empty_desctructible_entity_hl
;   out->hl
;===========================================
get_next_empty_destructible_entity_hl
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
;::get_next_empty_indesctructible_entity_hl
;   out->hl
;===========================================
get_next_empty_indestructible_entity_hl
        ld      hl, list_indestructible_entities_data
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
;::get_next_empty_destructible_entity_ix
;   out->ix
;===========================================
get_next_empty_destructible_entity_ix
        call    get_next_empty_destructible_entity_hl
        push    hl
        pop     ix
        ret

;==========================================
;::get_next_empty_indestructible_entity_ix
;   out->ix
;===========================================
get_next_empty_indestructible_entity_ix
        call    get_next_empty_indestructible_entity_hl
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

;====================================
;::init_entities_level
;====================================
init_entities_level
        ld      a, [level]
        sla     a
        ld      c, a
        ld      b, 0
        ld      hl, init_entities_data
        add     hl, bc

        ld      e, [hl]
        inc     hl
        ld      d, [hl]
        ex      de, hl

        ; load entities characters

        ld      e, [hl]
        inc     hl
        ld      d, [hl]
        inc     hl
        ex      de, hl
        push    de

        call    init_entity_character

        pop     hl

init_entities_level_loop
        ld      a, [hl]
        cp      EOF
        ret     z

        cp      DESTRUCTIBLE
        jp      z, init_entities_level_destructible

        call    get_next_empty_indestructible_entity_ix_save_hl
        jr      init_entities_level_post_get_next_empty

init_entities_level_destructible
        call    get_next_empty_destructible_entity_ix_save_hl

init_entities_level_post_get_next_empty
        inc     hl      
        ld      a, [hl] ; character type
        ld      [ix+OFFSET_CHARACTER_TYPE], a

        inc     hl
        ld      a, [hl]
        inc     hl
        cp      INIT_TYPE_0
        jp      z, init_entity_type_1
        
init_entities_level_assert jp      init_entities_level_assert

post_init_entity_type

        ld      [ix+OFFSET_STATE], 0
        ld      [ix+OFFSET_STATE_COUNTER], 0
        ld      [ix+OFFSET_IS_VISIBLE], 0

        inc     hl
        jp      init_entities_level_loop

        ret

;=================================================
;::init_entity_character
; in->hl pointer to character
;=================================================
init_entity_character
        ld      e, [hl]
        inc     hl
        ld      d, [hl]
        inc     hl
        push    de    

        ld      e, [hl]
        inc     hl
        ld      d, [hl]

        pop     hl

        call    load_tileset_character_1

        ret


;=================================================
;::get_next_empty_indestructible_entity_ix_save_hl
;=================================================
get_next_empty_indestructible_entity_ix_save_hl
        push    hl
        call    get_next_empty_indestructible_entity_ix
        pop     hl
        ret

;=================================================
;::get_next_empty_destructible_entity_ix_save_hl
;=================================================
get_next_empty_destructible_entity_ix_save_hl
        push    hl
        call    get_next_empty_destructible_entity_ix
        pop     hl
        ret

;=================================
;::where_is_player
;  OUT: a: K_position
;=================================
where_is_player
        ld      a, [player_x]
        sub     8
        cp      [ix+OFFSET_X]
        jr      nc, .is_right
        add     16
        cp      [ix+OFFSET_X]
        jp      c, .is_left

                ; Same X
        ld      a, [player_y]
        sub     8
        cp      [ix+OFFSET_Y]
        jp      nc, .is_down
        add     16
        cp      [ix+OFFSET_Y]
        jp      c, .is_up

        ld      a, KEY_NO_KEY
        ret

.is_down
        ld      a, KEY_DOWN
        ret

.is_up
        ld      a, KEY_UP
        ret

.is_left
        ld      a, [player_y]
        sub     8
        cp      [ix+OFFSET_Y]
        jp      nc, .is_left_down
        add     16
        cp      [ix+OFFSET_Y]
        jp      c, .is_left_up

        ld      a, KEY_LEFT
        ret

.is_left_down
        ld      a, KEY_DOWNLEFT
        ret
.is_left_up
        ld      a, KEY_UPLEFT
        ret

.is_right
        ld      a, [player_y]
        sub     8
        cp      [ix+OFFSET_Y]
        jp      nc, .is_right_down
        add     16
        cp      [ix+OFFSET_Y]
        jp      c, .is_right_up

        ld      a, KEY_RIGHT
        ret

.is_right_down
        ld      a, KEY_DOWNRIGHT
        ret
.is_right_up
        ld      a, KEY_UPRIGHT
        ret
        
;=================================
;::inc_not_visible_counter
;=================================
inc_not_visible_counter
        inc     [ix+OFFSET_NO_VISIBLE_COUNTER]
        ld      a, [ix+OFFSET_NO_VISIBLE_COUNTER]
        cp      NOT_VISIBLE_MAX_TIME
        jp      nz, next_entity

        ld      [ix+OFFSET_TYPE], 0
        jp      next_entity

;================================
;::init_entity_type_1
;================================
init_entity_type_1
        ld      a, [hl]
        ld      [ix+OFFSET_TYPE], a
        inc     hl
        ld      a, [hl]
        ld      [ix+OFFSET_MAP_Y], a
        inc     hl
        ld      a, [hl]
        ld      [ix+OFFSET_MAP_X], a
        inc     hl
        ld      a, [hl]
        ld      [ix+OFFSET_X], a
        inc     hl
        ld      a, [hl]
        ld      [ix+OFFSET_Y], a
        jp      post_init_entity_type


;====================================
;::is_collision_player_entity
;    in-> de player [yx], ix
;    out->z collision
;=====================================
is_collision_player_entity   
.PLAYER_WIDTH equ 4
.ENTITY_WIDTH equ 4
        push    ix
        pop     hl
        inc     hl
        inc     hl      ;y
        
        ld      a, -.PLAYER_WIDTH
        add     e
        ld      e, a
        ld      a, .ENTITY_WIDTH
        add     [hl] ;y
        cp      e
        jp      c, .ret_no

        ld      a, .PLAYER_WIDTH*2
        add     e
        ld      e, a
        ld      a, -.ENTITY_WIDTH*2
        add     [hl] ;y
        cp      e
        jp      nc, .ret_no

        ;x
        inc     hl 
        ld      a, -.PLAYER_WIDTH
        add     d
        ld      d, a
        ld      a, .ENTITY_WIDTH
        add     [hl] ;x
        cp      d
        jp      c, .ret_no

        ld      a, .PLAYER_WIDTH*2
        add     d
        ld      d, a
        ld      a, -.ENTITY_WIDTH*2
        add     [hl] ;x
        cp      d
        jp      nc, .ret_no

.ret_yes
        xor     a
        cp      0
        ret
.ret_no
        xor     a
        cp      1
        ret  


;=================================
;::trate_collision_player_entity
;=================================
trate_collision_player_entity
.assert   jr .assert


;================================
;::render_character
;  in->IX entity
;================================
render_character
        ld      a, [ix+OFFSET_CHARACTER_TYPE]
        cp      0
        ret     z
        cp      1
        jp      render_character_1

.assert jr      .assert        


;================================
;::render_character_1
;================================
render_character_1
        ld      b, [ix+OFFSET_X]
        ld      c, [ix+OFFSET_Y]
        call    YXToOffset
        ld      hl, camera_view - 33 ; From x,y to upper-left tile to render.
        add     hl, de
        
        ld      a, [ix+OFFSET_DIRECTION]
        dec     a
        sla     a
        sla     a
        sla     a
        add     CHARACTER_1_OFFSET_TILE
        ld      b, a ; save tile
        ld      a, [animation_tick]
        and     8
        cp      0
        jp      z, .setframe
        inc     b
        inc     b
        inc     b
        inc     b
.setframe
        ld      a, b
        ld      [hl], a
        inc     hl
        inc     a
        ld      [hl], a
        ld      bc, 31
        add     hl, bc
        inc     a
        ld      [hl], a
        inc     hl
        inc     a
        ld      [hl], a

        ret

;===========================
;::assign_random_free_y
; IN->ix with x filled
; OUT -> z assigned
;===========================
assign_random_free_y
        xor     a
        ld      [tmp_var_1], a

        ld      a, [animation_tick]
        ld      [tmp_var_2], a
.loop        
        cp      8*3
        jp      c, .abort
        cp      23*8
        jp      nc, .abort

        ld      [ix+OFFSET_Y], a

        call    check_if_valid_position_entity
        ret     z

        ld      a, [tmp_var_1]
        inc     a
        ld      [tmp_var_1], a
        cp      5
        jp      nc, .abort

        ld      a, [tmp_var_2]
        add     8
        ld      [tmp_var_2], a
        jp      .loop

.abort
        ld      [ix+OFFSET_TYPE], 0
        ret




