module mux2to1 #(parameter WIDTH = 32) (
  input [WIDTH-1:0] in0,
  input [WIDTH-1:0] in1,
  input sel,
  output [WIDTH-1:0] out
);
endmodule

module PC (
  input clk,
  input reset,
  input en,
  input [31:0] inp,
  output reg [31:0] out
);
endmodule

module adder (
  input [31:0] a,
  input [31:0] b,
  output [31:0] y
);
endmodule

module instr_mem (
  input [31:0] read_address,
  output [31:0] instruction
);
endmodule

module reg_file (
  input clk,
  input reset,
  input write_en,
  input [4:0] read_reg1,
  input [4:0] read_reg2,
  input [4:0] write_reg,
  input [31:0] write_data,
  output [31:0] read_data1,
  output [31:0] read_data2
);
endmodule

module sign_extend (
  input [15:0] in,
  output [31:0] out
);
endmodule

module sll_2_same (
  input [31:0] in,
  output [31:0] out
);
endmodule

module sll_2_pad #(INP_WIDTH=26) (
  input [INP_WIDTH-1:0] in,
  output [INP_WIDTH+1:0] out
);
endmodule
re
module ALU (
  input [31:0] a,
  input [31:0] b,
  input [3:0] op,
  output [31:0] result,
  output zero
);
endmodule

module data_mem (
  input clk,
  input write_en,
  input read_en,
  input [31:0] address,
  input [31:0] write_data,
  output [31:0] read_data
);
endmodule
