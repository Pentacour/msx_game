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
        and     1
        cp      1
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
        
        call    check_if_player_shoot_hit
        jp      z, .quit_entity

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
        ld      a, [player_x]
        ld      [ix+OFFSET_X], a
        ld      a, [player_y]
        ld      [ix+OFFSET_Y], a
        ld      [ix+OFFSET_STATE], .STATE_MOVE

        ld      a, [player_direction]
        cp      KEY_UP
        jp      z, .shoot_up
        cp      KEY_UPRIGHT
        jp      z, .shoot_upright
        cp      KEY_RIGHT
        jp      z, .shoot_right
        cp      KEY_DOWNRIGHT
        jp      z, .shoot_downright
        cp      KEY_DOWN
        jp      z, .shoot_down
        cp      KEY_DOWNLEFT
        jp      z, .shoot_downleft
        cp      KEY_LEFT
        jp      z, .shoot_left
        cp      KEY_UPLEFT
        jp      z, .shoot_upleft
.lk jr .lk      ;ASSERT

.shoot_up
        ld      [ix+OFFSET_INC_X], 0
        ld      [ix+OFFSET_INC_Y], -.INCREMENT
        jp      .render

.shoot_upright
        ld      [ix+OFFSET_INC_X], .INCREMENT
        ld      [ix+OFFSET_INC_Y], -.INCREMENT
        jp      .render

.shoot_right
        ld      [ix+OFFSET_INC_X], .INCREMENT
        ld      [ix+OFFSET_INC_Y], 0
        jp      .render

.shoot_downright
        ld      [ix+OFFSET_INC_X], .INCREMENT
        ld      [ix+OFFSET_INC_Y], .INCREMENT
        jp      .render

.shoot_down
        ld      [ix+OFFSET_INC_X], 0
        ld      [ix+OFFSET_INC_Y], .INCREMENT
        jp      .render

.shoot_downleft
        ld      [ix+OFFSET_INC_X], -.INCREMENT
        ld      [ix+OFFSET_INC_Y], .INCREMENT
        jp      .render

.shoot_left
        ld      [ix+OFFSET_INC_X], -.INCREMENT
        ld      [ix+OFFSET_INC_Y], 0
        jp      .render

.shoot_upleft
        ld      [ix+OFFSET_INC_X], -.INCREMENT
        ld      [ix+OFFSET_INC_Y], -.INCREMENT
        jp      .render

.quit_entity 
        ld      a, [concurrent_shoots]
        dec     a
        ld      [concurrent_shoots], a

        ld      [ix+OFFSET_TYPE], 0
        jp      next_entity
        