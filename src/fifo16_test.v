`timescale 1ns/1ns
// ncverilog 
module testbench;

  reg clk;
  reg rst;
  parameter STEP = 10; //10ns
  //--------------------------------------

  // for fifo16
  reg p_req_val, p_arb_val;
  reg [1:0] p_req_ch, p_arb_ch;
  reg [3:0] p_reg_id;
  wire p_sel_val;
  wire [3:0] p_sel_req_id;

  // clk
  always #(STEP / 2) clk = ~clk;

  // initial statements
  integer i, i2;
  initial begin
    $shm_open("./shm_fifo16_rtl");
    $shm_probe("AS");
    $monitor("req(val,ch,id):%h,%h,%h, arb(val,ch):%h,%h, sel(val,req_id):%h,%h", p_req_val, p_req_ch, p_req_id, p_arb_val, p_arb_ch, p_sel_val, p_sel_req_id);
    $monitoron ;
    #0 clk <= 1;
    rst <= 1;
    #(4)
    rst <= 0;
    #(6)
    #(STEP)
    rst <= 1;
    test(0,0,0,0,0);
    test(1,1,0,0,0);
    test(1,0,1,0,0);
    test(1,1,2,0,0);
    test(1,2,3,1,0);
    test(0,0,0,0,0);
    test(0,0,0,1,2);
    test(0,0,0,1,1);
    test(0,0,0,1,1);
    test(0,0,0,0,0);
    $shm_close();
    $finish;
  end

  // task
  task test
    input p_req_val_task;
    input [1:0] p_req_ch_task;
    input [3:0] p_req_id_task;
    input p_arb_val_task;
    input [1:0] p_arb_ch_task;
    begin
      @ (posedge clk);
        p_req_val <= p_req_val_task;
        p_req_ch <= p_req_ch_task;
        p_req_id <= p_req_id_task;
        p_arb_val <= p_arb_val_task;
        p_arb_ch <= p_arb_ch_task;
    end
  endtask

  fifo16_1705 fifo_16_0(.clk(clk),
    .rst(rst),
    .p_req_val(p_req_val),
    .p_req_ch(p_req_ch),
    .p_req_id(p_req_id),
    .p_arb_val(p_arb_val),
    .p_arb_ch(p_arb_ch),
    .p_sel_val(p_sel_val),
    .p_sel_req_id(p_sel_req_id)
  );

endmodule

/*
// display
  always @(posedge clk) begin
    $display ("req(val,ch,id):%h,%h,%h, arb(val,ch):%h,%h, sel(val,req_id):%h,%h", p_req_val, p_req_ch, p_req_id, p_arb_val, p_arb_ch, p_sel_val, p_sel_req_id);
  end
*/
