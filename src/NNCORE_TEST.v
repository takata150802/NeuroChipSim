`timescale 1ns / 1ps


module NNCORE_TEST();

    wire [31:0]weight_addr;
    wire [31:0]weight_din;
    wire [31:0]weight_dout;
    wire weight_en;
    wire [3:0]weight_we;

    wire [31:0]data_addr;
    wire [31:0]data_din;
    wire [31:0]data_dout;
    wire data_en;
    wire [3:0]data_we;
    
    /////////‚ ‚Æ‚ÅÁ‚¹tkt151124/////////////
    wire [31:0]output_addr;
    wire [31:0]output_din;
    wire [31:0]output_dout;
    wire output_en;
    wire [3:0]output_we;
    /////////////////////////////   
    
    wire [31:0]inst_addr;
    wire [15:0]inst_din;
    wire [15:0]inst_dout;
    wire inst_en;
    wire [3:0]inst_we;

    reg [0:0]nnreset_n;
    reg [0:0]nnstart;
    reg nnclk;
    wire nnend;
    
    parameter num_of_input = 10'd785;
    parameter num_of_output = 5'd30;

    core core( 
            .nnclk(nnclk),
            .nnreset_n(nnreset_n),
           
            .num_of_input(num_of_input),
            .num_of_output(num_of_output),
            
            .weight_addr(weight_addr),
            .weight_din(weight_din),
            .weight_dout(weight_dout),
            .weight_en(weight_en),
            .weight_we(weight_we),
            
            .data_addr(data_addr),
            .data_din(data_din),
            .data_dout(data_dout),
            .data_en(data_en),
            .data_we(data_we),
            
            .output_addr(output_addr),
            .output_din(output_din),
            .output_dout(output_dout),
            .output_en(output_en),
            .output_we(output_we),
            
            .inst_addr(inst_addr),
            .inst_din(inst_din),
            .inst_dout(inst_dout),
            .inst_en(inst_en),
            .inst_we(inst_we),
            
            .nnend(nnend),
            .nnstart(nnstart)
    
    );
    
    data_ram_model data_ram_model//input_ram_model input_ram_model//tkt
      (
        .rsta(~nnreset_n),
        .clka(nnclk),
        .ena(data_en),
        .wea(data_we),
        .addra(data_addr),
        .dina(data_din),
        .douta(data_dout)
      );   
      
    weight_ram_model weight_ram_model
       (
         .rsta(~nnreset_n),
         .clka(nnclk),
         .ena(weight_en),
         .wea(weight_we),
         .addra(weight_addr),
         .dina(weight_din),
         .douta(weight_dout)
      );     
      
    inst_ram_model inst_ram_model
         (
           //.rsta(~nnreset_n),//tkt151124
           .clka(nnclk),
           .ena(inst_en),
           .wea(inst_we),
           .addra(inst_addr[13:0]),
           .dina(inst_din),
           .douta(inst_dout)
        );  
      
  initial begin
    nnclk = 1'b0;
    nnreset_n = 1'b0;
    repeat(4) #5 nnclk = ~nnclk;
    nnreset_n = 1'b1;
    forever #5 nnclk = ~nnclk;
  end
  
  // state wire
  initial begin
    nnstart = 1'b0;
    #(50)
    nnstart = 1'b1;
  end
  
//  always @(nnclk)begin
//    if(core.nnnext)begin
//      //$display("d %d, w%d", core.);
//      $display("test");
      
//       generate
//          genvar i;
//          for (i = 0 ; i <= 128 - 1 ; i = i + 1 ) begin
//          //assign input_wire[i]= $signed(({1'b0,in_128[i]})*weight_in_128[i]); 
//          //assign input_wire[i]= data[i]*weight[i];
//         // assign input_wire[i]= $signed({1'b0,data[i]})*weight[i];
//           $display("d %d, w%d", core.data[i] , core.weight[i]);
//          end
//      endgenerate      
//      $display("test");
//    end
//  end


      
       generate
          genvar i;
          for (i = 0 ; i <= 128 - 1 ; i = i + 1 ) begin
  
  always @(nnclk)begin
    if(core.nn128write)begin
      //$display("d %d, w%d", core.);

          //assign input_wire[i]= $signed(({1'b0,in_128[i]})*weight_in_128[i]); 
          //assign input_wire[i]= data[i]*weight[i];
         // assign input_wire[i]= $signed({1'b0,data[i]})*weight[i];
           $display("[%d],d %d,w %d",i, core.data[i], core.weight[i]);
          //end
   
 //     $display("test");
    end
  end  
         end
       endgenerate    
  
endmodule
