

SOLID_TILE                      EQU     64

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
        ld      hl, SPRITE_GIRL_0 ;[player_pattern]
        ld      de, SPRTBL
        call    setvramadd
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
        ld      de, screen_view+32*2 ;camera_screen ;mwork.camera_screen+k_camera_lines_offset_up*32
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
;============================================
build_level
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
;::CanGo
;       in-> BC: YX (B=X, C=Y)
;========================================================
CanGo

        ld      [param_can_go_y], bc

        call    YXToOffset
        ld      hl, camera_screen
        add     hl, de

        ld      a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        inc   hl
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        ld    bc, 32
        add   hl, bc    
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        dec   hl
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        
RetYes
        xor   a
        cp    0
        ret

RetNo
        xor   a
        cp    1
        ret


;=======================================================
;::CanGo_OLD
;       in-> BC: YX (B=X, C=Y)
;========================================================
CanGo_OLD

        ld      [param_can_go_y], bc

        call    YXToOffset
        ld      hl, camera_screen
        add     hl, de

                ; Si X%8=0 ...
        ld      a, [param_can_go_x]
        and     7
        cp      0
        jp      z, .modx0

                ; si x%8 != 0 mira la y
        ld      a, [param_can_go_y]
        and     7
        cp      0
        jp      z, .modxno0y0

.modxno0yno0    ; mira actual, siguiente y anterior en x y en y
        ld      a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        inc   hl
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        dec   hl
        dec   hl
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        ld    bc, -32
        add   hl, bc    ;linea superior
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        inc   hl
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        inc   hl
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        ld    bc, 64
        add   hl, bc    ;linea inferior a la central
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        dec   hl
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        dec   hl
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
    jp    RetYes

.modxno0y0 ; //x%8 != 0 y y%8=0-> mira actual, siguiente y anterior
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        inc   hl
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        dec   hl
        dec   hl
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        ld    bc, -32
        add   hl, bc    ;linea superior
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        inc   hl
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        inc   hl
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        jp    RetYes

.modx0  ;//x%8=0. mira la y...
        ld    a, [param_can_go_y]
        and   7
        cp    0
        jp    z, .modxy0

.modx0yno0 ;//x%8 = 0 y y%8 != 0 -> mira los actuales y los anteriores en x y actuales, anteriores y posteriores en y
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        dec   hl
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        ld    bc, -32
        add   hl, bc    ; linea superior
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        inc   hl
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        ld    bc, 64
        add   hl, bc    ; linea inferior a la central
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        dec   hl
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        jp    RetYes

.modxy0 ;//x%8=0 y y%8=0 -> mira los actuales y los anteriores
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        dec   hl
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        ld    bc, -32
        add   hl, bc
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        inc   hl
        ld    a, [hl]
        cp    SOLID_TILE
        jp    nc, RetNo
        jp    RetYes

;RetYes
        xor   a
        cp    0
        ret

;RetNo
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

