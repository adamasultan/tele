function meca1_MoveJoint(adsClt, Move_command, Jmovement, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)
    % Ensure Jmovement is numeric
    %Jmovement = cell2mat(Jmovement);  % Convert from cell to numeric if necessary
    
    % Get current joint positions
    R1_Joint = meca1_GetJoints(adsClt, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6);
    
    % Ensure R1_Joint is numeric
    if iscell(R1_Joint)
        R1_Joint = cell2mat(R1_Joint);  % Convert from cell to numeric if necessary
    end
    
    % Compute new joint positions (cumulative)
    val = R1_Joint + Jmovement;
    
    % Construct values array and send to robot
    values = [val 1 32010 32011 1 1];   
    
    % Clear previous move command
    adsClt.WriteAny(Move_command.IndexGroup, Move_command.IndexOffset, single(zeros(1, length(values))));
    pause(0.1);  % Small delay to ensure TwinCAT processes it

    % Send new movement command
    adsClt.WriteAny(Move_command.IndexGroup, Move_command.IndexOffset, single(values));
    
    % Pause to allow movement execution
    pause(1);
end
