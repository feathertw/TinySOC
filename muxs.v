module muxs(
	sub_op_sv,
	read_reg_data2,
	mem_read_data,
	alu_output,
	imm_5bit,
	imm_15bit,
	imm_20bit,

	imm_reg_select,
	imm_extend_select,
	write_reg_select,

	output_imm_reg_mux,
	write_reg_data,
);

	parameter DataSize = 32;

	input [1:0] sub_op_sv;
	input [DataSize-1:0] read_reg_data2;
	input [DataSize-1:0] mem_read_data;
	input [DataSize-1:0] alu_output;
	input [4:0] imm_5bit;
	input [14:0] imm_15bit;
	input [19:0] imm_20bit;

	input [1:0] imm_extend_select;
	input [1:0] write_reg_select;
	input [1:0] imm_reg_select;

	output reg [DataSize-1:0] output_imm_reg_mux;
	output reg [DataSize-1:0] write_reg_data;
	
	reg [DataSize-1:0] imm;

	always @(*) begin
		case(imm_extend_select)
			2'b00: begin //5bit ZE
				imm={ {27{1'b0}}, imm_5bit };
			end
			2'b01: begin //15bit SE
				imm={ {17{imm_15bit[14]}}, {imm_15bit} };
			end
			2'b10: begin //15bit ZE
				imm={ {17{1'b0}}, {imm_15bit} };
			end
			2'b11: begin //20bit SE
				imm={ {12{imm_20bit[19]}}, {imm_20bit} };
			end
		endcase
	end

	always @(*) begin
		case(imm_reg_select)
			2'b00: begin
				output_imm_reg_mux = read_reg_data2;
			end
			2'b01: begin
				output_imm_reg_mux = imm;
			end
			2'b10: begin
				output_imm_reg_mux = imm_15bit<<2; 
			end
			2'b11: begin
				output_imm_reg_mux = read_reg_data2<<sub_op_sv;
			end
		endcase
	end

	always @(*) begin
		case(write_reg_select)
			2'b00: begin
				write_reg_data = alu_output;
			end
			2'b01: begin
				write_reg_data = output_imm_reg_mux;
			end
			2'b10: begin
				write_reg_data = mem_read_data;
			end
		endcase
	end
endmodule

