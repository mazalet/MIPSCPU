module NumExpansion(
input [15:0] Imm,
input [1:0] Ex_top,
output [31:0] Immediate32
);

wire [31:0]Imm_ex;
assign Imm_ex = {((Ex_top[0] == 0)?{16{Imm[15]}}:16'b0),Imm};
assign Immediate32 = (Ex_top[1] == 1)?({Imm,16'b0}):(Imm_ex);

endmodule
