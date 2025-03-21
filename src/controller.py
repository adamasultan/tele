from matlabconnection import setup_matlab_vars
import matlab
import time
from forcedim import init, close, get_pose
eng, adsClt, Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6 = setup_matlab_vars()



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
    return Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6

def clamp_joint_angles(joint_values):
    limits = [(-170, 170), (-120, 120), (-170, 170),
              (-120, 120), (-170, 170), (-180, 180)]
    return [max(min(val, max_lim), min_lim) for val, (min_lim, max_lim) in zip(joint_values, limits)]

def set_joint_velocity(vel):
    eng.meca_SetJVel(adsClt, Move_command, float(vel), nargout=0)

def move_connect(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6):
    print("Force Dimension mapped to Meca")
    try:
        while True:
                pose = get_pose()
                safe_pose = clamp_joint_angles(pose)
                move_to_absolute_joint_path(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6, safe_pose)
    except KeyboardInterrupt as e:
        print(e)

def reset_joints(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6):
    move_to_absolute_joint_path(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6,[0,0,0,0,0,0])

def move_to_absolute_joint_path(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6, float_array):
    R1_Joint = eng.meca1_GetJoints(adsClt, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)
    negative_joint_pose = [-R1_Joint[0][i] for i in range(len(R1_Joint[0]))]
    final_pose = []
    for i in range(len(float_array)):
        final_pose.append(negative_joint_pose[i]+float_array[i])
    Jmovement = matlab.double([final_pose])
    eng.meca1_MoveJoint(adsClt, Move_command, Jmovement, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6, nargout=0)


def home_and_setup(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6):
    eng.meca1_ETC_Setup(adsClt, nargout=0)
    reset_joints(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)


def cli_movement(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6):
    while True:
        try:
            input_string = input("\nEnter joint positions (or 'exit'): ").strip()
            float_array = []
            for val in input_string.split():
                float_array.append(float(val))
            move_to_absolute_joint_path(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6, float_array)
        except Exception as e:
            print(f"Input error: {e}")

def main():
    Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6 = setup_matlab_vars()
    home_and_setup(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)
    init()
    print("Devices initialized")
    set_joint_velocity(100)
    time.sleep(1)
    print("Velocity set")
    try:
        #move_connect(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)
        #cli_movement(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)
        print("Hello")
    finally:
        close()
        eng.meca1_ETC_Shotdown(adsClt, nargout=0)
        print("\nClosing MATLAB engine...")
        eng.quit()


if __name__ == '__main__':
    main()
