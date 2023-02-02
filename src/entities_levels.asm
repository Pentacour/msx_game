init_entities_data
    dw entities_sea_0, entities_sea_1
entities_sea_0
    dw  strong_zombie
    db  INDESTRUCTIBLE, CHARACTER_1, INIT_TYPE_0, ENTITY_GEN_STOPWALK,15,20,15*8,20*8
    ;db  DESTRUCTIBLE, CHARACTER_1, INIT_TYPE_0,ENTITY_FOLLOWPLAYER,15,20,15*8,20*8
    db  EOF
entities_sea_1
    dw  strong_zombie
    ;db  DESTRUCTIBLE, CHARACTER_1, INIT_TYPE_0, ENTITY_FOLLOWPLAYER,20,5,20*8,5*8
    db  EOF
