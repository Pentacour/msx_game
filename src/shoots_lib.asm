;================================
;::trate_shoot_simple
;  in-> ix: entity vars.
;===============================
trate_shoot_simple
.INCREMENT      equ     8
.STATE_CREATE   equ     0
.STATE_MOVE     equ     1

        ld      a, [ix+OFFSET_STATE]
        cp      .STATE_CREATE
        jp      z, .create_shoot

        ld      a, [animation_tick]
        and     7
        cp      7
        jp      nz, .render

                ; Move
        ld      a, [ix+OFFSET_INC_X]
        add     [ix+OFFSET_X]
        cp      31*8    ;TODO
        jp      nc, .quit_entity
        cp      1*8    ;TODO
        jp      c, .quit_entity
        ld      [ix+OFFSET_X], a
        
        ld      a, [ix+OFFSET_INC_Y]
        add     [ix+OFFSET_Y]
        cp      23*8    ;TODO
        jp      nc, .quit_entity
        cp      2*8+1*8    ;TODO
        jp      c, .quit_entity
        ld      [ix+OFFSET_Y], a

        call    check_if_valid_position_entity
        jp      nz, .quit_entity
        
.render
        ld      b, [ix+OFFSET_X]
        ld      c, [ix+OFFSET_Y]
        call    YXToOffset
        ld      hl, camera_view
        add     hl, de
        xor     a
        ld      [hl], a

        jp      next_entity

.create_shoot
        ld      [ix+OFFSET_INC_X], .INCREMENT
        ld      [ix+OFFSET_INC_Y], 0
        ld      a, [player_x]
        ld      [ix+OFFSET_X], a
        ld      a, [player_y]
        ld      [ix+OFFSET_Y], a
        ld      [ix+OFFSET_STATE], .STATE_MOVE
        jp      .render

.quit_entity ;TODO
        ld      [ix+OFFSET_TYPE], 0
        jp      next_entity
        