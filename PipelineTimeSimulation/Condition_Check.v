module MUX8_1_Icontrol(Sel,S0,S1,S2,S3,S4,S5,S6,S7,out);

input [2:0] Sel;
input S0,S1,S2,S3,S4,S5,S6,S7;
output out;

assign out = (Sel[2])? (Sel[1]?(Sel[0]?S7:S6) : (Sel[0]?S5:S4))  :  (Sel[1]?(Sel[0]?S3:S2) : (Sel[0]?S1:S0));

endmodule

module MUX8_1_SL(Sel,Write_Byte_En,S0,S1,S2,S3,S4,S5,S6,S7,out);

input [3:0] Sel;
input [3:0] Write_Byte_En;
input [3:0] S0,S1,S2,S3,S4,S5,S6,S7;
output [3:0] out;

assign out = (Sel[3])?Write_Byte_En:((Sel[2])? (Sel[1]?(Sel[0]?S7:S6) : (Sel[0]?S5:S4))  :  (Sel[1]?(Sel[0]?S3:S2) : (Sel[0]?S1:S0)));
//assign out = (Sel[2])? (Sel[1]?(Sel[0]?S7:S6) : (Sel[0]?S5:S4))  :  (Sel[1]?(Sel[0]?S3:S2) : (Sel[0]?S1:S0));

endmodule

module MUX4_1_SL(Sel,S0,S1,S2,S3,out);

input [1:0] Sel;
input [3:0] S0,S1,S2,S3;
output [3:0]out;

assign out = (Sel[1]?(Sel[0]?S3:S2) : (Sel[0]?S1:S0));

endmodule


module Condition_Check(
input [2:0] Condition,PC_Write,
input [1:0] addr, 
input MemWBSrc,
input OverflowEn,Branch,Overflow,
input [3:0] Mem_Byte_Write,
input [3:0] Rd_Write_Byte_en,
input Less,Zero,

output BranchValid,
output [3:0] RdWriteEn,
output [3:0] MemWriteEn
);

wire[1:0] Right;
wire Load,Store;
wire [3:0] LoadOut,StoreOut;
//110-right-01   010-left-00   other-10 
assign Right = (PC_Write == 3'b110 ?2'b01:(PC_Write == 3'b010)?2'b00:2'b10);
//assign StoreRight = (PC_Write == 3'b110 ?1'b1:1'b0);
assign Load = (MemWBSrc == 1'b1)?1'b1:1'b0;
assign Store = (Mem_Byte_Write == 4'b1111);


MUX8_1_SL sl1({Right,addr[1:0]},Rd_Write_Byte_en,4'b1111,4'b1110,4'b1100,4'b1000,4'b0001,4'b0011,4'b0111,4'b1111,LoadOut);
MUX8_1_SL sl2({Right,addr[1:0]},Mem_Byte_Write,4'b1111,4'b0111,4'b0011,4'b0001,4'b1000,4'b1100,4'b1110,4'b1111,StoreOut);


wire condition_out;
MUX8_1_Icontrol MUX_Con(Condition,1'b0,Zero,!Zero,!Less,!(Less^Zero),Less^Zero,Less,1'b1,condition_out);
assign BranchValid = condition_out & Branch;
assign RdWriteEn = (Load === 1'b1)?LoadOut:((OverflowEn == 0)?(Rd_Write_Byte_en):((Overflow == 1'b0)?(4'b1111):(4'b0000)));

assign MemWriteEn = (Store === 1'b1) ? StoreOut:4'b0000;

endmodule
