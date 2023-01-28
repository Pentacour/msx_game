init_entities_data
    dw entities_sea_0, entities_sea_1
entities_sea_0
    ;db INDESTRUCTIBLE,INIT_TYPE_0,ENTITY_GEN_STOPWALK,15,20,15*8,20*8
    db DESTRUCTIBLE,INIT_TYPE_0,ENTITY_STOPSEARCH,15,20,15*8,20*8
    db EOF
entities_sea_1
    db DESTRUCTIBLE,INIT_TYPE_0,ENTITY_STOPWALK,20,5,20*8,5*8
    db EOF
