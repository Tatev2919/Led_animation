module timer
  #(parameter N = 3)
  (
   input clk,rst,
   input [N-1:0] load,
   input trig,
   output reg out_pulse
);
  reg [N-1:0] cnt;
  reg trig_r;
 
  always @(posedge clk or posedge rst)
    begin 
      if(rst) begin
      	out_pulse <= 1'b0;
      	cnt <= 0;
      end
      else 
        begin
          trig_r <= trig;
          if(trig) begin  
            if ( trig_r^trig ) begin
              cnt <= load;
            end
          end
            if(cnt!=0) begin
              cnt <= cnt - {{N-1{1'b0}},1'b1};
            end
            if ( cnt == 1) begin 
              out_pulse <= 1'b1;
            end
            else begin 
              out_pulse <= 1'b0;
            end
        end
    end
  
endmodule
