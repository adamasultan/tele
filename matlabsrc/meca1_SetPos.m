function meca1_SetPos(adsClt, Move_command, pos)
    % takes cartesian position of end effector as input    
    values=[pos 2 32010 32011 1 1];   
    adsClt.WriteAny(Move_command.IndexGroup,Move_command.IndexOffset,single(values));    
end

