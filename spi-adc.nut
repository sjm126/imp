/ SPI example for interfacing to LTC2498, 24-bit, 16 channel ADC with temperature
// sjm 20130320

// Pin 2 = SPI MISO
// Pin 5 = SPI SCLK
// Pin 7 = SPI MOSI
// Pin 8 = Chip select

// ADC configuration bits
// 1 0 EN SGL ODD A2 A1 A0 EN2 IM FA FB SPD ...

// 101 10 000 1 0 00 0  = B080 - enable, single, Ch0, enable, non-temp, 50/60Hz, x1
// 101 10 001 1 0 00 0  = B180 - enable, single, Ch2, enable, non-temp, 50/60Hz, x1
// 101 10 010 1 0 00 0  = B280 - enable, single, Ch4, enable, non-temp, 50/60Hz, x1
// 101 10 011 1 0 00 0  = B380 - enable, single, Ch6, enable, non-temp, 50/60Hz, x1
// 101 10 100 1 0 00 0  = B480 - enable, single, Ch8, enable, non-temp, 50/60Hz, x1 
// 101 10 101 1 0 00 0  = B580 - enable, single, Ch10, enable, non-temp, 50/60Hz, x1
// 101 10 110 1 0 00 0  = B680 - enable, single, Ch12, enable, non-temp, 50/60Hz, x1
// 101 10 111 1 0 00 0  = B780 - enable, single, Ch14, enable, non-temp, 50/60Hz, x1
// 101 11 000 1 0 00 0  = B880 - enable, single, Ch1, enable, non-temp, 50/60Hz, x1
// 101 11 001 1 0 00 0  = B980 - enable, single, Ch3, enable, non-temp, 50/60Hz, x1
// 101 11 010 1 0 00 0  = BA80 - enable, single, Ch5, enable, non-temp, 50/60Hz, x1
// 101 11 011 1 0 00 0  = BB80 - enable, single, Ch7, enable, non-temp, 50/60Hz, x1
// 101 11 100 1 0 00 0  = BC80 - enable, single, Ch9, enable, non-temp, 50/60Hz, x1
// 101 11 101 1 0 00 0  = BD80 - enable, single, Ch11, enable, non-temp, 50/60Hz, x1
// 101 11 110 1 0 00 0  = BE80 - enable, single, Ch13, enable, non-temp, 50/60Hz, x1
// 101 11 111 1 0 00 0  = BF80 - enable, single, Ch15, enable, non-temp, 50/60Hz, x1
// 101 00 000 1 1 00 0  = A0C0 - enable, single, internal temperature, 50/60Hz, x1

WriteData <- blob(4);   // Configuration data written to ADC
ReadData <- blob(4);    // Sample data read back from ADC

// This function is bi-directional. It writes out the channel config for the next measurement
// cycle, and reads back data from the previous measurement cycle.
function ReadADC(data)
{
    WriteData.seek(0);
    WriteData.writen(swap4(data),'i'); // We pass 32-bit big-endian data, but blob is little endian
    hardware.pin8.write(0);         // chip select = low
    ReadData = hardware.spi.writeread(WriteData);
    hardware.pin8.write(1);     // chip select = high
    imp.sleep(0.2);     // 160ms conversion time in x1 mode, ideally, should poll EOC here
}

function PrintValue(Channel)
{
    ReadData.seek(0);
    local val = ReadData.readn('i');  // convert blob to a 32 bit, little endian integer
    val = (swap4(val) >> 5) & 0x00FFFFFF;  // make it big endian,and extract 24 data bits

    if (Channel == 99)      // internal temperature
    {
        local temp = (val * 3.3)/1570.0 - 273.0;
        server.log(format("Temperature = %3.1f",temp));
    }
    else
    {
        local volt = 3.3 * (val/16777216.0);
        server.log(format("Ch %d, voltage = %1.3f",Channel,volt));
    }
}

imp.configure("SPI-ADC", [], []);
hardware.spi257.configure(MSB_FIRST | CLOCK_IDLE_LOW, 100);
hardware.pin8.configure(DIGITAL_OUT); // chip select
hardware.pin8.write(1); 

// Prime the ADC by writing something, so the first read will be legitimate
ReadADC(0xB0800000);    // Write Ch0, read unknown

ReadADC(0xB8800000);    // Write Ch1, read previous channel (which was 0)
PrintValue(0);  

ReadADC(0xBB800000);    // Write Ch7, read Ch1
PrintValue(1);

ReadADC(0xBC800000);    // Write Ch9, read Ch7
PrintValue(7);

ReadADC(0xA0C00000);    // Write temperature, read Ch9
PrintValue(9);

ReadADC(0xB0800000);    // Write Ch0, read temperature
PrintValue(99);


