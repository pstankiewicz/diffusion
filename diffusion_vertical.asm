// Diffusion simulation
.pc = $801 "Basic"
:BasicUpstart(main)
.pc = $80d "Program"
  // The colors of the C64
  .const BLACK = 0
  .const WHITE = 1
  .const DARK_GREY = $b
  .const HALF_SCREEN = $1e0
  .const CIRCLE = $51
  .const MARGIN = $28
  .const SCREEN_SIZE = $3e8
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
    .label __5 = 8
    .label __6 = $a
    .label __7 = 4
    .label __8 = 6
    jsr rand
    lda.z address
    sec
    sbc #1
    sta.z address
    lda.z address+1
    sbc #0
    sta.z address+1
    cmp #>SCREEN_SIZE-MARGIN
    bcc !+
    bne __breturn
    lda.z address
    cmp #<SCREEN_SIZE-MARGIN
    bcs __breturn
  !:
    lda #MARGIN
    clc
    adc.z address
    sta.z next_address
    lda #0
    adc.z address+1
    sta.z next_address+1
    lda.z address
    clc
    adc #<screen_color
    sta.z __5
    lda.z address+1
    adc #>screen_color
    sta.z __5+1
    ldy #0
    lda (__5),y
    tax
    lda.z next_address
    clc
    adc #<screen_color
    sta.z __6
    lda.z next_address+1
    adc #>screen_color
    sta.z __6+1
    clc
    lda.z __7
    adc #<screen_color
    sta.z __7
    lda.z __7+1
    adc #>screen_color
    sta.z __7+1
    lda (__6),y
    sta (__7),y
    clc
    lda.z __8
    adc #<screen_color
    sta.z __8
    lda.z __8+1
    adc #>screen_color
    sta.z __8+1
    txa
    sta (__8),y
  __breturn:
    rts
}
// Returns a pseudo-random number in the range of 0 to RAND_MAX (65535)
// Uses an xorshift pseudorandom number generator that hits all different values
// Information https://en.wikipedia.org/wiki/Xorshift
// Source http://www.retroprogramming.com/2017/07/xorshift-pseudorandom-numbers-in-z80.html
rand: {
    .label __0 = $c
    .label __1 = $e
    .label __2 = 8
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
    .label i = 4
    .label i1 = 6
    .label __2 = $c
    .label __3 = $e
    .label __4 = 8
    .label __5 = $a
    lda #<0
    sta.z i
    sta.z i+1
  __b1:
    lda.z i+1
    cmp #>HALF_SCREEN
    bcc __b2
    bne !+
    lda.z i
    cmp #<HALF_SCREEN
    bcc __b2
  !:
    lda #<HALF_SCREEN
    sta.z i1
    lda #>HALF_SCREEN
    sta.z i1+1
  __b3:
    lda.z i1+1
    cmp #>SCREEN_SIZE
    bcc __b4
    bne !+
    lda.z i1
    cmp #<SCREEN_SIZE
    bcc __b4
  !:
    rts
  __b4:
    lda.z i1
    clc
    adc #<screen
    sta.z __4
    lda.z i1+1
    adc #>screen
    sta.z __4+1
    lda #CIRCLE
    ldy #0
    sta (__4),y
    lda.z i1
    clc
    adc #<screen_color
    sta.z __5
    lda.z i1+1
    adc #>screen_color
    sta.z __5+1
    lda #DARK_GREY
    sta (__5),y
    inc.z i1
    bne !+
    inc.z i1+1
  !:
    jmp __b3
  __b2:
    lda.z i
    clc
    adc #<screen
    sta.z __2
    lda.z i+1
    adc #>screen
    sta.z __2+1
    lda #CIRCLE
    ldy #0
    sta (__2),y
    lda.z i
    clc
    adc #<screen_color
    sta.z __3
    lda.z i+1
    adc #>screen_color
    sta.z __3+1
    lda #WHITE
    sta (__3),y
    inc.z i
    bne !+
    inc.z i+1
  !:
    jmp __b1
}
init_colors: {
    lda #BLACK
    sta BG_COLOR
    sta BORDER_COLOR
    rts
}
