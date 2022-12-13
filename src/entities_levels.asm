init_entities_data
        dw      entities_level_0, entities_level_1

entities_level_0
                ; Indestructible TYPE, MAP_Y, MAP_X, Y, X
        db      ENTITY_GEN_STOPWALK, 15, 20, 15*8, 20*8
        db      EOF
                ; Destructible
        db      EOF

entities_level_1
        db      EOF
        db      EOF