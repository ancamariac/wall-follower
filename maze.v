`timescale 1ns / 1ps

module maze(
input 		clk,
input [maze_width - 1:0] 	starting_col, starting_row, 		// indicii punctului de start
input 		maze_in, 							// ofera informatii despre punctul de coordonate [row, col]
output reg [maze_width - 1:0] row, col, 						// selecteaza un rând si o coloana din labirint
output reg	maze_oe,							// output enable (activeaza citirea din labirint la rândul ?i coloana date) - semnal sincron	
output reg	maze_we, 							// write enable (activeaza scrierea în labirint la rândul ?i coloana  date) - semnal sincron
output reg	done);		 					// iesirea din labirint a fost gasita; semnalul ramane activ 

//TODO implementare
parameter maze_width = 6;
parameter state_width = 4;

reg[maze_width - 1:0] prev_row,prev_col;
reg[1:0] i = 0;
reg [state_width - 1:0] state, next;


`define start	0
`define look	1	//ma uit la cruce
`define move	2	//ma intorc din perete
`define done	3

always @(posedge clk)begin

	if(!done) begin
		state <= next;
   end

end


always @(*) begin

next=`start;
maze_oe=0;
maze_we=0;
done=0;

case(state)
	`start:begin	
		maze_we=1;
		row=starting_row;
		col=starting_col;
		next=`look;
		
	end
	
	`look:begin
        prev_row=row;
		prev_col=col;
        maze_oe=1;
        next=`move;
		case(i)				//numerotez starile i sa-mi indice unde sa ma uit
		
			0:begin         // next up
				i=1;
		        row=row-1;
			end
			1:begin         // next left
				i=2;
		        col=col-1;
			end

			2:begin         // next down
				i=3;
		        row=row+1;
			end
				
			3:begin         // next right
                i = 0;
		        col=col+1;
			end
		endcase
		
	end
	
	`move:begin		
        next=`look;
        if(maze_in==1) begin		//ma intorc daca dau in perete
			row=prev_row;
		    col=prev_col;
        end
        else begin
            maze_we=1;
		    if(prev_col==col+1 && prev_row==row)begin		//vin din dreapta ma uit in sus
			    i=0;
			    end
            if(prev_row==row-1 && prev_col==col)begin		//vin de sus ma uit la stanga
			    i=1;
			    end
    		if(prev_col==col-1 && prev_row==row)begin		//vin din stanga ma uit in jos
	    		i=2;
		    	end
		    if(prev_row==row+1 && prev_col==col)begin		//vin de jos la uit la dreapta
		    	i=3;
			    end
		    if(row==0 || row==63 || col==0 || col==63)
			    next=`done;
        end
	end
	
	
	`done: begin
		done=1;
	end


endcase
end



endmodule