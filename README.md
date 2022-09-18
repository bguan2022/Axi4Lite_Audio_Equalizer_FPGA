# AXI4LITE_Audio_Equalizer

Objective: 

  The goal was to implement an audio equalizer with a series of Finite Impluse Response (FIR) filters that can be used to attenuate a wide-band of frequency spectrum. The audio sginal can be digitized through a 12-bit ADC, then being proccessed by the filter, and eventually would be converted back to audio signal. A MatLab GUI was built to control the frequency spectrum that needed to be attenuated. Axi4Lite communication protocal and a Microblaze processor were used to communicate between the host and all the other peripherals. 
  
<img width="1224" alt="Screen Shot 2022-09-06 at 1 55 53 PM" src="https://user-images.githubusercontent.com/42010432/188736413-4b51ec93-74b0-47bb-8004-17659f5b7121.png">


Tools and Languages: System Verilog / MatLab / Simulink / C++ / Xilinx SDK / Zynq-7000 SoCs / UART


## Microblaze Soft Processor (Instatiated on PL side)
<img width="691" alt="Screen Shot 2022-09-17 at 4 53 55 PM" src="https://user-images.githubusercontent.com/42010432/190879968-3cea38ba-4a1b-42fe-af35-09bc852605f8.png">

A system wrapper is created to include the microblaze. The C++ program will be built in Xilinx SDK and loaded onto the processor by programning the FPGA. When run, microblaze will execute the program and data can be sent to the PC through UART. 
