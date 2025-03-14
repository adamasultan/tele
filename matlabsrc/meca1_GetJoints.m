function R1_Joint = meca1_GetJoints(adsClt, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)
    % gives joint angels     
    R1_Joint = [adsClt.ReadSymbol(R1_j1)
                adsClt.ReadSymbol(R1_j2)
                adsClt.ReadSymbol(R1_j3)
                adsClt.ReadSymbol(R1_j4)
                adsClt.ReadSymbol(R1_j5)
                adsClt.ReadSymbol(R1_j6)]';
end
