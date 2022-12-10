

MAX_NUMBER_OF_SPRITES           equ     10
EOF                             equ 	254
NEG_VALUE                       equ     100
MAX_LIFE                        equ     8


;============================================
; static sprites pattern in vram
;============================================
SPRITES_PLAYER_START_MEMORY     EQU     0
SPRITES_INDEX_PLAYER_LEFT_1     EQU     0
SPRITES_INDEX_PLAYER_LEFT_2     EQU     8
SPRITES_INDEX_PLAYER_RIGHT_1    EQU     16
SPRITES_INDEX_PLAYER_RIGHT_2    EQU     24
SPRITES_INDEX_PLAYER_STAIR_1    EQU     32
SPRITES_INDEX_PLAYER_STAIR_2    EQU     40

SPRITES_SKELETON_START_MEMORY   EQU     48*8
SPRITES_INDEX_SKELETON_LEFT_1   EQU     48
SPRITES_INDEX_SKELETON_LEFT_2   EQU     52
SPRITES_INDEX_SKELETON_RIGHT_1  EQU     56
SPRITES_INDEX_SKELETON_RIGHT_2  EQU     60

SPRITES_SWORD_START_MEMORY      EQU     64*8
SPRITES_INDEX_SWORD_LEFT_1      EQU     64
SPRITES_INDEX_SWORD_RIGHT_1     EQU     68
                                
;============================================
; tiles for enemies
;============================================
TILES_ENEMIE_1                  EQU     32

;============================================
; game vars
;============================================
animation_tick		        #1              ; clock for animations and random numbers
level                           #1
;===========================================
; player vars
;===========================================
KEY_NO_KEY      EQU 0
KEY_UP          EQU 1
KEY_UPRIGHT     EQU 2
KEY_RIGHT       EQU 3
KEY_DOWNRIGHT   equ 4
KEY_DOWN        EQU 5
KEY_DOWNLEFT    equ 6
KEY_LEFT        EQU 7
KEY_UPLEFT      EQU 8
KEY_SPACE       EQU 10

player_key_pressed              #1
player_inc_y                    #1
player_jump_inc_x               #1
player_attacking_no_move        #1
player_direction                #1
player_space_key_pressed        #1
player_attack_counter           #1
;player_life                     #1
;player_immunity         #1
player_y        	        #1
player_x        	        #1
player_attitude    	        #1
player_previous_y   	        #1
player_previous_x   	        #1
player_jump_pointer	        #2
player_frame                    #1
;player_is_jumping	#1
;player_sprites_frame    #2
player_in_stair                 #1
player_key_up_pressed           #1
player_inter_scroll_counter_x   #1
player_inter_scroll_counter_y   #1

;===========================================
; entities vars
;===========================================
MAX_NUMBER_OF_DESTRUCTIBLES_ENTITIES    EQU     15
MAX_NUMBER_OF_INDESTRUCTIBLES_ENTITIES  EQU     7
MAX_NUMBER_OF_ENTITIES EQU MAX_NUMBER_OF_DESTRUCTIBLES_ENTITIES + MAX_NUMBER_OF_INDESTRUCTIBLES_ENTITIES
DATA_SIZE_PER_ENTITY            EQU     13
NOT_VISIBLE_MAX_TIME            EQU     250

OFFSET_TYPE                     EQU     0 ;
OFFSET_STATE                    EQU     1 ;
OFFSET_STATE_COUNTER            EQU     2 ;
OFFSET_Y                        EQU     3 ;
OFFSET_X                        EQU     4 ;
OFFSET_INC_Y                    EQU     5 ;
OFFSET_INC_X                    EQU     6 ;
OFFSET_IS_VISIBLE               EQU     7 ;
OFFSET_MAP_X                    EQU     8 ; Stores X map position when PNC goes out of the screen
OFFSET_MAP_Y                    EQU     9 ; Stores Y map position when PNC goes out of the screen
OFFSET_NO_VISIBLE_COUNTER       EQU     10 ;

;;;;;
OFFSET_ID                       EQU 2
OFFSET_LIVE                     EQU 3
OFFSET_TICK_REFRESH             EQU 8
OFFSET_HEIGHT                   EQU 10
OFFSET_COUNTER_2                EQU 11
;;;;

;============================================
; function parameters and local vars
;============================================
param_valid_position_y          #1
param_valid_position_x      	#1
prev_player_y                   #2
tmp_yx_offset                   #2
param_on_ground_yx              #2
tmp_yx                          #2
trate_jump_tmp_inc_y            #1
tmp_hl                          #2
tmp_de                          #2
tmp_bc                          #2
tmp_offset                      #2
trate_weapon_attack_y           #1
trate_weapon_attack_x           #1
tmp_pos_y                       #1
tmp_pos_x                       #1
param_can_go_y                  #1
param_can_go_x                  #1
scroll_entities_direction       #1

;============================================
; screen vars
;============================================
CAMERA_WIDTH          	        EQU 	32
CAMERA_HEIGHT                   EQU     22
CAMERA_LINES_OFFSET_UP          EQU     2
CAMERA_LINES_OFFSET_DOWN        EQU     2
MAP_MAX_RIGHT			EQU	255

ship_map_address_0_0            #2
ship_map_address_0_1            #2
ship_map_address_1_0            #2
ship_map_address_1_1            #2
current_map_screen              #1

camera_tile_y_top               #1
camera_tile_x_left              #1

screen_view                     #(2*32)
camera_view                     #(22*32)

tmp_unzip       	        #(32*8*8)

the_level                       #(32*2*44)

;============================================
; operation vars
;============================================
SPRITE_Y                        EQU     0
SPRITE_X                        EQU     1
SPRITE_NUMBER                   EQU     2
SPRITE_COLOR                    EQU     3

player_sprite_1                 #4
player_sprite_2                 #4
player_sprite_3                 #4

current_sprites_index           #2
start_sprites_index             #2
sprites_attributes	        #(4*MAX_NUMBER_OF_SPRITES)		; y, x, pattern, color
sprites_attributes_eof          #1



;===========================================
; list_entities
;===========================================
list_destructible_entities_data    #(MAX_NUMBER_OF_DESTRUCTIBLES_ENTITIES*DATA_SIZE_PER_ENTITY)
list_indestructible_entities_data  #(MAX_NUMBER_OF_INDESTRUCTIBLES_ENTITIES*DATA_SIZE_PER_ENTITY)
list_entities_data_end          #1
list_entities_data EQU list_destructible_entities_data

