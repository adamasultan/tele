function meca_SetJVel(adsClt, Move_command, vel)
    % takes joint velocity in %   
    vel = 10;
    values = [vel 0 0 0 0 0 8 32010 32011 1 1];  
    adsClt.WriteAny(Move_command.IndexGroup, Move_command.IndexOffset, single(values)); 
    pause(2)

    values = [vel-2 0 0 0 0 0 8 32010 32011 1 2];  
    adsClt.WriteAny(Move_command.IndexGroup, Move_command.IndexOffset, single(values));    
end

