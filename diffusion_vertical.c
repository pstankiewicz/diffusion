// Diffusion simulation

#include <c64.h>
#include <stdlib.h>


byte* screen = 0x0400;
byte* screen_color = 0xd800;

const word HALF_SCREEN = 480;
const byte CIRCLE = 81;
const byte MARGIN = 40;
const word SCREEN_SIZE = 1000;

void main() {

    init_screen();

    while(true) {
        swap_cells();
    }
}


void init_screen() {
    init_colors();
    set_screen();
}


void init_colors() {
    *BG_COLOR = BLACK;
    *BORDER_COLOR = BLACK;
}


void set_screen() {

    for (word i=0; i<HALF_SCREEN; i++) {
        screen[i] = CIRCLE;
        screen_color[i] = WHITE;
    }
    for (word i=HALF_SCREEN; i<SCREEN_SIZE; i++) {
        screen[i] = CIRCLE;
        screen_color[i] = DARK_GREY;
    }
}


void swap_cells() {
    word address = rand() - 1;
    if (address < SCREEN_SIZE - MARGIN) {
        word next_address = address + MARGIN;
        byte first_color = screen_color[address];
        screen_color[address] = screen_color[next_address];
        screen_color[next_address] = first_color;
    }

}
