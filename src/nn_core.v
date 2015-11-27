`default_nettype none

`timescale 1ns / 1ps

//    `define NUM_OF_OUTPUT  30
//    `define WEIGHT_CYCLE  1024
module core(

    input wire nnclk,
    input wire nnreset_n,
    

//    input wire [9:0] num_of_input,    // saka
    input wire [31:0] num_of_input,     
//    input wire [9:0] num_of_output,   // saka
    input wire [31:0] num_of_output,
    
    output wire [31:0]weight_addr,
    output wire [31:0]weight_din,
    input wire [31:0]weight_dout,
    output wire weight_en,
    output wire [3:0]weight_we,
    
    output wire [31:0]data_addr,
    output wire [31:0]data_din,
    input wire [31:0]data_dout,
    output wire data_en,
    output wire [3:0]data_we,
   
    output wire [31:0]output_addr,
    output wire [31:0]output_din,
    input wire [31:0]output_dout,
    output wire output_en,
    output wire [3:0]output_we,
 
    output wire [31:0]inst_addr,
    output wire [15:0]inst_din,
    input wire [15:0]inst_dout,
    output wire inst_en,
    output wire [3:0]inst_we, 
    
    output wire nnend,
    input wire nnstart
    );
    
    
   reg [3:0] state_reg;
     wire [3:0] state;
     assign state=state_reg;
     integer j;
     
     `define STATE_IDLE       4'b1111
     `define STATE_CALC       4'b0001
     `define STATE_CHECK      4'b0010 
     `define STATE_LASTCALC   4'b0011 
     `define STATE_INIT       4'b0100 
     `define STATE_END        4'b0110
     `define STATE_WRITE      4'b0111
     
     
     reg [31:0] cnt_reg;
     //reg [31:0] calc_cnt_reg;
     reg [7:0]  cnt_node_reg;
     wire    calc_output;
     //reg     [30:0] calc_output_reg;
     wire signed [31:0] calc_output_check;
     //reg [31:0] calc_output_reg_check [29:0];
     
     reg [31:0]weight_addr_reg;
     reg [31:0]weight_din_reg;
     reg weight_en_reg;
     reg [3:0]weight_we_reg;
     assign weight_addr = weight_addr_reg;
     assign weight_din  = weight_din_reg;
     assign weight_en   = weight_en_reg;
     assign weight_we   = weight_we_reg;
     
     reg [31:0]data_addr_reg;
     reg [31:0]data_din_reg;
     reg data_en_reg;
     reg [3:0]data_we_reg;
     assign data_addr  = data_addr_reg;
     assign data_din   = data_din_reg;
     assign data_en    = data_en_reg;
     assign data_we    = data_we_reg;
     
     reg [31:0]output_addr_reg;
     reg output_en_reg;
     reg [3:0]output_we_reg;
     assign output_addr  = output_addr_reg;
     assign output_en    = output_en_reg;
     assign output_we    = output_we_reg;
     
 //    reg [31:0] calc_output_reg_check [`NUM_OF_OUTPUT-1 : 0];
     reg [31:0] calc_output_reg_check [29 : 0];
         
     
     assign output_din = calc_output_reg_check[cnt_node_reg];
     
     reg nnnext;
     reg nn128write;
     reg nnend_reg;
     assign nnend  = nnend_reg;
     //reg [7:0]weight_cycle;
 
     wire [31:0] cnt;
     wire [31:0] calc_cnt;
     assign cnt = cnt_reg;
     //assign calc_cnt = calc_cnt_reg;
     assign calc_cnt = cnt - 2;
     //reg [4:0] num_of_calc;
     reg [31:0] num_of_calc;  // saka
                  
     reg [7:0] data [127:0];              
     reg signed [7:0] weight [127:0];   //1module
 
     
     always @(posedge nnclk or negedge nnreset_n)
     
     
         begin
            if(!nnreset_n)
            begin
                 state_reg <= `STATE_IDLE;
                 cnt_reg      <= 0;
                 cnt_node_reg<=0;
                 num_of_calc <= 0;
     
                 nnend_reg    <= 0;
                 nnnext <= 0;
                        
                 weight_addr_reg <= 0;
                 weight_din_reg  <= 0;
                 weight_en_reg   <= 1;
                 weight_we_reg   <= 0;
     
                 data_addr_reg  <= 0;
                 data_din_reg   <= 0;
                 data_en_reg    <= 1;
                 data_we_reg    <= 0;
                 
                 output_addr_reg  <= 0;
                 output_en_reg    <= 1;
                 output_we_reg    <= 0;    
 
                 for (j = 0 ; j <= 128 - 1 ; j = j + 1 ) begin
                     data[j] <= 0;
                     weight[j] <= 0;
                 end
 
                 nn128write <= 0;
                 
 
                 //for (j = 0 ; j <= `NUM_OF_OUTPUT - 1 ; j = j + 1 ) begin
                 for (j = 0 ; j <= 29 ; j = j + 1 ) begin
                 calc_output_reg_check[j] <= 0;
                 end     
  
                 
                // weight_cycle <= (0 < num_of_input < 32)? 32 : (num_of_input < 256)? 256 : (num_of_input < 512)? 512 : 1024;
                
         end else begin 
             case(state_reg) 
                 `STATE_IDLE : 
                     begin
                     if(nnstart)
                         begin
                         
                         //if((num_of_calc +1)*128 > num_of_input -1)  //saka
                         if(((num_of_calc +1)*128) > (num_of_input -1))
                             begin
                                 state_reg<=`STATE_LASTCALC;
 
                                 for (j = 0 ; j <= 128 - 1 ; j = j + 1 ) begin
                                     data[j] <= 0;
                                     weight[j] <= 0;
                                 end
 
                             end
                         else //if((num_of_calc+1)*128 < num_of_input)
                             begin
                                 
                                 state_reg<=`STATE_CALC;
                             end
                         end else begin     
                             cnt_reg      <= 0;
                             cnt_node_reg<=0;
                             num_of_calc <= 0;
             
                             nnend_reg    <= 0;
                             nnnext <= 0;
                                
                             weight_addr_reg <= 0;
                             weight_din_reg  <= 0;
                             weight_en_reg   <= 1;
                             weight_we_reg   <= 0;
             
                             data_addr_reg  <= 0;
                             data_din_reg   <= 0;
                             data_en_reg    <= 1;
                             data_we_reg    <= 0;
                         
                             output_addr_reg  <= 0;
                             output_en_reg    <= 1;
                             output_we_reg    <= 0;    
         
                             for (j = 0 ; j <= 128 - 1 ; j = j + 1 ) begin
                                 data[j] <= 0;
                                 weight[j] <= 0;
                             end
                             nn128write <= 0;
                         
                             //for (j = 0 ; j <= `NUM_OF_OUTPUT - 1 ; j = j + 1 ) begin
                             for (j = 0 ; j <= 29 ; j = j + 1 ) begin
                                 calc_output_reg_check[j] <= 0;
                             end
                             end
                     end
                 `STATE_CALC :
                     begin      
                         cnt_reg <= cnt_reg + 1;
                         //if(calc_cnt>=0 && calc_cnt*4+3 < 128) begin   // saka
                         if((calc_cnt>=0) && (((calc_cnt*4+3) < 128))) begin
                             data[calc_cnt*4+0]<=data_dout[8*3+:8];
                             data[calc_cnt*4+1]<=data_dout[8*2+:8];
                             data[calc_cnt*4+2]<=data_dout[8*1+:8];
                             data[calc_cnt*4+3]<=data_dout[8*0+:8];
                             weight[calc_cnt*4+0]<=weight_dout[8*3+:8];
                             weight[calc_cnt*4+1]<=weight_dout[8*2+:8]; 
                             weight[calc_cnt*4+2]<=weight_dout[8*1+:8];
                             weight[calc_cnt*4+3]<=weight_dout[8*0+:8]; 
                         end
                         //else if(calc_cnt*4+0 ==128)
                         else if(calc_cnt*4 ==128)    // saka
                             begin
                                 num_of_calc <= num_of_calc +1; 
                                 nnnext <= 1;
                                 //nn128write <= 1;
                                // nn128write <= 0;
                                 calc_output_reg_check[cnt_node_reg] <= calc_output_reg_check[cnt_node_reg] + calc_output_check;
                                 state_reg <= `STATE_CHECK;//                              
                             end                                                       
 //                        if(nnnext == 1)begin
 //                            nn128write <= 0;
 //                            //calc_output_reg[cnt_node_reg] <= calc_output_reg[cnt_node_reg] + calc_output;
 //                            calc_output_reg_check[cnt_node_reg] <= calc_output_reg_check[cnt_node_reg] + calc_output_check;
 //                            state_reg <= `STATE_CHECK;//6/15kokomade
 //                        end
 //                        else begin
                         //if(calc_cnt*4+0 != 128 && calc_cnt*4+0 != 124)begin  // saka
                         if((calc_cnt*4 != 128) && (calc_cnt*4 != 124))begin
                             data_addr_reg <= data_addr_reg + 4;
                             weight_addr_reg <= weight_addr_reg + 4;
                         end
                         //else if (calc_cnt*4+0 == 124)begin    // saka
                         else if (calc_cnt*4 == 124)begin
                             data_addr_reg <= data_addr_reg -8;
                             weight_addr_reg <= weight_addr_reg -8;
                         end
                     end
                 `STATE_LASTCALC:
                     begin
                     cnt_reg <= cnt_reg + 1;
                     //if(calc_cnt>=0 && calc_cnt*4 + 3 < num_of_input - 1 - 128*num_of_calc ) begin  // saka
                     if((calc_cnt>=0) && ((calc_cnt*4 + 3) < (num_of_input - 1 - (128*num_of_calc))) ) begin
                                 data[calc_cnt*4+0]<=data_dout[8*3+:8];
                                 data[calc_cnt*4+1]<=data_dout[8*2+:8];
                                 data[calc_cnt*4+2]<=data_dout[8*1+:8];
                                 data[calc_cnt*4+3]<=data_dout[8*0+:8];
                                 weight[calc_cnt*4+0]<=weight_dout[8*3+:8];
                                 weight[calc_cnt*4+1]<=weight_dout[8*2+:8]; 
                                 weight[calc_cnt*4+2]<=weight_dout[8*1+:8];
                                 weight[calc_cnt*4+3]<=weight_dout[8*0+:8];  
                         end else begin
                     //if(calc_cnt*4 + 3 == num_of_input - 1 - 128*num_of_calc)  begin  // saka
                     if((calc_cnt*4 + 3) == (num_of_input - 1 - (128*num_of_calc)))  begin
                                 data[calc_cnt*4+0]<=data_dout[8*3+:8];
                                 data[calc_cnt*4+1]<=data_dout[8*2+:8];
                                 data[calc_cnt*4+2]<=data_dout[8*1+:8];
                                 data[calc_cnt*4+3]<=data_dout[8*0+:8];
                                 weight[calc_cnt*4+0]<=weight_dout[8*3+:8];
                                 weight[calc_cnt*4+1]<=weight_dout[8*2+:8]; 
                                 weight[calc_cnt*4+2]<=weight_dout[8*1+:8];
                                 weight[calc_cnt*4+3]<=weight_dout[8*0+:8];  
                                                 nnnext <= 1;
                                                 nn128write <= 1;
                         end
                     //else if(calc_cnt*4 + 2 == num_of_input - 1 - 128*num_of_calc)  begin  // saka
                     else if( (calc_cnt*4 + 2) == (num_of_input - 1 - (128*num_of_calc)))  begin
                                                 data[calc_cnt*4+0]<=data_dout[8*3+:8];
                                                 data[calc_cnt*4+1]<=data_dout[8*2+:8];
                                                 data[calc_cnt*4+2]<=data_dout[8*1+:8];
                                                 weight[calc_cnt*4+0]<=weight_dout[8*3+:8];
                                                 weight[calc_cnt*4+1]<=weight_dout[8*2+:8]; 
                                                 weight[calc_cnt*4+2]<=weight_dout[8*1+:8]; 
                                                 nnnext <= 1;    
                                                 nn128write <= 1;             
                         end
                     //else if(calc_cnt*4 + 1 ==num_of_input - 1 - 128*num_of_calc)  begin    // saka
                     else if((calc_cnt*4 + 1) == (num_of_input - 1 - (128*num_of_calc)))  begin
                                                 data[calc_cnt*4+0]<=data_dout[8*3+:8];
                                                 data[calc_cnt*4+1]<=data_dout[8*2+:8];
                                                 weight[calc_cnt*4+0]<=weight_dout[8*3+:8];
                                                 weight[calc_cnt*4+1]<=weight_dout[8*2+:8];
                                                 nnnext <= 1;   
                                                 nn128write <= 1;               
                         end
                     //else if(calc_cnt*4 == num_of_input - 1 - 128*num_of_calc)  begin
                     else if((calc_cnt*4) == (num_of_input - 1 - (128*num_of_calc)))  begin
                                                 data[calc_cnt*4+0]<=data_dout[8*3+:8];
                                                 weight[calc_cnt*4+0]<=weight_dout[8*3+:8]; 
                                                 nnnext <= 1;   
                                                 nn128write <= 1;               
                         end
                         end
                         
                         if(nnnext==1)begin
                             nn128write <= 0;
                             //calc_output_reg[cnt_node_reg] <= calc_output_reg[cnt_node_reg] + calc_output;
                             calc_output_reg_check[cnt_node_reg] <= calc_output_reg_check[cnt_node_reg] + calc_output_check;
                             
                             cnt_reg <= 0;
                             state_reg<=`STATE_WRITE;  
                             //state_reg<=`STATE_INIT;                              
                         end //of if(nnnext==1)
                         else begin
                             data_addr_reg <= data_addr_reg + 4;
                             weight_addr_reg <= weight_addr_reg + 4;
                         end
                     end
                 `STATE_INIT:
                     begin
                     output_we_reg    <= 0;
                     if(cnt_reg==0)begin
                         if(cnt_node_reg == num_of_output - 1)begin
                             state_reg <= `STATE_END;
                             nnnext <= 0;
                             end
                         else if(cnt_node_reg < num_of_output - 1)begin    
                             cnt_node_reg <= cnt_node_reg + 1;
                             output_addr_reg  <= output_addr_reg + 4;
                             data_addr_reg <= 0;
                             //weight_addr_reg <= (cnt_node_reg+1)*`WEIGHT_CYCLE;      
                             weight_addr_reg <= (cnt_node_reg+1)*1024;       
                             nnnext <= 0;
                             cnt_reg <= cnt_reg + 1;
                         end
                     end else if(cnt_reg == 1)begin
                         cnt_reg <= 0;
                         num_of_calc <= 0;
                         state_reg <= `STATE_CHECK;
                     end
                     end
                 `STATE_CHECK :
                 begin
                 nnnext <= 0;
                     //if((num_of_calc+1) * 128 > num_of_input - 1)begin   // saka
                     if(((num_of_calc+1) * 128) > (num_of_input - 1))begin
                         state_reg<=`STATE_LASTCALC;
                         cnt_reg<=0;
 
                             for (j = 0 ; j <= 128 - 1 ; j = j + 1 ) begin
                             data[j] <= 0;
                             weight[j] <= 0;
                             end
 
               
                     end
                     else //if((num_of_calc+1)*128 < num_of_input)
                         begin
                         cnt_reg<=0;
                         state_reg<=`STATE_CALC;
                     end
                 end
                 
                 `STATE_WRITE :
                 begin         
                     output_we_reg    <= 4'b1111;
                     state_reg<=`STATE_INIT;
                 end
                 
                 `STATE_END : 
                 begin
                 
                     cnt_reg <= 0;
                     nnend_reg <= 1;
                     if(!nnstart)
                         begin
                         state_reg <= `STATE_IDLE;
                         nnend_reg <= 0;                
                         weight_addr_reg <= 0;
                         data_addr_reg <= 0;               
                         end
                 end //of `STATE_END
             endcase                
         end    
     end        
     
      wire signed [31:0] sum;
      wire signed [15:0] data_wire [127:0];
      
      function    [15:0]  multi;
          input   [7:0]   a;
          input   [7:0]   b;
          reg             a_flag;
          reg             b_flag;
          reg     [7:0]   a_tmp;
          reg     [7:0]   b_tmp;
          begin
              if(a[7]==1'b1)begin
                  a_tmp[7:0] = (~a[7:0])+8'd1;
                  a_flag = 1;
              end else begin
                  a_tmp = a;
                  a_flag = 0;
              end
 
              if(b[7]==1'b1)begin
                  b_tmp[7:0] = (~b[7:0])+8'd1;
                  b_flag = 1;
              end else begin
                  b_tmp = b;
                  b_flag = 0;
              end
  
              if(((a_flag==1'b0)&&(b_flag==1'b0))||((a_flag==1'b1)&&(b_flag==1'b1)))begin
                  multi[15:0] = (a_tmp[7:0]*b_tmp[7:0]);
              end else if(((a_flag==1'b0)&&(b_flag==1'b1))||((a_flag==1'b1)&&(b_flag==1'b0)))begin
                  multi[15:0] = (~(a_tmp[7:0]*b_tmp[7:0]))+16'd1;
              end else begin
                  multi[15:0] = 16'h0000;
              end
          end
      endfunction     
      
        generate
            genvar i;
            for (i = 0 ; i <= 128 - 1 ; i = i + 1 ) begin
            //assign data_wire[i]= $signed(({1'b0,in_128[i]})*weight_in_128[i]); 
            //assign data_wire[i]= data[i]*weight[i];
            //assign data_wire[i]= $signed({1'b0,data[i]})*weight[i];
            assign data_wire[i] = multi(data[i],weight[i]);
            end
        endgenerate
 
 
   wire [22:0] sum_00_tmp;
 
   wire [21:0] sum_10_tmp;
   wire [21:0] sum_11_tmp;
 
   wire [20:0] sum_20_tmp;
   wire [20:0] sum_21_tmp;
   wire [20:0] sum_22_tmp;
   wire [20:0] sum_23_tmp;
 
   wire [19:0] sum_30_tmp;
   wire [19:0] sum_31_tmp;
   wire [19:0] sum_32_tmp;
   wire [19:0] sum_33_tmp;
   wire [19:0] sum_34_tmp;
   wire [19:0] sum_35_tmp;
   wire [19:0] sum_36_tmp;
   wire [19:0] sum_37_tmp;
 
   wire [18:0] sum_40_tmp;
   wire [18:0] sum_41_tmp;
   wire [18:0] sum_42_tmp;
   wire [18:0] sum_43_tmp;
   wire [18:0] sum_44_tmp;
   wire [18:0] sum_45_tmp;
   wire [18:0] sum_46_tmp;
   wire [18:0] sum_47_tmp;
   wire [18:0] sum_48_tmp;
   wire [18:0] sum_49_tmp;
   wire [18:0] sum_4a_tmp;
   wire [18:0] sum_4b_tmp;
   wire [18:0] sum_4c_tmp;
   wire [18:0] sum_4d_tmp;
   wire [18:0] sum_4e_tmp;
   wire [18:0] sum_4f_tmp;
 
   wire [17:0] sum_50_tmp;
   wire [17:0] sum_51_tmp;
   wire [17:0] sum_52_tmp;
   wire [17:0] sum_53_tmp;
   wire [17:0] sum_54_tmp;
   wire [17:0] sum_55_tmp;
   wire [17:0] sum_56_tmp;
   wire [17:0] sum_57_tmp;
   wire [17:0] sum_58_tmp;
   wire [17:0] sum_59_tmp;
   wire [17:0] sum_5a_tmp;
   wire [17:0] sum_5b_tmp;
   wire [17:0] sum_5c_tmp;
   wire [17:0] sum_5d_tmp;
   wire [17:0] sum_5e_tmp;
   wire [17:0] sum_5f_tmp;
   wire [17:0] sum_510_tmp;
   wire [17:0] sum_511_tmp;
   wire [17:0] sum_512_tmp;
   wire [17:0] sum_513_tmp;
   wire [17:0] sum_514_tmp;
   wire [17:0] sum_515_tmp;
   wire [17:0] sum_516_tmp;
   wire [17:0] sum_517_tmp;
   wire [17:0] sum_518_tmp;
   wire [17:0] sum_519_tmp;
   wire [17:0] sum_51a_tmp;
   wire [17:0] sum_51b_tmp;
   wire [17:0] sum_51c_tmp;
   wire [17:0] sum_51d_tmp;
   wire [17:0] sum_51e_tmp;
   wire [17:0] sum_51f_tmp;
 
   wire [16:0] sum_60_tmp;
   wire [16:0] sum_61_tmp;
   wire [16:0] sum_62_tmp;
   wire [16:0] sum_63_tmp;
   wire [16:0] sum_64_tmp;
   wire [16:0] sum_65_tmp;
   wire [16:0] sum_66_tmp;
   wire [16:0] sum_67_tmp;
   wire [16:0] sum_68_tmp;
   wire [16:0] sum_69_tmp;
   wire [16:0] sum_6a_tmp;
   wire [16:0] sum_6b_tmp;
   wire [16:0] sum_6c_tmp;
   wire [16:0] sum_6d_tmp;
   wire [16:0] sum_6e_tmp;
   wire [16:0] sum_6f_tmp;
   wire [16:0] sum_610_tmp;
   wire [16:0] sum_611_tmp;
   wire [16:0] sum_612_tmp;
   wire [16:0] sum_613_tmp;
   wire [16:0] sum_614_tmp;
   wire [16:0] sum_615_tmp;
   wire [16:0] sum_616_tmp;
   wire [16:0] sum_617_tmp;
   wire [16:0] sum_618_tmp;
   wire [16:0] sum_619_tmp;
   wire [16:0] sum_61a_tmp;
   wire [16:0] sum_61b_tmp;
   wire [16:0] sum_61c_tmp;
   wire [16:0] sum_61d_tmp;
   wire [16:0] sum_61e_tmp;
   wire [16:0] sum_61f_tmp;
   wire [16:0] sum_620_tmp;
   wire [16:0] sum_621_tmp;
   wire [16:0] sum_622_tmp;
   wire [16:0] sum_623_tmp;
   wire [16:0] sum_624_tmp;
   wire [16:0] sum_625_tmp;
   wire [16:0] sum_626_tmp;
   wire [16:0] sum_627_tmp;
   wire [16:0] sum_628_tmp;
   wire [16:0] sum_629_tmp;
   wire [16:0] sum_62a_tmp;
   wire [16:0] sum_62b_tmp;
   wire [16:0] sum_62c_tmp;
   wire [16:0] sum_62d_tmp;
   wire [16:0] sum_62e_tmp;
   wire [16:0] sum_62f_tmp;
   wire [16:0] sum_630_tmp;
   wire [16:0] sum_631_tmp;
   wire [16:0] sum_632_tmp;
   wire [16:0] sum_633_tmp;
   wire [16:0] sum_634_tmp;
   wire [16:0] sum_635_tmp;
   wire [16:0] sum_636_tmp;
   wire [16:0] sum_637_tmp;
   wire [16:0] sum_638_tmp;
   wire [16:0] sum_639_tmp;
   wire [16:0] sum_63a_tmp;
   wire [16:0] sum_63b_tmp;
   wire [16:0] sum_63c_tmp;
   wire [16:0] sum_63d_tmp;
   wire [16:0] sum_63e_tmp;
   wire [16:0] sum_63f_tmp;
 
   assign sum_00_tmp[22:0] =  {sum_10_tmp[21],sum_10_tmp[21:0]} + {sum_11_tmp[21],sum_11_tmp[21:0]};
 
   assign sum_10_tmp[21:0] =  {sum_20_tmp[20],sum_20_tmp[20:0]} + {sum_21_tmp[20],sum_21_tmp[20:0]};
   assign sum_11_tmp[21:0] =  {sum_22_tmp[20],sum_22_tmp[20:0]} + {sum_23_tmp[20],sum_23_tmp[20:0]};
 
   assign sum_20_tmp[20:0] =  {sum_30_tmp[19],sum_30_tmp[19:0]} + {sum_31_tmp[19],sum_31_tmp[19:0]};
   assign sum_21_tmp[20:0] =  {sum_32_tmp[19],sum_32_tmp[19:0]} + {sum_33_tmp[19],sum_33_tmp[19:0]};
   assign sum_22_tmp[20:0] =  {sum_34_tmp[19],sum_34_tmp[19:0]} + {sum_35_tmp[19],sum_35_tmp[19:0]};
   assign sum_23_tmp[20:0] =  {sum_36_tmp[19],sum_36_tmp[19:0]} + {sum_37_tmp[19],sum_37_tmp[19:0]};
 
   assign sum_30_tmp[19:0] =  {sum_40_tmp[18],sum_40_tmp[18:0]} + {sum_41_tmp[18],sum_41_tmp[18:0]};
   assign sum_31_tmp[19:0] =  {sum_42_tmp[18],sum_42_tmp[18:0]} + {sum_43_tmp[18],sum_43_tmp[18:0]};
   assign sum_32_tmp[19:0] =  {sum_44_tmp[18],sum_44_tmp[18:0]} + {sum_45_tmp[18],sum_45_tmp[18:0]};
   assign sum_33_tmp[19:0] =  {sum_46_tmp[18],sum_46_tmp[18:0]} + {sum_47_tmp[18],sum_47_tmp[18:0]};
   assign sum_34_tmp[19:0] =  {sum_48_tmp[18],sum_48_tmp[18:0]} + {sum_49_tmp[18],sum_49_tmp[18:0]};
   assign sum_35_tmp[19:0] =  {sum_4a_tmp[18],sum_4a_tmp[18:0]} + {sum_4b_tmp[18],sum_4b_tmp[18:0]};
   assign sum_36_tmp[19:0] =  {sum_4c_tmp[18],sum_4c_tmp[18:0]} + {sum_4d_tmp[18],sum_4d_tmp[18:0]};
   assign sum_37_tmp[19:0] =  {sum_4e_tmp[18],sum_4e_tmp[18:0]} + {sum_4f_tmp[18],sum_4f_tmp[18:0]};
 
   assign sum_40_tmp[18:0] =  {sum_50_tmp[17],sum_50_tmp[17:0]} + {sum_51_tmp[17],sum_51_tmp[17:0]};
   assign sum_41_tmp[18:0] =  {sum_52_tmp[17],sum_52_tmp[17:0]} + {sum_53_tmp[17],sum_53_tmp[17:0]};
   assign sum_42_tmp[18:0] =  {sum_54_tmp[17],sum_54_tmp[17:0]} + {sum_55_tmp[17],sum_55_tmp[17:0]};
   assign sum_43_tmp[18:0] =  {sum_56_tmp[17],sum_56_tmp[17:0]} + {sum_57_tmp[17],sum_57_tmp[17:0]};
   assign sum_44_tmp[18:0] =  {sum_58_tmp[17],sum_58_tmp[17:0]} + {sum_59_tmp[17],sum_59_tmp[17:0]};
   assign sum_45_tmp[18:0] =  {sum_5a_tmp[17],sum_5a_tmp[17:0]} + {sum_5b_tmp[17],sum_5b_tmp[17:0]};
   assign sum_46_tmp[18:0] =  {sum_5c_tmp[17],sum_5c_tmp[17:0]} + {sum_5d_tmp[17],sum_5d_tmp[17:0]};
   assign sum_47_tmp[18:0] =  {sum_5e_tmp[17],sum_5e_tmp[17:0]} + {sum_5f_tmp[17],sum_5f_tmp[17:0]};
   assign sum_48_tmp[18:0] =  {sum_510_tmp[17],sum_510_tmp[17:0]} + {sum_511_tmp[17],sum_511_tmp[17:0]};
   assign sum_49_tmp[18:0] =  {sum_512_tmp[17],sum_512_tmp[17:0]} + {sum_513_tmp[17],sum_513_tmp[17:0]};
   assign sum_4a_tmp[18:0] =  {sum_514_tmp[17],sum_514_tmp[17:0]} + {sum_515_tmp[17],sum_515_tmp[17:0]};
   assign sum_4b_tmp[18:0] =  {sum_516_tmp[17],sum_516_tmp[17:0]} + {sum_517_tmp[17],sum_517_tmp[17:0]};
   assign sum_4c_tmp[18:0] =  {sum_518_tmp[17],sum_518_tmp[17:0]} + {sum_519_tmp[17],sum_519_tmp[17:0]};
   assign sum_4d_tmp[18:0] =  {sum_51a_tmp[17],sum_51a_tmp[17:0]} + {sum_51b_tmp[17],sum_51b_tmp[17:0]};
   assign sum_4e_tmp[18:0] =  {sum_51c_tmp[17],sum_51c_tmp[17:0]} + {sum_51d_tmp[17],sum_51d_tmp[17:0]};
   assign sum_4f_tmp[18:0] =  {sum_51e_tmp[17],sum_51e_tmp[17:0]} + {sum_51f_tmp[17],sum_51f_tmp[17:0]};
 
   assign sum_50_tmp[17:0] =  {sum_60_tmp[16],sum_60_tmp[16:0]} + {sum_61_tmp[16],sum_61_tmp[16:0]};
   assign sum_51_tmp[17:0] =  {sum_62_tmp[16],sum_62_tmp[16:0]} + {sum_63_tmp[16],sum_63_tmp[16:0]};
   assign sum_52_tmp[17:0] =  {sum_64_tmp[16],sum_64_tmp[16:0]} + {sum_65_tmp[16],sum_65_tmp[16:0]};
   assign sum_53_tmp[17:0] =  {sum_66_tmp[16],sum_66_tmp[16:0]} + {sum_67_tmp[16],sum_67_tmp[16:0]};
   assign sum_54_tmp[17:0] =  {sum_68_tmp[16],sum_68_tmp[16:0]} + {sum_69_tmp[16],sum_69_tmp[16:0]};
   assign sum_55_tmp[17:0] =  {sum_6a_tmp[16],sum_6a_tmp[16:0]} + {sum_6b_tmp[16],sum_6b_tmp[16:0]};
   assign sum_56_tmp[17:0] =  {sum_6c_tmp[16],sum_6c_tmp[16:0]} + {sum_6d_tmp[16],sum_6d_tmp[16:0]};
   assign sum_57_tmp[17:0] =  {sum_6e_tmp[16],sum_6e_tmp[16:0]} + {sum_6f_tmp[16],sum_6f_tmp[16:0]};
   assign sum_58_tmp[17:0] =  {sum_610_tmp[16],sum_610_tmp[16:0]} + {sum_611_tmp[16],sum_611_tmp[16:0]};
   assign sum_59_tmp[17:0] =  {sum_612_tmp[16],sum_612_tmp[16:0]} + {sum_613_tmp[16],sum_613_tmp[16:0]};
   assign sum_5a_tmp[17:0] =  {sum_614_tmp[16],sum_614_tmp[16:0]} + {sum_615_tmp[16],sum_615_tmp[16:0]};
   assign sum_5b_tmp[17:0] =  {sum_616_tmp[16],sum_616_tmp[16:0]} + {sum_617_tmp[16],sum_617_tmp[16:0]};
   assign sum_5c_tmp[17:0] =  {sum_618_tmp[16],sum_618_tmp[16:0]} + {sum_619_tmp[16],sum_619_tmp[16:0]};
   assign sum_5d_tmp[17:0] =  {sum_61a_tmp[16],sum_61a_tmp[16:0]} + {sum_61b_tmp[16],sum_61b_tmp[16:0]};
   assign sum_5e_tmp[17:0] =  {sum_61c_tmp[16],sum_61c_tmp[16:0]} + {sum_61d_tmp[16],sum_61d_tmp[16:0]};
   assign sum_5f_tmp[17:0] =  {sum_61e_tmp[16],sum_61e_tmp[16:0]} + {sum_61f_tmp[16],sum_61f_tmp[16:0]};
   assign sum_510_tmp[17:0] =  {sum_620_tmp[16],sum_620_tmp[16:0]} + {sum_621_tmp[16],sum_621_tmp[16:0]};
   assign sum_511_tmp[17:0] =  {sum_622_tmp[16],sum_622_tmp[16:0]} + {sum_623_tmp[16],sum_623_tmp[16:0]};
   assign sum_512_tmp[17:0] =  {sum_624_tmp[16],sum_624_tmp[16:0]} + {sum_625_tmp[16],sum_625_tmp[16:0]};
   assign sum_513_tmp[17:0] =  {sum_626_tmp[16],sum_626_tmp[16:0]} + {sum_627_tmp[16],sum_627_tmp[16:0]};
   assign sum_514_tmp[17:0] =  {sum_628_tmp[16],sum_628_tmp[16:0]} + {sum_629_tmp[16],sum_629_tmp[16:0]};
   assign sum_515_tmp[17:0] =  {sum_62a_tmp[16],sum_62a_tmp[16:0]} + {sum_62b_tmp[16],sum_62b_tmp[16:0]};
   assign sum_516_tmp[17:0] =  {sum_62c_tmp[16],sum_62c_tmp[16:0]} + {sum_62d_tmp[16],sum_62d_tmp[16:0]};
   assign sum_517_tmp[17:0] =  {sum_62e_tmp[16],sum_62e_tmp[16:0]} + {sum_62f_tmp[16],sum_62f_tmp[16:0]};
   assign sum_518_tmp[17:0] =  {sum_630_tmp[16],sum_630_tmp[16:0]} + {sum_631_tmp[16],sum_631_tmp[16:0]};
   assign sum_519_tmp[17:0] =  {sum_632_tmp[16],sum_632_tmp[16:0]} + {sum_633_tmp[16],sum_633_tmp[16:0]};
   assign sum_51a_tmp[17:0] =  {sum_634_tmp[16],sum_634_tmp[16:0]} + {sum_635_tmp[16],sum_635_tmp[16:0]};
   assign sum_51b_tmp[17:0] =  {sum_636_tmp[16],sum_636_tmp[16:0]} + {sum_637_tmp[16],sum_637_tmp[16:0]};
   assign sum_51c_tmp[17:0] =  {sum_638_tmp[16],sum_638_tmp[16:0]} + {sum_639_tmp[16],sum_639_tmp[16:0]};
   assign sum_51d_tmp[17:0] =  {sum_63a_tmp[16],sum_63a_tmp[16:0]} + {sum_63b_tmp[16],sum_63b_tmp[16:0]};
   assign sum_51e_tmp[17:0] =  {sum_63c_tmp[16],sum_63c_tmp[16:0]} + {sum_63d_tmp[16],sum_63d_tmp[16:0]};
   assign sum_51f_tmp[17:0] =  {sum_63e_tmp[16],sum_63e_tmp[16:0]} + {sum_63f_tmp[16],sum_63f_tmp[16:0]};
 
   assign sum_60_tmp[16:0] =  {data_wire[0][15],data_wire[0][15:0]} + {data_wire[1][15],data_wire[1][15:0]};
   assign sum_61_tmp[16:0] =  {data_wire[2][15],data_wire[2][15:0]} + {data_wire[3][15],data_wire[3][15:0]};
   assign sum_62_tmp[16:0] =  {data_wire[4][15],data_wire[4][15:0]} + {data_wire[5][15],data_wire[5][15:0]};
   assign sum_63_tmp[16:0] =  {data_wire[6][15],data_wire[6][15:0]} + {data_wire[7][15],data_wire[7][15:0]};
   assign sum_64_tmp[16:0] =  {data_wire[8][15],data_wire[8][15:0]} + {data_wire[9][15],data_wire[9][15:0]};
   assign sum_65_tmp[16:0] =  {data_wire[10][15],data_wire[10][15:0]} + {data_wire[11][15],data_wire[11][15:0]};
   assign sum_66_tmp[16:0] =  {data_wire[12][15],data_wire[12][15:0]} + {data_wire[13][15],data_wire[13][15:0]};
   assign sum_67_tmp[16:0] =  {data_wire[14][15],data_wire[14][15:0]} + {data_wire[15][15],data_wire[15][15:0]};
   assign sum_68_tmp[16:0] =  {data_wire[16][15],data_wire[16][15:0]} + {data_wire[17][15],data_wire[17][15:0]};
   assign sum_69_tmp[16:0] =  {data_wire[18][15],data_wire[18][15:0]} + {data_wire[19][15],data_wire[19][15:0]};
   assign sum_6a_tmp[16:0] =  {data_wire[20][15],data_wire[20][15:0]} + {data_wire[21][15],data_wire[21][15:0]};
   assign sum_6b_tmp[16:0] =  {data_wire[22][15],data_wire[22][15:0]} + {data_wire[23][15],data_wire[23][15:0]};
   assign sum_6c_tmp[16:0] =  {data_wire[24][15],data_wire[24][15:0]} + {data_wire[25][15],data_wire[25][15:0]};
   assign sum_6d_tmp[16:0] =  {data_wire[26][15],data_wire[26][15:0]} + {data_wire[27][15],data_wire[27][15:0]};
   assign sum_6e_tmp[16:0] =  {data_wire[28][15],data_wire[28][15:0]} + {data_wire[29][15],data_wire[29][15:0]};
   assign sum_6f_tmp[16:0] =  {data_wire[30][15],data_wire[30][15:0]} + {data_wire[31][15],data_wire[31][15:0]};
   assign sum_610_tmp[16:0] =  {data_wire[32][15],data_wire[32][15:0]} + {data_wire[33][15],data_wire[33][15:0]};
   assign sum_611_tmp[16:0] =  {data_wire[34][15],data_wire[34][15:0]} + {data_wire[35][15],data_wire[35][15:0]};
   assign sum_612_tmp[16:0] =  {data_wire[36][15],data_wire[36][15:0]} + {data_wire[37][15],data_wire[37][15:0]};
   assign sum_613_tmp[16:0] =  {data_wire[38][15],data_wire[38][15:0]} + {data_wire[39][15],data_wire[39][15:0]};
   assign sum_614_tmp[16:0] =  {data_wire[40][15],data_wire[40][15:0]} + {data_wire[41][15],data_wire[41][15:0]};
   assign sum_615_tmp[16:0] =  {data_wire[42][15],data_wire[42][15:0]} + {data_wire[43][15],data_wire[43][15:0]};
   assign sum_616_tmp[16:0] =  {data_wire[44][15],data_wire[44][15:0]} + {data_wire[45][15],data_wire[45][15:0]};
   assign sum_617_tmp[16:0] =  {data_wire[46][15],data_wire[46][15:0]} + {data_wire[47][15],data_wire[47][15:0]};
   assign sum_618_tmp[16:0] =  {data_wire[48][15],data_wire[48][15:0]} + {data_wire[49][15],data_wire[49][15:0]};
   assign sum_619_tmp[16:0] =  {data_wire[50][15],data_wire[50][15:0]} + {data_wire[51][15],data_wire[51][15:0]};
   assign sum_61a_tmp[16:0] =  {data_wire[52][15],data_wire[52][15:0]} + {data_wire[53][15],data_wire[53][15:0]};
   assign sum_61b_tmp[16:0] =  {data_wire[54][15],data_wire[54][15:0]} + {data_wire[55][15],data_wire[55][15:0]};
   assign sum_61c_tmp[16:0] =  {data_wire[56][15],data_wire[56][15:0]} + {data_wire[57][15],data_wire[57][15:0]};
   assign sum_61d_tmp[16:0] =  {data_wire[58][15],data_wire[58][15:0]} + {data_wire[59][15],data_wire[59][15:0]};
   assign sum_61e_tmp[16:0] =  {data_wire[60][15],data_wire[60][15:0]} + {data_wire[61][15],data_wire[61][15:0]};
   assign sum_61f_tmp[16:0] =  {data_wire[62][15],data_wire[62][15:0]} + {data_wire[63][15],data_wire[63][15:0]};
   assign sum_620_tmp[16:0] =  {data_wire[64][15],data_wire[64][15:0]} + {data_wire[65][15],data_wire[65][15:0]};
   assign sum_621_tmp[16:0] =  {data_wire[66][15],data_wire[66][15:0]} + {data_wire[67][15],data_wire[67][15:0]};
   assign sum_622_tmp[16:0] =  {data_wire[68][15],data_wire[68][15:0]} + {data_wire[69][15],data_wire[69][15:0]};
   assign sum_623_tmp[16:0] =  {data_wire[70][15],data_wire[70][15:0]} + {data_wire[71][15],data_wire[71][15:0]};
   assign sum_624_tmp[16:0] =  {data_wire[72][15],data_wire[72][15:0]} + {data_wire[73][15],data_wire[73][15:0]};
   assign sum_625_tmp[16:0] =  {data_wire[74][15],data_wire[74][15:0]} + {data_wire[75][15],data_wire[75][15:0]};
   assign sum_626_tmp[16:0] =  {data_wire[76][15],data_wire[76][15:0]} + {data_wire[77][15],data_wire[77][15:0]};
   assign sum_627_tmp[16:0] =  {data_wire[78][15],data_wire[78][15:0]} + {data_wire[79][15],data_wire[79][15:0]};
   assign sum_628_tmp[16:0] =  {data_wire[80][15],data_wire[80][15:0]} + {data_wire[81][15],data_wire[81][15:0]};
   assign sum_629_tmp[16:0] =  {data_wire[82][15],data_wire[82][15:0]} + {data_wire[83][15],data_wire[83][15:0]};
   assign sum_62a_tmp[16:0] =  {data_wire[84][15],data_wire[84][15:0]} + {data_wire[85][15],data_wire[85][15:0]};
   assign sum_62b_tmp[16:0] =  {data_wire[86][15],data_wire[86][15:0]} + {data_wire[87][15],data_wire[87][15:0]};
   assign sum_62c_tmp[16:0] =  {data_wire[88][15],data_wire[88][15:0]} + {data_wire[89][15],data_wire[89][15:0]};
   assign sum_62d_tmp[16:0] =  {data_wire[90][15],data_wire[90][15:0]} + {data_wire[91][15],data_wire[91][15:0]};
   assign sum_62e_tmp[16:0] =  {data_wire[92][15],data_wire[92][15:0]} + {data_wire[93][15],data_wire[93][15:0]};
   assign sum_62f_tmp[16:0] =  {data_wire[94][15],data_wire[94][15:0]} + {data_wire[95][15],data_wire[95][15:0]};
   assign sum_630_tmp[16:0] =  {data_wire[96][15],data_wire[96][15:0]} + {data_wire[97][15],data_wire[97][15:0]};
   assign sum_631_tmp[16:0] =  {data_wire[98][15],data_wire[98][15:0]} + {data_wire[99][15],data_wire[99][15:0]};
   assign sum_632_tmp[16:0] =  {data_wire[100][15],data_wire[100][15:0]} + {data_wire[101][15],data_wire[101][15:0]};
   assign sum_633_tmp[16:0] =  {data_wire[102][15],data_wire[102][15:0]} + {data_wire[103][15],data_wire[103][15:0]};
   assign sum_634_tmp[16:0] =  {data_wire[104][15],data_wire[104][15:0]} + {data_wire[105][15],data_wire[105][15:0]};
   assign sum_635_tmp[16:0] =  {data_wire[106][15],data_wire[106][15:0]} + {data_wire[107][15],data_wire[107][15:0]};
   assign sum_636_tmp[16:0] =  {data_wire[108][15],data_wire[108][15:0]} + {data_wire[109][15],data_wire[109][15:0]};
   assign sum_637_tmp[16:0] =  {data_wire[110][15],data_wire[110][15:0]} + {data_wire[111][15],data_wire[111][15:0]};
   assign sum_638_tmp[16:0] =  {data_wire[112][15],data_wire[112][15:0]} + {data_wire[113][15],data_wire[113][15:0]};
   assign sum_639_tmp[16:0] =  {data_wire[114][15],data_wire[114][15:0]} + {data_wire[115][15],data_wire[115][15:0]};
   assign sum_63a_tmp[16:0] =  {data_wire[116][15],data_wire[116][15:0]} + {data_wire[117][15],data_wire[117][15:0]};
   assign sum_63b_tmp[16:0] =  {data_wire[118][15],data_wire[118][15:0]} + {data_wire[119][15],data_wire[119][15:0]};
   assign sum_63c_tmp[16:0] =  {data_wire[120][15],data_wire[120][15:0]} + {data_wire[121][15],data_wire[121][15:0]};
   assign sum_63d_tmp[16:0] =  {data_wire[122][15],data_wire[122][15:0]} + {data_wire[123][15],data_wire[123][15:0]};
   assign sum_63e_tmp[16:0] =  {data_wire[124][15],data_wire[124][15:0]} + {data_wire[125][15],data_wire[125][15:0]};
   assign sum_63f_tmp[16:0] =  {data_wire[126][15],data_wire[126][15:0]} + {data_wire[127][15],data_wire[127][15:0]};       
   assign  sum=  sum_00_tmp;

  assign calc_output_check = sum[31:0];               
                                        
 endmodule
//6/17` ,,,state machine made.
`default_nettype wire