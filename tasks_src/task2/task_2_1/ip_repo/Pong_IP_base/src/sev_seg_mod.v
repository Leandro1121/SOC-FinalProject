module sev_seg_mod (
 input [3:0] digit_value,
 output reg [6:0] sev_seg
 );

always @(*) begin
	case (digit_value)
		4'd0: sev_seg = 7'b1000000;
		4'd1: sev_seg = 7'b1111001;
		4'd2: sev_seg = 7'b0100100;
		4'd3: sev_seg = 7'b0110000;
		4'd4: sev_seg = 7'b0011001;
		4'd5: sev_seg = 7'b0010010;
		4'd6: sev_seg = 7'b0000010;
		4'd7: sev_seg = 7'b1111000;
		4'd8: sev_seg = 7'b0000000;
		4'd9: sev_seg = 7'b0010000;
		default: sev_seg = 7'b1111111;
	endcase
end

endmodule
