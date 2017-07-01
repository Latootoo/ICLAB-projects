module LMFE ( clk, reset, Din, in_en, busy, out_valid, Dout);
input clk;
input reset;
input in_en;
output reg busy;
output reg out_valid;
input [7:0] Din;
output [7:0] Dout;

wire ceb;
wire web;
wire [7:0] Mout;
wire [9:0] addr;

reg nextout_valid;
reg halt;
reg nexthalt;
reg [1:0] state;
reg [1:0] nextstate;
reg [5:0] count;
reg [5:0] nextcount;
reg [7:0] posx;
reg [7:0] nextposx; 
reg [7:0] posy;
reg [7:0] nextposy;
reg [7:0] colori;
reg [7:0] nextcolori;
reg [7:0] Min;
reg [9:0] winx; 
reg [9:0] nextwinx; 
reg [9:0] Raddr;
reg [9:0] nextRaddr;
reg [9:0] Raddrmod;
reg [9:0] nextRaddrmod;
reg [9:0] Waddr;
reg [9:0] nextWaddr;
reg [7:0] color [0:48];
reg [7:0] nextcolor [0:48];

integer i;

parameter INIT = 2'b00;
parameter READ = 2'b01;
parameter SORT = 2'b10;
parameter WRITE = 2'b11;

sram_1024x8_t13 ram1(.Q(Mout), .A(addr), .D(Min), .CLK(clk), .CEN(ceb), .WEN(web));

assign addr = web == 0 ? Waddr : Raddr; 
assign Dout = color[24];
assign ceb = 0;
assign web = state == READ;

always @(posedge clk or posedge reset) begin
	if (reset) begin
		state <= INIT;
		winx <= 0;
		posx <= 0;
		posy <= 0;
		Raddr <= 0;
		Raddrmod <= 0;
		Waddr <= 0;
		out_valid <= 0;
		colori <= 0;
		count <= 0;
		halt <= 1;
		for (i = 0; i <= 48; i = i + 1) begin
			color[i] = 0;
		end
	end else begin
		state <= nextstate;
		winx <= nextwinx;
		posx <= nextposx;
		posy <= nextposy;
		Raddr <= nextRaddr;
		Raddrmod <= nextRaddrmod;
		Waddr <= nextWaddr;
		out_valid <= nextout_valid;
		colori <= nextcolori;
		count <= nextcount;
		halt <= nexthalt;
		for (i = 0; i <= 48; i = i + 1) begin
			color[i] = nextcolor[i];
		end
	end
end

always @(*) begin
	case (state)
		INIT: 	if (Waddr == 937) nextstate = READ;
				else nextstate = INIT;
		READ:	if (colori == 48) nextstate = SORT;
				else nextstate = READ;
		SORT: 	if (count == 48 && winx == 127) nextstate = WRITE;
				else if (count == 48) nextstate = READ;
				else nextstate = SORT;
		WRITE: 	if (posx == 133) nextstate = READ;
              	else nextstate = WRITE;
	endcase 
end

always @(*) begin
	nextwinx = winx;
	nextposx = posx;
	nextposy = posy;
	nextRaddr = Raddr;
	nextRaddrmod = Raddrmod;
	nextWaddr = Waddr;
	nextcolori = colori;
	nextout_valid = 0;
	nextcount = count;
	nexthalt = halt;
	for (i = 0; i <= 48; i = i + 1) begin
		nextcolor[i] = color[i];
	end
	case (state)
		INIT:	begin	
					nextposx = posx == 133 ? 0 : posx + 1;
					nextposy = posx == 133 ? posy + 1 : posy;
					nextRaddr = 0;
					nextRaddrmod = 0;
					nextWaddr = Waddr == 937 ? 0 : Waddr + 1;
				end
		READ:	begin
					nextRaddr = Raddrmod == winx + 6 ? Raddr + 128 : Raddr + 1;
					nextRaddrmod = Raddrmod == winx + 6 ? winx : Raddrmod + 1;
					if(halt == 1)begin
						nexthalt = 0;
					end else begin
						nextcolor[colori] = Mout;
						nextcolori = colori == 48 ? 0 : colori + 1;
					end
				end
		SORT: 	begin
					nexthalt = 1;
					if(count == 48) begin
						nextwinx = winx == 127 ? 0 : winx + 1;
						nextRaddr = nextwinx;
						nextRaddrmod = nextwinx;
						nextout_valid = 1;
						nextcount = 0;
					end else if(count[0] == 0) begin
						for (i = 0; i <= 46; i = i + 2) begin
							if (color[i] >= color[i+1]) begin
								nextcolor[i+1] = color[i];
								nextcolor[i] = color[i+1];
							end else begin
								nextcolor[i] = color[i];
								nextcolor[i+1] = color[i+1];
							end
						end
						nextcolor[48] = color[48];
						nextcount = count + 1; 
					end else begin
						for (i = 1; i <= 47; i = i + 2) begin
							if (color[i] >= color[i+1]) begin
								nextcolor[i+1] = color[i];
								nextcolor[i] = color[i+1];
							end else begin
								nextcolor[i] = color[i];
								nextcolor[i+1] = color[i+1];
							end
						end
						nextcolor[0] = color[0];
						nextcount = count + 1; 
					end
				end
		WRITE: 	begin
					nextposx = posx == 133 ? 0 : posx + 1;
					nextposy = posx == 133 ? posy + 1 : posy;
					nextRaddr = 0;
					nextRaddrmod = 0;
					nextWaddr = Waddr == 937 ? 0 : Waddr + 1;
              	end
	endcase  
end

always @(*) begin
	if(posx <= 2 || posy <= 2 || posx >= 131 || posy >= 131) begin
		Min = 0;
		busy = 1;
	end else begin 
		Min = Din;
		busy = 0;
	end
end

endmodule
