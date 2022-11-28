LEVEL_MAX_TILE_RIGHT      EQU 32
LEVEL_MAX_TILE_DOWN       EQU 22

SCROLL_MARGIN_RIGHT     EQU 28*8
SCROLL_MARGIN_LEFT      EQU 4*8+1
SCROLL_MARGIN_UP        EQU 6*8
SCROLL_MARGIN_DOWN      EQU 18*8

CHANGE_LEVEL_MAX_X      EQU 31*8
CHANGE_LEVEL_MIN_X      EQU 1*8+1
CHANGE_LEVEL_MIN_Y      EQU 3*8+1
CHANGE_LEVEL_MAX_Y      EQU 22*8

PLAYER_INC              EQU     2

;====================================
;::m_check_start_shoot
;====================================
 macro m_check_start_shot
        xor     a
        call    GTTRIG
        cp      0
        jp      nz, .button_pressed
        ld      a, 1
        call    GTTRIG
        cp      0
        jp      nz, .button_pressed
        
        xor     a
        ld      [player_space_key_pressed], a
        jp      .end_m_checkshoot

.button_pressed
        ld      a, [player_space_key_pressed]
        cp      1

        call    add_new_player_shot

.end_m_checkshoot

 endmacro


;=====================================
; ::move_player
;=====================================
move_player
        ld      bc, [player_y]
        ld      [player_previous_y], bc

        ld      a, 0
        call    GTSTCK

        cp      KEY_UPRIGHT
        jp      z, TrateUpRightKey
        cp      KEY_RIGHT
        jp      z, TrateRightKey
        cp      KEY_DOWNRIGHT
        jp      z, TrateDownRightKey
        cp      KEY_DOWN
        jp      z, TrateDownKey
        cp      KEY_DOWNLEFT
        jp      z, TrateDownLeftKey
        cp      KEY_LEFT
        jp      z, TrateLeftKey
        cp      KEY_UPLEFT
        jp      z, TrateUpLeftKey
        cp      KEY_UP
        jp      z, TrateUpKey

        ret

;===============================
;::TrateUpRightKey
;===============================
TrateUpRightKey
        call    TrateUpKey
        ld      bc, [player_y]
        ld      [player_previous_y], bc
        call    TrateRightKey
        ret


;===============================
;::TrateRightKey
;===============================
TrateRightKey
        ld      a, [player_x]
        cp      SCROLL_MARGIN_RIGHT
        jp      nc, .CheckIfScroll

.MovePlayer
                ; Checks if change level

        ld      a, [player_x]
        cp      CHANGE_LEVEL_MAX_X
        jp      nc, LoadLevelRight

        add     PLAYER_INC
        ld      [player_x], a
        call    CanGoPlayer
        jp      nz, UndoMovement
        ret
 
.CheckIfScroll
                ; Checks if the camera is at maximum right

        ld      a, [camera_tile_x_left]
        cp      LEVEL_MAX_TILE_RIGHT
        jp      z, .MovePlayer

                ; Increments interscroll counter

        ld      a, [player_inter_scroll_counter_x]
        add     PLAYER_INC
        ld      [player_inter_scroll_counter_x], a
        and     7
        cp      0
        ret     nz

                ; Checks if scroll causes background colision

        ld      bc, [player_y]
        ld      a, 8
        add     b
        ld      b, a
        call    CanGo
        ret     nz

                ; Scroll when right 
        ld      a, [camera_tile_x_left]
        inc     a
        ld      [camera_tile_x_left], a

        ld      a, KEY_RIGHT
        ld      [scroll_entities_direction], a
        call    scroll_entities
        ret
       

;===============================
;::TrateDownRightKey
;===============================
TrateDownRightKey
        call    TrateDownKey
        ld      bc, [player_y]
        ld      [player_previous_y], bc
        call    TrateRightKey
        ret


;===============================
;::TrateLeftKey
;===============================
TrateLeftKey
        ld      a, [player_x]
        cp      SCROLL_MARGIN_LEFT
        jp      c, .CheckIfScroll

.MovePlayer
                ; Checks if change level

        ld      a, [player_x]
        cp      CHANGE_LEVEL_MIN_X
.assert
        jp      c, LoadLevelLeft

        sub     PLAYER_INC
        ld      [player_x], a
        call    CanGoPlayer
        jp      nz, UndoMovement
        ret

 
.CheckIfScroll
                ;checks if the camera is at minim up

        ld      a, [camera_tile_x_left]
        cp      0
        jp      z, .MovePlayer

                ;increments interscroll counter

        ld      a, [player_inter_scroll_counter_x]
        add     PLAYER_INC
        ld      [player_inter_scroll_counter_x], a
        and     7
        cp      0
        ret     nz

                ; Checks if scroll causes background colision

        ld      bc, [player_y]
        ld      a, b
        sub     8
        ld      b, a
        call    CanGo
        ret     nz       

        ld      a, [camera_tile_x_left]
        dec     a
        ld      [camera_tile_x_left], a

        ld      a, KEY_LEFT
        ld      [scroll_entities_direction], a
        call    scroll_entities

        ret
       

;===============================
;::TrateDownLeftKey
;===============================
TrateDownLeftKey
        call    TrateDownKey
        ld      bc, [player_y]
        ld      [player_previous_y], bc
        call    TrateLeftKey
        ret


;===============================
;::TrateUpLeftKey
;===============================
TrateUpLeftKey
        call    TrateUpKey
        ld      bc, [player_y]
        ld      [player_previous_y], bc
        call    TrateLeftKey
        ret


;===============================
;::TrateUpKey
;===============================
TrateUpKey
        ld      a, [player_y]
        cp      SCROLL_MARGIN_UP
        jp      nc, .CheckIfScroll

.MovePlayer
                ; Checks if change level

        ld      a, [player_y]
        cp      CHANGE_LEVEL_MIN_Y
.assert
        jp      c, .assert

        sub     PLAYER_INC
        ld      [player_y], a
        call    CanGoPlayer
        jp      nz, UndoMovement
        ret

 
.CheckIfScroll
                ;checks if the camera is at minim up

        ld      a, [camera_tile_y_top]
        cp      0
        jp      z, .MovePlayer

                ;increments interscroll counter

        ld      a, [player_inter_scroll_counter_y]
        add     PLAYER_INC
        ld      [player_inter_scroll_counter_y], a
        and     7
        cp      0
        ret     nz

                ; Checks if scroll causes background colision

        ld      bc, [player_y]
        ld      a, c
        sub     8
        ld      c, a
        call    CanGo
        ret     nz

        ld      a, [camera_tile_y_top]
        dec     a
        ld      [camera_tile_y_top], a

        ld      a, KEY_UP
        ld      [scroll_entities_direction], a
        call    scroll_entities

        ret
       


;===============================
;::TrateDownKey
;===============================
TrateDownKey
        ld      a, [player_y]
        cp      SCROLL_MARGIN_DOWN
        jp      nc, .CheckIfScroll

.MovePlayer
                ; Checks if change level

        ld      a, [player_y]
        cp      CHANGE_LEVEL_MAX_Y
.assert
        jp      nc, .assert

        add     PLAYER_INC
        ld      [player_y], a
        call    CanGoPlayer
        jp      nz, UndoMovement
        ret

 
.CheckIfScroll
                ;checks if the camera is at minim up

        ld      a, [camera_tile_y_top]
        cp      LEVEL_MAX_TILE_DOWN
        jp      z, .MovePlayer

                ;increments interscroll counter

        ld      a, [player_inter_scroll_counter_y]
        add     PLAYER_INC
        ld      [player_inter_scroll_counter_y], a
        and     7
        cp      0
        ret     nz

                ; Checks if scroll causes background colision

        ld      bc, [player_y]
        ld      a, c
        add     8
        ld      c, a
        call    CanGo
        ret     nz

        ld      a, [camera_tile_y_top]
        inc     a
        ld      [camera_tile_y_top], a

        ld      a, KEY_DOWN
        ld      [scroll_entities_direction], a
        call    scroll_entities

        ret
       



;=======================================================
;::UndoMovement
;========================================================
UndoMovement
        ld    bc, [player_previous_y]
        ld    [player_y], bc
        ret


;================================
;::LoadLevelRight
;================================
LoadLevelRight
        ld      a, KEY_RIGHT
        call    ChangeLevel
        ret

;================================
;::LoadLevelLeft
;================================
LoadLevelLeft
        ld      a, KEY_LEFT
        call    ChangeLevel
        ret

;================================
;::SetPlayerFrame
;================================
SetPlayerFrame
        ld      de, sprites_attributes
        ld      hl, tmp_sp_1
        ld      bc, 8
        ldir

        ld      a, [player_y]
        sub     8 ;15
        ld      [sprites_attributes], a
        ld      a, [player_x]
        sub     8
        ld      [sprites_attributes+1], a

        ret


tmp_sp_1        db      20, 20, 0, 8
tmp_sp_2        db      20, 20, 4, 4


;====================================
;::add_new_player_shoot
;====================================
add_new_player_shoot
/*
        call  entity.get_next_empty_indestructible_in_game
        ld    [hl], entity.k_entity_player_shoot
        inc   hl
        ld    [hl], 1 ;isvisible
        inc   hl
        ld    a, [mwork.player_direction]
        cp    k_key_up
        jp    z, .sup
        cp    k_key_upright
        jp    z, .supright
        cp    k_key_right
        jp    z, .sright
        cp    k_key_downright
        jp    z, .sdownright
        cp    k_key_down
        jp    z, .sdown
        cp    k_key_downleft
        jp    z, .sdownleft
        cp    k_key_left
        jp    z, .sleft

.supleft
    ld    a, [mwork.player_y]
    add   7
    ld    [hl], a
    inc   hl
    ld    a, [mwork.player_x]
    ld    [hl], a
    inc   hl
    ld    [hl], -8
    inc   hl
    ld    [hl], -8
    ret

.sup
    ld    a, [mwork.player_y]
    ld    [hl], a
    inc   hl
    ld    a, [mwork.player_x]
    ld    [hl], a
    inc   hl
    ld    [hl], -8
    inc   hl
    ld    [hl], 0
    ret

.supright
    ld    a, [mwork.player_y]
    add   7
    ld    [hl], a
    inc   hl
    ld    a, [mwork.player_x]
    ld    [hl], a
    inc   hl
    ld    [hl], -8
    inc   hl
    ld    [hl], 8
    ret

.sright
    ld    a, [mwork.player_y]
    add   3
    ld    [hl], a
    inc   hl
    ld    a, [mwork.player_x]
    ld    [hl], a
    inc   hl
    ld    [hl], 0
    inc   hl
    ld    [hl], 8
    ret

.sdownright
    ld    a, [mwork.player_y]
    ld    [hl], a
    inc   hl
    ld    a, [mwork.player_x]
    ld    [hl], a
    inc   hl
    ld    [hl], 8
    inc   hl
    ld    [hl], 8
    ret

.sdown
    ld    a, [mwork.player_y]
    ld    [hl], a
    inc   hl
    ld    a, [mwork.player_x]
    ld    [hl], a
    inc   hl
    ld    [hl], 8
    inc   hl
    ld    [hl], 0
    ret

.sdownleft
    ld    a, [mwork.player_y]
    ld    [hl], a
    inc   hl
    ld    a, [mwork.player_x]
    ld    [hl], a
    inc   hl
    ld    [hl], 8
    inc   hl
    ld    [hl], -8
    ret

.sleft
    ld    a, [mwork.player_y]
    add   3
    ld    [hl], a
    inc   hl
    ld    a, [mwork.player_x]
    ld    [hl], a
    inc   hl
    ld    [hl], 0
    inc   hl
    ld    [hl], -8
    ret
*/