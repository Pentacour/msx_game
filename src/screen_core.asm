

SOLID_TILE                      EQU     128

;========================================
;::clear_screen
;========================================
clear_screen
        ld              bc, 32*24
        ld              de, screen_view
        call            reset_big_ram

        ; sprites
        ld              a, 209
        ld              hl, SPRATR
        ld              bc, 4*MAX_NUMBER_OF_SPRITES
        call            FILVRM

        ; tiles

        ld              hl, screen_view
        ld              de, NAMTBL
        ld              b, 48
        call            ufldirvm

        ret

;========================================
;::render
;========================================
render
        halt

        ld      hl, screen_view
        ld      de, NAMTBL
        call    setvramadd
        ld      b, 0
        call    ufldirvm_16
        call    ufldirvm_16
        call    ufldirvm_16

        ; render player sprites
        ; positions
        ld      hl, sprites_attributes
        ld      de, SPRATR
        call    setvramadd
        ld      b, 16
        call    ufldirvm_16
        ld      b, 16
        call    ufldirvm_16


        ;render sprites
        ld      hl, sprites_patterns_player
        ld      de, SPRTBL
        call    setvramadd
        ld      b, 16
        call    ufldirvm_16
        ld      b, 16
        call    ufldirvm_16
        ld      b, 16
        call    ufldirvm_16
        ld      b, 16
        call    ufldirvm_16

  ;      call    reset_sprites_list

        ret

;========================================
;::update_camera
;========================================
update_camera
        ld      hl, the_level
        ld      a, [camera_tile_y_top]
        ex      de, hl
        ld      l, a
        ld      h, 0
        add     hl,hl   ;mul64
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl,hl
        add     hl, de

        ld      a, [camera_tile_x_left]
        ld      c, a
        ld      b, 0
        add     hl, bc
        ld      de, screen_view+32*2 ;camera_view ;mwork.camera_view+k_camera_lines_offset_up*32
        ld      b, CAMERA_HEIGHT
.slooprows
        push    bc
        ld      bc, CAMERA_WIDTH
        ldir
        ld      bc, 32
        add     hl, bc
        pop     bc
        djnz    .slooprows
        ret

;====================
;::reset_sprites_list
;====================
reset_sprites_list
        ld      a, 209
        ld      de, sprites_attributes
        ld      b, MAX_NUMBER_OF_SPRITES

.loop_reset_sprites     
        ld      [de], a
        inc     de
        inc     de    
        inc     de
        inc     de
        djnz    .loop_reset_sprites

        ld      hl, [start_sprites_index]

        ld      [start_sprites_index], hl
        ld      [current_sprites_index], hl

        ret


;============================================
;::build_level
; hl->compressed level map 
;============================================
build_level
        call    unzip_level

        ld      de, the_level
        ld      b, 22    ; macrotiles per column

.srowsloop
        push    bc
        ld      b, 32    ; macrotiles per row

.scolsloop
        push    bc

        ld      a, [hl] ; macrotile code

        call    build_macro_tile

        inc     de     
        inc     de

        inc     hl

        pop     bc
        djnz    .scolsloop

        ex      de, hl
        ld      bc, 64
        add     hl, bc
        ex      de, hl

        pop     bc
        djnz    .srowsloop

        ret


;============================================
;::build_macro_tile
;            in: a macrotile code
;                de address of map position
;============================================
build_macro_tile
        push    hl
        push    de

        ld      bc, BLOCKS_0
        ld      l, a
        ld      h, 0
        add     hl,hl   ;mul4
        add     hl,hl
        add     hl, bc

        ld      b, 2    ;tiles in a row

.srowsloop
        push    bc
        ld      bc, 2
        ldir

        ;next row
        ex      de, hl
        ld      bc, 64-2    ;next line
        add     hl, bc
        ex      de, hl

        pop     bc
        djnz    .srowsloop

        pop     de
        pop     hl

        ret


;=======================================================
;::CanGoPlaer
;       in-> BC YX (B=X, C=Y)
;========================================================
CanGoPlayer
        ld      bc, [player_y]


;=======================================================
;::can_go_16x16
;       origin-> (8,8)
;       in-> BC: YX (B=X, C=Y)
;========================================================
can_go_16x16

        ld      [param_can_go_y], bc

        call    YXToOffset
        ld      hl, camera_view
        add     hl, de

                ; calculates X%8
        ld      a, [param_can_go_x]
        and     7
        cp      0
        jp      z, .mod_x_0

        ld      a, [param_can_go_y]
        and     7
        cp      0
        jp      z, .mod_x_no0_y_0

.mod_x_no0_y_no0 
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        inc     hl
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        dec     hl
        dec     hl
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        ld      bc, -32
        add     hl, bc
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        inc     hl
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        inc     hl
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        ld      bc, 64
        add     hl, bc    
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        dec     hl
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        dec     hl
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        jp      RetYes

.mod_x_no0_y_0 
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        inc     hl
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        dec     hl
        dec     hl
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        ld      bc, -32
        add     hl, bc
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        inc     hl
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        inc     hl
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        jp      RetYes

.mod_x_0  
        ld      a, [param_can_go_y]
        and     7
        cp      0
        jp      z, .mod_x_0_y_0

.mod_x0_y_no0 
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        dec     hl
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        ld      bc, -32
        add     hl, bc 
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        inc     hl
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        ld      bc, 64
        add     hl, bc  
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        dec     hl
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        jp      RetYes

.mod_x_0_y_0    
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        dec     hl
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        ld      bc, -32
        add     hl, bc
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        inc     hl
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetNo
        jp      RetYes

RetYes
        xor   a
        cp    0
        ret

RetNo
        xor   a
        cp    1
        ret
        



        
;=================================================
;::IsSolidTile
;       in-> hl tile pointer
;=================================================
IsSolidTile
        ld      a, [hl]
        cp      SOLID_TILE
        jp      nc, RetYes

        jp      RetNo

;==========================================
;::unzip_level
;   in-> hl compressed level data
;   out->hl decompressed level data
;==========================================
unzip_level
        ld      de, tmp_unzip
        call    pletter_unpack
        ld      hl, tmp_unzip
        ret