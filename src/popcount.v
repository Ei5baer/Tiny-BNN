
module popcount #(
    parameter INPUTS = 8,
    parameter COUNTER_BITS = 4
) (
    input [INPUTS-1:0] in,
    output reg [COUNTER_BITS-1:0] count
);
    integer i;
    always @(*) begin
        if (INPUTS == 4) begin
            count =                                 in[3] + in[2] + in[1] + in[0];
        end else if (INPUTS == 8) begin
            count = in[7] + in[6] + in[5] + in[4] + in[3] + in[2] + in[1] + in[0];
        end else if (INPUTS == 10) begin
            count =                                                 in[9] + in[8] +
                    in[7] + in[6] + in[5] + in[4] + in[3] + in[2] + in[1] + in[0];
        end else if (INPUTS == 16) begin
            count = in[15]+in[14] +in[13] +in[12] +in[11] +in[10] + in[9] + in[8] +
                    in[7] + in[6] + in[5] + in[4] + in[3] + in[2] + in[1] + in[0];
        end else begin
            count = 0;
            for  (i = 0; i < INPUTS; i = i + 1) begin
                count = count + in[i];
            end
        end
    end

endmodule

module popcount_and_threshold #(
    parameter INPUTS = 8,
    parameter THRESHOLD_BITS = 3
) (
    input [INPUTS-1:0] in,
    input [THRESHOLD_BITS-1:0] threshold,
    output reg out
);
    integer i;
    always @(*) begin
        if (INPUTS == 4) begin
            out =                                  (in[3] + in[2] + in[1] + in[0]) > threshold;
        end else if (INPUTS == 8) begin
            out =  (in[7] + in[6] + in[5] + in[4] + in[3] + in[2] + in[1] + in[0]) > threshold;
        end else if (INPUTS == 10) begin
            out =                                                  (in[9] + in[8] +
                    in[7] + in[6] + in[5] + in[4] + in[3] + in[2] + in[1] + in[0]) > threshold;
        end else if (INPUTS == 16) begin
            out =  (in[15]+in[14] +in[13] +in[12] +in[11] +in[10] + in[9] + in[8] +
                    in[7] + in[6] + in[5] + in[4] + in[3] + in[2] + in[1] + in[0]) > threshold;
        end else begin
            localparam COUNTER_BITS = $clog2(INPUTS) + 1;
            reg [COUNTER_BITS-1:0] count;

            count = 0;
            for  (i = 0; i < INPUTS; i = i + 1) begin
                count = count + in[i];
            end
            out = count > threshold;
        end
    end

endmodule

module popcount_and_mask #(
    parameter INPUTS = 8,
    parameter MASK_BITS = 3
) (
    input [INPUTS-1:0] in,
    input [MASK_BITS-1:0] mask,
    output reg out
);
    integer i;
    always @(*) begin
        if (INPUTS == 4) begin
            out = |(                                (in[3] + in[2] + in[1] + in[0]) & mask);
        end else if (INPUTS == 8) begin
            out = |((in[7] + in[6] + in[5] + in[4] + in[3] + in[2] + in[1] + in[0]) & mask);
        end else if (INPUTS == 10) begin
            out = |(                                                (in[9] + in[8] +
                     in[7] + in[6] + in[5] + in[4] + in[3] + in[2] + in[1] + in[0]) & mask);
        end else if (INPUTS == 16) begin
            out = |((in[15]+in[14] +in[13] +in[12] +in[11] +in[10] + in[9] + in[8] +
                     in[7] + in[6] + in[5] + in[4] + in[3] + in[2] + in[1] + in[0]) & mask);
        end else begin
            localparam COUNTER_BITS = $clog2(INPUTS) + 1;
            reg [COUNTER_BITS-1:0] count;

            count = 0;
            for  (i = 0; i < INPUTS; i = i + 1) begin
                count = count + in[i];
            end
            out = |(count & mask);
        end
    end

endmodule
