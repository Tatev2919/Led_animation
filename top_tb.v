module top_tb;
  reg clk,rst;
  reg [1:0] mode;
  wire [7:0] led_out;
  
  top t11(
    .clk(clk),
    .rst(rst),
    .mode(mode),
    .led_out(led_out)
  );
  
  initial begin 
    $dumpfile("v.vcd");
    $dumpvars();
  end
  
  initial begin 
  	rst = 1'b1;
    clk = 1'b0;
    #25;
    rst = 1'b0; 
    @(negedge clk ) mode <= 2'b0;
    #2510;
    @(negedge clk ) mode <= 2'b1;
    #4500;
    @(negedge clk ) mode <= 2'd2;
    #100000;
    $finish;
  end
  
  always begin 
  	#10 clk = ~clk; 
  end
  
endmodule
