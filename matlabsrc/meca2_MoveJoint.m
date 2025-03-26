function meca2_MoveJoint(adsClt, Move_command, Jmovement, R2_j1, R2_j2, R2_j3, R2_j4, R2_j5, R2_j6)
    % Ensure Jmovement is numeric
    %Jmovement = cell2mat(Jmovement);  % Convert from cell to numeric if necessary
    
    % Get current joint positions
    R2_Joint = meca2_GetJoints(adsClt, R2_j1, R2_j2, R2_j3, R2_j4, R2_j5, R2_j6);
    
    % Ensure R2_Joint is numeric
    if iscell(R2_Joint)
        R2_Joint = cell2mat(R2_Joint);  % Convert from cell to numeric if necessary
    end
    
    % Compute new joint positions (cumulative)
    val = R2_Joint + Jmovement;
    
    % Construct values array and send to robot
    values = [val 1 32010 32011 1 2];   
    
    % Clear previous move command
    adsClt.WriteAny(Move_command.IndexGroup, Move_command.IndexOffset, single(zeros(1, length(values))));
    

    % Send new movement command
    adsClt.WriteAny(Move_command.IndexGroup, Move_command.IndexOffset, single(values));
    
    % Pause to allow movement execution
end
