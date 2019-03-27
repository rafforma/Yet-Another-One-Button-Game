/*

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
.var showRasterTime=true
.var showSubTime=false
.var r1=$0314
.var r2=$0315
//.var r1=$fffe
//.var r2=$ffff
.var flagpause=true

.var max_sprites=16;
//.var music = LoadSid("../music/Funky_Freak.sid")

//.var cachechar=$e0	
//.var cachechar1=$e8
.var first_sprite_char=50
.var bank =$8000

	
//*=music.location "Music"
  //      .fill music.size, music.getData(i)

* = * "Code"
init_cachechar:{
shiftv0:
	lda #0
	lda mychar+0
	sta cachebuff+0
	lda mychar+1
	sta cachebuff+1	
	lda mychar+2
	sta cachebuff+2
	lda mychar+3
	sta cachebuff+3
	lda mychar+4
	sta cachebuff+4
	lda mychar+5
	sta cachebuff+5
	lda mychar+6
	sta cachebuff+6
	lda mychar+7
	sta cachebuff+7
	lda #0
	sta cachebuff+8
	sta cachebuff+9
	sta cachebuff+10
	sta cachebuff+11
	sta cachebuff+12
	sta cachebuff+13
	sta cachebuff+14
	sta cachebuff+15
	
	
shiftv2:
	lda #0
	sta cachebuff+16
	sta cachebuff+17
	

	lda mychar
	sta cachebuff+18
	lda mychar+1
	sta cachebuff+19
	lda mychar+2
	sta cachebuff+20
	lda mychar+3
	sta cachebuff+21
	lda mychar+4
	sta cachebuff+22
	lda mychar+5
	sta cachebuff+23
	lda mychar+6
	sta cachebuff+24
	lda mychar+7
	sta cachebuff+25
	
	lda #0
	sta cachebuff+26
	sta cachebuff+27
	sta cachebuff+28
	sta cachebuff+29
	sta cachebuff+30
	sta cachebuff+31
		
shiftv4:
	lda #0
	sta cachebuff+32
	sta cachebuff+33
	sta cachebuff+34
	sta cachebuff+35

	
	lda mychar
	sta cachebuff+36
	lda mychar+1
	sta cachebuff+37
	lda mychar+2
	sta cachebuff+38
	lda mychar+3
	sta cachebuff+39
	lda mychar+4
	sta cachebuff+40
	lda mychar+5
	sta cachebuff+41
	lda mychar+6
	sta cachebuff+42
	lda mychar+7
	sta cachebuff+43	
	
	lda #0
	sta cachebuff+44
	sta cachebuff+45
	sta cachebuff+46
	sta cachebuff+47
	

shiftv6:
	lda #0
	sta cachebuff+48
	sta cachebuff+49
	sta cachebuff+50
	sta cachebuff+51
	sta cachebuff+52
	sta cachebuff+53
	
	
	lda mychar
	sta cachebuff+54
	lda mychar+1
	sta cachebuff+55
	lda mychar+2
	sta cachebuff+56
	lda mychar+3
	sta cachebuff+57
	lda mychar+4
	sta cachebuff+58
	lda mychar+5
	sta cachebuff+59
	lda mychar+6
	sta cachebuff+60
	lda mychar+7
	sta cachebuff+61
	
	lda #0
	sta cachebuff+62
	sta cachebuff+63
	rts
}
	
get_char:{
	lda cursory
	asl 
	tax
	lda bufferid
	bne buffer_1
	
	lda screen_table,x
	sta $02
	lda screen_table+1,x
	sta $03
	jmp cont
buffer_1:	
	lda screen1_table,x
	sta $02
	lda screen1_table+1,x
	sta $03
cont:
	lda $02
	clc
	adc cursorx
	sta $02
	lda $03
	adc #0
	sta $03
	
	rts
}

get_char_in_backdrop:{
	lda cursory
	asl 
	tax
	lda backdrop_table,x
	sta $02
	lda backdrop_table+1,x
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
	sta bank+$400+$100,y
	sta bank+$400+$200,y
	sta bank+$400+$300,y	
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
	
.macro next_buffer () {
	lda bufferid
	bne reset
	lda #1
	sta bufferid
	jmp f
reset:
	lda #0
	sta bufferid
f:
	
}
.macro switch_buffer (){
	lda bufferid
	bne swith_buffer1
	lda #$19
	sta $d018
	jmp fine
	
swith_buffer1:	
	lda #$CE
	sta $d018
	
fine:
}
.macro incSprMem () {
	lda $f0
	clc
	adc #8
	sta $f0
	lda $f1
	adc #0
	sta $f1
}
sprupdateflag:
	.byte 0
shift_mask_vert:
	.byte $ff
v_shift:
	.byte 0
h_shift:
	.byte 0

game_ps:
	.byte 0
game_tm:
	.byte 0
game_idx:
	.byte 0
game_spanw_pt:
	.byte 112+0/8*8,112+80/8*8,112+55/8*8,112+88/8*8,112+45/8*8,112+74/8*8,112+32/8*8,112+58/8*8,112+94/8*8,112+76/8*8
	.byte 112+52/8*8,112+11/8*8,112+26/8*8,112+75/8*8,112+35/8*8,112+96/8*8
	
game_put_enemy: {

	inc game_tm
	lda game_tm
	cmp #8
	bcc leave
	

	jsr sprite_alloc
	cmp #$ff
	beq leave
	tax
	
	lda #0
	sta game_tm
	
	inc game_idx
	lda game_idx
	and #15
	sta game_idx
	
	tay
	lda game_spanw_pt,y
	sta sprite_pos_x_lo,x
	
	lda #$18
	sta sprite_pos_y_lo,x
	
	
	inc game_ps
	lda game_ps
	and #1
	bne lento
	lda #2
	jmp nnn
lento:
	lda #1
nnn:
	sta sprite_dir_y,x
leave:
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
	
	lda #swid
	sta $87F8+hwid
	sta $b3F8+hwid
	lda #1
	sta $d027+hwid
}
.macro putsprite(_x,_y) {
	jsr sprite_alloc
	tay
	lda #_x
	sta sprite_pos_x_lo,y
	lda #_y
	sta sprite_pos_y_lo,y
	
}
main: {
		
	ldx #0
	
n1:
	txa	
	asl
	asl
	asl
	asl
	sta asl4,x
	asl
	asl
	sta asl6,x
	
	txa
	lsr
	lsr
	lsr
	lsr
	sta lsr4,x
	lsr
	lsr
	sta lsr6,x
	inx
	bne n1
	
	lda #0
	sta 53280
	lda #6
	sta 53281
	
	lda $dd02
    ora #3
	sta $dd02     //               ; Make sure CIA#2 lines set to OUTPUT
	lda $dd00
	and #%11111100
	ora #1           //          ;  Bank #1, $4000-$7FFF, 16384-32767.
	sta $dd00 
		
	
	lda #1
	sta level_mask+128
	sta level_mask+129
	sta level_mask+130
	sta level_mask+131
		
	//lda #$18	
	//sta $d018

	lda #$13
	sta $d011
	
	ldy #0
chardef:
	lda charset,y
	sta bank+$2000,y
	sta bank+$3800,y
	
	lda charset+$100,y
	sta bank+$2000+$100,y
	sta bank+$3800+$100,y

	lda charset+$200,y
	sta bank+$2000+$200,y
	sta bank+$3800+$200,y
	
	lda charset+$300,y
	sta bank+$2000+$300,y
	sta bank+$3800+$300,y

	iny
	bne chardef
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
	
	jsr sprite_alloc
	sta playerid
	tay
	lda #5*8
	sta sprite_pos_x_lo,y
	lda #28*8
	sta sprite_pos_y_lo,y
	
	//lda #music.startSong-1	
	//lda #0
	//jsr music.init
	//jsr init_cachechar
	
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
		
	jsr initraster
	lda #10
	sta $d021
	
mainloop:
	
	lda sprupdateflag
	bne mainloop
	
	
	
	next_buffer()	
	
	
	jsr getjoy	
	jsr update_player
	.if (flagpause) {
	lda pause
	bne *+5
	}
	jsr game_put_enemy
	
	jsr sprite_update	
	jsr sprite_sort
	jsr calc_raster
		
	inc sprupdateflag 					
	
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
	lda #7
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
	
	lda #$00
    sta sprupdateflag	


.if (showRasterTime){
   lda #0
	sta $d020
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
	
	printhex(bank+$0400,rast_flag_1)
	
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
	lda #9
	sta $d020
	
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
	lda #9
	sta $d020
	
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
   lda #0
   sta $d020
}

	retirq()  
	
imposta_sprite_8_16:
	saveregs()
imposta_sprite_8_16_no:	


.if (showRasterTime){
	lda #1
	sta $d020
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
	lda #0
	sta $d020
}	
		

leave:	

.if (showRasterTime){
	lda #0
	sta $d020
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
	lda #0
	sta sprite_dir_x,y
	lda #0
	sta sprite_dir_y,y
	
	lda joy            
	and #$4
	beq check_left
	lda #-2
	ldy playerid
	sta sprite_dir_x,y
	
check_left:
	lda joy            
	and #$8
	beq check_up
	ldy playerid
	lda #2
	sta sprite_dir_x,y


check_up:
	lda joy            
	and #$1
	beq check_down
	ldy playerid
	lda #-2
	sta sprite_dir_y,y

check_down:
	lda joy            
	and #$2
	beq check_press
	ldy playerid
	lda #2
	sta sprite_dir_y,y

check_press:
	lda joy            
	and #$10
	beq none
	lda pressed_time
	cmp #8
	bcc none
	lda #0
	sta pressed_time
.if (flagpause) {
	lda pause
	eor #1
	sta pause
}

.if (flagpause==false) {	
	jsr sprite_alloc	
	cmp #$ff
	beq none
	tax
	ldy playerid
	lda sprite_pos_x_lo,y
	sta sprite_pos_x_lo,x
	lda sprite_pos_y_lo,y
	sta sprite_pos_y_lo,x
	
	lda #-4
	sta sprite_dir_y,x
}
none:		
nojump:

norinculo:		

check_coll:
	
	
noground:
	
	rts
}



	
		
sprite_alloc: {
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
}

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


sprite_update: {

	ldx #0
	lda #0
	sta sprite_count
	sta bucketIdx
	
	
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
	
	//lda sprite_pos_x_lo,x
	//cmp #248
	//bcs dealloc	
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

	/*lda sprite_count
	tay
	txa
	sta sprite_list,y
	inc sprite_count
	*/
	
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
	

	inx
	
	jmp next	
	
select_sprites:
	
	
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

	lda val
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

/*mychar: 
		 .byte %01111110
		 .byte %10000001
		 .byte %10100101 
		 .byte %10000001
		 .byte %10000001
		 .byte %10000001
		 .byte %10000001
		 .byte %01111110
*/
mychar: 
		 .byte %00000000
		 .byte %00011000
		 .byte %00111100 
		 .byte %00111100
		 .byte %00111100
		 .byte %00111100
		 .byte %00111100
		 .byte %00111100
/*mychar: 
		 .byte %00000000
		 .byte %00000000
		 .byte %00000000 
		 .byte %11111000
		 .byte %11111110
		 .byte %11111110
		 .byte %11111110
		 .byte %00000000
*/

* = * "table"
mul8tab_lo:
	.fill 256,<((bank+$2000)+i*8)
mul8tab_hi:
	.fill 256,>((bank+$2000)+i*8)
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
asl6:
	.fill 256,0
asl4:
	.fill 256,0	
lsr6:
	.fill 256,0
lsr4:
	.fill 256,0			 
joy:
	.byte 0
cursorx:
	.byte 0
cursory:
	.byte 0

pixelx:
	.byte 0
pixely:
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
	
sprite_dir_x:
	.fill max_sprites+1,0
sprite_dir_y:
	.fill max_sprites+1,0
	
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


	
playerid:
	.byte 0
level_mask:
	.fill 256,mod(i,4) /2
scrolly:
	.byte 4
subtile:
	.byte 0
	
.encoding "screencode_upper"
level:
	.text "@        D"
	.text "@   A    D"
	.text "@ BB A   D"
	.text "@        D"
	.text "@   A    D"
	.text "@@     AAD"
	.text "@        D"
	.text "@BBBBBB  D"
	.text "@        D"
	.text "@  BBBBAAD"
	.text "@        D"
	.text "@AAAAAAAAD"
charset:
	.import binary "tileset.bin"
sprites:
	.import binary "sprites.bin"	
*=* "DATA" virtual
cachebuff:	

*=cachebuff+64  virtual
backdrop:

*=backdrop+1025 virtual

/*	
* = bank+$2000 "CHARDATA"
	.import binary "tileset.bin"	
* = bank+$3000 "BUFFER2"
	.fill 1025,32			
* = bank+$3800 "gfx2"		
	.import binary "tileset.bin"
	
*/


