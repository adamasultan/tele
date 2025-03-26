function R2_Joint = meca2_GetJoints(adsClt, R2_j1, R2_j2, R2_j3, R2_j4, R2_j5, R2_j6)
    % gives joint angels     
    R2_Joint = [adsClt.ReadSymbol(R2_j1)
                adsClt.ReadSymbol(R2_j2)
                adsClt.ReadSymbol(R2_j3)
                adsClt.ReadSymbol(R2_j4)
                adsClt.ReadSymbol(R2_j5)
                adsClt.ReadSymbol(R2_j6)]';
end
