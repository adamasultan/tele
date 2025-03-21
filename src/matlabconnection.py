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
    """Declare global Move_command and joint variables in MATLAB."""
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

def setup_matlab_vars():
    """Start engine, setup client, and fetch all key ADS symbols."""
    start_matlab()
    matlab_global_vars()
    Move_command = eng.workspace["Move_command"]
    R1_j1 = eng.workspace["R1_j1"]
    R1_j2 = eng.workspace["R1_j2"]
    R1_j3 = eng.workspace["R1_j3"]
    R1_j4 = eng.workspace["R1_j4"]
    R1_j5 = eng.workspace["R1_j5"]
    R1_j6 = eng.workspace["R1_j6"]
    return eng, adsClt, Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6
