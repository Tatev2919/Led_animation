module PWM_controller
  #(parameter t1 = 6'd20,
    parameter t2 = 6'd20) 
  (
   input start,clk,rst,
   output reg [3:0] d_c,
   output en
);
  
reg [4:0] inc_counter;
wire pwm_out,out_pulse;
reg trig;
reg [5:0] load; 
reg rst_timer,flag;
  
PWM #(.T(6'd10)) p1 (
    .clk(clk),
    .rst(rst),
    .duty_cycle(d_c),
    .pwm_out(pwm_out)
);
  
timer #(.N(6)) tim1 (
    .clk (clk),
    .rst (rst_timer),
    .load (load),
    .trig (trig),
    .out_pulse (out_pulse)
);
  
assign en = (inc_counter == 5'd20);
  
always @(posedge clk or posedge rst) begin 
    if(rst) begin
        inc_counter <= 5'b0;
        trig <= 1'b0;
        rst_timer <= 1'b0;
    end
    else begin 
      if(start) begin 
        flag  <= 1'b1;
      end
      if (flag) begin 
          trig <= 1'b1;
          load <= t1;
          rst_timer <= out_pulse;
          if(out_pulse) begin  
              inc_counter <= inc_counter + 5'b1;
          end
          if (out_pulse != rst_timer ) begin 
              trig <= 1'b0;
          end

          if(inc_counter == 5'd10) begin
              load <= t2;
              if ( out_pulse ) begin 
                  load <= t1;
                  inc_counter <= inc_counter + 1;
              end
            end
          end
          if ( inc_counter == 5'd20) begin
              flag <= 1'b0;
              inc_counter <= 5'b0;
          end
    end  
end
  
  always @(*)
    begin 
      if (rst) 
        d_c = 5'd0;
      else 
        if (flag) begin 
          if(inc_counter <= 5'd10)
            d_c = inc_counter;
          else 
            d_c = 5'd20 - inc_counter;
        end
    end
	
endmodule
