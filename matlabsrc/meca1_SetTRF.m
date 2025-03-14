function meca1_SetTRF(adsClt, Move_command, movement)
    % takes cartesian position of end effector as input    
    values=[movement 13 32010 32011 1 1];   
    adsClt.WriteAny(Move_command.IndexGroup,Move_command.IndexOffset,single(values));    
end

