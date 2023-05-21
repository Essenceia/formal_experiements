module model (
	input  clk,
	input  resetn,
	input  din,
	output dout
);

// trigger a pulse 1 cycle after din goes up
reg  edge_seen_q;
wire edge_seen_next;
reg  pulse_q;
wire pulse_next;
assign edge_seen_next = ( din & ~edge_seen_q) 
					  | ( din & edge_seen_q );
assign pulse_next      = din & ~edge_seen_q;
 
always @(posedge clk)
begin
	if ( ~resetn ) begin
		edge_seen_q <= 1'b0;
		pulse_q     <= 1'b0;
	end else begin
		edge_seen_q <= edge_seen_next;
		pulse_q     <= pulse_next;
	end
end

assign dout = pulse_q;

`ifdef FORMAL

reg din_f_q;

initial begin
	// assume
	a_reset : assume( ~resetn );
end


always @(posedge clk)
begin
	if ( ~resetn ) begin
		din_f_q <= 1'b0;
	end
	if (resetn) begin
		din_f_q <= din;
		
		// assert
		sva_pulse : assert( $rose(din_f_q) == dout );
	
		// cover
		c_dout : cover ( dout );  
		c_ndout : cover ( ~dout );  
	end
	c_nreset : cover ( ~resetn );
end
`endif
endmodule
