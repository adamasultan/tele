function R1_Pos = meca1_GetPos(adsClt, R1_px, R1_py, R1_pz, R1_rx, R1_ry, R1_rz)
    % gives cartesian position of end effector as output    
    R1_Pos = [  adsClt.ReadSymbol(R1_px)
                adsClt.ReadSymbol(R1_py)
                adsClt.ReadSymbol(R1_pz)
                adsClt.ReadSymbol(R1_rx)
                adsClt.ReadSymbol(R1_ry)
                adsClt.ReadSymbol(R1_rz) ]';
end

