`default_nettype none

module tt_um_sellicott_tiny_bnn (
//    input [7:0] io_in,
//    output [7:0] io_out
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);
    wire [7:0] io_in ;
    wire [7:0] io_out ;
    assign io_in = ui_in ;
    assign io_out = uo_out ;
    wire _unused = &{ clk, rst_n, ena, uio_in } ;
    assign uio_out = 0 ;
    assign uio_oe = 0 ;

    localparam GLOBAL_INPUTS = 8;
    localparam GLOBAL_OUTPUTS = 8;
    localparam HIDDEN_UNITS = 8;
    localparam HIDDEN_UNITS2 = 0;
    
    wire clk_user = io_in[0];
    wire setup = io_in[1];
    wire param_in = io_in[2];
    wire x_bank_hi = io_in[3];
    wire [3:0] x = io_in[7:4];


    reg [GLOBAL_INPUTS-1:0] global_input;
    wire [HIDDEN_UNITS-1:0] hidden;
    wire [HIDDEN_UNITS2-1:0] hidden2;
    wire [GLOBAL_OUTPUTS-1:0] global_output;
    wire [HIDDEN_UNITS+HIDDEN_UNITS2+GLOBAL_OUTPUTS-1:0] param_chain;
    
    always @(posedge clk_user) begin
        // during setup phase, reset global inputs to 0
        if (setup) begin
            global_input <= 0;
        end else begin
            if (x_bank_hi)
                global_input[7:4] <= x;
            else
                global_input[3:0] <= x;
        end
    end

//    genvar i;
//    generate
//        // input layer
//        if (HIDDEN_UNITS == 0) begin
//            // just a single layer
//            for (i = 0; i < GLOBAL_OUTPUTS; i = i + 1) begin
//                wire p = (i == 0) ? param_in : param_chain[i - 1];
//                neuron #(.INPUTS(GLOBAL_INPUTS)) output_layer(
//                    .clk(clk_user), .setup(setup), .param_in(p), .param_out(param_chain[i]),
//                    .inputs(global_input), .axon(global_output[i]));
//            end
//        end else if (HIDDEN_UNITS2 == 0) begin
//            for (i = 0; i < HIDDEN_UNITS; i = i + 1) begin
//                wire p = (i == 0) ? param_in : param_chain[i - 1];
//
//                neuron #(.INPUTS(GLOBAL_INPUTS)) input_layer(
//                    .clk(clk_user), .setup(setup), .param_in(p), .param_out(param_chain[i]),
//                    .inputs(global_input), .axon(hidden[i]));
//            end
//
//            // output layer
//            for (i = 0; i < GLOBAL_OUTPUTS; i = i + 1) begin
//                neuron #(.INPUTS(HIDDEN_UNITS)) output_layer(
//                    .clk(clk_user), .setup(setup), .param_in(param_chain[HIDDEN_UNITS + i - 1]), .param_out(param_chain[HIDDEN_UNITS + i]),
//                    .inputs(hidden), .axon(global_output[i]));
//            end
//        end else begin

    genvar i1;
    generate
            // 1st layer
            for (i1 = 0; i1 < HIDDEN_UNITS; i1 = i1 + 1) begin : gen_blk_i1
                wire p = (i1 == 0) ? param_in : param_chain[i1 - 1];

                neuron #(.INPUTS(GLOBAL_INPUTS)) input_layer(
                    .clk(clk_user), .setup(setup), .param_in(p), .param_out(param_chain[i1]),
                    .inputs(global_input), .axon(hidden[i1]));
            end
    endgenerate

    genvar i2;
    generate
            // 2nd layer
            for (i2 = 0; i2 < HIDDEN_UNITS2; i2 = i2 + 1) begin : gen_blk_i2
                neuron #(.INPUTS(HIDDEN_UNITS)) input_layer(
                    .clk(clk_user), .setup(setup), .param_in(param_chain[HIDDEN_UNITS + i2 - 1]), .param_out(param_chain[HIDDEN_UNITS + i2]),
                    .inputs(hidden), .axon(hidden2[i2]));
            end
    endgenerate

    genvar i3;
    generate
            // output layer
            for (i3 = 0; i3 < GLOBAL_OUTPUTS; i3 = i3 + 1) begin : gen_blk_i3
                neuron #(.INPUTS(HIDDEN_UNITS)) output_layer(
                    .clk(clk_user), .setup(setup), .param_in(param_chain[HIDDEN_UNITS + HIDDEN_UNITS2 + i3 - 1]), .param_out(param_chain[HIDDEN_UNITS + HIDDEN_UNITS2 + i3]),
                    .inputs(hidden2), .axon(global_output[i3]));
            end
    endgenerate
//        end

        // for (i = 0; i < GLOBAL_OUTPUTS; i = i + 1) begin 
        //     assign io_out[i] = (setup && i == GLOBAL_OUTPUTS - 1) ? param_chain[HIDDEN_UNITS+HIDDEN_UNITS2+GLOBAL_OUTPUTS-1] : global_output[i];
        // end

    genvar i4;
    generate
        for (i4 = 0; i4 < GLOBAL_OUTPUTS; i4 = i4 + 1) begin : gen_blk_i4
            assign io_out[i4] = global_output[i4];
        end
    endgenerate

endmodule
