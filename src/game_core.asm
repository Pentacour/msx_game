
 

;===========================================
;::init_game
;===========================================
init_game
        call    clear_screen
        call    init_sprites_size

        ld      a, EOF
        ld      [sprites_attributes_eof], a
        ld      [list_indestructible_entities_data_end], a
        ld      [list_destructible_entities_data_end], a

        ld      hl, sprites_attributes - 4
        ld      [current_sprites_index], hl
        ld      [start_sprites_index], hl

        call    reset_sprites_list

        ld      a, 17
        ld      [level], a
        xor     a
        ld      [player_space_key_pressed], a
        ld      [debug_number_of_indestructibles], a

        ld      a, 0
        ld      [camera_tile_y_top], a

        ld      a, 0
        ld      [camera_tile_x_left], a

        ld      bc, 3*8*256+13*8
        ld      [player_y], bc


        jp      main_post_init_game




;==========================================
;::load_tileset_one_bank
;   in->hl patterns
;       de colors
;==========================================
load_tileset_one_bank
        push    de
        ld      de, tmp_unzip
        call    pletter_unpack

        ld      hl, tmp_unzip
        ld      de, CHRTBL
        ld      bc, 32*8*8
        call    LDIRVM

        ld      hl, tmp_unzip
        ld      de, CHRTBL+32*8*8
        ld      bc, 32*8*8
        call    LDIRVM

        ld      hl, tmp_unzip
        ld      de, CHRTBL+32*8*8*2
        ld      bc, 32*8*8
        call    LDIRVM

        pop     hl
        ld      de, tmp_unzip
        call    pletter_unpack

        ld      hl, tmp_unzip
        ld      de, CLRTBL
        ld      bc, 32*8*8
        call    LDIRVM

        ld      hl, tmp_unzip
        ld      de, CLRTBL+32*8*8
        ld      bc, 32*8*8
        call    LDIRVM

        ld      hl, tmp_unzip
        ld      de, CLRTBL+32*8*8*2
        ld      bc, 32*8*8
        call    LDIRVM

        ret

;==========================================
;::load_tileset_character_1
;   in->hl patterns
;       de colors
;==========================================
load_tileset_character_1
        push    de

                ld      de, tmp_unzip
                call    pletter_unpack

                ld      hl, tmp_unzip
                ld      de, CHRTBL + CHARACTER_1_OFFSET_TILE*8
                ld      bc, 64*8
                call    LDIRVM

                ld      hl, tmp_unzip
                ld      de, CHRTBL + CHARACTER_1_OFFSET_TILE*8 + 32*8*8
                ld      bc, 64*8
                call    LDIRVM

                ld      hl, tmp_unzip
                ld      de, CHRTBL+ CHARACTER_1_OFFSET_TILE*8 + 32*8*8*2
                ld      bc, 64*8
                call    LDIRVM

        pop     hl

        ld      de, tmp_unzip
        call    pletter_unpack

        ld      hl, tmp_unzip
        ld      de, CLRTBL + CHARACTER_1_OFFSET_TILE*8
        ld      bc, 64*8
        call    LDIRVM

        ld      hl, tmp_unzip
        ld      de, CLRTBL + CHARACTER_1_OFFSET_TILE*8 + 32*8*8
        ld      bc, 64*8
        call    LDIRVM

        ld      hl, tmp_unzip
        ld      de, CLRTBL + CHARACTER_1_OFFSET_TILE*8 + 32*8*8*2
        ld      bc, 64*8
        call    LDIRVM

        ret



;================================
;::LoadLevelRight
;================================
LoadLevelRight:
        ld      a, KEY_RIGHT
        call    ChangeLevel
        ret

;================================
;::LoadLevelLeft
;================================
LoadLevelLeft:
        ld      a, KEY_LEFT
        call    ChangeLevel
        ret

;================================
;::LoadLevelDown
;================================
LoadLevelDown:
        ld      a, KEY_DOWN
        call    ChangeLevel
        ret

;================================
;::LoadLevelUp
;================================
LoadLevelUp:
        ld      a, KEY_UP
        call    ChangeLevel
        ret


;===============================
;::ChangeLevel
;       in-> a: change direction
;===============================
ChangeLevel:
        cp      KEY_RIGHT
        jp      z, .TrateRight
        cp      KEY_LEFT
        jp      z, .TrateLeft
        cp      KEY_DOWN
        jp      z, .TrateDown

        jp      .TrateUp


.TrateRight:
        ld      a, [level]
        ld      b, a
        ld      hl, SCREENS_RIGHT
.LoopRight
        ld      a, [hl]
        cp      b
        jp      z, .FoundRight
        cp      EOF
        jp      z, .assert

        inc     hl
        jp      .LoopRight
        
.FoundRight
        xor     a
        ld      [camera_tile_x_left], a
        ld      a, 8
        ld      [player_x], a
        inc     hl
        jp      change_level

.TrateDown
        ld      a, [level]
        ld      b, a
        ld      hl, SCREENS_DOWN
.LoopDown        
        ld      a, [hl]
        cp      b
        jp      z, .FoundDown
        cp      EOF
        jp      z, .assert

        inc     hl
        jp      .LoopDown

.FoundDown
        xor     a
        ld      [camera_tile_y_top], a
        ld      a, 8*3
        ld      [player_y], a
        inc     hl
        jp      change_level


.TrateLeft
        ld      a, [level]
        ld      b, a
        ld      hl, SCREENS_RIGHT+1
.LoopLeft
        ld      a, [hl]
        cp      b
        jp      z, .FoundLeft
        cp      EOF
        jp      z, .assert

        inc     hl
        jp      .LoopLeft

.FoundLeft
        ld      a, 32
        ld      [camera_tile_x_left], a
        ld      a, 248
        ld      [player_x], a
        dec     hl
        jp      change_level

.TrateUp
        ld      a, [level]
        ld      b, a
        ld      hl, SCREENS_DOWN+1
.LoopUp
        ld      a, [hl]
        cp      b
        jp      z, .FoundUp
        cp      EOF
        jp      z, .assert

        inc     hl
        jp      .LoopUp

.FoundUp
        ld      a, 22
        ld      [camera_tile_y_top], a
        ld      a, 8*22
        ld      [player_y], a
        dec     hl
        jp      change_level

.assert jr .assert

;==================================
;::change_level
;       IN-> hl point to new level
;==================================
change_level
        ld      a, [hl]
        ld      [level], a
        jp      init_level

;============================================
;::init_level
;============================================
init_level
        xor     a
        ld      [player_key_pressed], a
        ld      [player_inc_y], a
        ld      [player_key_up_pressed], a
        ld      [player_space_key_pressed], a
        ld      [player_attack_counter], a
        ld      [player_attacking_no_move], a
        ld      [player_inter_scroll_counter_x], a
        ld      [concurrent_shoots], a

        ld      a, KEY_RIGHT
        ld      [player_direction], a

        call    init_tileset

        ld      a, [level]
        sla     a
        ld      c, a
        ld      b, 0
        ld      hl, map_data
        add     hl, bc

        ld      e, [hl]
        inc     hl
        ld      d, [hl]
        ex      de, hl

        call    build_level
        call    reset_entities
        call    init_entities_level
        call    scroll_entities

        ret

