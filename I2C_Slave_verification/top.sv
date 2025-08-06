
`define DW 8;
`define AW 8;
`include "uvm_macros.svh"
import uvm_pkg::*;

package cfg;
	bit clk_100khz;
    int bytes;			//number of packets to transfer [combination of mem_addr and mem_data is 1 packet]
	int temp_addr[$];
	bit rep_start;		//to control repeated start condition	
endpackage

import cfg::*;

`include "include_files.svh"
module toptestbench;

    //clock and reset signal declaration
	logic reset = 0;
    bit clk;
	
	//clock_genration gen(clk,50); //2nd argument is duty cycle in percentage
	always #5 clk=~clk;
    
	//creatinng instance of interface, inorder to connect DUT and testcase
    dut_inf inf(clk,reset);
	pullup(inf.scl);
	pullup(inf.sda);
	

    //reset Generation
    initial begin
		reset=0; inf.mst_sda_ctrl=0;
	    #5 reset=1;		
    end
	 
    //DUT instance, interface signals are connected to the DUT ports
	i2c_slave #(8, 8) dut (.rst_n(inf.reset),
		.SCL(inf.scl),
		.SDA(inf.sda));
    //enabling the wave dump

	initial begin
  		uvm_config_db#(virtual dut_inf)::set(null,"*","v_inf",inf);
		run_test();
	end

endmodule
