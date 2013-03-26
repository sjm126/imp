// Analog test using sampler class on Sparkfun April
 
function DataReady(buffer, length)
{
    local i;
    local sum=0;
    local avg=0;
    for (i=0;i<length;i+=2)
    {
        sum = sum + (buffer[i]+256*buffer[i+1]);
    //    server.log(format("%d",buffer[i]+256*buffer[i+1])); // little endian
    }
    avg = sum / (length/2);
    server.log(format("Average: %f",avg));
}

function StopSampler()
{
    hardware.sampler.stop();
}

buffer <- blob(2000); 
imp.configure("Sampler Demo", [], []);

hardware.sampler.configure(hardware.pin9, 10, [buffer], DataReady);
hardware.sampler.start();
imp.wakeup(2, StopSampler);


