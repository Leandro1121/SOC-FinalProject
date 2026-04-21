module vde_and (
    input  wire hsync_in,
    input  wire vsync_in,
    output wire vde_out
);
    assign vde_out = hsync_in & vsync_in;
endmodule
