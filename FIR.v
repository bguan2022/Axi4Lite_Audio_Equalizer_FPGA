`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Washington University in Saint Louis
// Engineers: Danielle Larson & Owen Rathbone 
// 
// Create Date: 09/09/2019 11:23:04 AM
// Design Name: 
// Module Name: FIR
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module FIR # 
    (parameter C_S_AXI_ADDR_WIDTH = 6, C_S_AXI_DATA_WIDTH = 32)
    (
        // Axi4Lite Bus
    //    output reg  reg_00,
      //  output reg  reg_01,
        //clock and reset
        input       S_AXI_ACLK,
        input       S_AXI_ARESETN,
        // address write channel
        input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
        input       S_AXI_AWVALID,
        output      S_AXI_AWREADY,
        //data write channel
        input       [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
        input       [3:0] S_AXI_WSTRB,
        input       S_AXI_WVALID,
        output      S_AXI_WREADY,
        output      [1:0] S_AXI_BRESP,
        output      S_AXI_BVALID,
        input       S_AXI_BREADY,
        //adress read channel
        input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
        input       S_AXI_ARVALID,
        output      S_AXI_ARREADY,
        //data read channel
        output      [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
        output      [1:0] S_AXI_RRESP,
        output      S_AXI_RVALID,
        input       S_AXI_RREADY        
    );
    
    
 
    
    parameter INIT = 1, IDLE = 2, FIR = 3;
    reg [3:0] nextState, currentState;
    reg DoneD, DoneQ;
    
//internal
wire [C_S_AXI_ADDR_WIDTH-1:0] wrAddr, rdAddr ;
wire [C_S_AXI_DATA_WIDTH-1:0] wrData;  
reg  [C_S_AXI_DATA_WIDTH-1:0] rdData ;
wire wr, rd ;
//flip flop to hold the index for taps
reg[5:0] TapsNumQ, TapsNumD;
//flip flop to hold the index for sine
reg[5:0] SineNumQ, SineNumD;
//flip flop to wrap around for the 61 values 
reg[5:0] BuffNumQ, BuffNumD;

//flip flop to hold incremental sum
reg signed [15:0] SumQ, SumD;
//flip flop to hold final result
reg signed [15:0] ResultQ, ResultD;
//flip flop for counter for arithmetic
reg[5:0] id, iq;
//temporary variables
reg[5:0] a1, a2;
//temporary holders for data in
reg signed[15:0] di1, di2;
//write enable for each of the addressees
reg we1, we2;
//RAM for the taps
reg signed [15:0] taps [63:0];
//RAMs for the sine
reg signed [15:0] sine [63:0];
//flip flop for read data
reg signed [15:0] rdDataD, rdDataQ;



//make the wires/regs for simple bus stuff?
Axi4LiteSupporter #(.C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),.C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH)) Axi4LiteSupporter1 (
    // Simple Bus
    .wrAddr(wrAddr),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
    .wrData(wrData),                    // output   [C_S_AXI_DATA_WIDTH-1:0]
    .wr(wr),                            // output
    .rdAddr(rdAddr),                    // output   [C_S_AXI_ADDR_WIDTH-1:0]
    .rdData(rdData),                                                                                                                            // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .rd(rd),                            // output   
    // Axi4Lite Bus
    .S_AXI_ACLK(S_AXI_ACLK),            // input
    .S_AXI_ARESETN(S_AXI_ARESETN),      // input
    .S_AXI_AWADDR(S_AXI_AWADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .S_AXI_AWVALID(S_AXI_AWVALID),      // input
    .S_AXI_AWREADY(S_AXI_AWREADY),      // output
    .S_AXI_WDATA(S_AXI_WDATA),          // input    [C_S_AXI_DATA_WIDTH-1:0]
    .S_AXI_WSTRB(S_AXI_WSTRB),          // input    [3:0]
    .S_AXI_WVALID(S_AXI_WVALID),        // input
    .S_AXI_WREADY(S_AXI_WREADY),        // output        
    .S_AXI_BRESP(S_AXI_BRESP),          // output   [1:0]
    .S_AXI_BVALID(S_AXI_BVALID),        // output
    .S_AXI_BREADY(S_AXI_BREADY),        // input
    .S_AXI_ARADDR(S_AXI_ARADDR),        // input    [C_S_AXI_ADDR_WIDTH-1:0]
    .S_AXI_ARVALID(S_AXI_ARVALID),      // input
    .S_AXI_ARREADY(S_AXI_ARREADY),      // output
    .S_AXI_RDATA(S_AXI_RDATA),          // output   [C_S_AXI_DATA_WIDTH-1:0]
    .S_AXI_RRESP(S_AXI_RRESP),          // output   [1:0]
    .S_AXI_RVALID(S_AXI_RVALID),        // output    
    .S_AXI_RREADY(S_AXI_RREADY)         // input
    ) ;
    

// Combinational block

always @ * begin
//set all the flip flop values that were set 
    DoneD = DoneQ;
    ResultD= ResultQ;
    TapsNumD = TapsNumQ;
    SineNumD = SineNumQ;
    nextState = currentState;
    rdDataD = rdDataQ;
    SumD=SumQ;
    BuffNumD = BuffNumQ;
    id=iq;
//reset all the base values to 0
    rdData = 0;
    a1 = 0;
    a2 =0;
    di1 = 0;
    di2 = 0;
    we1 = 0;
    we2 = 0;
   



case(currentState)
  
  //the init state that sets the data to all 0s in each of the RAMS
  INIT: begin
    if (iq<61)begin
//set the 0 values 
        di1 = 0;
        di2 = 0;
//enable the write so the data is written
        we1 = 1;
        we2 = 1;
//assign and increment so this is done only 61 times
        a1 = iq;
        a2 = iq;
        id = iq+1;
        nextState = INIT;
    end
    else begin
        id = 0;
//now it is done initializing to 0, so go to idle so that it can read and write
        nextState = IDLE;
    end 
  end

  IDLE: begin
    SumD = 0;
//check if write is asserted
    if(wr) begin
//check if the address is 8 (whether we want to write to taps)
        if(wrAddr==8)begin
            a1 = TapsNumQ;
//shift the data and round before calculations
            di1 = ((wrData+ 'h0080 )>>>8); 
//set write enable so that data is written
            we1 = 1;
//increment tap num so that the next value is read next time
            TapsNumD = TapsNumQ + 1; 
//reset it if it goes out of range          
             if(TapsNumQ > 60) begin
                  TapsNumD = 0;
              end
//stay in idle for the next read or write
            nextState = IDLE;
        end
//check if the address is 4 (whether we want to write to sine)
        if(wrAddr==4)begin
            a2 = SineNumQ;
//shift the data and round before calculations
            di2 = ((wrData+ 'h0080)>>>8);  
/set write enable so that data is written   
            we2 = 1;   
//set the next state to FIR to do the calculations   
            nextState = FIR;
//reset and increment the values
             BuffNumD = SineNumQ ;
              SineNumD = SineNumQ +1;
//ensure values wrap around
            if(SineNumD > 60)begin
                SineNumD=0;
            end
        end
    end     

//check if read is asserted
    if(rd)begin
//check if the addr is 8, meaning you are checking done bit
       if(rdAddr ==8)begin
//set data to done
        rdData = DoneQ;
//stay in IDLE
        nextState = IDLE;
        end
//for other addresses
       else begin
//set data to result
        rdData = ResultQ;
//stay in idle
        nextState = IDLE;
//set done to 0, since the result was just read
        DoneD = 0;
        end
     end
                                 
 end
 
//do calculations her
 FIR: begin
//do this state 61 times
        if(iq<61)begin
        //multiply the taps and the sine and add it to the incrementing sum
        SumD = SumQ + ((taps[id])*(sine[BuffNumQ])); 
//go back to FIR  
        nextState = FIR;
//increment the counter
        id = iq +1;
//increment buffnum
        BuffNumD = BuffNumQ+1;
//wrap around the buffer
          if(BuffNumD>60) begin
                BuffNumD = BuffNumD -61; 
             end

    end
        else begin
//reset the counter
            id = 0;   
//set the result to the final sum     
        ResultD = SumQ;
//set done to 1 to indicate that sum is finished
        DoneD = 1;
//go back to idle to read/write again
        nextState = IDLE;
        end
 end
 endcase
end


// Sequential block
//execute on every clock edge
always @ (posedge S_AXI_ACLK) begin
    if (  !S_AXI_ARESETN ) begin
//reset all the values to base if reset is high
        currentState <= INIT ;   
        TapsNumQ <= 0;
        SineNumQ<=0;
        BuffNumQ<=0;
        SumQ<=0;
        ResultQ<=0;
        iq <= 0;
        DoneQ = 0;
               
    end
    else begin
//if reset isn't high
//take care of all the flip flops
        TapsNumQ <= TapsNumD;
        SineNumQ<=SineNumD;
        BuffNumQ<=BuffNumD;
        DoneQ<= DoneD;
        currentState <= nextState ; 
        ResultQ <= ResultD;
        SumQ <= SumD;
        iq <= id;
//if the write enables are high, assign the appropriate data
       if(we1)begin
            taps[a1] <=di1;                      
        end    
        if(we2)begin
            sine[a2] <= di2;
        end    
    end   
end   

endmodule

