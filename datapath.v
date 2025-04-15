//Datapath
module MIPS_datapath(
  input clk,
  input reset,
  
  //From MIPS controller
  input RegDst,
  input Jump,
  input Branch,
  input MemRead,
  input MemToReg,
//   input ALUOp, //this is from MIPS controller to ALU controller
  input MemWrite, 
  input ALUSrc,
  input RegWrite,
  input Link,
  input PC_en,
  
  //From ALU controller
  input [3:0] ALU_opcode, //4bits, 1 bit is for binvert
  
  
  output wire [5:0] OpCode //To controller
);
  
  
  // Instruction Mem and Operand Decode
  wire [31:0] PC_out, instr_out;
  instr_mem Intruction_Memory(.read_address(PC_out), .instruction(instr_out));
  
  assign OpCode = instr_out[31:26];
  
  // Instruction fields
  wire [4:0] rs = instr_out[25:21];
  wire [4:0] rt = instr_out[20:16];
  wire [4:0] rd = instr_out[15:11];
  wire [15:0] immediate = instr_out[15:0];
  wire [25:0] jump_target = instr_out[25:0];
  
  //------------------------------------------------------------------------  
  // PC
  wire [31:0] PC_plus4, PC_next;
  wire ALU_zero;
  
  PC Program_Counter(.clk(clk), .reset(reset), .en(PC_en), .inp(PC_next), .out(PC_out));
  
  //PC+4
  adder PC_plus4_adder(.a(PC_out), .b(32'd4), .y(PC_plus4));
  
  // Jump address calc //////////////////////////////////////////////////////////////////////////
  wire [28:0] jump_target_shifted;
  sll_2_pad #(.INP_WIDTH(26)) Shift_Jump_2(.in(jump_target), .out(jump_target_shifted));
  wire [31:0] jump_addr = {PC_plus4[31:28], jump_target_shifted};
  
  // Immediate address calc
  wire [31:0] sign_ext_imm;
  sign_extend Sign_Extender(.in(immediate), .out(sign_ext_imm));
  
  wire [31:0] shifted_imm;
  sll_2_same Shift_Imm_2(.in(sign_ext_imm), .out(shifted_imm));
  
  wire [31:0] branch_addr;
  adder Branch_Adder(.a(PC_plus4), .b(shifted_imm), .y(branch_addr));
  
  // Branch instr or PC+4
  wire branch_taken = Branch & ALU_zero;
  wire [31:0] PC_branch_mux_out;
  mux2to1 #(.WIDTH(32)) PC_branch_mux(
    .in0(PC_plus4),
    .in1(branch_addr),
    .sel(branch_taken),
    .out(PC_branch_mux_out)
  );
  
  // whether Jump instr
  mux2to1 #(.WIDTH(32)) PC_jump_mux(
    .in0(PC_branch_mux_out),
    .in1(jump_addr),
    .sel(Jump),
    .out(PC_next)
  );
  
  //---------------------------------------------------------------------------------------
  
  // Registers
  wire [4:0] write_reg_intermediate, write_reg_final;
  wire [31:0] write_data;
  wire [31:0] reg_read_data1, reg_read_data2;
  
  // R-type or I-type instr
  mux2to1 #(.WIDTH(5)) write_reg_mux(
    .in0(rt), 
    .in1(rd), 
    .sel(RegDst), 
    .out(write_reg_intermediate)
  );
  // if Jump and Link
  mux2to1 #(.WIDTH(5)) link_reg_mux(
    .in0(write_reg_intermediate), 
    .in1(5'd31), // reg $ra
    .sel(Link), 
    .out(write_reg_final)
  );
  
  reg_file Registers(
    .clk(clk),
    .reset(reset),
    .write_en(RegWrite),
    .read_reg1(rs),
    .read_reg2(rt),
    .write_reg(write_reg_final),
    .write_data(write_data),
    .read_data1(reg_read_data1),
    .read_data2(reg_read_data2)
  );
  
  
  // ------------------------------------------------------------------------
  
  //ALU
  wire [31:0] ALU_in2;
  wire [31:0] ALU_result;
  
  //computing reg w/ immediate or reg w/ reg
  mux2to1 #(.WIDTH(32)) ALU_src_mux(
    .in0(reg_read_data2),
    .in1(sign_ext_imm),
    .sel(ALUSrc),
    .out(ALU_in2)
  );
  
  ALU Arithmetic_Logic_Unit(
    .a(reg_read_data1),
    .b(ALU_in2),
    .op(ALU_opcode),
    .result(ALU_result),
    .zero(ALU_zero)
  );
  
  // ------------------------------------------------------------------------
  
  
  
  // Data Mem and Write Back
  wire [31:0] mem_read_data;
  data_mem Data_Memory(
    .clk(clk),
    .write_en(MemWrite),
    .read_en(MemRead),
    .address(ALU_result),
    .write_data(reg_read_data2),
    .read_data(mem_read_data)
  );
  
  //load instr or addi instr
  wire [31:0] wb_data;
  mux2to1 #(.WIDTH(32)) wb_mux(
    .in0(ALU_result),
    .in1(mem_read_data),
    .sel(MemToReg),
    .out(wb_data)
  );
  
  //whether to write back PC+4 to $ra
  mux2to1 #(.WIDTH(32)) link_data_mux(
    .in0(wb_data),
    .in1(PC_plus4),
    .sel(Link),
    .out(write_data)
  );
  
endmodule