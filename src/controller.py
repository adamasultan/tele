from matlabconnection import setup_matlab_vars, start_matlab
import matlab
import time
from forcedim import init, close, get_pose
eng, adsClt = start_matlab()
Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6, R2_j1, R2_j2, R2_j3, R2_j4, R2_j5, R2_j6 = setup_matlab_vars()

def clamp_joint_angles(joint_values):
    limits = [(-170, 170), (-120, 120), (-170, 170),
              (-120, 120), (-170, 170), (-180, 180)]
    return [max(min(val, max_lim), min_lim) for val, (min_lim, max_lim) in zip(joint_values, limits)]


def limit_meca500_pose(pose):

    # Define safe limits (customize these as needed for your actual workspace)
    limits = {
        "x": (160, 220),     
        "y": (-40, 40),    # mm
        "z": (278, 338),      # mm 
        "rx": (-90, 90),   # degrees
        "ry": (60, 120),
        "rz": (-90, 90),
    }

    # Clamp helper
    def clamp(value, min_val, max_val):
        return max(min_val, min(max_val, value))

    # Clamp each value
    x = clamp(pose[0], *limits["x"])
    y = clamp(pose[1], *limits["y"])
    z = clamp(pose[2], *limits["z"])
    rx = clamp(pose[3], *limits["rx"])
    ry = clamp(pose[4], *limits["ry"])
    rz = clamp(pose[5], *limits["rz"])

    return [x, y, z, rx, ry, rz]
def set_joint_velocity(vel):
    eng.setallvelocity(adsClt, Move_command, float(vel), nargout=0)

def move_connect(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6, R2_j1, R2_j2, R2_j3, R2_j4, R2_j5, R2_j6):
    print("Force Dimension mapped to Meca")
    while True:
        try:
            pose1 = get_pose(0)
            safe_pose1 = limit_meca500_pose(pose1)
            move_to_absolute_joint_path(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6, safe_pose1, 1)

            pose2 = get_pose(1)
            safe_pose2 = limit_meca500_pose(pose2)
            move_to_absolute_joint_path(Move_command, R2_j1, R2_j2, R2_j3, R2_j4, R2_j5, R2_j6, safe_pose2, 2)

        except KeyboardInterrupt as e:
            break

def reset_joints(Move_command, j1, j2, j3, j4, j5, j6, rnum):
    move_to_absolute_joint_path(Move_command, j1, j2, j3, j4, j5, j6,[190,0,308,0,90,0], rnum)

def move_to_absolute_joint_path(Move_command, j1, j2, j3, j4, j5, j6, float_array, rnum):



    if rnum == 1:
        # R1_Joint = eng.meca1_GetJoints(adsClt, j1, j2, j3, j4, j5, j6)
        # negative_joint_pose = [-R1_Joint[0][i] for i in range(len(R1_Joint[0]))]
        # final_pose = []
        # for i in range(len(float_array)):
        #     final_pose.append(negative_joint_pose[i]+float_array[i])
        Jmovement = matlab.double([float_array])

        # # # move_array = float_array + [2, 32010, 32011, 1, float(rnum)]
        # # # eng.eval(f"Main.Values = single([{','.join(map(str, move_array))}]);", nargout=0)

        eng.meca1_SetPos(adsClt, Move_command, Jmovement, nargout=0)

    if rnum == 2:
        # R2_Joint = eng.meca2_GetJoints(adsClt, j1, j2, j3, j4, j5, j6)
        # negative_joint_pose = [-R2_Joint[0][i] for i in range(len(R2_Joint[0]))]
        # final_pose = []
        # for i in range(len(float_array)):
        #     final_pose.append(negative_joint_pose[i]+float_array[i])
        Jmovement = matlab.double([float_array])

        # # # move_array = float_array + [2, 32010, 32011, 1, float(rnum)]
        # # # eng.eval(f"Main.Values = single([{','.join(map(str, move_array))}]);", nargout=0)

        eng.meca2_SetPos(adsClt, Move_command, Jmovement, nargout=0)


def home_and_setup(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6, R2_j1, R2_j2, R2_j3, R2_j4, R2_j5, R2_j6):
    eng.meca1_ETC_Setup(adsClt, nargout=0)
    eng.meca2_ETC_Setup(adsClt, nargout=0)
    reset_joints(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6, 1)
    reset_joints(Move_command, R2_j1, R2_j2, R2_j3, R2_j4, R2_j5, R2_j6, 2)


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
    
    try:
        Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6, R2_j1, R2_j2, R2_j3, R2_j4, R2_j5, R2_j6 = setup_matlab_vars()
        home_and_setup(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6, R2_j1, R2_j2, R2_j3, R2_j4, R2_j5, R2_j6)
        init(0)
        init(1)
        print("Devices initialized")
        set_joint_velocity(100)
        time.sleep(1)
        print("Velocity set")
        move_connect(Move_command, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6, R2_j1, R2_j2, R2_j3, R2_j4, R2_j5, R2_j6)
        # print("hello")
    finally:
        close(0)
        close(1)
        eng.meca1_ETC_Shotdown(adsClt, nargout=0)
        eng.meca2_ETC_Shotdown(adsClt, nargout=0)
        print("\nClosing MATLAB engine...")
        eng.quit()


if __name__ == '__main__':
    main()
