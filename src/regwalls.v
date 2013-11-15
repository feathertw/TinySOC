module regwalls(
	clock,
	iREG1_instruction,
	oREG1_instruction,

	iREG2_reg_ra_data,
	iREG2_reg_rt_data,
	oREG2_reg_ra_data,
	oREG2_reg_rt_data,

	iREG2_opcode,
	iREG2_sub_op_base,
	iREG2_sub_op_ls,
	oREG2_opcode,
	oREG2_sub_op_base,
	oREG2_sub_op_ls,

	iREG2_imm_14bit,
	iREG2_imm_24bit,
	iREG2_select_pc,
	iREG2_select_write_reg,
	oREG2_imm_14bit,
	oREG2_imm_24bit,
	oREG2_select_pc,
	oREG2_select_write_reg,

	iREG2_do_im_read,
	iREG2_do_im_write,
	iREG2_do_dm_read,
	iREG2_do_dm_write,
	iREG2_do_reg_write,
	oREG2_do_im_read,
	oREG2_do_im_write,
	oREG2_do_dm_read,
	oREG2_do_dm_write,
	oREG2_do_reg_write,

	iREG2_alu_src2,
	oREG2_alu_src2
);
	input  clock;

	input  [31:0] iREG1_instruction;
	output [31:0] oREG1_instruction;
	reg    [31:0] oREG1_instruction;

	//regfile
	input  [31:0] iREG2_reg_ra_data;
	input  [31:0] iREG2_reg_rt_data;
	output [31:0] oREG2_reg_ra_data;
	output [31:0] oREG2_reg_rt_data;
	reg    [31:0] oREG2_reg_ra_data;
	reg    [31:0] oREG2_reg_rt_data;

	//controller
	input  [ 5:0] iREG2_opcode;
	input  [ 4:0] iREG2_sub_op_base;
	input  [ 7:0] iREG2_sub_op_ls;
	output [ 5:0] oREG2_opcode;
	output [ 4:0] oREG2_sub_op_base;
	output [ 7:0] oREG2_sub_op_ls;
	reg    [ 5:0] oREG2_opcode;
	reg    [ 4:0] oREG2_sub_op_base;
	reg    [ 7:0] oREG2_sub_op_ls;

	input  [13:0] iREG2_imm_14bit;
	input  [23:0] iREG2_imm_24bit;
	input  [ 1:0] iREG2_select_pc;
	input  [ 1:0] iREG2_select_write_reg;
	output [13:0] oREG2_imm_14bit;
	output [23:0] oREG2_imm_24bit;
	output [ 1:0] oREG2_select_pc;
	output [ 1:0] oREG2_select_write_reg;
	reg    [13:0] oREG2_imm_14bit;
	reg    [23:0] oREG2_imm_24bit;
	reg    [ 1:0] oREG2_select_pc;
	reg    [ 1:0] oREG2_select_write_reg;

	input  iREG2_do_im_read;
	input  iREG2_do_im_write;
	input  iREG2_do_dm_read;
	input  iREG2_do_dm_write;
	input  iREG2_do_reg_write;
	output oREG2_do_im_read;
	output oREG2_do_im_write;
	output oREG2_do_dm_read;
	output oREG2_do_dm_write;
	output oREG2_do_reg_write;
	reg    oREG2_do_im_read;
	reg    oREG2_do_im_write;
	reg    oREG2_do_dm_read;
	reg    oREG2_do_dm_write;
	reg    oREG2_do_reg_write;

	//muxs
	input  [31:0] iREG2_alu_src2;
	output [31:0] oREG2_alu_src2;
	reg    [31:0] oREG2_alu_src2;

	always@(negedge clock)begin
		oREG1_instruction<=iREG1_instruction;

		oREG2_reg_ra_data<=iREG2_reg_ra_data;
		oREG2_reg_rt_data<=iREG2_reg_rt_data;
		oREG2_opcode     <=iREG2_opcode;
		oREG2_sub_op_base<=iREG2_sub_op_base;
		oREG2_sub_op_ls  <=iREG2_sub_op_ls;

		oREG2_imm_14bit       <=iREG2_imm_14bit;
		oREG2_imm_24bit       <=iREG2_imm_24bit;
		oREG2_select_pc       <=iREG2_select_pc;
		oREG2_select_write_reg<=iREG2_select_write_reg;

		oREG2_do_im_read      <=iREG2_do_im_read;
		oREG2_do_im_write     <=iREG2_do_im_write;
		oREG2_do_dm_read      <=iREG2_do_dm_read;
		oREG2_do_dm_write     <=iREG2_do_dm_write;
		oREG2_do_reg_write    <=iREG2_do_reg_write;

		oREG2_alu_src2        <=iREG2_alu_src2;
	end
endmodule