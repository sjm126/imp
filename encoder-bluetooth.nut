// Simple example to read a rotary encoder using "interrupts", and write
// the value via a Bluetooth UART to a terminal program on a phone.

// Rotary encoder has detents, and outputs an entire cycle each detent, not just
// a single change of state. So to get direction, we only need to check one state, 
// since we know the previous will be 11 (final state in the previous cycle).
// However, we still get "interrupts" for each state change within the cycle.

// sjm 20130328

counter <- 0;
OldCounter <- 0;
OldState <- 3;  // binary 11

function Changed()
{
    local ChA = hardware.pin5.read();
    local ChB = hardware.pin7.read();
    
    local CurrentState = (ChA << 1) | ChB;
    local NewState = (CurrentState << 2) | OldState;

    switch(NewState)
    {
        case 11:    // 10 11 
                counter++; break;
        case 7:     // 01 11
                counter--; break;
    }
    OldState = CurrentState;
    if (counter != OldCounter)
    {
        //server.log(format("%d",counter));
        hardware.uart12.write(format("%d\r\n",counter));
        OldCounter = counter;
    }
}    

// Encoder pins are pulled up by the imp, switched to ground
hardware.pin5.configure(DIGITAL_IN_PULLUP,Changed);
hardware.pin7.configure(DIGITAL_IN_PULLUP,Changed);
hardware.uart12.configure(9600,8,PARITY_NONE,1,NO_RX);

imp.configure("Rotary Encoder via Bluetooth",[],[]);


