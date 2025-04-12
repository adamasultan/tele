function setallvelocity(adsClt, Move_command)
    % takes joint velocity in %   
    values1 = [100 0 0 0 0 0 8 32010 32011 1 1];  
    adsClt.WriteAny(Move_command.IndexGroup, Move_command.IndexOffset, single(values1)); 
    pause(1)
    

    values2 = [100 0 0 0 0 0 8 32010 32011 1 2];  
    adsClt.WriteAny(Move_command.IndexGroup, Move_command.IndexOffset, single(values2)); 
    pause(1)
    
    
    % set Cartesian Angular velocity
    values3=[1000 0 0 0 0 0 10 32010 32011 1 1];   
    adsClt.WriteAny(Move_command.IndexGroup,Move_command.IndexOffset,single(values3));  
    pause(1)

    % set Cartesian Linear velocity
    values4=[5000 0 0 0 0 0 11 32010 32011 1 1];   
    adsClt.WriteAny(Move_command.IndexGroup,Move_command.IndexOffset,single(values4));  


    values5=[1000 0 0 0 0 0 10 32010 32011 1 2];   
    adsClt.WriteAny(Move_command.IndexGroup,Move_command.IndexOffset,single(values5));  
    pause(1)

    % set Cartesian Linear velocity
    values6=[5000 0 0 0 0 0 11 32010 32011 1 2];   
    adsClt.WriteAny(Move_command.IndexGroup,Move_command.IndexOffset,single(values6));  
end

