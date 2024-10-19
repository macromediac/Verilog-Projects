// Verilog Test Fixture Template

  `timescale 1 ns / 1 ps

  module TEST_gate;

    // Inputs
    reg clk;
    reg reset_n;
    reg sensor_entrance;
    reg sensor_exit;
    reg [1:0] password_1;
    reg [1:0] password_2;

    // Outputs
    wire GREEN_LED;
    wire RED_LED;
    wire [6:0] HEX_1;
    wire [6:0] HEX_2;

    // Instantiate the Unit Under Test (UUT)
    parking_system uut (
        .clk(clk), 
        .reset_n(reset_n), 
        .sensor_entrance(sensor_entrance), 
        .sensor_exit(sensor_exit), 
        .password_1(password_1), 
        .password_2(password_2), 
        .GREEN_LED(GREEN_LED), 
        .RED_LED(RED_LED), 
        .HEX_1(HEX_1), 
        .HEX_2(HEX_2)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 50 MHz clock (period 20 time units)
    end

    // Test sequence
    initial begin
        // Scenario 1: Reset the system
        $display("Scenario 1: System Reset");
        reset_n = 0;
        sensor_entrance = 0;
        sensor_exit = 0;
        password_1 = 0;
        password_2 = 0;
        #100;
        reset_n = 1;
        #50;
        $display("Reset completed, system is in IDLE state. HEX_1 = %b, HEX_2 = %b", HEX_1, HEX_2);
        #100;

        // Scenario 2: Vehicle arrives and enters correct password
        $display("Scenario 2: Vehicle arrives and enters correct password");
        sensor_entrance = 1;
        #100;
        sensor_entrance = 0;
        password_1 = 2'b01;
        password_2 = 2'b10;
        #200;
        if (GREEN_LED)
            $display("Green LED ON: Correct password, vehicle allowed to enter");
        else
            $display("Error: Green LED should be ON");
        #1000;
        
        // Scenario 3: Vehicle exits, system goes to IDLE
        $display("Scenario 3: Vehicle exits");
        sensor_exit = 1;
        #500;
        sensor_exit = 0;
        if (RED_LED && ~GREEN_LED)
            $display("Red LED ON: Vehicle exited, system in IDLE state");
        else
            $display("Error: Incorrect LED behavior after exit");
        #1000;

        // Scenario 4: Incorrect password entered
        $display("Scenario 4: Vehicle arrives and enters incorrect password");
        sensor_entrance = 1;
        #100;
        sensor_entrance = 0;
        password_1 = 2'b11;  // Incorrect password
        password_2 = 2'b00;  // Incorrect password
        #200;
        if (RED_LED && ~GREEN_LED)
            $display("Red LED ON: Incorrect password, vehicle not allowed to enter");
        else
            $display("Error: Incorrect LED behavior on wrong password");
        #1000;

        // Scenario 5: Reset the system mid-operation
        $display("Scenario 5: System reset during operation");
        sensor_entrance = 1;
        password_1 = 2'b01;  // Correct password in the process of being entered
        password_2 = 2'b10;  // Correct password
        #100;
        reset_n = 0;  // Reset system during operation
        #100;
        reset_n = 1;
        #100;
        if (~GREEN_LED && ~RED_LED)
            $display("System reset: All LEDs off, system in IDLE state");
        else
            $display("Error: System not correctly reset");
        
        #1000;

        $finish;  // End the simulation
    end

endmodule
