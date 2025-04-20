`timescale 1ns / 1ps


// Code your testbench here
// or browse Examples
`timescale 1ns / 1ps

module tb_top_MIPS();

  reg clk;
  reg reset;
  
  // Instantiate the MIPS processor
  top_MIPS uut (
    .reset(reset),
    .clk(clk)
  );

  // Clock generation (100 MHz)
  always #5 clk = ~clk;

  // Reset and stimulus
  initial begin

    clk = 0;
    reset =1;

    $dumpfile("mips_waveform.vcd");
    $dumpvars(0, tb_top_MIPS);
    
    // Release reset after 20ns
    #20 reset = 0;
    
    // Run simulation for 200ns
    #900 $finish;
  end

endmodule