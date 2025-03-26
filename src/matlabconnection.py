# matlabconnection.py
import matlab.engine

# Global engine and client so they are initialized only once
eng = None
adsClt = None

def start_matlab():
    """Start MATLAB engine and return engine + ADS client."""
    global eng, adsClt
    if eng is None:
        eng = matlab.engine.start_matlab()
        eng.addpath("../matlabsrc", nargout=0)
        adsClt = eng.start_ads_client()
        eng.workspace["adsClt"] = adsClt
    return eng, adsClt

def matlab_global_vars():
    eng.eval("global Move_command; Move_command = adsClt.ReadSymbolInfo('Main.Values');", nargout=0)
    eng.eval("""
        global R1_j1 R1_j2 R1_j3 R1_j4 R1_j5 R1_j6;
        R1_j1 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_001');
        R1_j2 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_002');
        R1_j3 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_003');
        R1_j4 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_004');
        R1_j5 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_005');
        R1_j6 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_006');
    """, nargout=0)


    eng.eval("""
        global R2_j1 R2_j2 R2_j3 R2_j4 R2_j5 R2_j6;
        R2_j1 = adsClt.ReadSymbolInfo('GVL.Robot2.Inputs.Joint_Set.SubIndex_001');
        R2_j2 = adsClt.ReadSymbolInfo('GVL.Robot2.Inputs.Joint_Set.SubIndex_002');
        R2_j3 = adsClt.ReadSymbolInfo('GVL.Robot2.Inputs.Joint_Set.SubIndex_003');
        R2_j4 = adsClt.ReadSymbolInfo('GVL.Robot2.Inputs.Joint_Set.SubIndex_004');
        R2_j5 = adsClt.ReadSymbolInfo('GVL.Robot2.Inputs.Joint_Set.SubIndex_005');
        R2_j6 = adsClt.ReadSymbolInfo('GVL.Robot2.Inputs.Joint_Set.SubIndex_006');
    """, nargout=0)

def setup_matlab_vars():
    eng.workspace["adsClt"] = adsClt
    matlab_global_vars()
    Move_command = eng.workspace["Move_command"]
    R1_j1 = eng.workspace["R1_j1"]
    R1_j2 = eng.workspace["R1_j2"]
    R1_j3 = eng.workspace["R1_j3"]
    R1_j4 = eng.workspace["R1_j4"]
    R1_j5 = eng.workspace["R1_j5"]
    R1_j6 = eng.workspace["R1_j6"]

    R2_j1 = eng.workspace["R2_j1"]
    R2_j2 = eng.workspace["R2_j2"]
    R2_j3 = eng.workspace["R2_j3"]
    R2_j4 = eng.workspace["R2_j4"]
    R2_j5 = eng.workspace["R2_j5"]
    R2_j6 = eng.workspace["R2_j6"]
    return Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6, R2_j1, R2_j2, R2_j3, R2_j4, R2_j5, R2_j6
