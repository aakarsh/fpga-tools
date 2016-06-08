`timescale 1ns/1ps

module GP_2LUT(input IN0, IN1, output OUT);
	parameter [3:0] INIT = 0;
	assign OUT = INIT[{IN1, IN0}];
endmodule

module GP_3LUT(input IN0, IN1, IN2, output OUT);
	parameter [7:0] INIT = 0;
	assign OUT = INIT[{IN2, IN1, IN0}];
endmodule

module GP_4LUT(input IN0, IN1, IN2, IN3, output OUT);
	parameter [15:0] INIT = 0;
	assign OUT = INIT[{IN3, IN2, IN1, IN0}];
endmodule

module GP_ABUF(input wire IN, output wire OUT);
	
	assign OUT = IN;
	
	//cannot simulate mixed signal IP
	
endmodule

module GP_ACMP(input wire PWREN, input wire VIN, input wire VREF, output reg OUT);

	parameter BANDWIDTH = "HIGH";
	parameter VIN_ATTEN = 1;
	parameter VIN_ISRC_EN = 0;
	parameter HYSTERESIS = 0;
	
	initial OUT = 0;
	
	//cannot simulate mixed signal IP

endmodule

module GP_BANDGAP(output reg OK, output reg VOUT);
	parameter AUTO_PWRDN = 1;
	parameter CHOPPER_EN = 1;
	parameter OUT_DELAY = 100;
	
	//cannot simulate mixed signal IP
	
endmodule

module GP_COUNT8(input CLK, input wire RST, output reg OUT);

	parameter RESET_MODE 	= "RISING";	
	
	parameter COUNT_TO		= 8'h1;
	parameter CLKIN_DIVIDE	= 1;
	
	//more complex hard IP blocks are not supported for simulation yet
	
	reg[7:0] count = COUNT_TO;
	
	//Combinatorially output whenever we wrap low
	always @(*) begin
		OUT <= (count == 8'h0);
	end
	
	//POR or SYSRST reset value is COUNT_TO. Datasheet is unclear but conversations w/ Silego confirm.
	//Runtime reset value is clearly 0 except in count/FSM cells where it's configurable but we leave at 0 for now.
	//Datasheet seems to indicate that reset is asynchronous, but for now we model as sync due to Yosys issues...
	always @(posedge CLK) begin
		
		count		<= count - 1'd1;
		
		if(count == 0)
			count	<= COUNT_TO;
			
		/*
		if((RESET_MODE == "RISING") && RST)
			count	<= 0;
		if((RESET_MODE == "FALLING") && !RST)
			count	<= 0;
		if((RESET_MODE == "BOTH") && RST)
			count	<= 0;
		*/			
	end

endmodule

module GP_COUNT14(input CLK, input wire RST, output reg OUT);

	parameter RESET_MODE 	= "RISING";	
	
	parameter COUNT_TO		= 14'h1;
	parameter CLKIN_DIVIDE	= 1;
	
	//more complex hard IP blocks are not supported for simulation yet

endmodule

module GP_DELAY(input IN, output reg OUT);
	
	parameter DELAY_STEPS = 1;
	
	//TODO: additional delay/glitch filter mode
	
	initial OUT = 0;
	
	generate
		
		//TODO: These delays are PTV dependent! For now, hard code 3v3 timing
		//Change simulation-mode delay depending on global Vdd range (how to specify this?)
		always @(*) begin
			case(DELAY_STEPS)
				1: #166 OUT = IN;
				2: #318 OUT = IN;
				2: #471 OUT = IN;
				3: #622 OUT = IN;
				default: begin
					$display("ERROR: GP_DELAY must have DELAY_STEPS in range [1,4]");
					$finish;
				end
			endcase
		end
		
	endgenerate
	
endmodule

module GP_DFF(input D, CLK, output reg Q);
	parameter [0:0] INIT = 1'bx;
	initial Q = INIT;
	always @(posedge CLK) begin
		Q <= D;
	end
endmodule

module GP_DFFR(input D, CLK, nRST, output reg Q);
	parameter [0:0] INIT = 1'bx;
	initial Q = INIT;
	always @(posedge CLK, negedge nRST) begin
		if (!nRST)
			Q <= 1'b0;
		else
			Q <= D;
	end
endmodule

module GP_DFFS(input D, CLK, nSET, output reg Q);
	parameter [0:0] INIT = 1'bx;
	initial Q = INIT;
	always @(posedge CLK, negedge nSET) begin
		if (!nSET)
			Q <= 1'b1;
		else
			Q <= D;
	end
endmodule

module GP_DFFSR(input D, CLK, nSR, output reg Q);
	parameter [0:0] INIT = 1'bx;
	parameter [0:0] SRMODE = 1'bx;
	initial Q = INIT;
	always @(posedge CLK, negedge nSR) begin
		if (!nSR)
			Q <= SRMODE;
		else
			Q <= D;
	end
endmodule

module GP_IBUF(input IN, output OUT);
	assign OUT = IN;
endmodule

module GP_IOBUF(input IN, input OE, output OUT, inout IO);
	assign OUT = IO;
	assign IO = OE ? IN : 1'bz;
endmodule

module GP_INV(input IN, output OUT);
	assign OUT = ~IN;
endmodule

module GP_LFOSC(input PWRDN, output reg CLKOUT);
	
	parameter PWRDN_EN = 0;
	parameter AUTO_PWRDN = 0;
	parameter OUT_DIV = 1;
	
	initial CLKOUT = 0;
	
	//auto powerdown not implemented for simulation
	//output dividers not implemented for simulation
	
	always begin
		if(PWRDN)
			CLKOUT = 0;
		else begin
			//half period of 1730 Hz
			#289017;
			CLKOUT = ~CLKOUT;
		end
	end
	
endmodule

module GP_OBUF(input IN, output OUT);
	assign OUT = IN;
endmodule

module GP_OBUFT(input IN, input OE, output OUT);
	assign OUT = OE ? IN : 1'bz;
endmodule

module GP_PGA(input wire VIN_P, input wire VIN_N, input wire VIN_SEL, output reg VOUT);

	parameter GAIN = 1;
	parameter INPUT_MODE = "SINGLE";

	initial VOUT = 0;

	//cannot simulate mixed signal IP

endmodule

module GP_POR(output reg RST_DONE);
	parameter POR_TIME = 500;
	
	initial begin
		RST_DONE = 0;
		
		if(POR_TIME == 4)
			#4000;
		else if(POR_TIME == 500)
			#500000;
		else begin
			$display("ERROR: bad POR_TIME for GP_POR cell");
			$finish;
		end
		
		RST_DONE = 1;
		
	end
	
endmodule

module GP_RCOSC(input PWRDN, output reg CLKOUT_PREDIV, output reg CLKOUT_FABRIC);
	
	parameter PWRDN_EN = 0;
	parameter AUTO_PWRDN = 0;
	parameter PRE_DIV = 1;
	parameter FABRIC_DIV = 1;
	parameter OSC_FREQ = "25k";
	
	initial CLKOUT_PREDIV = 0;
	initial CLKOUT_FABRIC = 0;
	
	//output dividers not implemented for simulation
	//auto powerdown not implemented for simulation
	
	always begin
		if(PWRDN) begin
			CLKOUT_PREDIV = 0;
			CLKOUT_FABRIC = 0;
		end
		else begin
		
			if(OSC_FREQ == "25k") begin
				//half period of 25 kHz
				#20000;
			end
			
			else begin
				//half period of 2 MHz
				#250;
			end
			
			CLKOUT_PREDIV = ~CLKOUT_PREDIV;
			CLKOUT_FABRIC = ~CLKOUT_FABRIC;
		end
	end
	
endmodule

module GP_RINGOSC(input PWRDN, output reg CLKOUT_PREDIV, output reg CLKOUT_FABRIC);
	
	parameter PWRDN_EN = 0;
	parameter AUTO_PWRDN = 0;
	parameter PRE_DIV = 1;
	parameter FABRIC_DIV = 1;
	
	initial CLKOUT_PREDIV = 0;
	initial CLKOUT_FABRIC = 0;
	
	//output dividers not implemented for simulation
	//auto powerdown not implemented for simulation
	
	always begin
		if(PWRDN) begin
			CLKOUT_PREDIV = 0;
			CLKOUT_FABRIC = 0;
		end
		else begin
			//half period of 27 MHz
			#18.518;
			CLKOUT_PREDIV = ~CLKOUT_PREDIV;
			CLKOUT_FABRIC = ~CLKOUT_FABRIC;
		end
	end
	
endmodule

module GP_SHREG(input nRST, input CLK, input IN, output OUTA, output OUTB);

	parameter OUTA_TAP = 1;
	parameter OUTA_INVERT = 0;
	parameter OUTB_TAP = 1;
	
	reg[15:0] shreg = 0;
	
	always @(posedge CLK, negedge nRST) begin
		
		if(!nRST)
			shreg = 0;
		
		else
			shreg <= {shreg[14:0], IN};
		
	end
	
	assign OUTA = (OUTA_INVERT) ? ~shreg[OUTA_TAP - 1] : shreg[OUTA_TAP - 1];
	assign OUTB = shreg[OUTB_TAP - 1];

endmodule

//keep constraint needed to prevent optimization since we have no outputs
(* keep *)
module GP_SYSRESET(input RST);
	parameter RESET_MODE = "RISING";
	
	//cannot simulate whole system reset
	
endmodule

module GP_VDD(output OUT);
       assign OUT = 1;
endmodule

module GP_VREF(input VIN, output reg VOUT);
	parameter VIN_DIV = 1;
	parameter VREF = 0;
	//cannot simulate mixed signal IP
endmodule

module GP_VSS(output OUT);
       assign OUT = 0;
endmodule
