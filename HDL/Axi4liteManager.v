// Axi4Lite Manager module declaration
module Axi4LiteManager #
    (parameter C_M_AXI_ADDR_WIDTH = 6, C_M_AXI_DATA_WIDTH = 32)
    (
        // Simple Bus
        input           [C_M_AXI_ADDR_WIDTH-1:0] wrAddr,
        input           [C_M_AXI_DATA_WIDTH-1:0] wrData,
        input           wr,
        output reg      wrDone,
        input           [C_M_AXI_ADDR_WIDTH-1:0] rdAddr,
        output reg      [C_M_AXI_DATA_WIDTH-1:0] rdData,
        input           rd,
        output reg      rdDone,
        // Axi4Lite Bus
        input           M_AXI_ACLK,
        input           M_AXI_ARESETN,
        output reg      [C_M_AXI_ADDR_WIDTH-1:0] M_AXI_AWADDR,
        output reg      M_AXI_AWVALID,
        input           M_AXI_AWREADY,
        output reg      [C_M_AXI_DATA_WIDTH-1:0] M_AXI_WDATA,
        output reg      [3:0] M_AXI_WSTRB,
        output reg      M_AXI_WVALID,
        input           M_AXI_WREADY,
        input           [1:0] M_AXI_BRESP,
        input           M_AXI_BVALID,
        output reg      M_AXI_BREADY,
        output reg      [C_M_AXI_ADDR_WIDTH-1:0] M_AXI_ARADDR,
        output reg      M_AXI_ARVALID,
        input           M_AXI_ARREADY,
        input           [C_M_AXI_DATA_WIDTH-1:0] M_AXI_RDATA,
        input           [1:0] M_AXI_RRESP,
        input           M_AXI_RVALID,
        output reg      M_AXI_RREADY
    );
     
    //FSM States
    parameter IDLE = 0, RD1 = 1, RD2 =2, WR1 = 3 ;
    reg [3:0] nextState, currentState ; //why 3:0?? only two states
    //Read Flops
    reg [C_M_AXI_ADDR_WIDTH-1:0] rdAddrD, rdAddrQ, wrAddrD, wrAddrQ ;
   
always @ * begin
    //state register and rdAddr
    nextState = currentState  ;
    rdAddrD = rdAddrQ ;
    wrAddrD = wrAddrQ ;
    rdData = 0 ;
    rdDone = 0 ;
    wrDone = 0 ;
   
    M_AXI_WSTRB = 15;
    M_AXI_ARVALID = 0;
    M_AXI_BREADY = 0;
    M_AXI_RREADY = 0;
    M_AXI_AWVALID = 0;
    M_AXI_AWADDR = 0 ;
    M_AXI_WVALID = 0;
   
    case (currentState)

        IDLE: begin
            M_AXI_ARADDR = 0 ;
            M_AXI_WDATA = 0;
        
            if ( rd ) begin
                rdAddrD = rdAddr ;
                nextState = RD1 ;                
            end              
            else if ( wr ) begin
                wrAddrD = wrAddr ;
                nextState = WR1 ;
            end  
        end    
       
        RD1: begin
            M_AXI_ARADDR = rdAddrQ;
            M_AXI_ARVALID = 1;
             
            if(M_AXI_RVALID) begin
                nextState = RD2;            
            end
        end
             
        RD2: begin
            M_AXI_RREADY = 1;
            rdData = M_AXI_RDATA;
            rdDone = 1 ;
            nextState = IDLE;
            M_AXI_ARADDR = 0 ;
        end          
             
        WR1: begin
            M_AXI_AWADDR = wrAddrQ;
            M_AXI_AWVALID = 1;
            M_AXI_WVALID = 1;
            M_AXI_BREADY = 1;
            
            if (wrAddr == 1*4 || wrAddr == 2*4) begin
                M_AXI_WDATA = wrData;
            end
        
                    
            if(M_AXI_AWREADY) begin
                wrDone = 1;            
                nextState = IDLE;
            end                  
        end
     
        default: begin
            nextState = IDLE ;
        end
    endcase
end
 
always @ ( posedge M_AXI_ACLK ) begin
    if (  !M_AXI_ARESETN ) begin
        currentState <= IDLE ;          
        rdAddrQ <= 0 ;
        wrAddrQ <= 0;
    end
                         
    else begin
        currentState <= nextState ;
        rdAddrQ <= rdAddrD ;
        wrAddrQ <= wrAddrD ;
    end
end  
endmodule
