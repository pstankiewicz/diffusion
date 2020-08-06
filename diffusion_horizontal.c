// Diffusion simulation

#include <c64.h>
#include <stdlib.h>

byte* screen = 0x0400;
byte* screen_color = 0xd800;

word border_cells[] = {
    40, 80, 120, 160, 200, 240, 280, 320, 360, 400, 440, 480, 520,
    560, 600, 640, 680, 720, 760, 800, 840, 880, 920, 960
};

const byte CIRCLE = 81;
const word SCREEN_SIZE = 1000;
const byte COLUMNS = 40;
const byte HALF_COLUMNS = 20;


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

    for (word i=0; i<SCREEN_SIZE; i += COLUMNS) {
        for (byte j=0; j<HALF_COLUMNS; j++) {
            screen[i+j] = CIRCLE;
            screen_color[i+j] = WHITE;
        }
        for (byte j=HALF_COLUMNS; j<COLUMNS; j++) {
            screen[i+j] = CIRCLE;
            screen_color[i+j] = DARK_GREY;
        }
    }
}


void swap_cells() {
    word address = rand() - 1;
    if (address < SCREEN_SIZE - 1) {
        if (!is_border_cell(address)){
            word next_address = address + 1;
            byte first_color = screen_color[address];
            screen_color[address] = screen_color[next_address];
            screen_color[next_address] = first_color;
        }
    }

}


bool is_border_cell(word address){
    for (byte x=0; x<sizeof(border_cells); x++){
        if (address + 1 == border_cells[x]) {
            return true;
        }
    }
    return false;
}

