module ram_data(
	clock,
	index,
	offset,
	data_in,
	data_out,
	write
);
	input  clock;
	input  [`IDX-1:0] index;
	input  [`OFS-1:0] offset;
	input  [`BLK-1:0] data_in;
	output [`WOR-1:0] data_out;
	input  write;

	reg [`WOR-1:0] data_out;
	reg [`BLK-1:0] data_ram [`DEP-1:0];

	always@(negedge clock)begin
		if(write) data_ram[index]<= data_in;
	end
	always@(posedge clock)begin
		data_out<=( (data_ram[index]>>(offset*32))&(32'hFFFF_FFFF) );
	end
endmodule