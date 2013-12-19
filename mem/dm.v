`define WAIT_STATE 2
`define WS `WAIT_STATE
module dm(
	clock,
	reset,
	DM_read,
	DM_write,
	DM_enable,
	DM_address,
	DM_in,
	DM_out,
	DM_ack,
	DM_ready
);
	parameter data_size=32;
	parameter mem_size=4096;
	parameter mem_size_bit=12;

	input clock;
	input reset;
	input DM_read;
	input DM_write;
	input DM_enable;
	input [mem_size_bit-1:0] DM_address;
	input [data_size-1:0] DM_in;
	output [data_size-1:0] DM_out;
	output DM_ack;
	output DM_ready;

	reg [data_size-1:0] DM_out;
	reg DM_ack;
	reg DM_ready;

	reg [data_size-1:0] mem_data[mem_size-1:0];

	reg REG_DM_enable [`WAIT_STATE:0];
	reg REG_DM_read   [`WAIT_STATE:0];
	reg REG_DM_write  [`WAIT_STATE:0];
	reg [31:0] REG_DM_address [`WAIT_STATE:0];
	reg [31:0] REG_DM_data    [`WAIT_STATE:0];

	reg [31:0] DM_base_address;
	reg [3:0] counter;
	reg start;
	integer i;
	always@(negedge clock)begin
		REG_DM_enable[0] <=DM_enable;
		REG_DM_read[0]   <=DM_read;
		REG_DM_write[0]  <=DM_write;
		REG_DM_address[0]<=DM_address;
		REG_DM_data[0]   <=DM_in;

		for(i=0;i<`WAIT_STATE;i=i+1) REG_DM_enable[i+1] <=REG_DM_enable[i];
		for(i=0;i<`WAIT_STATE;i=i+1) REG_DM_read[i+1]   <=REG_DM_read[i];
		for(i=0;i<`WAIT_STATE;i=i+1) REG_DM_write[i+1]  <=REG_DM_write[i];
		for(i=0;i<`WAIT_STATE;i=i+1) REG_DM_address[i+1]<=REG_DM_address[i];
		for(i=0;i<`WAIT_STATE;i=i+1) REG_DM_data[i+1]   <=REG_DM_data[i];
	end

	always@(posedge clock)begin
		if(reset)begin
			for(i=0;i<mem_size;i=i+1)begin
				mem_data[i]<=0;
				DM_out<=0;
				DM_ready<=1'b1;
			end
		end
		else begin
			if(DM_enable&&DM_read)begin
				DM_ready<=1'b0;
				start<=1'b0;
			end
			if(REG_DM_enable[`WS])begin
				if(REG_DM_read[`WS])begin
					counter<=4'b1;
					start<=1'b1;
					DM_base_address<=REG_DM_address[`WS]&32'hffff_fff0;
					DM_out<=mem_data[( (REG_DM_address[`WS]&32'hffff_fff0)/4)];
					DM_ack<=1'b1;
				end
				else if(REG_DM_write[`WS])begin
					mem_data[(REG_DM_address[`WS]/4)] <= REG_DM_data[`WS];
				end
			end
		end
	end
	always@(posedge clock)begin
		if(start)begin
			if(counter)begin
				DM_out<=mem_data[( (DM_base_address+4*counter)/4)];
				counter<=counter+4'b1;
				if(counter==4'b1111) begin
					DM_ready<=1'b1;
				end
				DM_ack<=1'b1;
			end
			else begin
				DM_ack<=1'b0;
				start<=1'b0;
			end
		end
	end
endmodule
