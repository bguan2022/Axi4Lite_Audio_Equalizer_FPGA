AXI4LITE_Audio_Equalizer

Objective: 

  The goal was to implement an audio equalizer with a series of Finite Impluse Response (FIR) filters that can be used to attenuate a wide-band of frequency spectrum. The audio sginal can be digitized through a 12-bit ADC, then being proccessed by the filter, and eventually would be converted back to audio signal. A MatLab GUI was built to control the frequency spectrum that needed to be attenuated. Axi4Lite communication protocal and a Microblaze processor were used to communicate between the host and all the other peripherals. 
  
<img width="1224" alt="Screen Shot 2022-09-06 at 1 55 53 PM" src="https://user-images.githubusercontent.com/42010432/188736413-4b51ec93-74b0-47bb-8004-17659f5b7121.png">


System Verilog / MatLab / Simulink / C++ / Xilinx SDK / Zynq-7000 SoCs
