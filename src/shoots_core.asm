;=============================
;::check_if_player_shoot_hit
; in-> IX entity
; out-> z if true. HL entity.
;=============================
check_if_player_shoot_hit
        ld      d, [ix+OFFSET_X]
        ld      e, [ix+OFFSET_Y]
        ld      [check_colision_pos], de
        ld      hl, list_destructible_entities_data
        ld      b, MAX_NUMBER_OF_DESTRUCTIBLES_ENTITIES
.loop
        push    bc
                ld      a, [hl]
                cp      0    
                jp      z, .next

                inc     hl  ;isvisible
                ld      a, [hl]
                cp      0
                jp      z, .next_because_no_visible
                inc     hl  ;y
                ld      c, [hl]
                inc     hl  ;x
                ld      b, [hl]
                ld      a, [ix]
        
                ld      de, [check_colision_pos] 
                call    is_colision_player_shoot_entity
                jp      z, .ret_yes

                ld      bc, DATA_SIZE_PER_ENTITY-3
                add     hl, bc
        pop     bc
        djnz    .loop
        jp      .exit

.next_because_no_visible
                dec     hl
.next
                ld      bc, DATA_SIZE_PER_ENTITY
                add     hl, bc
        pop     bc
        djnz    .loop

.exit
        xor     a
        cp      1
        ret     ;ret no

.ret_yes
        pop     bc
        dec     hl  ;y
        dec     hl  ;isvisible
        dec     hl  ;entity
        xor     a
        ld      [hl], a ; quit entity
        cp      0
        ret

;=====================================
;::is_colision_player_shoot_entity
;   in-> de player shoot [yx], bc [yx]
;   out->z collision
;=====================================
is_colision_player_shoot_entity
.SHOOT_WIDTH    equ     5
.ENTITY_WIDTH   equ     8

        ld      a, -.SHOOT_WIDTH
        add     d       ; shoot x
        ld      d, a    ; shoot left 
        ld      a, .ENTITY_WIDTH
        add     b       ; entity x
        cp      d
        jp      c, .ret_no

        sub     .ENTITY_WIDTH*2 ;entity left
        ld      b, a
        ld      a, .SHOOT_WIDTH*2 ;shoot right
        add     d
        cp      b
        jp      c, .ret_no

        ld      a, -.SHOOT_WIDTH
        add     e
        ld      e, a    ;shoot top
        ld      a, .ENTITY_WIDTH
        add     c       ;entity bottom
        cp      e
        jp      c, .ret_no

        sub     .ENTITY_WIDTH*2 ;entity top 
        ld      c, a
        ld      a, .SHOOT_WIDTH*2 ;shoot bottom
        add     e
        cp      c
        jp      c, .ret_no

.ret_yes
        xor     a
        cp      0
        ret
.ret_no
        xor     a
        cp      1
        ret
