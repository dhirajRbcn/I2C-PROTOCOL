`timescale 1ns/100ps
module clock_genration (output bit clk, input integer duty_cycle);

	always begin
		clk=1;
		#(`CYCLE*(duty_cycle/100)); 
		clk=0;
		#(`CYCLE*((100-duty_cycle)/100)); 
	end
		
endmodule
