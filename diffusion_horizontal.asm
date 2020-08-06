// Diffusion simulation
.pc = $801 "Basic"
:BasicUpstart(main)
.pc = $80d "Program"
  // The colors of the C64
  .const BLACK = 0
  .const WHITE = 1
  .const DARK_GREY = $b
  .const CIRCLE = $51
  .const SCREEN_SIZE = $3e8
  .const COLUMNS = $28
  .const HALF_COLUMNS = $14
  .const SIZEOF_WORD = 2
  .label BORDER_COLOR = $d020
  .label BG_COLOR = $d021
  .label screen = $400
  .label screen_color = $d800
  // The random state variable
  .label rand_state = 2
main: {
    jsr init_screen
    lda #<1
    sta.z rand_state
    lda #>1
    sta.z rand_state+1
  __b2:
    jsr swap_cells
    jmp __b2
}
swap_cells: {
    .label __0 = 4
    .label address = 4
    .label next_address = 6
    .label __8 = 8
    .label __9 = $a
    .label __10 = 4
    .label __11 = 6
    jsr rand
    lda.z address
    sec
    sbc #1
    sta.z address
    lda.z address+1
    sbc #0
    sta.z address+1
    cmp #>SCREEN_SIZE-1
    bcc !+
    bne __breturn
    lda.z address
    cmp #<SCREEN_SIZE-1
    bcs __breturn
  !:
    lda.z address
    sta.z is_border_cell.address
    lda.z address+1
    sta.z is_border_cell.address+1
    jsr is_border_cell
    cmp #0
    bne __breturn
    lda.z address
    clc
    adc #1
    sta.z next_address
    lda.z address+1
    adc #0
    sta.z next_address+1
    lda.z address
    clc
    adc #<screen_color
    sta.z __8
    lda.z address+1
    adc #>screen_color
    sta.z __8+1
    ldy #0
    lda (__8),y
    tax
    lda.z next_address
    clc
    adc #<screen_color
    sta.z __9
    lda.z next_address+1
    adc #>screen_color
    sta.z __9+1
    clc
    lda.z __10
    adc #<screen_color
    sta.z __10
    lda.z __10+1
    adc #>screen_color
    sta.z __10+1
    lda (__9),y
    sta (__10),y
    clc
    lda.z __11
    adc #<screen_color
    sta.z __11
    lda.z __11+1
    adc #>screen_color
    sta.z __11+1
    txa
    sta (__11),y
  __breturn:
    rts
}
// is_border_cell(word zp(6) address)
is_border_cell: {
    .label __2 = 8
    .label address = 6
    ldx #0
  __b1:
    cpx #$18*SIZEOF_WORD
    bcc __b2
    lda #0
    rts
  __b2:
    lda.z address
    clc
    adc #1
    sta.z __2
    lda.z address+1
    adc #0
    sta.z __2+1
    txa
    asl
    tay
    lda.z __2+1
    cmp border_cells+1,y
    bne __b3
    lda.z __2
    cmp border_cells,y
    bne __b3
    lda #1
    rts
  __b3:
    inx
    jmp __b1
}
// Returns a pseudo-random number in the range of 0 to RAND_MAX (65535)
// Uses an xorshift pseudorandom number generator that hits all different values
// Information https://en.wikipedia.org/wiki/Xorshift
// Source http://www.retroprogramming.com/2017/07/xorshift-pseudorandom-numbers-in-z80.html
rand: {
    .label __0 = 8
    .label __1 = $c
    .label __2 = $e
    .label return = 4
    lda.z rand_state+1
    lsr
    lda.z rand_state
    ror
    sta.z __0+1
    lda #0
    ror
    sta.z __0
    lda.z rand_state
    eor.z __0
    sta.z rand_state
    lda.z rand_state+1
    eor.z __0+1
    sta.z rand_state+1
    lsr
    sta.z __1
    lda #0
    sta.z __1+1
    lda.z rand_state
    eor.z __1
    sta.z rand_state
    lda.z rand_state+1
    eor.z __1+1
    sta.z rand_state+1
    lda.z rand_state
    sta.z __2+1
    lda #0
    sta.z __2
    lda.z rand_state
    eor.z __2
    sta.z rand_state
    lda.z rand_state+1
    eor.z __2+1
    sta.z rand_state+1
    lda.z rand_state
    sta.z return
    lda.z rand_state+1
    sta.z return+1
    rts
}
init_screen: {
    jsr init_colors
    jsr set_screen
    rts
}
set_screen: {
    .label __2 = $c
    .label __3 = $e
    .label __5 = 8
    .label __6 = $a
    .label i = 4
    .label __7 = $c
    .label __8 = $e
    .label __9 = 8
    .label __10 = $a
    lda #<0
    sta.z i
    sta.z i+1
  __b1:
    lda.z i+1
    cmp #>SCREEN_SIZE
    bcc __b6
    bne !+
    lda.z i
    cmp #<SCREEN_SIZE
    bcc __b6
  !:
    rts
  __b6:
    ldx #0
  __b2:
    cpx #HALF_COLUMNS
    bcc __b3
    ldx #HALF_COLUMNS
  __b4:
    cpx #COLUMNS
    bcc __b5
    lda #COLUMNS
    clc
    adc.z i
    sta.z i
    bcc !+
    inc.z i+1
  !:
    jmp __b1
  __b5:
    txa
    clc
    adc.z i
    sta.z __5
    lda #0
    adc.z i+1
    sta.z __5+1
    clc
    lda.z __9
    adc #<screen
    sta.z __9
    lda.z __9+1
    adc #>screen
    sta.z __9+1
    lda #CIRCLE
    ldy #0
    sta (__9),y
    txa
    clc
    adc.z i
    sta.z __6
    tya
    adc.z i+1
    sta.z __6+1
    clc
    lda.z __10
    adc #<screen_color
    sta.z __10
    lda.z __10+1
    adc #>screen_color
    sta.z __10+1
    lda #DARK_GREY
    sta (__10),y
    inx
    jmp __b4
  __b3:
    txa
    clc
    adc.z i
    sta.z __2
    lda #0
    adc.z i+1
    sta.z __2+1
    clc
    lda.z __7
    adc #<screen
    sta.z __7
    lda.z __7+1
    adc #>screen
    sta.z __7+1
    lda #CIRCLE
    ldy #0
    sta (__7),y
    txa
    clc
    adc.z i
    sta.z __3
    tya
    adc.z i+1
    sta.z __3+1
    clc
    lda.z __8
    adc #<screen_color
    sta.z __8
    lda.z __8+1
    adc #>screen_color
    sta.z __8+1
    lda #WHITE
    sta (__8),y
    inx
    jmp __b2
}
init_colors: {
    lda #BLACK
    sta BG_COLOR
    sta BORDER_COLOR
    rts
}
  border_cells: .word $28, $50, $78, $a0, $c8, $f0, $118, $140, $168, $190, $1b8, $1e0, $208, $230, $258, $280, $2a8, $2d0, $2f8, $320, $348, $370, $398, $3c0
