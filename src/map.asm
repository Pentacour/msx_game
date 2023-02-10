    include "sea_map.asm"

map_data
    dw sea_screen_0,sea_screen_1,sea_screen_2,sea_screen_3,sea_screen_4,sea_screen_5
    dw sea_screen_6,sea_screen_7,sea_screen_8,sea_screen_9,sea_screen_10,sea_screen_11
    dw sea_screen_12,sea_screen_13,sea_screen_14,sea_screen_15,sea_screen_16,sea_screen_17
    dw sea_screen_18

SCREENS_RIGHT
SEA_SCREENS_RIGHT
    db  0, 1
    db  2, 3, 4
    db  8, 9, 10
    db  11, 12, 6
    db  14, 15, 16, 17
    db 254

SCREENS_DOWN
SEA_SCREENS_DOWN
    db 0, 7, 13
    db 1, 8, 14
    db 3, 10
    db 4, 11
    db 5, 12, 18
    db 254