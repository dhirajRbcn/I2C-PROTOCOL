`define SLAVE_ID 7'b1010101

module i2c_slave#(parameter AW=8, DW=8)(
	input rst_n,

	inout SDA,
	input SCL
);

	// slave ID
	localparam SLAVE_ADDRESS = `SLAVE_ID;

	// master states
	reg [3:0] state, n_state;

	localparam	IDLE='d0,
				TARGET_ADDRESS='d1,
				SEND_DATA='d2,
				RECEIVE_DATA='d3,
				MASTER_ACK='d4,
				SLAVE_ACK='d5,
				STOP='d6;

	// to handle SDA inout
	reg sda_out;
	wire slv_sda_ctrl;
	assign SDA = (slv_sda_ctrl) ? sda_out : 1'bz;
	
	reg [3:0] count; // byte count
	// reg to store SDA data
	reg addr_data;  //0: taking addr,	1: taking data
	reg [7 : 0] addr_op;
	reg [AW-1 : 0] mem_addr;
	reg [DW-1 : 0] data;
	reg [DW-1 : 0] addr;

	// slave memory
	reg [DW-1 : 0] mem [0 : (1<<AW)-1];

	// state transition
	// assign n_state to state at posedge SCL
	always @(negedge rst_n or negedge SCL) begin	
		if(!rst_n) begin
			state <= IDLE;
			n_state <= IDLE;
		//	slv_sda_ctrl <= 0;
			sda_out <= 1;
			count <= 0;
			addr_data <= 0; // ##########
			addr_op <= 0;
			mem_addr <= 0;
			data <= 0;
			addr <= 0;
		end else begin
			state <= n_state;
		end
	end

assign slv_sda_ctrl=((state == SLAVE_ACK /*&& addr_op[7:1]==`SLAVE_ID*/) || (state==SEND_DATA));

	// for going to IDLE to START because there won't be any scl toggle
	always @(SDA) begin	
		if(SCL && !SDA) begin
			//$display("%t\t[START CONDITION DETECTED]...", $time);
			state <= TARGET_ADDRESS;
			addr_data <= 0;
			count<=0;
			//$strobe("%t\tslave_mem[%b] = %b", $time, mem_addr, mem[mem_addr]);
		end
		if(SCL && SDA) begin
			//$display("%t\t[STOP CONDITION DETECTED]...", $time);
			state <= IDLE;
			count<=0;
		//	slv_sda_ctrl <= 0;
		end
	end

	// next state block
	always@(*) begin
		case(state)
			TARGET_ADDRESS: begin
				if(count==8)
					n_state = SLAVE_ACK;
				else
					n_state = TARGET_ADDRESS;
			end

			SLAVE_ACK: begin
				if(addr_op[0]) 
					n_state = SEND_DATA;
				else 
					n_state = RECEIVE_DATA;
				
			end

			MASTER_ACK: begin
				//n_state = STOP;
			end

			RECEIVE_DATA: begin
				if(count == 8)
					n_state = SLAVE_ACK;
				else
					n_state = RECEIVE_DATA;
			end
			
			SEND_DATA: begin
				if(count == 8)
					n_state = MASTER_ACK;
				else
					n_state = SEND_DATA;
			end

		endcase
	end

	// posedge to sample data send by master
	always@(posedge SCL) begin	
		case(state)
			TARGET_ADDRESS: begin
				addr_op[~count[2:0]] <= SDA;
				count <= count + 1'b1;
			end
		
			RECEIVE_DATA: begin
				if(addr_data) begin
					data[~count[2:0]] <= SDA; // just for waveform
				end else begin
					addr[~count[2:0]] <= SDA; // just for waveform
				end
				count <= count + 1'b1;
			end

			MASTER_ACK: begin
		//		slv_sda_ctrl <= 0;
			end

			SEND_DATA: begin
				count <= count + 1'b1;
			end
		endcase
	end


	// negedge to send data to master also take/give control of SDA
	always@(negedge SCL or state) begin	
		case(state)
			TARGET_ADDRESS: begin
				if(count == 8) begin
					count <= 0;
					if(addr_op[7:1]==`SLAVE_ID)
						sda_out <= 0;
				end
			end
			SLAVE_ACK: begin
			end

			RECEIVE_DATA: begin
//				slv_sda_ctrl <=0;
				if(count == 8) begin
					mem_addr<= addr;
					mem[mem_addr] <= data;
					addr_data <= ~addr_data;
					count <= 0;
					//$strobe($time,"  addr_data:%d mem_addr:%d data:%d",addr_data,mem_addr,mem[mem_addr]);
				end
			end

			MASTER_ACK: begin
//				slv_sda_ctrl <= 0;
			end

			SEND_DATA: begin
//				slv_sda_ctrl <= 1;
				sda_out <= mem[mem_addr][~count[2:0]];
				if(count == 8) begin
					count <= 0;
				end
			end

			STOP: begin
//				slv_sda_ctrl <= 0;
			end
		endcase
	end

endmodule

