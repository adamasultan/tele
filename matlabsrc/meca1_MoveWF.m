function meca1_MoveWF(adsClt, Move_command, movement)
    % takes cartesian position of end effector as input    
    values=[movement 5 32010 32011 1 1];   
    adsClt.WriteAny(Move_command.IndexGroup,Move_command.IndexOffset,single(values));    
end

