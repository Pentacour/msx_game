
;======================================
;::reset_big_ram
;  in->bc size, de destination
;======================================
reset_big_ram
                        xor             a
                        ld              [de], a
                        inc             de
                        dec             bc
                        ld              a, b
                        or              c
                        cp              0
                        jp              nz, reset_big_ram
                        ret

;============================
;setvramadd:    ; --- rutina que prepara una direccion en vram para escribir ---
; --- entrada: de -> direccion de vram donde escribir        ---
; --- salida: c -> puerto #0 de escritura del vdp            ---
;============================
setvramadd
                        set             6,d                             ; activamos el sexto bit del byte alto (normalmente escritura)
                        ld              a, [7] ;[vdpdatawrite]          ; a = puerto #0 de escritura del vdp
                        ld              c,a                             ; c = puerto #0 de escritura del vdp
                        inc             c                               ; c = puerto #1 de escritura del vdp
                        out             [c],e                           ; escribimos en el vdp el byte bajo de la direccion de destino
                        nop                                   ; pausa...
                        nop                                   ; pausa...
                        out             [c],d                           ; escribimos en el vdp el byte alto de la direccion de destino
                        dec             c                               ; c = puerto #0 de escritura del vdp
                        ret                                   ; volvemos





;======================================
;ufldirvm:       ; --- volcado de ram a vram version ultra. usar en el vblank  ---
; --- entrada: hl = origen en ram                             ---
; ---          de = destino en vram                           ---
; ---          b = (n. de bloques de 16bytes * 17) mod 256    ---
;=======================================*/
ufldirvm
                        call            setvramadd
.loop
                        outi                                    ; out c,[hl] ; inc hl ; dec b (1)
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        djnz                    .loop
                        ret

;======================================
;ufldirvm_16:       ; --- volcado de ram a vram version ultra. usar en el vblank  ---
; --- entrada: hl = origen en ram                             ---
; ---          de = destino en vram                           ---
; ---          b = bytes a copiar: multiplo de 16 bytes
;=======================================*/
ufldirvm_16
                        ;call            setvramadd
.loop
                        outi                                    ; out c,[hl] ; inc hl ; dec b (1)
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        outi
                        nop
                        nop
                        inc     b
                        djnz                    .loop
                        ret


;============================================
;::init_sprites_size
;============================================
init_sprites_size
                        ld              a, [RG0SAV+1]                   ; sprites 16x16
                        or              00000010b
                        ld              b,1
                        out             [099h],a
                        ld              a,b
                        or              10000000b
                        out             [099h],a
                        ret

;===================
;::YXToOffset_OLD
;in->bc=[yx]  b=x c=y
;out->de offset
;====================
YXToOffset_OLD
                        ld      a, c
                        sub     8*2 ; Upper margin TODO: A k
                        ld      c, a

                        ld      d, b
                        ld      e, c    ; save bc

                        srl     c       ; div8
                        srl     c
                        srl     c
                        ld      l, c
                        ld      h, 0
                        add     hl,hl   ; mul32
                        add     hl,hl
                        add     hl,hl
                        add     hl,hl
                        add     hl,hl

                        ld      b, d    ; restore bc
                        ld      c, e

                        srl     b       ; div8
                        srl     b
                        srl     b
                        ld      c, b
                        ld      b, 0
                        add     hl, bc

                        ex      de, hl

                        ret

;==================================
;::YXToOffset 
;       Offset in camera_view               
;in->bc=[yx]  b=x c=y
;out->de offset 
;==================================
YXToOffset
                        ld      a, c    ;REFACTOR: two upper rows. Maybe it will be by configuration.
                        sub     8*2     ;
                        ld      c, a    ;

                        ld      d, b
                        ld      e, c    ; save bc

                        srl     c       ; div8
                        srl     c
                        srl     c
                        ld      l, c
                        ld      h, 0
                        add     hl,hl   ; mul32
                        add     hl,hl
                        add     hl,hl
                        add     hl,hl
                        add     hl,hl

                        ld      b, d    ; restore bc
                        ld      c, e

                        srl     b       ; div8
                        srl     b
                        srl     b
                        ld      c, b
                        ld      b, 0
                        add     hl, bc

                        ex      de, hl

                        ret


;============================
;::get_next_index_sprite
;               out-> de
;============================
get_next_index_sprite
                ld      de, [current_sprites_index]
                inc     de
                inc     de
                inc     de
                inc     de
                ld      [current_sprites_index], de
                ld      a, [de]
                cp      EOF
                ret     nz
.assert jp .assert

;========================================
;::load_sprites
; in->hl patterns
;     bc bytes size
;     de offset
;========================================
load_sprites
                        push    hl
                        ld      hl, SPRTBL
                        add     hl, de
                        ex      de, hl

                        pop     hl
;                        ld              hl, characters.player
 ;                       ld              de, sprtbl
  ;                      ld              bc, 16*4*8 ;*16 sprites
                        call            LDIRVM
                        ret


;=========================================
;::reset_sprites
;=========================================
reset_sprites
                        ld              a, 209
                        ld              de, sprites_attributes
                        ld              b, 4 ;work.k_max_number_of_sprites

.loop_reset_sprites     ld              [de], a
                        inc             de
                        inc             de    
                        inc             de
                        inc             de
                        djnz            .loop_reset_sprites

                        ret

