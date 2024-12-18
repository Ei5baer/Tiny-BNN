
module neuron #(
    parameter INPUTS = 8,
    parameter BIAS_BITS = 3,
    parameter USE_CHEAP_BIAS = 0
) (
    input clk,
    input setup,
    input param_in,
    output param_out,

    input wire [INPUTS-1:0] inputs,
    output reg axon
);

    reg [INPUTS-1:0 ] weights;
    reg [BIAS_BITS-1:0] bias;

    assign param_out = bias[BIAS_BITS-1];

    always @(posedge clk) begin
        // load weights & bias in the setup phase
        if (setup) begin
            bias <= bias << 1;
            bias[0] <= weights[INPUTS-1];
            weights <= weights << 1;
            weights[0] <= param_in;
            // $display(">> ", param_in);
            // $display("w = ", weights);
            // $display("b = ", bias);
        // end else begin
        //     axon <= spike;
        end
    end

    // localparam ACCUMULATOR_BITS = $clog2(INPUTS) + 1;
    // reg [ACCUMULATOR_BITS-1:0] accumulator;
    // integer i;
    // reg [INPUTS-1:0] synapses;
    // always @(*) begin
    //     // synapses <= weights & inputs;
    //     // $display("w = ", weights);
    //     // $display("b = ", bias);
    //     // $display("i = ", inputs);
    //     // $display("t = ", synapses);
    //     // accumulator = 0;
    //     // for  (i = 0; i < INPUTS; i = i + 1)
    //     //     accumulator = accumulator + (weights[i] & inputs[i]);
    //     // // $display("accumulator value = ", accumulator);
    //     // if (USE_CHEAP_BIAS == 1)
    //     //     axon <= |(accumulator & bias);
    //     // else
    //     //     axon <= (accumulator > bias);

    //     // synapses = weights & inputs;
    //     if (USE_CHEAP_BIAS == 1) begin
    //         axon = |((synapses[7]+synapses[6]+synapses[5]+synapses[4]+synapses[3]+synapses[2]+synapses[1]+synapses[0]) & bias);
    //     end else begin
    //         axon = (synapses[7]+synapses[6]+synapses[5]+synapses[4]+synapses[3]+synapses[2]+synapses[1]+synapses[0]) > bias;
    //     end
    // end

    // wire [INPUTS-1:0] synapses;
    // assign synapses = weights & inputs;
    // wire spike;
    // if (USE_CHEAP_BIAS == 1) begin
    //     assign spike = |((synapses[7]+synapses[6]+synapses[5]+synapses[4]+synapses[3]+synapses[2]+synapses[1]+synapses[0]) & bias);
    // end else begin
    //     assign spike = (synapses[7]+synapses[6]+synapses[5]+synapses[4]+synapses[3]+synapses[2]+synapses[1]+synapses[0]) > bias;
    // end

    wire [INPUTS-1:0] synapses;
    assign synapses = weights & inputs;
    if (USE_CHEAP_BIAS == 1) begin
        popcount_and_mask      #(.INPUTS(INPUTS),      .MASK_BITS(BIAS_BITS)) spike_counter(.in(synapses),      .mask(bias), .out(axon));
    end else begin
        popcount_and_threshold #(.INPUTS(INPUTS), .THRESHOLD_BITS(BIAS_BITS)) spike_counter(.in(synapses), .threshold(bias), .out(axon));
    end

    // localparam ACCUMULATOR_BITS = $clog2(INPUTS) + 1;
    // reg [ACCUMULATOR_BITS-1:0] accumulator;
    // popcount #(.INPUTS(INPUTS), .COUNTER_BITS(ACCUMULATOR_BITS)) spike_counter(.in(synapses), .count(accumulator));
    // if (USE_CHEAP_BIAS == 1) begin
    //     assign axon = |(accumulator & bias);
    // end else begin
    //     assign axon = accumulator > bias;
    // end
    // if (USE_CHEAP_BIAS) begin
    //     assign axon = |((synapses[7]+synapses[6]+synapses[5]+synapses[4]+synapses[3]+synapses[2]+synapses[1]+synapses[0]) & bias);
    // end else begin
    //     assign axon = (synapses[7]+synapses[6]+synapses[5]+synapses[4]+synapses[3]+synapses[2]+synapses[1]+synapses[0]) > bias;
    // end

endmodule
