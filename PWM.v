module PWM
  #(parameter T = 6'd10) 
  (
	input clk,rst,
    input [3:0] duty_cycle,
    output reg pwm_out
);
reg [3:0] duty_cycle_r;  
reg  [4:0]  counter;
wire [4:0]  t2 = (T*duty_cycle_r/10);
  
  always @(posedge clk or negedge rst) begin
    if (rst) begin
      counter <= {5{1'b0}};
      duty_cycle_r <= duty_cycle;
    end 
    else begin 
      counter <= counter + 1;
      if(counter == (T-1) )
        counter <= {5{1'b0}};
        duty_cycle_r <= duty_cycle;
      end
  end
  
  always @(*)
    begin
      if (rst)
        begin 
        	pwm_out = 1'b0;  
        end
      else 
        begin 
          if (counter < t2) begin 
            pwm_out = 1'b1;
          end
          else  
            pwm_out = 1'b0;
        end
    end
endmodule