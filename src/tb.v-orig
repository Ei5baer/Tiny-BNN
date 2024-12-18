`default_nettype none
`timescale 1ns/1ps

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

module tb (
    // testbench is controlled by test.py
    input clk,
    input setup,
    input param_in,
    input x_bank_hi,
    input wire [7:0] x,
    output wire [7:0] out
   );

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
        #1;
    end

    // wire up the inputs and outputs
    wire [7:0] inputs = {(x_bank_hi ? x[7:4] : x[3:0]), x_bank_hi, param_in, setup, clk};
    wire [7:0] outputs;
    assign out = outputs;


    tiny_bnn tiny_bnn(
        `ifdef GL_TEST
            .vccd1( 1'b1),
            .vssd1( 1'b0),
        `endif
        .io_in  (inputs),
        .io_out (outputs)
        );

endmodule
