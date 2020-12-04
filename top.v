module top (
	input  	      clk,
	input  	      rst,
	input   [1:0] mode,
	output  [7:0] led_out 
);
  reg trig,rst_timer,st,cnt2,start;
  reg  [7:0] led_out0,led_out1;
  wire out_pulse;
  wire [7:0] overflow,half_overflow;
  reg  [4:0] cnt, cnt1;
  reg  [1:0] mode_r;
  reg  [12:0] load;
  reg  [2:0] i;
  wire [7:0] cont_out,start_tmp;
  //reg  [12:0] t2;

  timer #(.N(13)) top_tim(
    .clk(clk),
    .rst(rst_timer),
    .trig(trig),
    .out_pulse(out_pulse),
    .load(load)
  );

PWM_controller #(.t1(6'd40), .K(5'd20) )
PWM_cont_top0 (
		.clk(clk),
		.rst(rst),
		.start(start_tmp[0]),
		.overflow(overflow[0]),
		.overflow1(half_overflow[0]),
		.pwm_out(cont_out[0]),
	 	.t2(13'd40)
	     );
  
genvar j;
generate 
	for (j = 1 ; j < 8; j = j+1) begin 
        PWM_controller #(.t1(6'd40),.K(5'd20) )
	PWM_cont_top (
			.clk(clk),
			.rst(rst),
			.start(start_tmp[j]),
			.overflow(overflow[j]),
			.overflow1(half_overflow[j]),
 			.pwm_out(cont_out[j]),
			.t2(13'd40)
		     );
	end
endgenerate

assign start_tmp[7:1] = (mode == 2) ? overflow[6:0]:half_overflow[6:0];
assign led_out = (mode == 0) ? led_out0 : 
      		 (mode == 1) ? led_out1 : cont_out;
assign start_tmp[0] = st;
	
always @(posedge clk or posedge rst) begin 
    if(rst) begin
        mode_r <= 2'b0;
        load <= 6'd10;
    	start <= 1'b0;
        led_out0 <= 8'b00000000;
        led_out1 <= 8'b00000000;
        cnt <= 5'd8;
        cnt1 <= 5'd16;
        i <= 3'd7;
        st <= 1'b0;
    end
    else begin 
      if(mode != mode_r) begin 
            cnt <= 5'd8;
            cnt1 <= 5'd16;
            mode_r <= mode;
      end
      if(rst_timer) begin 
      	trig <= 0;
      end
      else begin 
      if(mode == 2'b0) begin
            trig <= 1'b1; 
            if(led_out0 == 8'b0 && cnt == 5'd7) begin  
              led_out0[7] <= 1'b1;
            end
            if(out_pulse) begin 
              led_out0 <= (led_out0>>1'b1);
              cnt <= cnt - 5'b1;
              trig <= 1'b0;
              if(cnt == 8'b0) begin
                 cnt <= 5'd8;
                 led_out0[7] <= 1'b1;
              end 
            end
      end
      else if (mode == 2'b1 ) begin 
            trig <= 1'b1;
            if(out_pulse) begin 
                  led_out1 <= (led_out1 >> 1'b1);
                  cnt1 <= cnt1 - 5'b1;
              	  trig <= 1'b0;
                  if( cnt1 >=5'd9 ) begin 
                  	led_out1[7] <= 1'b1;
                  end
              	  if(cnt1 == 5'd7) begin 
                         led_out1[7] <= 1'b0;
                  end
                  else if (cnt1 == 5'd0) begin 
			  led_out1[7] <= 1'b1;
			  cnt1 <= 5'd16;
                  end
            end
      end
      else if (mode == 2'd2) begin 
          //  start_tmp[0] <= st ? overflow[7]:start;
            if (cnt2 == 1'b1 ) begin 
	       st <= 0;
            end
            else begin 
	    	st <= 1'b1;
	    	cnt2 <= 1'b1; 
	    end 
      end
      else if (mode == 2'd3) begin 
      	   //led_out[7] <= PWM_cont_top.pwm_out;
         //  t2 <= 40 * 10 *i;  
           /*if(half_overflow) begin 
	   	i <= i - 4'd1;
                PWM_gen1(i);
           end
           if (d_c == 4'd10 || d_c == 4'd0) begin 
	   	start <= 1'b1;
           end
	   else 
		start <= 1'b0;*/
      end
      else begin  
          trig <= 1'b0;
       end
      end
    end
end
  
always @(posedge clk or posedge rst) begin 
    if(rst )  begin 
       rst_timer <= 1'b1;
    end
    if(mode != mode_r) begin 
        rst_timer <= 1'b1;
    end
    else begin 
    	rst_timer <= 1'b0;
    end
end
    
endmodule
