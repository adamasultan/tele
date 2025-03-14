function raw_Force = read_Force(adsClt, fx, fy, fz)
 % gives Force sensor values as output    
    raw_Force = [  adsClt.ReadSymbol(fx) 
                   adsClt.ReadSymbol(fy) 
                   adsClt.ReadSymbol(fz) ]';
