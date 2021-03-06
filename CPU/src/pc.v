`include "def_opcode.v"
`include "def_muxs.v"
module pc(
	clock,
	reset,
	enable_pc,
	current_pc,
	target_pc,
	do_branch,

	opcode,
	sub_op_b,
	sub_op_bz,
	reg_rt_ra_equal,
	reg_rt_zero,
	reg_rt_negative,

	imm_14bit,
	imm_16bit,
	imm_24bit,
	reg_rb_data,

	do_flush_REG1,
	do_hazard,

	xREG1_do_jcache,
	jcache_pc,
	do_jcache,

	xREG1_bcache_opc,
	xREG1_do_bcache,
	bcache_pc,
	do_bcache,

	do_halt_pc,
	do_interrupt,
	interrupt_pc,
	do_it_load_pc,
	it_return_pc
);
	input clock;
	input reset;
	input enable_pc;
	output [31:0] current_pc;
	output [31:0] target_pc;
	output do_branch;

	input [5:0] opcode;
	input sub_op_b;
	input [3:0] sub_op_bz;
	input reg_rt_ra_equal;
	input reg_rt_zero;
	input reg_rt_negative;

	input [13:0] imm_14bit;
	input [15:0] imm_16bit;
	input [23:0] imm_24bit;
	input [31:0] reg_rb_data;

	output do_flush_REG1;
	input  do_hazard;

	input xREG1_do_jcache;
	input [31:0] jcache_pc;
	input do_jcache;

	input [31:0] xREG1_bcache_opc;
	input xREG1_do_bcache;
	input [31:0] bcache_pc;
	input do_bcache;

	input  do_halt_pc;
	input  do_interrupt;
	input  [31:0] interrupt_pc;
	input  do_it_load_pc;
	input  [31:0] it_return_pc;

	reg [31:0] current_pc;
	reg [31:0] next_pc;
	reg [31:0] target_pc;
	reg [ 2:0] select_pc;

	reg  do_flush_REG1_pc;
	wire do_flush_REG1_bcache=(xREG1_do_bcache)&&(!do_branch);
	wire do_flush_REG1=do_flush_REG1_pc||do_flush_REG1_bcache;

	wire [ 2:0] final_select_pc=( (xREG1_do_jcache)||(xREG1_do_bcache&&do_branch) )? `PC_4:select_pc;

	wire do_branch=(select_pc==`PC_14BIT||select_pc==`PC_16BIT);

	always@(negedge clock) begin
		if(reset) 	      current_pc<=32'b0;
		else if(enable_pc)begin
			if(do_it_load_pc)     current_pc<=it_return_pc;
			else if(do_interrupt) current_pc<=interrupt_pc;
			else if(do_hazard)    current_pc<=current_pc;
			else if(final_select_pc==`PC_4&&do_jcache) current_pc<=jcache_pc;
			else if(final_select_pc==`PC_4&&do_bcache&&!do_halt_pc) current_pc<=bcache_pc;
			else if( (xREG1_do_bcache)&&(!do_branch) ) current_pc<=xREG1_bcache_opc+4;
			else if(final_select_pc!=`PC_4) current_pc<=next_pc;
			else if(do_halt_pc)   	  current_pc<=current_pc;
			else		      	  current_pc<=next_pc;
		end
	end

	always@(opcode or sub_op_b or sub_op_bz or reg_rt_ra_equal or reg_rt_zero or reg_rt_negative) begin
		case(opcode)
			`TY_B:begin
				if(      (sub_op_b==`BEQ)&&( reg_rt_ra_equal) ) select_pc=`PC_14BIT;
				else if( (sub_op_b==`BNE)&&(!reg_rt_ra_equal) ) select_pc=`PC_14BIT;
				else					 	select_pc=`PC_4;
			end
			`TY_BZ:begin
				if(      (sub_op_bz==`BEQZ)&&(reg_rt_zero) ) 		      select_pc=`PC_16BIT;
				else if( (sub_op_bz==`BGEZ)&&(!reg_rt_negative) ) 	      select_pc=`PC_16BIT;
				else if( (sub_op_bz==`BGTZ)&&((!reg_rt_zero)&&(!reg_rt_negative)) )select_pc=`PC_16BIT;
				else if( (sub_op_bz==`BLEZ)&&(reg_rt_zero||reg_rt_negative) ) select_pc=`PC_16BIT;
				else if( (sub_op_bz==`BLTZ)&&(reg_rt_negative) )	      select_pc=`PC_16BIT;
				else if( (sub_op_bz==`BNEZ)&&(!reg_rt_zero) )		      select_pc=`PC_16BIT;
				else							      select_pc=`PC_4;
			end
			`TY_J:begin
				select_pc=`PC_24BIT;
			end
			`TY_JR:begin
				select_pc=`PC_REGISTER;
			end
			default:begin
				select_pc=`PC_4;
			end
		endcase
	end

	always @(final_select_pc or current_pc or target_pc or imm_14bit or imm_16bit or imm_24bit or reg_rb_data) begin
		case(final_select_pc)
			`PC_4:begin
				next_pc=current_pc+4;
				do_flush_REG1_pc=1'b0;
			end
			`PC_14BIT:begin
				next_pc=target_pc;
				do_flush_REG1_pc=1'b1;
			end
			`PC_16BIT:begin
				next_pc=target_pc;
				do_flush_REG1_pc=1'b1;
			end
			`PC_24BIT:begin
				next_pc=target_pc;
				do_flush_REG1_pc=1'b1;
			end
			`PC_REGISTER:begin
				next_pc=reg_rb_data;
				do_flush_REG1_pc=1'b1;
			end
			default:begin
				next_pc='bx;
				do_flush_REG1_pc=1'b0;
			end
		endcase
	end

	always@(opcode or current_pc or imm_14bit or imm_16bit or imm_24bit)begin
		case(opcode)
			`TY_B:   target_pc=(current_pc-4)+({ {17{imm_14bit[13]}},imm_14bit,1'b0});
			`TY_BZ:  target_pc=(current_pc-4)+({ {15{imm_16bit[15]}},imm_16bit,1'b0});
			`TY_J:   target_pc=(current_pc-4)+({ { 7{imm_24bit[23]}},imm_24bit,1'b0});
			default: target_pc='bx;
		endcase
	end
endmodule
