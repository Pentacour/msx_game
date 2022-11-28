

;===========================================
;::init_game
;===========================================
init_game
        call    clear_screen
        call    init_sprites_size

        ld      a, EOF
        ld      [sprites_attributes_eof], a
        ld      [list_entities_data_end], a

        ld      hl, sprites_attributes - 4
        ld      [current_sprites_index], hl
        ld      [start_sprites_index], hl

        call    reset_sprites_list

;        call    load_player_sprites
;        ld      a, 14
;        ld      [player_sprite_1 + SPRITE_COLOR], a
;        ld      a, 11
;        ld      [player_sprite_2 + SPRITE_COLOR], a
;        ld      a, 4
;        ld      [player_sprite_3 + SPRITE_COLOR], a
;        xor     a
;        ld      [player_frame], a

;        call    load_sword_sprites

        xor     a
        ld      [level], a

        xor     a
        ld      [camera_tile_y_top], a
        ld      [camera_tile_x_left], a

        ld      bc, 5*8*256+15*8
        ld      [player_y], bc


        jp      main_post_init_game


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

        call    reset_entities

        ld      a, [level]
        cp      0
        jp      z, init_level_0

        cp      1
        jp      z, init_level_1

.assert 
        jr .assert
        



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

;===============================
;::ChangeLevel
;       in-> a: change direction
;===============================
ChangeLevel

        cp      KEY_RIGHT
        jp      z, .TrateRight
        cp      KEY_LEFT
        jp      z, .TrateLeft

        ret

.TrateRight
        ld      a, [level]
        ld      b, a

        ld      hl, SCREENS_RIGHT
        ld      a, [hl]
        cp      b
        jp      z, .FoundRight
        cp      EOF
        jp      z, .assert

        inc     hl
        jp      .TrateRight
        
.FoundRight
        xor     a
        ld      [camera_tile_x_left], a
        ld      a, 8
        ld      [player_x], a
        inc     hl
        jp      InitLevel

.TrateLeft
        ld      a, [level]
        ld      b, a

        ld      hl, SCREENS_RIGHT+1
        ld      a, [hl]
        cp      b
        jp      z, .FoundLeft
        cp      EOF
        jp      z, .assert

        inc     hl
        jp      .TrateLeft

.FoundLeft
        ld      a, 32
        ld      [camera_tile_x_left], a
        ld      a, 248
        ld      [player_x], a
        dec     hl
        jp      InitLevel


.assert jr .assert


;==================================
;::InitLevel
;       IN-> hl point to new level
;==================================
InitLevel
        ld      a, [hl]
        ld      [level], a

        cp      0
        jp      z, init_level_0
        cp      1
        jp      z, init_level_1

