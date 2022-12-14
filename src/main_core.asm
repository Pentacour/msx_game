        output          rom_name.rom
        defpage         0, $0000, $4000         ; page with data
        defpage         1, $4000, $8000          ; page with logic

        map             $c000                   ; ram

        page            0
        code            @ $0000
        dw              $0000

        page            1
        code            @ $4000
        db              $41, $42                ; rom
        dw              init                    ; start address
        dw              0, 0, 0, 0, 0, 0

        include         "core_bios.asm"
        include         "core_setpages.asm"
        include         "game_core.asm"
        include         "game.asm"
        include         "entities_core.asm"
        ;include         "entities_lib.asm"
        include         "entities.asm"
        include         "entities_levels.asm"
        include         "shoots_lib.asm"

        include         "screen_core.asm"
        include         "support_core.asm"
        include         "core_unpack.asm"
        
active_bios             
        call            RESTOREBIOS
        ei
        ret

quit_bios
        di
        call            SETGAMEPAGE0
        ret

init                
    
        di
        im              1
        ld              sp, [HIMEM]
        call            SETPAGES48K
        call            RESTOREBIOS

        ld              a, 2                    ; screen 2
        call            CHGMOD
        xor             a                       ; click sound off
        ld              [CLIKSW], a
        ld              a, 0                    ; border color
        ld              [BDRCLR], a
        call            INIGRP

        jp              init_game

main_post_init_game     
        call            init_level

main_post_init_level


game_loop               
;        xor     a
;        ld      [camera_changed], a

;        MF1PAUSE
        ld      a, [animation_tick]
        inc     a
        ld      [animation_tick], a

        call    move_player
        call    update_camera
        call    trate_entities
        call    SetPlayerFrame
        call    render

        jp      game_loop

        include         "characters.asm"
        include         "player_core.asm"
        include         "map.asm"
        include         "tilesets.asm"
        include         "tiles_macro.asm"
        include         "sprites_player.asm"
        include         "work_core.asm"
