from matlabconnection import setup_matlab_vars, start_matlab
import matlab
import time
import threading
from forcedim import init, close, get_pose

eng, adsClt = start_matlab() # gets the matlab adsClt to reference the twincat project running
Move_command = setup_matlab_vars() # gets the move command matlab var needed to move robots

quit_flag = False 
def listen_for_quit(): # function for quit thread that interrupts program
    global quit_flag
    while True:
        if input().strip().lower() == 'q':
            quit_flag = True
            break

def limit_meca500_pose(pose):
    limits = { # limits for meca position and orientation (can change)
        "x": (50, 240), # forward and back position
        "y": (-100, 100), # left right position
        "z": (260, 330), # up down position
        "rx": (-100000, 100000), # left right orientation *****DOESNT WORK******
        "ry": (5, 175), # up down orientation
        "rz": (-180, 180), # tool tip orientation
    }

    def clamp(value, min_val, max_val): # helper function that doesnt let the actual meca position exceed limits 
        return max(min_val, min(max_val, value))

    return [
        clamp(pose[0], *limits["x"]),
        clamp(pose[1], *limits["y"]),
        clamp(pose[2], *limits["z"]),
        clamp(pose[3], *limits["rx"]),
        clamp(pose[4], *limits["ry"]),
        clamp(pose[5], *limits["rz"]),
    ]

def set_joint_velocity():
    eng.setallvelocity(adsClt, Move_command, nargout=0) # uses matlab function to set the linear, orientation and joint velocities to the max

def robot_worker(robot_id): # function for robot thread that listens for changes in the force dimension controller
    global quit_flag
    print(f"Thread started for Robot {robot_id}")
    while not quit_flag:
        try:
            pose = get_pose(robot_id - 1) # get position of force dimension controller for the specific robot
            safe_pose = limit_meca500_pose(pose) # clamp the position so its safe for the meca robot
            move_to_absolute_joint_path(Move_command, safe_pose, robot_id) # Finally, move the meca robot to the safe position of the force dimension controller
        except Exception as e:
            print(f"Robot {robot_id} Error: {e}")
            break
    print(f"Thread exiting for Robot {robot_id}")

def reset_joints(Move_command, rnum):
    move_to_absolute_joint_path(Move_command,[190, 0, 308, 0, 90, 0], rnum) # hard coded the home destination to the move function. [190, 0, 308, 0, 90, 0] represents home

def move_to_absolute_joint_path(Move_command, float_array, rnum):
    Jmovement = matlab.double([float_array]) # must convert the movement array to matlab variable types
    if rnum == 1: # depending on robot1 or 2, set position for it
        eng.meca1_SetPos(adsClt, Move_command, Jmovement, nargout=0)
    elif rnum == 2:
        eng.meca2_SetPos(adsClt, Move_command, Jmovement, nargout=0)

def home_and_setup(Move_command):
    eng.meca1_ETC_Setup(adsClt, nargout=0) # set up all flags and values for meca robot in twincat
    eng.meca2_ETC_Setup(adsClt, nargout=0)
    reset_joints(Move_command, 1) # home robots
    reset_joints(Move_command, 2)

def main():
    global quit_flag
    try:
        home_and_setup(Move_command)

        init(0) #initialize for dimension controllers
        print("Force Dimension 1 initialized")
        init(1)
        print("Force Dimension 2 initialized")

        set_joint_velocity() #set velocities for the robots
        time.sleep(1)
        print("Robot Velocities set")

        print("Press 'q' then Enter at any time to quit...")
        # Start quit listener
        listener = threading.Thread(target=listen_for_quit, daemon=True) # create thread for listening to quit
        listener.start() 

        # Start both robot threads
        r1_thread = threading.Thread(target=robot_worker, args=(1,))
        r2_thread = threading.Thread(target=robot_worker, args=(2,))
        r1_thread.start()
        r2_thread.start()

        # Wait for both threads to finish
        r1_thread.join()
        r2_thread.join()

    finally:
        close(0) # close force dimension controllers
        close(1)
        print("Closing Force Dimension connection")
        eng.meca1_ETC_Shutdown(adsClt, nargout=0)
        print("Robot1 Deactivated")
        eng.meca2_ETC_Shutdown(adsClt, nargout=0)
        print("Robot2 Deactivated")
        eng.quit()
        print("Closing Matlab")

if __name__ == '__main__':
    main()
