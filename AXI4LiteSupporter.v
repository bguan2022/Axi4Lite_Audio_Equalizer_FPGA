// Axi4Lite Supporter module declaration
module Axi4LiteSupporter #
    (parameter C_S_AXI_ADDR_WIDTH = 6, C_S_AXI_DATA_WIDTH = 32)
    (
        // Simple Bus
        output reg  [C_S_AXI_ADDR_WIDTH-1:0] wrAddr,
        output reg  [C_S_AXI_DATA_WIDTH-1:0] wrData,
        output reg  wr,
        output reg  [C_S_AXI_ADDR_WIDTH-1:0] rdAddr,
        input       [C_S_AXI_DATA_WIDTH-1:0] rdData,
        output reg  rd,
        // Axi4Lite Bus
        input       S_AXI_ACLK,
        input       S_AXI_ARESETN,
        input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_AWADDR,
        input       S_AXI_AWVALID,
        output reg  S_AXI_AWREADY,
        input       [C_S_AXI_DATA_WIDTH-1:0] S_AXI_WDATA,
        input       [3:0] S_AXI_WSTRB,
        input       S_AXI_WVALID,
        output reg  S_AXI_WREADY,
        output reg  [1:0] S_AXI_BRESP,
        output reg  S_AXI_BVALID,
        input       S_AXI_BREADY,
        input       [C_S_AXI_ADDR_WIDTH-1:0] S_AXI_ARADDR,
        input       S_AXI_ARVALID,
        output reg  S_AXI_ARREADY,
        output reg  [C_S_AXI_DATA_WIDTH-1:0] S_AXI_RDATA,
        output reg  [1:0] S_AXI_RRESP,
        output reg  S_AXI_RVALID,
        input       S_AXI_RREADY
    );
   
    //FSM States
    parameter IDLE = 0, RD1 = 1, WR1 = 2, RD2 =3 ;
    reg [3:0] nextState, currentState ; 
    reg [C_S_AXI_DATA_WIDTH-1:0] rdDataD, rdDataQ;
   
    //Combinational Block
always @ * begin
    //state register and rdAddr
    nextState = currentState  ;
    rdDataD = rdDataQ;
    rdAddr = 0;
    wrAddr = 0;
    wrData = 0 ;
   
    wr = 0 ;  
    rd = 0;

    S_AXI_AWREADY = 0 ;
    S_AXI_WREADY = 0;
    S_AXI_ARREADY = 0;
    S_AXI_BRESP = 0;
    S_AXI_RRESP = 0;
    S_AXI_BVALID = 0;
    S_AXI_RDATA = 0;
    S_AXI_RVALID = 0;
   
    case (currentState)
        IDLE: begin
            wr = 0;
            rd = 0;

            if ( S_AXI_ARVALID ) begin
                nextState = RD1 ;      
            end
               
            else if ( S_AXI_AWVALID ) begin
                nextState = WR1 ;
            end  
        end
       
        RD1: begin
            S_AXI_ARREADY = 1 ;
            S_AXI_RVALID = 1;
            rdAddr = S_AXI_ARADDR ;
            rdDataD = rdData;
            S_AXI_RDATA = rdData;
            rd = 1;
            nextState  = RD2;
        end
           
        RD2: begin    
            S_AXI_RVALID = 1;    
            S_AXI_RDATA = rdDataQ;
            
            if (S_AXI_RREADY) begin  
                rd = 0;                              
                nextState = IDLE;
            end
        end

        WR1: begin
            S_AXI_AWREADY = 1;
            wrAddr = S_AXI_AWADDR;
            S_AXI_WREADY = 1 ;
            wrData = S_AXI_WDATA ;
            S_AXI_BVALID = 1 ;
            wr = 1 ;
            
            if (S_AXI_WVALID) begin                
                nextState = IDLE ;
            end
        end
         
        default: begin
            nextState = IDLE ;
        end
    endcase
end
 
 
always @ ( posedge S_AXI_ACLK ) begin
    if (  !S_AXI_ARESETN ) begin
        currentState <= IDLE ;
        rdDataQ <= 0;
    end else begin
         currentState <= nextState ;
         rdDataQ <= rdDataD ;
    end
end
  
   
endmodule