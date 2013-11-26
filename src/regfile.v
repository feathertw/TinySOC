module regfile(
	clock,
	reset,
	enable_reg_fetch,
	enable_reg_write,

	reg_ra_addr,
	reg_rb_addr,
	reg_rt_addr,
	write_reg_addr,
	write_reg_data,
	do_reg_write,

	reg_rt_ra_equal,
	reg_ra_data,
	reg_rb_data,
	reg_rt_data
);

	parameter DataSize = 32;
	parameter AddrSize = 5;

	input clock;
	input reset;
	input enable_reg_fetch; 
	input enable_reg_write;

	input [AddrSize-1:0] reg_ra_addr;
	input [AddrSize-1:0] reg_rb_addr;
	input [AddrSize-1:0] reg_rt_addr;
	input [AddrSize-1:0] write_reg_addr;
	input [DataSize-1:0] write_reg_data;
	input do_reg_write;

	output reg_rt_ra_equal;
	output [DataSize-1:0] reg_ra_data;
	output [DataSize-1:0] reg_rb_data;
	output [DataSize-1:0] reg_rt_data;

	reg [DataSize-1:0] reg_ra_data;
	reg [DataSize-1:0] reg_rb_data;

	reg [DataSize-1:0] rw_reg [31:0];
	integer i;

	assign reg_rt_ra_equal=(reg_rt_data==reg_ra_data)?1'b1:1'b0;
	assign reg_rt_data = rw_reg[reg_rt_addr];

	always @(posedge clock or posedge reset) begin
		if(reset) begin
			for(i=0;i<32;i=i+1)
				rw_reg[i]<=32'b0;
		end
		else begin
			if(enable_reg_fetch) begin
				reg_ra_data <= rw_reg[reg_ra_addr];
				reg_rb_data <= rw_reg[reg_rb_addr];
			end
			if(enable_reg_write && do_reg_write) begin
				rw_reg[write_reg_addr] <= write_reg_data;
			end
		end
	end
endmodule	
	
