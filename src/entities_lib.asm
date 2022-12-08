;================================
;::trate_stopwalk
;  in-> ix: entity vars.
;===============================
trate_stopwalk

.WALK_INC       equ     2
.WALK_TIME      equ     60
.STOP_TIME      equ     15
.STATE_STOPPED  equ     0
.STATE_WALKING  equ     1

        ld      a, [ix+OFFSET_IS_VISIBLE]
        cp      0
        jp      z, inc_not_visible_counter

        ld      a, [animation_tick]
        and     3
        cp      3
        jp      nz, .render

        ld      a, [ix+OFFSET_STATE]
        cp      .STATE_STOPPED
        jp      z, .trate_stopped

.trate_walking
        inc     [ix+OFFSET_STATE_COUNTER]
        ld      a, [ix+OFFSET_STATE_COUNTER]
        cp      .WALK_TIME
        jr      z, .change_state_stopped

        ld      a, [ix+OFFSET_INC_X]
        add     [ix+OFFSET_X]
        ld      [ix+OFFSET_X], a

        ld      a, [ix+OFFSET_INC_Y]
        add     [ix+OFFSET_Y]
        ld      [ix+OFFSET_Y], a

        call    check_if_valid_position_entity
        jp      nz, .turn_around

        ld      a, [ix+OFFSET_X]
        cp      31*8+1
        jp      nc, .turn_around

        cp      8
        jp      c, .turn_around

        ld      a, [ix+OFFSET_Y]
        cp      22*8
        jp      nc, .turn_around

        cp      8*2+8
        jp      c, .turn_around

        jp      .render

.turn_around
        ld      a, [ix+OFFSET_INC_X]        
        cp      0
        jr      z, .turn_around_y

        ld      a, [ix+OFFSET_INC_X]
        neg
        ld      [ix+OFFSET_INC_X], a
        jr      .trate_walking

.turn_around_y
        ld      a, [ix+OFFSET_INC_Y]
        neg
        ld      [ix+OFFSET_INC_Y], a
        jr      .trate_walking

.change_state_stopped
        ld      [ix+OFFSET_STATE_COUNTER], 0
        ld      [ix+OFFSET_STATE], .STATE_STOPPED

.trate_stopped
        inc     [ix+OFFSET_STATE_COUNTER]
        ld      a, [ix+OFFSET_STATE_COUNTER]
        cp      .STOP_TIME
        jr      z, .change_state_walking
        jp      .render

.change_state_walking
        ld      [ix+OFFSET_STATE_COUNTER], 0
        ld      [ix+OFFSET_STATE], .STATE_WALKING

        ld      a, [animation_tick]
        cp      64
        jp      c, .change_up
        cp      128
        jr      c, .change_right
        cp      192
        jr      c, .change_down
.change_left
        ld      [ix+OFFSET_INC_X], -.WALK_INC
        ld      [ix+OFFSET_INC_Y], 0
        jr      .render

.change_up
        ld      [ix+OFFSET_INC_Y], -.WALK_INC
        ld      [ix+OFFSET_INC_X], 0
        jr      .render

.change_right
        ld      [ix+OFFSET_INC_X], .WALK_INC
        ld      [ix+OFFSET_INC_Y], 0
        jr      .render

.change_down
        ld      [ix+OFFSET_INC_Y], .WALK_INC
        ld      [ix+OFFSET_INC_X], 0
        jr      .render

.render
        ld      b, [ix+OFFSET_X]
        ld      c, [ix+OFFSET_Y]
        call    YXToOffset
        ld      hl, camera_view
        add     hl, de
        xor     a
        ld      [hl], a
        dec     hl
        ld      [hl], a
        ld      bc, -32
        add     hl, bc
        ld      [hl], a
        inc     hl
        ld      [hl], a 

        jp      next_entity


;================================
;::trate_gen_stopwalk
;  in-> ix: entity vars.
;===============================
trate_gen_stopwalk

.PERIOD_TIME    equ     60
        ld      a, [ix+OFFSET_IS_VISIBLE]
        cp      0
        jp      z, next_entity 

        ld      a, [animation_tick]
        and     3
        cp      3
        jp      nz, next_entity

        inc     [ix+OFFSET_STATE_COUNTER]        
        ld      a, [ix+OFFSET_STATE_COUNTER]
        cp      .PERIOD_TIME
        jp      nz, .render

                ; Generate a stopwalk entity

        push    ix

        call    get_next_empty_entity_ix
        ld      [ix+OFFSET_TYPE], 1 ;TODO Use constant
        ld      [ix+OFFSET_STATE], 0
        ld      [ix+OFFSET_STATE_COUNTER], 0
        ld      [ix+OFFSET_X], 31*8
        ld      [ix+OFFSET_Y], 8*8
        ld      [ix+OFFSET_IS_VISIBLE], 1

        pop     ix

        ld      [ix+OFFSET_STATE_COUNTER], a
        jp      next_entity
        
.render
        ld      b, [ix+OFFSET_X]
        ld      c, [ix+OFFSET_Y]
        call    YXToOffset
        ld      hl, camera_view
        add     hl, de
        xor     a
        ld      [hl], a

        jp      next_entity


;================================
;::trate_stopsearch
;  in-> ix: entity vars.
;===============================
trate_stopsearch

.WALK_INC       equ     8
.WALK_TIME      equ     20
.STOP_TIME      equ     5
.STATE_STOPPED  equ     0
.STATE_WALKING  equ     1

        ld      a, [ix+OFFSET_IS_VISIBLE]
        cp      0
        jp      z, inc_not_visible_counter

        ld      a, [animation_tick]
        and     15
        cp      15
        jp      nz, .render

        ld      a, [ix+OFFSET_STATE]
        cp      .STATE_STOPPED
        jp      z, .trate_stopped

.trate_walking
        inc     [ix+OFFSET_STATE_COUNTER]
        ld      a, [ix+OFFSET_STATE_COUNTER]
        cp      .WALK_TIME
        jr      z, .change_state_stopped

        ld      a, [ix+OFFSET_INC_X]
        add     [ix+OFFSET_X]
        ld      [ix+OFFSET_X], a

        ld      a, [ix+OFFSET_INC_Y]
        add     [ix+OFFSET_Y]
        ld      [ix+OFFSET_Y], a

        call    check_if_valid_position_entity
        jp      nz, .turn_around

        ld      a, [ix+OFFSET_X]
        cp      31*8+1
        jp      nc, .turn_around

        cp      8
        jp      c, .turn_around

        ld      a, [ix+OFFSET_Y]
        cp      22*8
        jp      nc, .turn_around

        cp      8*2+8
        jp      c, .turn_around

        jp      .render

.turn_around
        ld      a, [ix+OFFSET_INC_X]        
        cp      0
        jr      z, .turn_around_y

        ld      a, [ix+OFFSET_INC_X]
        neg
        ld      [ix+OFFSET_INC_X], a
        jr      .trate_walking

.turn_around_y
        ld      a, [ix+OFFSET_INC_Y]
        neg
        ld      [ix+OFFSET_INC_Y], a
        jr      .trate_walking

.change_state_stopped
        ld      [ix+OFFSET_STATE_COUNTER], 0
        ld      [ix+OFFSET_STATE], .STATE_STOPPED

.trate_stopped
        inc     [ix+OFFSET_STATE_COUNTER]
        ld      a, [ix+OFFSET_STATE_COUNTER]
        cp      .STOP_TIME
        jr      z, .change_state_walking
        jp      .render

.change_state_walking
        ld      [ix+OFFSET_STATE_COUNTER], 0
        ld      [ix+OFFSET_STATE], .STATE_WALKING

        call    where_is_player

        cp      KEY_DOWN
        jp      z, .change_down
        cp      KEY_UP
        jp      z, .change_up
        cp      KEY_LEFT
        jp      z, .change_left
        cp      KEY_RIGHT
        jp      z, .change_right
        cp      KEY_UPLEFT
        jp      z, .change_up_left
        cp      KEY_DOWNLEFT
        jp      z, .change_down_left
        cp      KEY_UPRIGHT
        jp      z, .change_up_right
        cp      KEY_DOWNRIGHT
        jp      z, .change_down_right

.change_left
        ld      [ix+OFFSET_INC_X], -.WALK_INC
        ld      [ix+OFFSET_INC_Y], 0
        jp      .render

.change_up
        ld      [ix+OFFSET_INC_Y], -.WALK_INC
        ld      [ix+OFFSET_INC_X], 0
        jp      .render

.change_up_left
        ld      [ix+OFFSET_INC_Y], -.WALK_INC
        ld      [ix+OFFSET_INC_X], -.WALK_INC
        jp      .render

.change_right
        ld      [ix+OFFSET_INC_X], .WALK_INC
        ld      [ix+OFFSET_INC_Y], 0
        jp      .render

.change_up_right
        ld      [ix+OFFSET_INC_X], .WALK_INC
        ld      [ix+OFFSET_INC_Y], -.WALK_INC
        jp      .render

.change_down_right
        ld      [ix+OFFSET_INC_X], .WALK_INC
        ld      [ix+OFFSET_INC_Y], .WALK_INC
        jp      .render


.change_down
        ld      [ix+OFFSET_INC_Y], .WALK_INC
        ld      [ix+OFFSET_INC_X], 0
        jp      .render

.change_down_left
        ld      [ix+OFFSET_INC_Y], .WALK_INC
        ld      [ix+OFFSET_INC_X], -.WALK_INC
        jp      .render


.render
        ld      b, [ix+OFFSET_X]
        ld      c, [ix+OFFSET_Y]
        call    YXToOffset
        ld      hl, camera_view
        add     hl, de
        xor     a
        ld      [hl], a
        dec     hl
        ld      [hl], a
        ld      bc, -32
        add     hl, bc
        ld      [hl], a
        inc     hl
        ld      [hl], a 

        jp      next_entity


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
        ld      a, KEY_DOWN
        ret

.is_left
        ld      a, [player_y]
        sub     8
        cp      [ix+OFFSET_Y]
        jp      nc, .is_left_down
        add     8
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
        add     8
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



        ld      a, KEY_RIGHT
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