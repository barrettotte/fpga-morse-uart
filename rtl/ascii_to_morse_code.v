`timescale 1ns/1ps

// ascii to (international) morse
//
// https://en.wikipedia.org/wiki/Morse_code#Letters,_numbers,_punctuation,_prosigns_for_Morse_code_and_non-Latin_variants
// note: I am not supporting nonstandard punctuation, prosigns, and non-latin characters

module ascii_to_morse_code
    (
        input wire [7:0] ascii_i, // ASCII character
        output reg [3:0] len_o,   // length of morse character
        output reg [5:0] morse_o  // morse symbols - dot=1, dash=0
    );

    always @* begin
        // default behavior
        morse_o = 6'bxxxxxx;
        len_o = 0;

        casex (ascii_i)
            // letters
            8'b01x00001:  begin  morse_o = 6'bxxxx01;  len_o = 2;  end // A      .-
            8'b01x00010:  begin  morse_o = 6'bxx1110;  len_o = 4;  end // B    -...
            8'b01x00011:  begin  morse_o = 6'bxx1010;  len_o = 4;  end // C    -.-.
            8'b01x00100:  begin  morse_o = 6'bxxx110;  len_o = 3;  end // D     -..
            8'b01x00101:  begin  morse_o = 6'bxxxxx1;  len_o = 1;  end // E       .
            8'b01x00110:  begin  morse_o = 6'bxx1011;  len_o = 4;  end // F    ..-.
            8'b01x00111:  begin  morse_o = 6'bxxx100;  len_o = 3;  end // G     --.
            8'b01x01000:  begin  morse_o = 6'bxx1111;  len_o = 4;  end // H    ....
            8'b01x01001:  begin  morse_o = 6'bxxxx11;  len_o = 2;  end // I      ..
            8'b01x01010:  begin  morse_o = 6'bxx0001;  len_o = 4;  end // J    .---
            8'b01x01011:  begin  morse_o = 6'bxxx010;  len_o = 3;  end // K     -.-
            8'b01x01100:  begin  morse_o = 6'bxx1101;  len_o = 4;  end // L    .-..
            8'b01x01101:  begin  morse_o = 6'bxxxx00;  len_o = 2;  end // M      --
            8'b01x01110:  begin  morse_o = 6'bxxxx10;  len_o = 2;  end // N      -.
            8'b01x01111:  begin  morse_o = 6'bxxx000;  len_o = 3;  end // O     ---
            8'b01x10000:  begin  morse_o = 6'bxx1001;  len_o = 4;  end // P    .--.
            8'b01x10001:  begin  morse_o = 6'bxx0100;  len_o = 4;  end // Q    --.-
            8'b01x10010:  begin  morse_o = 6'bxxx101;  len_o = 3;  end // R     .-.
            8'b01x10011:  begin  morse_o = 6'bxxx111;  len_o = 3;  end // S     ...
            8'b01x10100:  begin  morse_o = 6'bxxxxx0;  len_o = 1;  end // T       -
            8'b01x10101:  begin  morse_o = 6'bxxx011;  len_o = 3;  end // U     ..-
            8'b01x10110:  begin  morse_o = 6'bxx0111;  len_o = 4;  end // V    ...-
            8'b01x10111:  begin  morse_o = 6'bxxx001;  len_o = 3;  end // W     .--
            8'b01x11000:  begin  morse_o = 6'bxx0110;  len_o = 4;  end // X    -..-
            8'b01x11001:  begin  morse_o = 6'bxx1101;  len_o = 4;  end // Y    -.--
            8'b01x11010:  begin  morse_o = 6'bxx1100;  len_o = 4;  end // Z    --..
            // digits
            8'b00110000:  begin  morse_o = 6'bx00000;  len_o = 5;  end // 0   -----
            8'b00110001:  begin  morse_o = 6'bx00001;  len_o = 5;  end // 1   .----
            8'b00110010:  begin  morse_o = 6'bx00011;  len_o = 5;  end // 2   ..---
            8'b00110011:  begin  morse_o = 6'bx00111;  len_o = 5;  end // 3   ...--
            8'b00110100:  begin  morse_o = 6'bx01111;  len_o = 5;  end // 4   ....-
            8'b00110101:  begin  morse_o = 6'bx11111;  len_o = 5;  end // 5   .....
            8'b00110110:  begin  morse_o = 6'bx11110;  len_o = 5;  end // 6   -....
            8'b00110111:  begin  morse_o = 6'bx11100;  len_o = 5;  end // 7   --...
            8'b00111000:  begin  morse_o = 6'bx11000;  len_o = 5;  end // 8   ---..
            8'b00111001:  begin  morse_o = 6'bx10000;  len_o = 5;  end // 9   ----.
            // punctuation
            8'b00101110:  begin  morse_o = 6'b010101;  len_o = 6;  end // .  .-.-.-
            8'b00101100:  begin  morse_o = 6'b001100;  len_o = 6;  end // ,  --..--
            8'b00111111:  begin  morse_o = 6'b110011;  len_o = 6;  end // ?  ..--..
            8'b00100111:  begin  morse_o = 6'b100001;  len_o = 6;  end // '  .----.
            8'b00101111:  begin  morse_o = 6'bx10110;  len_o = 5;  end // /   -..-.
            8'b00101000:  begin  morse_o = 6'bx10010;  len_o = 5;  end // (   -.--.
            8'b00101001:  begin  morse_o = 6'b010010;  len_o = 6;  end // )  -.--.-
            8'b00111010:  begin  morse_o = 6'b111000;  len_o = 6;  end // :  ---...
            8'b00111101:  begin  morse_o = 6'bx01110;  len_o = 5;  end // =   -...-
            8'b00101011:  begin  morse_o = 6'bx10101;  len_o = 5;  end // +   .-.-.
            8'b00101101:  begin  morse_o = 6'b011110;  len_o = 6;  end // -  -....-
            8'b00100010:  begin  morse_o = 6'b101101;  len_o = 6;  end // "  .-..-.
            8'b01000000:  begin  morse_o = 6'b101001;  len_o = 6;  end // @  .--.-.

            default:      begin  morse_o = 6'bxxxxxx;  len_o = 0;  end // invalid / not supported
        endcase
    end

endmodule
