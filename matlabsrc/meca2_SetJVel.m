function meca2_SetJVel(adsClt, Move_command, vel)
    values2 = [vel 0 0 0 0 0 8 32010 32011 1 2];  
    adsClt.WriteAny(Move_command.IndexGroup, Move_command.IndexOffset, single(values2)); 
    pause(1)
    disp("Robot 2 Velocity Set")
end

