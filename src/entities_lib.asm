; Not compiled with project. It will be in msx_gen app that will copy
; only needed functions in entities.asm

;ENTITY_STOPWALK_START_FUNC
;================================
;::trate_stopwalk
;  in-> ix: entity vars.
;===============================
trate_stopwalk

.WALK_INC       equ     8
.WALK_TIME      equ     20
.STOP_TIME      equ     2
.STATE_STOPPED  equ     0
.STATE_WALKING  equ     1
        ld      a, [ix+OFFSET_IS_VISIBLE]
        cp      0
        jp      z, inc_not_visible_counter

        ld      a, [animation_tick]
        and     7
        cp      7
        jp      nz, .render

        ld      a, [ix+OFFSET_STATE]
        cp      .STATE_STOPPED
        jp      z, .trate_stopped

.trate_walking
        ld      de, [player_y]
        call    is_collision_with_entity
        jp      z, trate_collision_player_entity

        inc     [ix+OFFSET_STATE_COUNTER]
        ld      a, [ix+OFFSET_STATE_COUNTER]
        cp      .WALK_TIME
        jr      z, .change_state_stopped

        ld      a, [ix+OFFSET_X]
        ld      [tmp_pos_x], a
        ld      a, [ix+OFFSET_Y]
        ld      [tmp_pos_y], a

        ld      a, [ix+OFFSET_INC_X]
        add     [ix+OFFSET_X]
        ld      [ix+OFFSET_X], a

        ld      a, [ix+OFFSET_INC_Y]
        add     [ix+OFFSET_Y]
        ld      [ix+OFFSET_Y], a

        call    check_if_valid_position_entity
        jp      nz, .undo

        ld      a, [ix+OFFSET_X]
        cp      30*8+1
        jp      nc, .undo

        cp      8
        jp      c, .undo

        ld      a, [ix+OFFSET_Y]
        cp      22*8
        jp      nc, .undo

        cp      8*3+8
        jp      c, .undo

        jp      .render

.undo
        ld      a, [tmp_pos_x]
        ld      [ix+OFFSET_X], a
        ld      a, [tmp_pos_y]
        ld      [ix+OFFSET_Y], a
        jp      .render

.change_state_stopped
        ld      [ix+OFFSET_STATE_COUNTER], 0
        ld      [ix+OFFSET_STATE], .STATE_STOPPED

.trate_stopped
        inc     [ix+OFFSET_STATE_COUNTER]
        ld      a, [ix+OFFSET_STATE_COUNTER]
        cp      .STOP_TIME
        jp      nz, .render

        ld      [ix+OFFSET_STATE_COUNTER], 0
        ld      [ix+OFFSET_STATE], .STATE_WALKING

.change_state_walking
        ld      a, [animation_tick]
        cp      64
        jp      c, .change_up
        cp      128
        jr      c, .change_right
        cp      192
        jr      c, .change_down

                ; change_left
        ld      [ix+OFFSET_INC_X], -.WALK_INC
        ld      [ix+OFFSET_INC_Y], 0
        ld      [ix+OFFSET_DIRECTION], KEY_LEFT
        jr      .render

.change_up
        ld      [ix+OFFSET_INC_Y], -.WALK_INC
        ld      [ix+OFFSET_INC_X], 0
        ld      [ix+OFFSET_DIRECTION], KEY_UP
        jr      .render

.change_right
        ld      [ix+OFFSET_INC_X], .WALK_INC
        ld      [ix+OFFSET_INC_Y], 0
        ld      [ix+OFFSET_DIRECTION], KEY_RIGHT
        jr      .render

.change_down
        ld      [ix+OFFSET_INC_Y], .WALK_INC
        ld      [ix+OFFSET_INC_X], 0
        ld      [ix+OFFSET_DIRECTION], KEY_DOWN
        jr      .render

.render
        call    render_character
        jp      next_entity
;ENTITY_STOPWALK_END_FUNC        

;ENTITY_GEN_STOPWALK_RIGHT_FIXED_START_FUNC
;================================
;::trate_gen_stopwalk
;  in-> ix: entity vars.
;===============================
trate_gen_stopwalk
trate_gen_stopwalk_right
trate_gen_stopwalk_right_fixed
trate_gen_stopwalk_left_fixed
.PERIOD_TIME    equ     40
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

        ld      a, [ix+OFFSET_TYPE]
        ld      [tmp_gen_type], a
        ld      a, [ix+OFFSET_Y]
        ld      [tmp_pos_y], a
        ld      a, [ix+OFFSET_CHARACTER_TYPE]
        
        push    ix

                push    af

                        call    get_next_empty_destructible_entity_ix
                        ld      [ix+OFFSET_TYPE], ENTITY_STOPWALK
                        ld      [ix+OFFSET_STATE], 1
                        ld      [ix+OFFSET_STATE_COUNTER], 0
                        ld      a, [tmp_gen_type]
                        cp      ENTITY_GEN_STOPWALK_RIGHT_FIXED
                        jp      z, .trate_right_fixed
                        cp      ENTITY_GEN_STOPWALK_LEFT_FIXED
                        jp      z, .trate_left_fixed

                        call    assign_random_free_y
                        ld      [ix+OFFSET_DIRECTION], KEY_LEFT
                        jp      .continue_creating
.trate_right_fixed
                        ld      a, [tmp_pos_y]
                        ld      [ix+OFFSET_Y], a
                        ld      [ix+OFFSET_X], 30*8
                        ld      [ix+OFFSET_DIRECTION], KEY_LEFT
                        jp      .continue_creating
.trate_left_fixed
                        ld      a, [tmp_pos_y]
                        ld      [ix+OFFSET_Y], a
                        ld      [ix+OFFSET_X], 1*8
                        ld      [ix+OFFSET_DIRECTION], KEY_RIGHT
                        jp      .continue_creating

.continue_creating
                        ld      [ix+OFFSET_IS_VISIBLE], 1
                        ld      [ix+OFFSET_INC_X], -8
                        ld      [ix+OFFSET_INC_Y], 0
                pop     af

                ld      [ix+OFFSET_CHARACTER_TYPE], a

        pop     ix

        ld      [ix+OFFSET_STATE_COUNTER], 0
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
;ENTITY_GEN_STOPWALK_RIGHT_FIXED_END_FUNC

;ENTITY_FOLLOWPLAYER_START_FUNC
;================================
;::trate_followplayer
;  in-> ix: entity vars.
;===============================
trate_followplayer

.WALK_INC       equ     8
        ld      a, [ix+OFFSET_IS_VISIBLE]
        cp      0
        jp      z, inc_not_visible_counter

        ld      a, [animation_tick]
        and     15
        cp      15
        jp      nz, .render

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
        ld      [ix+OFFSET_DIRECTION], KEY_LEFT
        jp      .move

.change_up
        ld      [ix+OFFSET_INC_Y], -.WALK_INC
        ld      [ix+OFFSET_INC_X], 0
        ld      [ix+OFFSET_DIRECTION], KEY_UP
        jp      .move

.change_right
        ld      [ix+OFFSET_INC_X], .WALK_INC
        ld      [ix+OFFSET_INC_Y], 0
        ld      [ix+OFFSET_DIRECTION], KEY_RIGHT
        jp      .move

.change_down
        ld      [ix+OFFSET_INC_Y], .WALK_INC
        ld      [ix+OFFSET_INC_X], 0
        ld      [ix+OFFSET_DIRECTION], KEY_DOWN
        jp      .move

.change_up_left
        ld      [ix+OFFSET_INC_Y], -.WALK_INC
        ld      [ix+OFFSET_INC_X], -.WALK_INC
        ld      [ix+OFFSET_DIRECTION], KEY_UPLEFT
        jp      .move

.change_up_right
        ld      [ix+OFFSET_INC_X], .WALK_INC
        ld      [ix+OFFSET_INC_Y], -.WALK_INC
        ld      [ix+OFFSET_DIRECTION], KEY_UPRIGHT
        jp      .move

.change_down_right
        ld      [ix+OFFSET_INC_X], .WALK_INC
        ld      [ix+OFFSET_INC_Y], .WALK_INC
        ld      [ix+OFFSET_DIRECTION], KEY_DOWNRIGHT
        jp      .move

.change_down_left
        ld      [ix+OFFSET_INC_Y], .WALK_INC
        ld      [ix+OFFSET_INC_X], -.WALK_INC
        ld      [ix+OFFSET_DIRECTION], KEY_DOWNLEFT
        jp      .move


.move
        ld      a, [ix+OFFSET_X]
        ld      [prev_x], a
        ld      a, [ix+OFFSET_Y]
        ld      [prev_y], a
        
        ld      a, [ix+OFFSET_INC_X]
        add     [ix+OFFSET_X]
        ld      [ix+OFFSET_X], a

        ld      a, [ix+OFFSET_INC_Y]
        add     [ix+OFFSET_Y]
        ld      [ix+OFFSET_Y], a

        call    check_if_valid_position_entity
        jr      nz, .undo

.check_collision
        ld      de, [player_y]
        call    is_collision_with_entity
        jp      z, trate_collision_player_entity

.render
        call    render_character
        jp      next_entity

.undo
        ld      bc, [prev_y]
        ld      [ix+OFFSET_X], b
        ld      [ix+OFFSET_Y], c
        jr      .check_collision
;ENTITY_FOLLOWPLAYER_END_FUNC


