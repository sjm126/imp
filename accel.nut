// MMA7455L accelerometer using I2C mode
// Pin 8 is I2C SCL
// Pin 9 is I2C SDA
// sjm 20130414

WriteAddr <- 0x3A; // 0x1D << 1;
ReadAddr <- 0x3B; // (0x1D << 1) | 0x01;

function Measurement()
{

    // poll status register to check if data is ready
    local data = hardware.i2c89.read(ReadAddr, "\x09",1);
    //server.log(format("status = %02x",data[0]));
    while ((data[0] & 0x01) == 0)
    {
        local data = hardware.i2c89.read(ReadAddr, "\x09",1);
        imp.sleep(0.1);
    }

/*
    // 10-bit data output
    local data = hardware.i2c89.read(ReadAddr, "\x00",6);
    local X = (data[0] << 8) | data[1];         
    local Y = (data[2] << 8) | data[3];
    local Z = (data[4] << 8) | data[5];
    server.log(format("%02x%02x(%d)  %02x%02x(%d)  %02x%02x(%d)",data[1],data[0],X,data[3],data[2],Y,data[5],data[4],Z));
*/

  
    // 8-bit data output
    local data = hardware.i2c89.read(ReadAddr, "\x06",3);
    local X = data[0];
    local Y = data[1];
    local Z = data[2];
    if (X & 0x80) X = 0 - (0xFF - X) - 1;
    if (Y & 0x80) Y = 0 - (0xFF - Y) - 1;
    if (Z & 0x80) Z = 0 - (0xFF - Z) - 1;
    server.log(format("%02x(%d) %02x(%d)  %02x(%d)",data[0],X,data[1],Y,data[2],Z));


    imp.wakeup(1,Measurement);
}

hardware.i2c89.configure(CLOCK_SPEED_100_KHZ); 
imp.configure("Accelerometer",[],[]);
//local data = hardware.i2c89.read(ReadAddr, "\x0D",1); // test read capability
//server.log(format("%02x",data[0]));

hardware.i2c89.write(WriteAddr,"\x16\x05"); // 2g, normal measurement

// Offsets - for negative, it seems we need a full 16 bit 2's comp. value
// whereas, for positive, just an 8 bit value will do
hardware.i2c89.write(WriteAddr,"\x10\x10"); // X offset LSB
hardware.i2c89.write(WriteAddr,"\x11\x00"); // X offset MSB
hardware.i2c89.write(WriteAddr,"\x12\x40"); // Y offset LSB
hardware.i2c89.write(WriteAddr,"\x13\x00"); // X offset MSB
hardware.i2c89.write(WriteAddr,"\x14\xF0");  // Z offset LSB
hardware.i2c89.write(WriteAddr,"\x15\xFF");  // Z offset MSB

imp.sleep(0.5); // wait for device to configure
Measurement();


