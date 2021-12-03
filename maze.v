`timescale 1ns / 1ps

module maze(
input 		clk,
input[maze_width - 1:0] 	starting_col, starting_row, 		// indicii punctului de start
input 		maze_in, 							// ofera informa?ii despre punctul de coordonate [row, col]
output reg [maze_width - 1:0] row, col, 							// selecteaza un rând si o coloana din labirint
output  reg maze_oe,							// output enable (activeaza citirea din labirint la rândul ?i coloana date) - semnal sincron	
output  reg maze_we, 							// write enable (activeaza scrierea în labirint la rândul ?i coloana  date) - semnal sincron
output  reg done);		 						// ie?irea din labirint a fost gasita; semnalul ramane activ 

	parameter maze_width = 6;
	parameter width = 4;
	reg[5:0] prev_row,prev_col;
	reg[1:0] i = 0, ii = 0;
	reg [width - 1:0] state, next;


	`define start	0
	`define look	1	//ma uit la cruce
	`define check	2	//vad daca-i perete sau drum	
	`define back	3
	`define right 	4
	`define down	5
	`define left	6
	`define up		7
	`define move	8	//ma intorc din perete
	`define done	9

	always @(posedge clk)begin

		if (!done) begin
			state <= next;
		end

	end


	always @(*) begin

	next = `start;
	maze_oe = 0;
	maze_we = 0;
	done = 0;


	case(state)
		`start : begin
			
			maze_we = 1;
			row = starting_row;
			col = starting_col;
			next = `look;
			
		end
		
		`look : begin
		
			case(i)				//numerotez starile i sa-mi indice unde sa ma uit
			
				0 : begin
					next = `up;
					i = i + 1;
				end
				
				1 : begin
					next = `left;
					i = i + 1;
				end
							//nu stiu cat de ok e ordinea...
				2 : begin
					next = `down;
					i = i + 1;
				end
					
				3 : begin
					next = `right;	
					i = i + 1;
				end
								
			
			endcase
			
		end
		
		`right : begin
			ii = 3;
			prev_row = row;
			prev_col = col;
			maze_oe = 1;
			
			col = col + 1;
			next = `check;
		end
		
		`down : begin
			ii = 2;
			prev_row = row;			//ma uit pe fiecare directie si verific
			prev_col = col;
			maze_oe = 1;
			
			row = row + 1;
			next = `check;
		end
		
		`left : begin
			ii = 1;
			prev_row = row;
			prev_col = col;
			maze_oe = 1;
			
			col = col - 1;
			next = `check;
		end
		
		`up : begin
			ii = 0;
			prev_row = row;
			prev_col = col;
			maze_oe = 1;
			
			row = row - 1;
			next = `check;
		end
		
		`check : begin			//verific valoarea din casuta
			
			if (maze_in == 1)		//ma intorc daca dau in perete
				next = `back;
			else begin
				next = `move;		//dau de 0 ma mut acolo
				maze_we = 1;
			end
			
		end
		
		`back : begin
			row = prev_row;
			col = prev_col;		
			next = `look; 		//ma intorc si ma uit mai departe la celelalte directii
		end
		
		`move : begin			
			i = 0;				//dupa fiecare mutare tre sa ma uit din nou
			
			if (prev_row == row - 1 && prev_col == col) begin		//vin de sus ma uit la stanga
				next = `left;
				i = ii;
			end
			
			if (prev_col == col + 1 && prev_row == row) begin		//vin din dreapta ma uit in sus
				next = `up;
				i = ii;
			end
			
			if (prev_col == col - 1 && prev_row == row) begin		//vin din stanga ma uit in jos
				next = `down;
				i = ii;
			end
			
			if (prev_row == row + 1 && prev_col == col) begin		//vin de jos la uit la dreapta
				next = `right;
				i = ii;
			end
			
			if (row == 0 || row == 63 || col == 0 || col == 63)
				next = `done;
				
		end
		
		
		`done : begin
			done = 1;

		end


	endcase
end



endmodule