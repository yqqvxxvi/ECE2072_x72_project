module binary_to_bcd(
    input [15:0] binary,
    output reg [3:0] ten_thousands,
    output reg [3:0] thousands,
    output reg [3:0] hundreds,
    output reg [3:0] tens,
    output reg [3:0] ones
);

    reg [15:0] binary_value;

    always @(*) begin
        binary_value = binary;

        // Initialize BCD digits
        ten_thousands = 4'd0;
        thousands = 4'd0;
        hundreds = 4'd0;
        tens = 4'd0;
        ones = 4'd0;

        // Compute ten_thousands digit
        if (binary_value >= 16'd10000) begin
            ten_thousands = binary_value / 16'd10000;
            binary_value = binary_value % 16'd10000;
        end

        // Compute thousands digit
        if (binary_value >= 16'd1000) begin
            thousands = binary_value / 16'd1000;
            binary_value = binary_value % 16'd1000;
        end

        // Compute hundreds digit
        if (binary_value >= 16'd100) begin
            hundreds = binary_value / 16'd100;
            binary_value = binary_value % 16'd100;
        end

        // Compute tens digit
        if (binary_value >= 16'd10) begin
            tens = binary_value / 16'd10;
            binary_value = binary_value % 16'd10;
        end

        // Remaining value is ones digit
        ones = binary_value;
    end

endmodule
