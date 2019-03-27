/*
/*
Super Star Path
https://shmups.system11.org/index.php
xeno crisis

int free=0;
char buffer[16];
void init () {
	
	for (int i=0;i<14;i++)
		buffer[i]=i+1;
		
	buffer[15]=-1;
	
	free=0;
	
}

int alloc () {
	int id=free;
	free=bufffer[free];
	
	return id;
}

int release(int k) {
	buffer[k]=free;
	free=k;
}
*/

BasicUpstart2(main)
.var IRQ1LINE        = $0           //IRQ at the top of screen
.var showRasterTime=false
.var showSubTime=false
.var r1=$0314
.var r2=$0315
.var TYPE_BULLET=$1
.var TYPE_ENEMY=$2
.var TYPE_PLAYER=$3
.var TYPE_COIN=$4

.var MODEL_PLAYER=$0
.var MODEL_ENEMY=$1
.var MODEL_BULLET=$02
.var MODEL_COIN=$03

.var ANIM_SPAWN=$00
.var ANIM_DIE=$01
.var ANIM_WALK=$02
.var ANIM_ATTACK=$03
.var ANIM_PAIN=$04


//.var r1=$fffe
//.var r2=$ffff
.var flagpause=false

.var max_sprites=24;
//.var music = LoadSid("../music/Funky_Freak.sid")

//.var cachechar=$e0	
//.var cachechar1=$e8
.var first_sprite_char=50
.var bank =$8000

* = * "Code"	
	
//*=music.location "Music"
//        .fill music.size, music.getData(i)



get_char_in_backdrop:{
	lda cursory
	asl
	tay
///	lda screen_table,y
	lda backdrop_table,y
	sta $02
	///lda screen_table+1,y
	lda backdrop_table+1,y
	sta $03
	
	lda $02
	clc
	adc cursorx
	sta $02
	lda $03
	adc #0
	sta $03
	
	rts
}

clearscreen:{
	ldy #$0
	lda #32
rep:
	sta bank+$400,y
	sta backdrop,y
	sta bank+$400+$100,y
	sta backdrop+$100,y
	sta bank+$400+$200,y
	sta backdrop+$200,y
	sta bank+$400+$300,y	
	sta backdrop+$300,y
	iny
	bne rep
	rts
}

copyscreen: {
	ldy #$0
	lda bufferid
	bne rep1
rep:
	lda backdrop,y
	sta bank+$400,y
	sta bank+$3000,y
	
	lda backdrop+$100,y
	sta bank+$500,y
	sta bank+$3100,y
	
	lda backdrop+$200,y
	sta bank+$600,y
	sta bank+$3200,y
	
	lda backdrop+$300,y
	sta bank+$700,y
	sta bank+$3300,y
	
	iny
	bne rep
	

	lda #1
	ldy #0
rep1:
	
	sta $D800,y
	sta $D900,y
	sta $DA00,y
	sta $DB00,y
	
	iny
	bne rep1
	rts	

}
lines:
	.byte 0
	
gameover:
	.byte 0
v1:
	.word 0
	
sprupdateflag:
	.byte 0
.var freq=50;
.var timeline=100;
game_spanw_pt:
	.for(var i=0;i<250;i++) {
		
			spawnAt(timeline,MODEL_ENEMY,(50+11*8)+random()*(11*8),21)

		.if (i==50) .eval freq=40
		.if (i==150) .eval freq=30
		.if (i==200) .eval freq=20		
		.eval timeline+=freq;
			
	}
	

	levelEnd()
	
game_sprite_state_table_lo:
	.byte <game_sprite_anim_spawn,<game_sprite_anim_die,<game_sprite_anim_walk,<game_sprite_anim_attack,<game_sprite_anim_pain

game_sprite_state_table_hi:
	.byte >game_sprite_anim_spawn,>game_sprite_anim_die,>game_sprite_anim_walk,>game_sprite_anim_attack,>game_sprite_anim_pain
	
game_sprite_anim_spawn:
	modelDef(TYPE_PLAYER,1,1,spawn_player,25,default_callback)
	modelDef(TYPE_ENEMY,4,8,spawn_enemy,1,default_callback)
	modelDef(TYPE_BULLET,2,2,spawn_bullet,1,default_callback)
	modelDef(TYPE_COIN,3,3,spawn_coin,1,default_callback)
	
game_sprite_anim_die:
	modelDef(TYPE_PLAYER,1,1,spawn_player,1,default_callback)
	modelDef(TYPE_ENEMY,4,8,spawn_enemy,1,default_callback)
	modelDef(TYPE_BULLET,2,2,spawn_bullet,1,default_callback)
	modelDef(TYPE_COIN,3,3,spawn_coin,1,default_callback)
	
game_sprite_anim_walk:
	modelDef(TYPE_PLAYER,1,1,walk_player,1,default_callback)
	modelDef(TYPE_ENEMY,0,0,spawn_enemy,1,default_callback)
	modelDef(TYPE_BULLET,2,2,spawn_bullet,1,default_callback)
	modelDef(TYPE_COIN,3,3,spawn_coin,1,default_callback)
	
game_sprite_anim_attack:
	modelDef(TYPE_PLAYER,1,1,spawn_player,1,default_callback)
	modelDef(TYPE_ENEMY,0,0,spawn_enemy,1,default_callback)
	modelDef(TYPE_BULLET,2,2,spawn_bullet,1,default_callback)
	modelDef(TYPE_COIN,3,3,spawn_coin,1,default_callback)
		
game_sprite_anim_pain:
	modelDef(TYPE_PLAYER,1,1,spawn_player,1,default_callback)   
	modelDef(TYPE_ENEMY,0,0,spawn_enemy,1,default_callback)
	modelDef(TYPE_BULLET,2,2,spawn_bullet,1,default_callback)
	modelDef(TYPE_COIN,3,3,spawn_coin,1,default_callback)
	
game_idx_lo:
	.byte <game_spanw_pt
game_idx_hi:
	.byte >game_spanw_pt
	
game_time_hi:
	.byte 0
game_time_lo:
	.byte 0
.macro levelEnd() {
	.word $ffff
}
.macro spawnAt(tm,spwid,posx,posy) {
    .byte <(tm)
	.byte >(tm)
	.byte spwid
	.byte posx
	.byte posy
}	

.macro modelDef(model_type,first_frame,last_frame,callback,fps,frame_callback) {
	.byte model_type
	.byte first_frame
	.byte last_frame
	.byte fps
	.byte <callback
	.byte >callback	
	.byte <frame_callback
	.byte >frame_callback
}

game_put_enemy:{
cont:			
	lda game_idx_lo
	sta $04
	lda game_idx_hi
	sta $05
	
	ldy #1
	lda ($04),y
	cmp #$ff
	bne !+
	ldy #0
	cmp ($04),y		
	bne !+
	
	lda #0
	sta game_time_hi
	sta game_time_lo	
	
	lda #<game_spanw_pt
	sta game_idx_lo
	lda #>game_spanw_pt
	sta game_idx_hi

!:	
	ldy #1
	lda game_time_hi
	cmp ($04),y 
	
	bcc leave
	beq compare_lo_byte
	bcs go_with_the_spawn
compare_lo_byte:
	ldy #0
	lda game_time_lo 
	cmp ($04),y	
	bcc leave
	
go_with_the_spawn:
	sed
	clc
	lda  nspawn+1
	adc #1
	sta  nspawn+1	
	lda nspawn
	adc #$0
	sta nspawn
	cld
	
	ldy #2
	lda ($04),y
	jsr model_alloc
	cmp #$ff
	beq leave
	tax
		
	ldy #3
	lda ($04),y
	sta sprite_pos_x_lo,x

	iny
	lda ($04),y
	sta sprite_pos_y_lo,x
	
	lda #40
	sta sprite_timeout,x
	
	lda game_idx_lo
	clc
	adc #5
	sta game_idx_lo
	
	lda game_idx_hi
	adc #0
	sta game_idx_hi
	jmp cont
leave:

	inc game_time_lo
    bne l1
    inc game_time_hi
l1:
	rts
}

vblank: {

	lda $d011
	bmi vblank
L2: 
	lda $d011
	bpl L2
	rts


}



getjoy: {
	lda     #$FF
	sta     $DC00
	lda     $DC00
	eor     #$FF
	sta     joy
	rts
}

initraster:  {
	sei
			
	/*lda #<brkirq
	ldy #>brkirq
	sta $fffa
	sty $fffb
*/
	lda #<irq1	
	sta r1
	lda #>irq1	
	sta r2
	
	lda #$7f
	sta $dc0d
	sta $dd0d

	lda #$01                    //Raster interrupt on
	sta $d01a	
	sta $d01a
	
	lda #27                     //High bit of interrupt position = 0
	sta $d011
	
	lda #IRQ1LINE               //Line where next IRQ happens
	sta $d012
	
	lda $dc0d                   //Acknowledge IRQ (to be sure)
	lda $dc0d //;ack any pending timer irq
	lda $dd0d //;at cia #2 too
	
	/*lda #$35
	sta $01 //;turn off kern_A_l
	*/
	cli
	rts

}
.macro retirq() {
	
	
	asl $d019

	loadregs()
	//rti
	jmp $ea81
 }
 
 savea:
 .byte 0
 savex:
 .byte 0
 savey:
 .byte 0

 .macro saveregs() {
	
	/*php		
	pha        
	txa
	pha        
	tya
	pha        */
	
 }
 
 .macro loadregs () {
	
	
	
	/*pla
	tay        
	pla
	tax        
	pla        
	plp*/

 }
brkirq:
	rti
	
irq1: {

	saveregs()
		
		
	lda sprupdateflag               //New sprites?
	beq irq1_nonewsprites
	
	inc pressed_time
	
	jmp hw_draw_sprite
	
irq1_nonewsprites: 
irq1_d015value: 
	
	
		
	retirq()

	
}
.macro drawsprite(hwid,swid) {
	lda sprite_w_list+swid
	tax
	lda sprite_w_pos_y_lo,x
	sta $d000+2*hwid+1
	lda sprite_w_pos_x_lo,x
	sta $d000+2*hwid
	
	//lda #swid
	lda sprite_w_image_id,x
	sta $87F8+hwid
	sta $b3F8+hwid
	lda #10
	sta $d027+hwid
}
/*.macro putsprite(_x,_y) {
	jsr sprite_alloc
	tay
	lda #_x
	sta sprite_pos_x_lo,y
	lda #_y
	sta sprite_pos_y_lo,y
	
}*/
main: {
		
	ldx #0
	
	
	lda #0
	sta 53280
	lda #0
	sta 53281
	
	lda $dd02
    ora #3
	sta $dd02     //               ; Make sure CIA#2 lines set to OUTPUT
	lda $dd00
	and #%11111100
	ora #1           //          ;  Bank #1, $4000-$7FFF, 16384-32767.
	sta $dd00 
		
		
	//lda #$18	
	//sta $d018

	lda #$13
	sta $d011
	
	ldy #0

copysprite:
	lda sprites,y
	sta bank,y
	lda sprites+$100,y
	sta bank+$100,y
	lda sprites+$200,y
	sta bank+$200,y
	lda sprites+$300,y
	sta bank+$300,y

	iny 	
	bne copysprite
	
	
	jsr clearscreen
	//jsr drawlevel
	//jsr copyscreen
	
	lda #MODEL_PLAYER
	jsr model_alloc
	sta playerid
	tay
	

	lda #20*8
	sta sprite_pos_x_lo,y
	lda #28*8
	sta sprite_pos_y_lo,y
		
	//lda #music.startSong-1	
	//lda #0
	//jsr music.init
	
	
	/*
		test show sprite
	*/
	lda #0
	sta $D027
	//lda #$ff
	//sta 53276
	/*.for (var i=0;i<3;i++) {
		
		putsprite(60+25*7,60+i*60)
		putsprite(60+25*6,60+i*60)
		putsprite(60+25*5,60+i*60)
		putsprite(60+25*4,60+i*60)			
		putsprite(60+25*3,60+i*60)			
//		putsprite(60+25*2,60+i*60)			
//		putsprite(60+25*1,60+i*60)					
//		putsprite(60+25*0,60+i*60)					
	} */
		
	
	lda #0
	sta $d021

	lda #<level_1
	sta $02
	lda #>level_1
	sta $03
	jsr draw_room
	
	jsr initraster
mainloop:
	
	lda sprupdateflag
	bne mainloop
	
	lda gameover
	beq !+
	jsr mygameover
!:
	lda game_idx_lo
	sta $04
	lda game_idx_hi
	sta $05
	
	ldy #1
	lda ($04),y
	sta v1
	
	ldy #0	
	lda ($04),y
	sta v1+1
		
	printhex(bank+$0411+40*4,score);

	
	
	
	jsr model_update
	jsr sprite_update	
	jsr sprite_sort
	jsr calc_raster
		
	inc sprupdateflag 					
	jsr getjoy	
	jsr update_player
	
	jsr sprite_collision
	jsr sprite_erase_collision_map
	
.if (flagpause) {
	lda pause
	bne *+5
}
	jsr game_put_enemy
	
	
	
l1:
	jmp mainloop
	rts
}
.macro check_hw_sp(id) {
	lda sprite_w_count
	cmp #id
	bcs  *+5
	
}

.macro check_hw_rf(id,data,addr) {
	
	lda #<addr
	sta r1
	lda #>addr
	sta r2	
		
	ldy id+1
	lda #id-1
	cmp data
	beq  *+7
	bcc  *+5

}
lastYcoord_1:
	.byte 0
	
lastYcoord_2:
	.byte 0

	
rast_flag_1:
	.byte 0

f_raster_1:
	.byte 0

rast_flag_2:
	.byte 0

f_raster_2:
	.byte 0

gmt:
	.byte 0
mygameover: {


	lda #$20
	sta gmt
!:	
	lda #1
	sta 53280	
	sta 53281
	jsr vblank 
	lda #0
	sta 53280	
	sta 53281
	jsr vblank 
	
	dec gmt
	bne !-

	lda #<	gameover_r
	sta $02
	lda #>	gameover_r
	sta $03
	jsr draw_room
	
	printhex(bank+$0411+40*14,score);
	
!:
	jsr getjoy	
	lda joy            
	and #$10
	beq !-
	
	

!:
	jsr getjoy	
	lda joy            
	and #$10
	bne !-


	lda #0
	sta game_time_hi
	sta game_time_lo	
	sta sprite_count
	sta bucketIdx
	sta score
	sta score+1

	
	lda #<game_spanw_pt
	sta game_idx_lo
	lda #>game_spanw_pt
	sta game_idx_hi
	
	lda #0
	sta gameover
	sta sprite_first_free
	
	lda #<	level_1
	sta $02
	lda #>	level_1
	sta $03
	jsr draw_room	
	

	ldy #0	
	ldx #1
!:	
	txa
	sta sprite_free_list,y
	
	lda #0
	sta sprite_state,y
	inx
	iny 
	cpy #max_sprites
	bne !-
	
	lda #MODEL_PLAYER
	jsr model_alloc
	sta playerid
	tay
	

	lda #20*8
	sta sprite_pos_x_lo,y
	lda #28*8
	sta sprite_pos_y_lo,y

	
	rts

}
calc_raster: {

	lda #$60
	sta f_raster_2
	sta f_raster_1
	
	lda sprite_count
	cmp #9
	bcc leave

	lda sprite_list+7
	tax
	lda sprite_pos_y_lo,x
	clc 
	adc #21
	sta lastYcoord_1

calc_raster_band_1:
	ldy #8	
next:
	lda sprite_list,y
	tax
	lda sprite_pos_y_lo,x	
	cmp lastYcoord_1
	//beq nnk
	bcs ok
nnk:
	iny
	cpy  #16
	beq  ok

	cpy  sprite_count
	bcc  next
	
ok:	
	sty f_raster_1

	lda sprite_count
	cmp #17
	bcc leave	
	
	
	lda sprite_list+15
	tax
	lda sprite_pos_y_lo,x
	clc 
	adc #21
	sta lastYcoord_2

calc_raster_band_2:	
	ldy #16
next1:
	lda sprite_list,y
	tax
	lda sprite_pos_y_lo,x
	cmp lastYcoord_2
	beq nnk1
	bcs ok1
nnk1:
	iny
	cpy  #24
	bcs  ok1
	cpy  sprite_count
	bcc  next1
	
ok1:	
	sty f_raster_2
	
leave:
	rts
}

hw_draw_sprite:{
	
.if (showRasterTime){
//	lda #7
//	sta $d020
}
	lda #$ff                        //Any sprites?
	sta $d015


	lda f_raster_1
	sta rast_flag_1
	
	lda f_raster_2
	sta rast_flag_2

	lda sprite_count
	sta sprite_w_count

.for (var i=0;i<max_sprites;i++){	
	lda sprite_list +i
	sta sprite_w_list +i
	lda sprite_pos_x_lo+i
	sta sprite_w_pos_x_lo+i
	lda sprite_pos_y_lo+i
	sta sprite_w_pos_y_lo+i			
	lda sprite_image_id+i
	sta sprite_w_image_id+i
}
	lda #0
	sta $d001
	sta $d003
	sta $d005
	sta $d007
	sta $d009
	sta $d00b
	sta $d00d
	sta $d00f
	lda #$ff
	sta $d01c
	
	lda #7
	sta $D025
	sta $D026
	
	lda #$00
    sta sprupdateflag	


.if (showRasterTime){
   //lda #0
	//sta $d020
}
 	
		
	check_hw_sp(1)
	jmp leave
	drawsprite(0,0)
	
	
	check_hw_sp(2)	
	jmp leave
	

	
	drawsprite(1,1)

	
	check_hw_sp(3)
	jmp leave
	
	
	drawsprite(2,2)	
	
	check_hw_sp(4)	
	jmp leave
	
	
	drawsprite(3,3)
	
	check_hw_sp(5)	
	jmp leave
	
	
	drawsprite(4,4)
	
	check_hw_sp(6)	
	jmp leave
	
	
	drawsprite(5,5)
	
	check_hw_sp(7)	
	jmp leave
		
	drawsprite(6,6)
	
	check_hw_sp(8)	
	jmp leave
		
	drawsprite(7,7)	
	
	check_hw_sp(9)	
	jmp leave
	
	
	lda rast_flag_1
	cmp #8
	beq normal
	
	//printhex(bank+$0400,rast_flag_1)
	
	
	lda #27                     //High bit of interrupt position = 0
	sta $d011
	
	lda sprite_w_list+8
	tax
	lda sprite_w_pos_y_lo,x
	sec	
	sbc #4
	cmp $d012
	beq *+4
	bcs setok1 
	jmp imposta_sprite_8_16_no	
	
setok1:
	sta $d012
	
    jmp setupirq	
	
normal:
.if (showRasterTime){
	//lda #9
	//sta $d020
	
}
		
	lda #27                     //High bit of interrupt position = 0
	sta $d011
	
	ldy rast_flag_1		
	
	lda #$60
	sta rast_flag_1
	

	lda sprite_w_list+7
	tax
	lda sprite_w_pos_y_lo,x
	clc
	adc #21
	//cmp $d012
	//bcc imposta_sprite_8_16_no
		
	sta $d012
	jmp setupirq
	
normal2round:
.if (showRasterTime){
	//lda #9
	//sta $d020
	
}
		
	lda #27                     //High bit of interrupt position = 0
	sta $d011
	
	ldy rast_flag_1		
	
	lda #$60
	sta rast_flag_1
	
	lda sprite_w_list,y
	
	tax
	lda sprite_w_pos_y_lo,x
	/*sec
	sbc #8
	cmp $d012
	beq *+4
	bcs setok
	*/
		
	lda sprite_w_pos_y_lo,x
	clc
	adc #4	

setok:
	sta $d012	
	retirq()
	
setupirq:
	lda #<imposta_sprite_8_16
	sta r1
	lda #>imposta_sprite_8_16
	sta r2	
	
	
.if (showRasterTime){
   //lda #0
   //sta $d020
}

	retirq()  
	
imposta_sprite_8_16:
	saveregs()
imposta_sprite_8_16_no:	


.if (showRasterTime){
	//lda #1
	//sta $d020
	//sta $d021
}
	
sp8:
	drawsprite(0,8)
		
	check_hw_rf(8,rast_flag_1,sp8)	
	jmp normal2round

sp9:
	check_hw_sp(10)	
	jmp leave	
	check_hw_rf(9,rast_flag_1,sp9)	
	jmp normal2round
	drawsprite(1,9)	
	
sp10:	
	check_hw_sp(11)	
	jmp leave
	check_hw_rf(10,rast_flag_1,sp10)
	jmp normal2round	
	drawsprite(2,10)	
	
sp11:	
	check_hw_sp(12)	
	jmp leave
	check_hw_rf(11,rast_flag_1,sp11)
	jmp normal2round
	drawsprite(3,11)

sp12:	
	check_hw_sp(13)	
	jmp leave
	check_hw_rf(12,rast_flag_1,sp12)
	jmp normal2round
	drawsprite(4,12)
	
sp13:		
	check_hw_sp(14)	
	jmp leave
	check_hw_rf(13,rast_flag_1,sp13)
	jmp normal2round
	drawsprite(5,13)
	
sp14:		
	check_hw_sp(15)	
	jmp leave
	check_hw_rf(14,rast_flag_1,sp14)
	jmp normal2round	
	drawsprite(6,14)
	
sp15:		
	check_hw_sp(16)	
	jmp leave
	//check_hw_rf(15,rast_flag_1)
	//jmp normal2round	
	drawsprite(7,15)	
	
.if (showRasterTime){
	//lda #0
	//sta $d020
}	
		

leave:	

.if (showRasterTime){
	//lda #0
	//sta $d020
}	
	lda #27                     //High bit of interrupt position = 0
	sta $d011
	lda #IRQ1LINE
	sta $d012
	
	lda #<irq1
	sta r1
	lda #>irq1
	sta r2	
		
	retirq()  
}
pause:
	.byte 0
	
update_player: {
	ldy playerid
	lda sprite_dir_x,y
	bne !+
	lda #2
	sta sprite_dir_x,y
!:	
	lda sprite_pos_x_lo,y
	cmp #120
	bcs !+
	lda #120
	sta sprite_pos_x_lo,y
	lda #2
	sta sprite_dir_x,y
	jmp check_press
!:
	lda sprite_pos_x_lo,y
	cmp #240
	bcc  check_press
	lda #240
	sta sprite_pos_x_lo,y
	lda #-2
	sta sprite_dir_x,y
	
check_press:
	lda joy            
	and #$10
	beq none
	lda pressed_time
	cmp #10
	bcc none
	lda #0
	sta pressed_time

	lda #MODEL_BULLET
	jsr model_alloc	
	cmp #$ff
	beq none
	tax
	ldy playerid
	
	lda sprite_pos_x_lo,y
	clc
	adc #4
	sta sprite_pos_x_lo,x
	
	lda sprite_pos_y_lo,y
	sec
	sbc #4
	sta sprite_pos_y_lo,x
	
	lda #-4
	sta sprite_dir_y,x
	
	lda #0
	sta sprite_dir_x,x

	/// cambia la direzione
	lda sprite_dir_x,y
	bmi !+
	lda #-2
	sta sprite_dir_x,y
	jmp none
!:
	lda #2
	sta sprite_dir_x,y
	
none:		
	rts
}

default_callback: {
	inc $d020
	rts
}

spawn_player:{
	lda #0
	sta sprite_dir_x,x
	sta sprite_dir_y,x	
leave:
	rts
}

walk_player:{
	
	rts
}
spawn_coin:{
	lda sprite_cur_frame,x
	cmp sprite_first_frame,x
	bne leave

	lda #0
	sta sprite_dir_x,x
	lda #2
	sta sprite_dir_y,x
	
leave:
	rts
}
spawn_enemy:{
	lda sprite_cur_frame,x
	cmp sprite_first_frame,x
	bne leave

	lda #0
	sta sprite_dir_x,x
	lda #2
	sta sprite_dir_y,x
	
	lda sprite_pos_y_lo,x
	cmp #215
	bcc leave
	lda #215
	sta sprite_pos_y_lo,x
	lda sprite_timeout,x
	bne !+

	
	lda #ANIM_DIE
	jsr model_set_anim

!:
	dec sprite_timeout,x
leave:
	lda sprite_pos_y_lo,x
	cmp #200
	bcc !+
	
	ldy playerid
	lda sprite_pos_x_lo,x
	adc #24
	cmp sprite_pos_x_lo,y
	bcc !+

	lda sprite_pos_x_lo,y
	adc #12
	cmp sprite_pos_x_lo,x
	bcc !+
	
	//lda #1
	//sta gameover
	
!:
	rts
}

spawn_bullet:{
	lda sprite_cur_frame,x
	cmp sprite_first_frame,x
	bne leave

	lda #0
	sta sprite_dir_x,x
	lda #-4
	sta sprite_dir_y,x
	
leave:
	rts
}

model_set_anim: {
	
	sty savey
	sta sprite_anim_id,x
	
	tay
	
	lda game_sprite_state_table_lo,y
	sta $06
	lda game_sprite_state_table_hi,y
	sta $07
	
	
	lda sprite_model_id,x
	asl
	asl
	asl
	tay
	
	lda ($06),y
	sta sprite_type,x
	iny
	
	lda ($06),y
	sta sprite_first_frame,x
	sta sprite_cur_frame,x
	iny
	
	lda ($06),y
	sta sprite_last_frame,x	
	iny

	lda ($06),y
	sta sprite_frame_max_delay,x
	iny
	
	lda ($06),y	
	sta sprite_frame_callback_lo,x
	iny
	
	lda ($06),y
	sta sprite_frame_callback_hi,x
	iny
	
	/*lda ($06),y	
	sta sprite_frame_callback_lo,x
	iny
	
	lda ($06),y
	sta sprite_frame_callback_hi,x
	*/
	
	lda #0
	sta sprite_frame_delay,x
	//jmp callback:$0000	
	ldy savey
	rts
}

modelid:
.byte 0
model_alloc: {


	sta modelid
	
	ldx sprite_first_free
	cpx #max_sprites
	bcs err
	lda sprite_free_list,x
	sta sprite_first_free
	
  
   /*
		 /// init sprite
		.byte model_type
		.byte first_frame
		.byte last_frame
		.byte dir_x
		.byte dir_y
		.byte max_delay
		.byte 0
		.byte 0	
		
	*/
	
	lda modelid	
	sta sprite_model_id,x
	lda #ANIM_SPAWN
	jsr model_set_anim

////////////////////	
		
	lda #1
	sta sprite_state,x
	txa
	
	rts
err:
	lda #$ff
	rts	
}
/*sprite_alloc: {
	//ldy #0
next:
	
	ldx sprite_first_free
	cpx #max_sprites
	bcs err
	lda sprite_free_list,x
	sta sprite_first_free
		
found:
	
	
	lda #1
	sta sprite_state,x
	txa
	rts
err:
	lda #$ff
	rts
}*/

.macro visitbucket (offs) {
	ldx bucket+offs	
	bmi isempty
	lda #$ff
	sta bucket+offs
cont:
	lda bucketSpid,x
	sta sprite_list,y
	iny
	lda bucketNext,x
	tax		
	bpl cont
	
isempty:	
	
}
sprite_sort: {
/*for (i=0;i<255;i++) {
		if (bucket[i]!=EMPTY) {
			int id = bucket[i];
			for (;id!=EMPTY;id=bucketNext[id]) {
				printf ("#%d %d\n",bucketSpid[id],bucketVal[id]);				
			}
			bucket[i]=EMPTY;
		}
	}
	*/
	
	ldy #0
	
	.for (var i=21;i<255;i++) {
		visitbucket(i);
	}

	sty sprite_count

	
	rts
}

modx:
	.byte 0
mody:
	.byte 0
	
model_update:{
	ldx #0
next:
	cpx #max_sprites
	bcs leave
	lda sprite_state,x
	bne found
cc:
	inx
	jmp next

found:	
	lda sprite_frame_callback_lo,x
	sta callback
	lda sprite_frame_callback_hi,x
	sta callback+1
	jsr callback:$0000
	
	inx
	jmp next
leave:
	rts
}

sprite_update: {

	ldx #0
	lda #0
	sta sprite_count
	sta bucketIdx
	sta bullet_num


	
	
next:
	cpx #max_sprites
	bcs leave
	lda sprite_state,x
	bne found
	inx
	jmp next
leave:
	jmp select_sprites
found:	
.if (flagpause) {
	lda pause
	bne no_hor_move	
}
	lda sprite_state,x
	cmp #4
	beq dealloc
	
	lda sprite_dir_x,x
	beq no_hor_move	
	
	lda sprite_pos_x_lo,x	
	
	clc
	adc sprite_dir_x,x
	sta sprite_pos_x_lo,x
	
no_hor_move:
.if (flagpause) {
	lda pause
	bne no_vert_move	
}
	lda sprite_dir_y,x
	beq no_vert_move	
	
	lda sprite_pos_y_lo,x	
	
	clc
	adc sprite_dir_y,x
	sta sprite_pos_y_lo,x

no_vert_move:	
	lda sprite_pos_y_lo,x
	cmp #10
	bcc dealloc
	cmp #200+50
	bcc cont		
dealloc:
	lda #0
	sta sprite_state,x
	lda sprite_first_free
	sta sprite_free_list,x
	stx sprite_first_free
	//jsr decn
	
	inx
	jmp next
cont:
	
	// inizio gestione bullet if a sprite is a bullet put in collision buffer
	
	lda sprite_type,x
	cmp #TYPE_BULLET
	bne add_sprite_to_bucket
 
    /* aggiunge il bullet in una lista */
	ldy bullet_num
	txa
	sta bullet_list,y
	inc bullet_num
	
	/*lda sprite_pos_y_lo,x
	sec
	sbc #50
	tay
	lda div8,y 
	sta cursory
	lda mod8,y
	sta mody
	
	lda sprite_pos_x_lo,x
	sec
	sbc #21
	tay
	lda div8,y 
	sta cursorx
	lda mod8,y
	sta modx

	
	jsr get_char_in_backdrop
	
	ldy #0
	txa
	sta ($02),y
	
	lda modx
	beq nrow
	iny
	txa	
	sta ($02),y

nrow:
	lda mody
	beq add_sprite_to_bucket
	ldy #40
	txa	
	sta ($02),y

	lda modx
	beq add_sprite_to_bucket
	iny 
	txa	
	sta ($02),y
	*/
/// nie gestione bullet
	
add_sprite_to_bucket:	
	// add sprite id to bucket
	
	lda sprite_pos_y_lo,x  // prev = bucket[coordy];
	tay
	lda bucket,y	
	
	
	
	ldy bucketIdx          // bucketNext[idx]=prev;	
	sta bucketNext,y
	
	txa                    // bucketSpid[idx]=spid;
	sta bucketSpid,y
	
	lda bucketIdx
	ldy sprite_pos_y_lo,x    /// bucket[val]=idx++;
	sta bucket,y
	
	inc bucketIdx
	
	
	//// update anim
	

	
	lda sprite_cur_frame,x
	sta sprite_image_id,x
	
	lda sprite_frame_delay,x
	cmp sprite_frame_max_delay,x
	bcc frame_no_change
	
	lda #0
	sta sprite_frame_delay,x
	
	/*lda sprite_frame_callback_lo,x
	sta callback
	lda sprite_frame_callback_hi,x
	sta callback+1
	jsr callback:$0000
*/
	inc sprite_cur_frame,x
frame_no_change:	
	inc sprite_frame_delay,x
	
	lda sprite_cur_frame,x	
	cmp sprite_last_frame,x
	bcc nn
	lda sprite_first_frame,x
	sta sprite_cur_frame,x
	
	lda sprite_anim_id,x
	cmp #ANIM_SPAWN
	bne check_die
	
	lda #ANIM_WALK
	jsr model_set_anim
	
	jmp nn
check_die:

	cmp #ANIM_DIE
	bne nn
	lda #4
	sta sprite_state,x
	
nn:
	
	inx
	
	jmp next	
	
select_sprites:
	
	
	rts
	
}
////////
sprite_erase_collision_map: {
	ldx #0
next:
	cpx #max_sprites
	bcs leave
	lda sprite_state,x
	bne found
cc:
	inx
	jmp next

found:	
	
	lda sprite_type,x
	cmp #TYPE_BULLET
	bne select_next
	
	
cont:
	lda sprite_pos_y_lo,x
	sec
	sbc #50
	tay
	lda div8,y 
	sta cursory
	lda mod8,y
	sta mody
	
	lda sprite_pos_x_lo,x
	sec
	sbc #21
	tay
	lda div8,y 
	sta cursorx
	lda mod8,y
	sta modx
	
	jsr get_char_in_backdrop
	
	ldy #0
	lda #32
	sta ($02),y
	
	lda modx
	beq nrow
	iny
	lda #32
	sta ($02),y

nrow:
	lda mody
	beq select_next
	ldy #40
	lda #32
	sta ($02),y

	lda modx
	beq select_next
	iny 
	lda #32
	sta ($02),y
	
select_next:	
	inx	
	jmp next	
	
leave:
		
	rts
}

bullid:
	.byte 0
x0:
	.byte 0
x1:
	.byte 0
y0:
	.byte 0
y1:
	.byte 0
	
	
check_enemy_bullet_collision:{
	/// a contains bullet id
	/// x contains enemy id
	
	sta bullid
/*	lda sprite_state,x
	cmp #4
	bne ok
	
	lda #0
	
	rts*/
ok:
	lda sprite_pos_x_lo,x
	sta x0
	clc
	adc #24
	sta x1
	
	lda sprite_pos_y_lo,x
	sta y0
	clc
	adc #21
	sta y1
	
	sty savey
	ldy bullid
	
	lda sprite_pos_y_lo,y
	cmp y0
	bcc nohit
	cmp y1
	bcs nohit

	lda sprite_pos_x_lo,y
	cmp x0
	bcc nohit
	cmp x1
	bcs nohit

	
	lda #1
	rts
	
nohit:
	ldy savey
	lda #0	
	rts
}
sprite_collision:{
	ldx #0	
next:
	cpx #max_sprites
	bcs leave
	lda sprite_state,x
	bne found
	inx
	jmp next
leave:
	jmp fine
found:	
	
	lda sprite_type,x
	cmp #TYPE_ENEMY
	bne select_next
		
	lda sprite_state,x
	cmp #4
	beq select_next
			
	ldy #0
!:
	cpy bullet_num
	beq !+

	lda bullet_list,y
	jsr check_enemy_bullet_collision	
	bne hitit
	iny	
	jmp !-
!:
	
	/*
	lda sprite_pos_y_lo,x
	sec
	sbc #50
	tay
	lda div8,y 
	sta cursory
	cmp #21 
	bcs select_next
	lda mod8,y
	sta mody
	
	lda sprite_pos_x_lo,x
	sec
	sbc #21
	tay
	lda div8,y 
	sta cursorx
	lda mod8,y
	sta modx
	
	jsr get_char_in_backdrop

b0:	
	ldy #0
	lda ($02),y
	cmp #32
	beq b1
	jsr check_enemy_bullet_collision
	bne hitit

b1:
	ldy #1
	lda ($02),y
	cmp #32
	beq b2
	jsr check_enemy_bullet_collision
	bne hitit

b2:
	ldy #2
	lda ($02),y
	cmp #32
	beq b3
	jsr check_enemy_bullet_collision
	bne hitit


b3:
	ldy #40
	lda ($02),y
	cmp #32
	beq b4
	jsr check_enemy_bullet_collision
	bne hitit
	
b4:
	ldy #41
	lda ($02),y
	cmp #32
	beq b5
	jsr check_enemy_bullet_collision
	bne hitit
	
b5:
	ldy #42
	lda ($02),y
	cmp #32
	beq select_next
	jsr check_enemy_bullet_collision
	beq select_next
*/
select_next:	
	inx	
	jmp next	
	
hitit:
	sed
	clc
	lda  score+1
	adc #1
	sta  score+1	
	lda score
	adc #$0
	sta score
	cld

	lda #4	
	sta sprite_state,y
	
	lda #ANIM_DIE
	jsr model_set_anim
	
	/*lda #4	
	sta sprite_first_frame,x
	sta sprite_cur_frame,x
	
	lda #8
	sta sprite_last_frame,x
	*/

	
	/*lda #TYPE_PLAYER
	sta sprite_type,x
	lda #3
	sta sprite_dir_y,x
	
	//lda #1
	//sta sprite_dir_x,x
	
	lda sprite_pos_y_lo,x
	sec
	sbc #8
	sta sprite_pos_y_lo,x
	*/
	//sta sprite_state,x
	inx
	jmp next
fine:
	
	rts
	
}
counter:
	.byte 0
	
addn:{
	sed
	clc
	ldy #$0

	lda counter
	adc #1
	sta counter
	cld
	
	rts
}

decn:{
	sed
	sec
	

	lda counter
	sbc #1
	sta counter
	cld
	
	rts
}
hex:
	.byte '0','1','2','3','4','5','6','7','8','9',1,2,3,4,5,6
.macro printhex(addr,val)
{

		ldy #$0			
		lda val+1,y
		and #$0f
		ora #$30
		sta addr+$3,y
			
		lda val+1,y
		and #$f0
		lsr
		lsr
		lsr
		lsr
		ora #$30
		sta addr+$2,y

		lda val
		and #$0f
		ora #$30
		sta addr+$1,y

					
		/*lda val
		and #$f0
		lsr
		lsr
		lsr
		lsr
		ora #$30
		sta addr
		*/
		
	/*lda val
	and #$f0
	lsr
	lsr
	lsr
	lsr

	tax 
	lda hex,x
	sta addr

	lda val
	and #$0f
	tax 
	lda hex,x
	sta addr+1
	*/
	
}
print:{
		
		lda counter
		and #$0f
		ora #$30
		sta bank+$0401
					
		lda counter
		and #$f0
		lsr
		lsr
		lsr
		lsr
		ora #$30
		sta bank+$0400

		rts
}
draw_room: {
/*	ldy cur_room
	lda room_addr_lo,y
	sta $02
	lda room_addr_hi,y
	sta $03
	*/
	lda #11
	sta $0c
	
	lda #$d8
	sta $0d

	lda #11
	sta $0a
	lda #$84
	sta $0b
	
	lda #23
	sta lines
next_row:
	ldy #0
	
next_char:
	lda ($02),y
	sta ($0a),y
	
//	lda ($02),y
//	tax
//	lda color_char,x	

	lda #1
	sta ($0c),y
	
	iny
	cpy #18
	bne next_char
	
	lda $0a
	clc
	adc #40
	sta $0a
	lda $0b
	adc #0
	sta $0b
	
	lda $0c
	clc
	adc #40
	sta $0c
	lda $0d
	adc #0
	sta $0d

	lda $02
	clc
	adc #18
	sta $02
	lda $03
	adc #0
	sta $03
	
	dec lines
	bne next_row
	
	rts
}

.encoding "screencode_upper"
level_1:
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"	
	.text "X  YET ANOTHER   X"
	.text "X  ONE BUTTON    X"
	.text "X     GAME       X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"

gameover_r:
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X   GAME OVER    X"
	.text "X                X"
	.text "X  PRESS BUTTON  X"
	.text "X                X"
	.text "X   YOUR SCORE   X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	.text "X                X"
	
* = * "table"
screen_table:
	.word 0*40+bank+1024
	.word 1*40+bank+1024
	.word 2*40+bank+1024
	.word 3*40+bank+1024
	.word 4*40+bank+1024
	.word 5*40+bank+1024
	.word 6*40+bank+1024
	.word 7*40+bank+1024
	.word 8*40+bank+1024
	.word 9*40+bank+1024
	.word 10*40+bank+1024
	.word 11*40+bank+1024
	.word 12*40+bank+1024
	.word 13*40+bank+1024
	.word 14*40+bank+1024
	.word 15*40+bank+1024
	.word 16*40+bank+1024
	.word 17*40+bank+1024
	.word 18*40+bank+1024
	.word 19*40+bank+1024
	.word 20*40+bank+1024
	.word 21*40+bank+1024
	.word 22*40+bank+1024
	.word 23*40+bank+1024
	.word 24*40+bank+1024
	.word 25*40+bank+1024
		
screen1_table:
	.word 0*40+bank+$3000
	.word 1*40+bank+$3000
	.word 2*40+bank+$3000
	.word 3*40+bank+$3000
	.word 4*40+bank+$3000
	.word 5*40+bank+$3000
	.word 6*40+bank+$3000
	.word 7*40+bank+$3000
	.word 8*40+bank+$3000
	.word 9*40+bank+$3000
	.word 10*40+bank+$3000
	.word 11*40+bank+$3000
	.word 12*40+bank+$3000
	.word 13*40+bank+$3000
	.word 14*40+bank+$3000
	.word 15*40+bank+$3000
	.word 16*40+bank+$3000
	.word 17*40+bank+$3000
	.word 18*40+bank+$3000
	.word 19*40+bank+$3000
	.word 20*40+bank+$3000
	.word 21*40+bank+$3000
	.word 22*40+bank+$3000
	.word 23*40+bank+$3000
	.word 24*40+bank+$3000
	.word 25*40+bank+$3000

backdrop_table:
	.word 0*40+backdrop
	.word 1*40+backdrop
	.word 2*40+backdrop
	.word 3*40+backdrop
	.word 4*40+backdrop
	.word 5*40+backdrop
	.word 6*40+backdrop
	.word 7*40+backdrop
	.word 8*40+backdrop
	.word 9*40+backdrop
	.word 10*40+backdrop
	.word 11*40+backdrop
	.word 12*40+backdrop
	.word 13*40+backdrop
	.word 14*40+backdrop
	.word 15*40+backdrop
	.word 16*40+backdrop
	.word 17*40+backdrop
	.word 18*40+backdrop
	.word 19*40+backdrop
	.word 20*40+backdrop
	.word 21*40+backdrop
	.word 22*40+backdrop
	.word 23*40+backdrop
	.word 24*40+backdrop
	.word 25*40+backdrop		
				
*=* "MISC"	
div8:
	.fill 256,i/8
mod8:
	.fill 256,mod(i,8)
	
joy:
	.byte 0
cursorx:
	.byte 0
cursory:
	.byte 0


bufferid:
	.byte 0
	

pressed_time:
	.byte 0
/*
BUCKET DATA
*/	
bucketVal:
	.fill 90,0
bucketNext:
	.fill 90,0
bucketSpid:
	.fill 90,0
bucketIdx:
	.byte 0
bucket:
	.fill 256,$ff
	
/*
	SPRITE DATA
*/			
sprite_count:
	.byte 0
sprite_w_count:
	.byte 0

sprite_list:
	.fill max_sprites+1,0
sprite_w_list:
	.fill max_sprites+1,0
	
sprite_free_list:
	.fill max_sprites+1,i+1
sprite_first_free:
	.byte 0
	
sprite_type:
	.fill max_sprites+1,0
	
sprite_first_frame:
	.fill max_sprites+1,0
sprite_last_frame:
	.fill max_sprites+1,0
sprite_cur_frame:
	.fill max_sprites+1,0
sprite_dir_x:
	.fill max_sprites+1,0
sprite_dir_y:
	.fill max_sprites+1,0
	
sprite_image_id:
	.fill max_sprites+1, 0
sprite_w_image_id:	
	.fill max_sprites+1, 0
	
sprite_pos_x_lo:
	.fill max_sprites+1, 32+8*i
sprite_w_pos_x_lo:
	.fill max_sprites+1, 32+8*i

sprite_pos_x_hi:
	.fill max_sprites+1,0
sprite_pos_y_lo:
	.fill max_sprites+1,8*(i+1)
sprite_w_pos_y_lo:
	.fill max_sprites+1,8*(i+1)

sprite_pos_y_hi:
	.fill max_sprites+1,0

sprite_pos_old_x_lo:
	.fill max_sprites+1, 8*4
sprite_pos_old_x_hi:
	.fill max_sprites+1, 0
sprite_pos_old_y_lo:
	.fill max_sprites+1,8*4
sprite_pos_old_y_hi:
	.fill max_sprites+1,0
sprite_state:
	.fill max_sprites+1,0	
sprite_frame_delay:
	.fill max_sprites+1,0	
sprite_frame_max_delay:
	.fill max_sprites+1,0	
sprite_anim_id:
	.fill max_sprites+1,0	
sprite_model_id:
	.fill max_sprites+1,0	
sprite_frame_callback_lo:
	.fill max_sprites+1,0	
sprite_frame_callback_hi:
	.fill max_sprites+1,0	
sprite_timeout:
	.fill max_sprites+1,0
	
playerid:
	.byte 0

scrolly:
	.byte 4
subtile:
	.byte 0
score:
	.word 0
nspawn:
	.word 0
charset:
	//.import binary "tileset.bin"
sprites:
	.import binary "sprites_final.bin"	
	.import binary "sprites_explo.bin"	
	.import binary "res_evil.bin"	
*=* "DATA" virtual

bullet_num:
	.byte 0
bullet_list:
	.fill 20,0	
	
cachebuff:	

*=cachebuff+64  virtual
backdrop:

*=backdrop+1025 virtual




