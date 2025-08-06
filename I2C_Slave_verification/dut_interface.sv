interface dut_inf(input bit clk,input bit reset);
	
	wire scl;
	wire sda;
	
	logic mst_sda_ctrl;
	logic hold_scl_high=0;
	logic scl_drv=0;
	logic sda_out = 0; 
	logic [7:0] data_write;
	logic [7:0] data_read;	

	assign sda = mst_sda_ctrl ? sda_out : 'bz;
	assign scl = scl_drv ? hold_scl_high ? 1'b1 : cfg::clk_100khz : 'bz;

	int counter;
	always @(posedge clk) begin
		if(inf.scl_drv) begin
			if (counter == 499) begin
				counter <= 0;
				clk_100khz <= ~clk_100khz;
			end else begin
				counter = counter + 1;
			end
		end else begin
			counter = 0;
			clk_100khz=1;
		end
	end

endinterface
