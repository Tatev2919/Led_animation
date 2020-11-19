module top (
    input  	     clk,
    input  	     rst,
    input      [1:0] mode,
    output reg [7:0] led_out 
);
  reg trig,rst_timer,start;
  wire out_pulse,pwm_out,en;
  reg  [4:0] cnt, cnt1,cnt2;
  reg  [1:0] mode_r;
  reg  [5:0] load;
  wire [3:0] d_c;
  reg  [3:0] i;
   
  timer #(.N(6)) t1(
    .clk(clk),
    .rst(rst_timer),
    .trig(trig),
    .out_pulse(out_pulse),
    .load(load)
  );
  
   PWM_controller #(
   .t1(6'd30),.t2(6'd35))
   p2 (
    .clk(clk),
    .rst(rst),
    .d_c(d_c),
    .start(start),
    .en(en) 
  );
  
  PWM #(.T(6'd20)) p1 (
    .clk(clk),
    .rst(rst),
    .duty_cycle(d_c),
    .pwm_out(pwm_out)
  );
  
  
always @(posedge clk or posedge rst) begin 
    if(rst) begin
        mode_r <= 2'b0;
        load <= 6'd10;
    	start <= 1'b0;
        led_out <= 8'b00000000;
        cnt <= 5'd8;
        cnt1 <= 5'd16;
        cnt2 <= 5'd20; 
        i <= 4'd8;
    end
    else begin 
      if(mode != mode_r) begin 
            led_out <= 8'b00000000;
            cnt <= 5'd8;
            cnt1 <= 5'd16;
            cnt2 <= 5'd20;
            mode_r <= mode;
      end
      if(rst_timer) begin 
      	trig <= 0;
      end
      else begin 
      if(mode == 2'b0) begin
          	trig <= 1'b1; 
            if(led_out == 8'b0 && cnt == 5'd7) begin  
              led_out[7] <= 1'b1;
            end
            if(out_pulse) begin 
              led_out <= (led_out>>1'b1);
              cnt <= cnt - 5'b1;
              trig <= 1'b0;
              if(cnt == 8'b0) begin
                 cnt <= 5'd8;
                 led_out[7] <= 1'b1;
              end 
            end
      end
      else if (mode == 2'b1 ) begin 
            trig <= 1'b1;
            if(out_pulse) begin 
                  led_out <= (led_out >> 1'b1);
                  cnt1 <= cnt1 - 5'b1;
              	  trig <= 1'b0;
                  if( cnt1 >=5'd10 ) begin 
                  	led_out[7] <= 1'b1;
                  end
              	  if(cnt1 == 5'd9) begin 
                    led_out[7] <= 1'b0;
                  end
                  else if (cnt1 == 5'd1) begin 
                    led_out[7] <= 1'b1;
                    cnt1 <= 5'd16;
                  end
            end
      end
      else if (mode == 2'd2) begin 
            led_out[i] <= pwm_out; 
            if( i == -4'd1) begin 
               i <= 4'd7; 
            end
            if (i == 4'd8) begin
              	i  <= 4'd7;
            end
        	if(en) begin 
                i <= i - 4'd1;
            end
        	if (d_c == 4'b0 || d_c == 4'd10) begin 
                start <= 1'b1;
            end
            else 
              start <= 1'b0;
      
        //$monitor (led_out[7] , "-----", pwm_out , "**" , i);
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
