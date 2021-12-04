`timescale 1ns / 1ps

module maze(
input 		clk,
input [maze_width - 1:0] 	starting_col, starting_row, 	// indicii punctului de start
input 		maze_in, 												// ofera informa?ii despre punctul de coordonate [row, col]
output reg [maze_width - 1:0] row, col, 						// selecteaza un rând si o coloana din labirint
output reg	maze_oe,													// output enable (activeaza citirea din labirint la rândul ?i coloana date) - semnal sincron		
output reg	maze_we, 												// write enable (activeaza scrierea în labirint la rândul ?i coloana date) - semnal sincron
output reg	done);		 											// ie?irea din labirint a fost gasita; semnalul ramane activ 

	parameter maze_width  = 6;
	parameter state_width = 4;
	
	parameter UP    =  0;
	parameter LEFT  =  1;
	parameter DOWN  =  2;
	parameter RIGHT =  3;

	reg [maze_width  - 1:0] last_row;
	reg [maze_width  - 1:0] last_col;
	reg [state_width - 1:0] state; 
	reg [state_width - 1:0] next_state;
	reg [1:0] direction = DOWN;

	`define init	                  0
	`define orientation	            1	
	`define move	                  2	
	`define mission_accomplished	   3
	


	// sequential part
	always @(posedge clk)begin
		// daca nu a fost gasita iesirea, se va trece in urmatoarea stare
		if (done == 0) begin
			state <= next_state;
		end
	end

	// combinational part
	always @(*) begin

	next_state = `init;
	maze_oe = 0;
	maze_we = 0;
	done = 0;

	case(state)
	
		`init : begin	
			// se atribuie coordonatele initiale (punctul de start din matrice)
			row = starting_row;
			col = starting_col;
			// se marcheaza punctul de start cu 2 si se trece la urmatoarea stare
			maze_we = 1;
			next_state = `orientation;	
		end
		
		`orientation : begin
			// se salveaza temporar coordonatele pentru a putea retrograda traseul
			last_row = row;
			last_col = col;
			maze_oe = 1;
			next_state = `move;
			
			case (direction)				
			
				UP : begin         // next up
					direction = LEFT;
					row = row - 1;
				end
				
				LEFT : begin         // next left
					direction = DOWN;
					col = col - 1;
				end

				DOWN : begin         // next down
					direction = RIGHT;
					row = row + 1;
				end
					
				RIGHT : begin         // next right
					direction = UP;
					col = col + 1;
				end
				
			endcase
			
		end
		
		`move : begin		
			next_state = `orientation;
			  
			if (maze_in == 1) begin		//ma intorc daca dau in perete
				
				row = last_row;
				col = last_col;
				
		   end else begin		
			
				maze_we = 1;
				
			   if (last_col - 1 ==col && last_row == row) begin		//vin din dreapta ma uit in sus
					direction = 0;
				end
				if (last_row + 1 == row && last_col == col) begin		//vin de sus ma uit la stanga
					direction = 1;
				end
			   if (last_col + 1 == col && last_row == row) begin		//vin din stanga ma uit in jos
				   direction = 2;
				end
			   if (last_row - 1 == row && last_col == col) begin		//vin de jos la uit la dreapta
				   direction = 3;
				end
			   if (col <= 0 || col >= 63 || row <= 0 || row >= 63) begin
				   next_state = `mission_accomplished;
				end
			end
		end
			
		`mission_accomplished : begin
			done = 1;
		end


	endcase
	end


endmodule