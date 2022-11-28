;================================
;::trate_stopwalk
;  in-> ix: entity vars.
;===============================
trate_stopwalk

.WALK_INC       equ     2
.WALK_TIME      equ     100
.STOP_TIME      equ     60
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
        cp      30*8
        jp      nc, .turn_around

        cp      8
        jp      c, .turn_around

        ld      a, [ix+OFFSET_Y]
        cp      22*8
        jp      nc, .turn_around

        cp      16
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