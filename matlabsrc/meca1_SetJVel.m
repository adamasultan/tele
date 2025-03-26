function meca1_SetJVel(adsClt, Move_command, vel)
    % takes joint velocity in %   
    values1 = [vel 0 0 0 0 0 8 32010 32011 1 1];  
    adsClt.WriteAny(Move_command.IndexGroup, Move_command.IndexOffset, single(values1)); 
    disp("Robot 1 Velocity Set")
end

