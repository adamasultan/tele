%% surface & lung phantom

% initial settings for the lung phantom with respiration
warning off
%% Initializations
close all
clear
clc
% TwinCat setup for Meca Robots 
global adsClt Move_command 
global R1_px R1_py R1_pz R1_rx R1_ry R1_rz

%
asm = NET.addAssembly('C:\Users\biom-admin\Desktop\Hoorieh\P3_v1_April_2024\TwinCAT.Ads.dll');
import TwinCAT.Ads.*;
adsClt = TwinCAT.Ads.TcAdsClient;           % create an ads client
adsClt.Connect('192.168.0.153.1.1',851);    % connect to the ip
%
Move_command = adsClt.ReadSymbolInfo('Main.Values'); 

R1_px = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.End_Effector_Pose.SubIndex_001');
R1_py = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.End_Effector_Pose.SubIndex_002');
R1_pz = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.End_Effector_Pose.SubIndex_003');
R1_rx = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.End_Effector_Pose.SubIndex_004');
R1_ry = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.End_Effector_Pose.SubIndex_005');
R1_rz = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.End_Effector_Pose.SubIndex_006');

R1_j1 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_001');
R1_j2 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_002');
R1_j3 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_003');
R1_j4 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_004');
R1_j5 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_005');
R1_j6 = adsClt.ReadSymbolInfo('GVL.Robot1.Inputs.Joint_Set.SubIndex_006');


%% RUN ROBOTS
meca1_ETC_Setup(adsClt)
pause(10)

%% Set velocities
% set joints velocity 
vel = 10;  % takes joint velocity in %  
values = [vel 0 0 0 0 0 8 32010 32011 1 1];  
adsClt.WriteAny(Move_command.IndexGroup, Move_command.IndexOffset, single(values)); 
pause(2)

% set Cartesian Angular velocity
values=[[30, 0, 0, 0, 0, 0] 10 32010 32011 1 1];   
adsClt.WriteAny(Move_command.IndexGroup,Move_command.IndexOffset,single(values));  
pause(10)

% set Cartesian Linear velocity
values=[[40, 0, 0, 0, 0, 0] 11 32010 32011 1 1];   
adsClt.WriteAny(Move_command.IndexGroup,Move_command.IndexOffset,single(values)); 


%% Robot's position reading
R1_Pos = meca1_GetPos(adsClt, R1_px, R1_py, R1_pz, R1_rx, R1_ry, R1_rz)

%%  Set Robots start points

% midle:  0.0000 -110.0000  375.0000   90.0000    0.0000  -88.0000
% front: 120.0000 -110.0000  375.0000   90.0000    0.0000  -88.0000
% back: -90.0000 -110.0000  375.0000   90.0000    0.0000  -88.0000
pos1 = [-53.0000 -171.0000  365.0000   90.0000    0.0000  -88.0000];   % End effector position with phantom
disp("set R1 pos1")
meca1_SetPos(adsClt, Move_command, pos1);

%% Joint move
Jmovement = [0    0    0    0    0    0];   % Joint movement values
meca1_MoveJoint(adsClt, Move_command, Jmovement, R1_j1, R1_j2, R1_j3, R1_j4, R1_j5, R1_j6)

%% WorldFrame move
meca1_MoveWF(adsClt, Move_command, [0  0  0  0  0  0])
% meca1_MoveTF(adsClt, Move_command, [0  0  0  0  0  0])

%% Force Sensor Data Initialization
Fx = adsClt.ReadSymbolInfo('GVL.Sensor.Inputs.Sensor_Data.Force_x');
Fy = adsClt.ReadSymbolInfo('GVL.Sensor.Inputs.Sensor_Data.Force_y');
Fz = adsClt.ReadSymbolInfo('GVL.Sensor.Inputs.Sensor_Data.Force_z');
Tx = adsClt.ReadSymbolInfo('GVL.Sensor.Inputs.Sensor_Data.Torque_x');
Ty = adsClt.ReadSymbolInfo('GVL.Sensor.Inputs.Sensor_Data.Torque_y');
Tz = adsClt.ReadSymbolInfo('GVL.Sensor.Inputs.Sensor_Data.Torque_z');

%% Force & Torque Calibration
check = 1;
while check==1

    mg = 1.35;
    force_offset = [0 0 0 0 0 0];
    force_offset1 = [0 0 0 0 0 0];
    force_offset2 = [0 0 0 0 0 0];
    force_offset3 = [0 0 0 0 0 0];
    force_offset4 = [0 0 0 0 0 0];
    force_offset5 = [0 0 0 0 0 0];
    
    % Theta = 0
    pos1 = [-53.0000 -171.0000  365.0000   90.0000    0.0000  -88.0000];   % End effector position with lung phantom
    meca1_SetPos(adsClt, Move_command, pos1);
    pause(2)
    disp("set R1 pos: theta = 0")
    
    R1_Pos = meca1_GetPos(adsClt, R1_px, R1_py, R1_pz, R1_rx, R1_ry, R1_rz);
    theta = (R1_Pos(6) + 88)
    Fg = [-mg*cosd(theta) mg*sind(theta) 0];
    
    for i = 1 : 20
        raw_Force(i,:) = read_Force(adsClt, Fx, Fy, Fz) - Fg;
        pause(100/1000)
    end
    force_offset1 = mean(raw_Force)
    pause(2)
    
    % Theta = 10
    meca1_MoveWF(adsClt, Move_command, [0, 0, 0, 0  -10  0])
    pause(2)
    disp("set R1 pos: theta = 10")
    R1_Pos = meca1_GetPos(adsClt, R1_px, R1_py, R1_pz, R1_rx, R1_ry, R1_rz);
    theta = (R1_Pos(6) + 88)
    Fg = [-mg*cosd(theta) mg*sind(theta) 0];
    
    for i = 1 : 20
        raw_Force(i,:) = read_Force(adsClt, Fx, Fy, Fz) - Fg;
        pause(100/1000)
    end
    force_offset2 = mean(raw_Force)
    pause(2)
    
    % Theta = 20
    meca1_MoveWF(adsClt, Move_command, [0, 0, 0,  0  -10  0])
    pause(2)
    disp("set R1 pos: theta = 20")
    R1_Pos = meca1_GetPos(adsClt, R1_px, R1_py, R1_pz, R1_rx, R1_ry, R1_rz);
    theta = (R1_Pos(6) + 88)
    Fg = [-mg*cosd(theta) mg*sind(theta) 0];
    
    for i = 1 : 20
        raw_Force(i,:) = read_Force(adsClt, Fx, Fy, Fz) - Fg;
        pause(100/1000)
    end
    force_offset3 = mean(raw_Force)
    pause(2)
    
    % Theta = -10
    meca1_MoveWF(adsClt, Move_command, [0, 0, 0, 0  30  0])
    pause(4)
    disp("set R1 pos: theta = -10")
    R1_Pos = meca1_GetPos(adsClt, R1_px, R1_py, R1_pz, R1_rx, R1_ry, R1_rz);
    theta = (R1_Pos(6) + 88)
    Fg = [-mg*cosd(theta) mg*sind(theta) 0];
    
    for i = 1 : 20
        raw_Force(i,:) = read_Force(adsClt, Fx, Fy, Fz) - Fg;
        pause(100/1000)
    end
    force_offset4 = mean(raw_Force)
    pause(2)
    
    % Theta = -20
    meca1_MoveWF(adsClt, Move_command, [0, 0, 0, 0  10  0])
    pause(4)
    disp("set R1 pos: theta = -20")
    R1_Pos = meca1_GetPos(adsClt, R1_px, R1_py, R1_pz, R1_rx, R1_ry, R1_rz);
    theta = (R1_Pos(6) + 88)
    Fg = [-mg*cosd(theta) mg*sind(theta) 0];
    
    for i = 1 : 20
        raw_Force(i,:) = read_Force(adsClt, Fx, Fy, Fz) - Fg;
        pause(100/1000)
    end
    force_offset5 = mean(raw_Force)
        
    check = 0;
end
force_offset = mean([force_offset1; force_offset2; force_offset3; force_offset4; force_offset5])
meca1_MoveWF(adsClt, Move_command, [0, 0, 0, 0  -20  0])
%% Calculating External Force
R1_Pos = meca1_GetPos(adsClt, R1_px, R1_py, R1_pz, R1_rx, R1_ry, R1_rz);
theta = (R1_Pos(6) + 88)   % theta = WRF rotation around y-axis
F_p_ext = Ext_Force(adsClt, Fx, Fy, Fz, mg, theta, force_offset)

%% Reading External Force Freely
while abs(F_p_ext(3))< 5
    F_p_ext = Ext_Force(adsClt, Fx, Fy, Fz, mg, theta, force_offset)
    pause(100/1000)
end

%% US setup
clc
size = 300; % image height & width in pixels
size_small = 60;

% Run this section to connect to the US
[res_x, res_y, X_axis, Y_axis] = US_start(size,size);
clc

%% 
pos1 = [-53.0000 -171.0000  365.0000   90.0000    -1.0000  -88.0000];   % End effector position with phantom
disp("set R1 pos1")
meca1_SetPos(adsClt, Move_command, pos1);

%% Parameter Initialization
alpha = 2;
beta = 70;
gamma = 0.05;
binary_threshold = 0.65;

col1 = size_small + 1;
n = size_small^2;
dev = 4;
n2 = n/dev;
x_mid = size_small / 2;
W = sparse(zeros(n2+size_small));
node = @(i,j) j + (i-1)*size_small;   
I2 = (1:n2-size_small)';
[x, y] = ind2sub([size_small size_small/dev-1], I2);
x_powers = x.^[0 1];
y_powers = y.^[0 1];
E = struct();

A = n*ones(n2,4);    % Adjacency Matrix
for i = 1:size_small/dev
    for j = 1:size_small
        idx = node(i,j);
        if i > 1
            q = node(i-1,j);
            A(idx,1) = q;   % Up
        end
        if i < size_small
            q = node(i+1,j);
            A(idx,2) = q;   % Down
        end
        if j > 1
            q = node(i,j-1);
            A(idx,3) = q;   % Left
        end
        if j < size_small
            q = node(i,j+1);
            A(idx,4) = q;   % Right
        end            
    end        
end

D = diag(exp(-alpha * ((1:size_small) ./ size_small)));

Img2 = zeros(size, size);

vref = 3;
vx_value = 3;

disp("Done!")
%% take the desired image
clear s_vec e_vec
iteration = 0; 
run_loop = true;
threshold = 1; % number of iterations to break imaging loop
calllib('USGFW2MATLABWRAPPER','Run_ultrasound_scanning');
frame_ptr = libpointer('uint32Ptr', zeros(1,size*size*4)); 
pause(2)


loop_f = 1;
while loop_f
    tic
    Img = US_readImage_single(size,size,frame_ptr);
    
    I = imresize(Img(15:end,:),[size_small size_small]); % resize the image for CM
    x_u = Confidence_map(D,I,A,W,beta,gamma,size_small,n,n2);
     % Confidence weighted Moments
    Cmoment = @(i,j) sum((x_powers(:,i+1)).*(y_powers(:,j+1)).*x_u(I2));
    
    E.Cm00 = Cmoment(0, 0);    
    E.alpha = full(E.Cm00 / n2);    
    E.theta = full(atand((Cmoment(1, 0) - x_mid*E.Cm00)/Cmoment(0, 1)));

    figure(1); imshow(Img) 
    CM = full(reshape(x_u,[size_small size_small/dev-1])');
    figure(3); imshow(CM,[],'InitialMagnification','fit') 
    title(['\alpha = ',sprintf('%.2f', E.alpha), '    \theta = ',sprintf('%.0f', E.theta),'^{\circ}' ])
    [E.alpha , E.theta]

    if E.alpha>0.37
        Img2(40:230, :) = Img(40:230, :);
        B_Img = bwareafilt(Img2 > binary_threshold,1);
        E = IW_moments(E,B_Img); % Binary Moments
        figure(1); hold on, line(E.xg+[-0.5 0.5]*E.l*cos(E.thetaN), E.yg+[-0.5 0.5]*E.l*sin(E.thetaN), 'LineWidth',1.5); hold off
        figure(2); imshow(B_Img)
    end
    
    toc
    
    
    disp("Select a direction to move R1 or press Esc to end:")
    k = waitforbuttonpress;
    value = double(get(gcf,'CurrentCharacter'));
    if value==30 % arrow right = x-
        meca1_MoveWF(adsClt, Move_command, [-1 0 0 0 0 0])
    elseif value==31 % arrow left = x+
        meca1_MoveWF(adsClt, Move_command, [1 0 0 0 0 0])
    elseif value==28 % arrow up = y-
        meca1_MoveWF(adsClt, Move_command, [0 -1 0 0 0 0])
    elseif value==29 % arrow down = y+
        meca1_MoveWF(adsClt, Move_command, [0 1 0 0 0 0])
    elseif value==49 % arrow down = z-
        meca1_MoveWF(adsClt, Move_command, [0 0 -1 0 0 0])
    elseif value==52 % arrow down = z+
        meca1_MoveWF(adsClt, Move_command, [0 0 1 0 0 0])
    elseif value==50 % arrow down = wx-
        meca1_MoveWF(adsClt, Move_command, [0 0 0 -1 0 0])
    elseif value==51 % arrow down = wx+
        meca1_MoveWF(adsClt, Move_command, [0 0 0 1 0 0])
    elseif value==53 % arrow down = wy-
        meca1_MoveWF(adsClt, Move_command, [0 0 0 0 -1 0])
    elseif value==54 % arrow down = wy+
        meca1_MoveWF(adsClt, Move_command, [0 0 0 0 1 0])
    elseif value==56 % arrow down = wz-
        meca1_MoveWF(adsClt, Move_command, [0 0 0 0 0 -1])
    elseif value==57 % arrow down = wz+
        meca1_MoveWF(adsClt, Move_command, [0 0 0 0 0 1])
    elseif value==32 % space
        meca1_MoveWF(adsClt, Move_command, [0 0 0 0 0 0])
    end

    if value==27
        loop_f=0;
        disp("End of loop");
    end   
end
l_ref = E.l
calllib('USGFW2MATLABWRAPPER','Freeze_ultrasound_scanning')  %% function to freeze scanning   
calllib('USGFW2MATLABWRAPPER','Stop_ultrasound_scanning'); % function stops ultrasound scanning

%% Robot1 Free keyboard movement
loop_f = 1;
while loop_f

    disp("Select a direction to move R1 or press Esc to end:")
    k = waitforbuttonpress;
    value = double(get(gcf,'CurrentCharacter'))
    if value==66666666666655530 % arrow right = x-
        meca1_MoveWF(adsClt, Move_command, [-1 0 0 0 0 0])
    elseif value==31 % arrow left = x+
        meca1_MoveWF(adsClt, Move_command, [1 0 0 0 0 0])
    elseif value==28 % arrow up = y-
        meca1_MoveWF(adsClt, Move_command, [0 -1 0 0 0 0])
    elseif value==29 % arrow down = y+
        meca1_MoveWF(adsClt, Move_command, [0 1 0 0 0 0])
    elseif value==49 % arrow down = z-
        meca1_MoveWF(adsClt, Move_command, [0 0 -1 0 0 0])
    elseif value==52 % arrow down = z+
        meca1_MoveWF(adsClt, Move_command, [0 0 1 0 0 0])
    elseif value==50 % arrow down = wx-
        meca1_MoveWF(adsClt, Move_command, [0 0 0 -1 0 0])
    elseif value==51 % arrow down = wx+
        meca1_MoveWF(adsClt, Move_command, [0 0 0 1 0 0])
    elseif value==53 % arrow down = wy-
        meca1_MoveWF(adsClt, Move_command, [0 0 0 0 -1 0])
    elseif value==54 % arrow down = wy+
        meca1_MoveWF(adsClt, Move_command, [0 0 0 0 1 0])
    elseif value==56 % arrow down = wz-
        meca1_MoveWF(adsClt, Move_command, [0 0 0 0 0 -1])
    elseif value==57 % arrow down = wz+
        meca1_MoveWF(adsClt, Move_command, [0 0 0 0 0 1])
    end

    if value==27
        loop_f=0;
        disp("End of loop");
    end   
end

%% Set Tool Reference Frame
meca1_SetTRF(adsClt, Move_command, [105, 0, 62, 0, 0, 0])
pause(1)
% meca1_SetTRF(adsClt, Move_command, [0, 0, 0, 0, 0, 0])
R1_Pos = meca1_GetPos(adsClt, R1_px, R1_py, R1_pz, R1_rx, R1_ry, R1_rz)

%% with TRF set start position
% pos1 = [262.0000    3.6644  115.0640    2.0000   92.0000         0];   % End effector position with phantom
%pos1 = [-106.4181 -214.0000  246.0000   90.0000   -1.0000  -88.0000];   % End effector position with phantom
% pos1 = [-59.3525 -232.8921  244.9648   90.2924   -0.9563  -93.5380];   % End effector position with phantom
pos1 = [-72.8451 -242.4569  245.8206   90.1500   -0.9519 -100.4462];   % End effector position with phantomdisp("set R1 pos1")
meca1_SetPos(adsClt, Move_command, pos1);
pause(2)

%% move in TRF
meca1_MoveTF(adsClt, Move_command, [0  1  0  0  0  0])
% meca1_MoveWF(adsClt, Move_command, [0, 0, 10, 0  0  0])

%% Contact Control y & alpha & beta
samples = 10000;
sampling_rate = 25;
r = rateControl(sampling_rate); % execute loop at fixed frequency 20Hz 
delta_T = 1/sampling_rate; % sampeling period
velocity = 2; % mm/s
dir = 1; % -->
fyref1 = -3;
fyref2 = -9;
Fext_vec = zeros(samples,3);
Fmean_vec = zeros(samples,3);
R1_Pos_vec = zeros(samples,6);
Img_vec = zeros(samples,size,size);
CM_vec = zeros(n2-size_small,samples);
time_val = zeros(1,samples);
clear E_vec

yincr = 0;
d_z = 0;
ystep = 0;
zstep = 0;
tstep = 0;
R1_Pos = meca1_GetPos(adsClt, R1_px, R1_py, R1_pz, R1_rx, R1_ry, R1_rz);
theta = (R1_Pos(6) + 88);   % theta = WRF rotation around x-axis
F_p_ext = Ext_Force(adsClt, Fx, Fy, Fz, mg, theta, force_offset);
Fext_vec(1,:) = F_p_ext;
Fext_vec(2,:) = F_p_ext;
Fext_vec(3,:) = F_p_ext;
Fext_vec(4,:) = F_p_ext;
cntr = 4;


initial_steps = 0;

control_data_vec = zeros(samples,12);

if R1_Pos(1) < -85
    vx_value = vref;
elseif R1_Pos(1) > -20
    vx_value = -vref;
end


calllib('USGFW2MATLABWRAPPER','Run_ultrasound_scanning');
frame_ptr = libpointer('uint32Ptr', zeros(1,size*size*4)); 
pause(2)

loop_f = 1;
reset(r)
while abs(F_p_ext(3)) < 5.5 && cntr <= samples
    cntr = cntr+1;
    initial_steps = initial_steps + 1;
    tic
    R1_Pos = meca1_GetPos(adsClt, R1_px, R1_py, R1_pz, R1_rx, R1_ry, R1_rz);
    theta = (R1_Pos(6) + 88);

    F_p_ext = Ext_Force(adsClt, Fx, Fy, Fz, mg, theta, force_offset);
    Fext_vec(cntr,:) = F_p_ext;
    Fmean_vec(cntr,:) = mean(Fext_vec(cntr-4:cntr,:));
    fy = Fmean_vec(cntr,2);
    fx = Fmean_vec(cntr,1);

    % =========================================================================
    Img = US_readImage_single(size,size,frame_ptr);
    
    I = imresize(Img(10:end,:),[size_small size_small]); % resize the image for CM
    x_u = Confidence_map(D,I,A,W,beta,gamma,size_small,n,n2);
     % Confidence weighted Moments
    Cmoment = @(i,j) sum((x_powers(:,i+1)).*(y_powers(:,j+1)).*x_u(I2));
    
    E.Cm00 = Cmoment(0, 0);    
    E.alpha = full(E.Cm00 / n2);    
    E.theta = full(atand((Cmoment(1, 0) - x_mid*E.Cm00)/Cmoment(0, 1)));
%     [E.alpha , E.theta]
    figure(1); imshow(Img,'InitialMagnification','fit') 
%     CM = full(reshape(x_u,[size_small size_small/dev-1])');
%     figure(3); imshow(CM,[],'InitialMagnification','fit') 
%     title(['\alpha = ',sprintf('%.2f', E.alpha), '    \theta = ',sprintf('%.0f', E.theta),'^{\circ}' , '    \theta US = ',sprintf('%.0f', theta),'^{\circ}'])
%     
    
%     if E.alpha > 0.10
%         Img2(40:230, :) = Img(40:230, :);
%         B_Img = bwareafilt(Img2 > binary_threshold,1);
%         E = IW_moments(E,B_Img); % Binary Moments
% %         figure(1); hold on, line(E.xg+[-0.5 0.5]*E.l*cos(E.thetaN), E.yg+[-0.5 0.5]*E.l*sin(E.thetaN), 'LineWidth',1.5); hold off
% %         figure(2); imshow(B_Img)
%         v_x = -0.05 * (l_ref - E.l);
%     else
%         v_x = 0;
%     end
        
    
    % =========================================================================
    if R1_Pos(1) < -85
        vx_value = vref;
    elseif R1_Pos(1) > -20
        vx_value = -vref;
    end
    v_x = vx_value;  
    v_y = 2.7 * (E.alpha - 0.45) * (fy-fyref2)/(1+abs(fy-fyref2));
    w_z = -0.12 * E.theta * 1/(1 + exp(-100*(E.alpha - 0.32)));

    d_x = v_x * delta_T;  
    d_z = v_y * delta_T;
    d_a = w_z * delta_T;
    
    if fy < -0.8  % ystep
        xstep = d_x * 1/(1 + exp(-100*(E.alpha - 0.33))); 
    else
        xstep = 0;
    end
    
    if R1_Pos(3) > 120 && R1_Pos(3) < 260   % zstep
        zstep = d_z; 
    else
        zstep = 0;
    end

%     if d_x > 0 && fx < -1.0  % tempval fx
%         tempval = 0.1 * (-1 - fx);
%     elseif d_x < 0 && fx > 1.0
%         tempval = 0.1 * (fx - 1);
%     else
%         tempval = 0;
%     end
    tempval = 0;

    if (theta > -60 && d_a < 0) || (theta < 60 && d_a > 0)  % tstep
        tstep = max(min(d_a + tempval,60),-60);
    else
        tstep = 0;
    end

    control_data_vec(cntr,:) = [n, dir, theta, yincr, xstep, v_y, d_z, zstep, w_z, d_a, tempval, tstep];
    
    move_val2 = [-zstep xstep 0 0 0 -tstep]
    meca1_MoveTF(adsClt, Move_command, [-zstep xstep 0 0 0 -tstep])

    time_val(cntr) = toc;

    control_data_vec(cntr,:) = [n, dir, theta, yincr, xstep, v_y, d_z, zstep, w_z, d_a, tempval, tstep];
    R1_Pos_vec(cntr,:) = R1_Pos;
    Img_vec(cntr,:,:) = Img;
    CM_vec(:,cntr) = x_u;
    E_vec{cntr} = E;
    
    

    waitfor(r);
end

disp("End")
time = r.TotalElapsedTime
stats = statistics(r)
calllib('USGFW2MATLABWRAPPER','Freeze_ultrasound_scanning')  %% function to freeze scanning   
calllib('USGFW2MATLABWRAPPER','Stop_ultrasound_scanning'); % function stops ultrasound scanning

%% Probe position set
value = 0;
p_step = 0.2;
while value~=27 
    disp("Select a direction to move R1 or press Esc to end:")
    k = waitforbuttonpress;
    value = double(get(gcf,'CurrentCharacter'))
    if value==30 % arrow up = x-
        meca1_MoveWF(adsClt, Move_command, [-p_step 0 0 0 0 0])
    elseif value==31 % arrow down = x+
        meca1_MoveWF(adsClt, Move_command, [p_step 0 0 0 0 0])
    elseif value==28 % arrow left = y-
        meca1_MoveWF(adsClt, Move_command, [0 -p_step 0 0 0 0])
    elseif value==29 % arrow right = y+
        meca1_MoveWF(adsClt, Move_command, [0 p_step 0 0 0 0])
    elseif value==49 % Num 1 = z-
        meca1_MoveWF(adsClt, Move_command, [0 0 -p_step 0 0 0])
    elseif value==52 % Num 4 = z+
        meca1_MoveWF(adsClt, Move_command, [0 0 p_step 0 0 0])
    elseif value==50 % Num 2 = wx-
        meca1_MoveWF(adsClt, Move_command, [0 0 0 -0.02 0 0])
    elseif value==51 % Num 3 = wx+
        meca1_MoveWF(adsClt, Move_command, [0 0 0 0.02 0 0])
    elseif value==53 % Num 5 = wy-
        meca1_MoveWF(adsClt, Move_command, [0 0 0 0 -0.02 0])
    elseif value==54 % Num 6 = wy+
        meca1_MoveWF(adsClt, Move_command, [0 0 0 0 0.02 0])
    elseif value==56 % Num 8 = wz-
        meca1_MoveWF(adsClt, Move_command, [0 0 0 0 0 -0.02])
    elseif value==57 % Num 9 = wz+
        meca1_MoveWF(adsClt, Move_command, [0 0 0 0 0 0.02])
    end
end
disp("End of loop");


%% free run moving (force & torque)
% f = [0 0 0 0 0 0];
p = [0 0 0 0 0 0];
trf = 1;
trt = 0.01;
k = 0.1;
while 1
    f = read_ForceTorque(adsClt, Fx, Fy, Fz, Tx, Ty, Tz, forceTorque_offset)
    p(1) = forceControl(f(3), -trf, trf, -k);
    p(2) = forceControl(f(1), -trf, trf, -k);
    p(3) = forceControl(f(2), -trf, 5*trf, k);
    p(4) = forceControl(f(6), -trt, trt, -3*k);
    p(5) = forceControl(f(4), -trt, trt, -3*k);
    p(6) = forceControl(f(5), -trt, trt, 3*k);
% 
    p        
    meca1_MoveWF(adsClt, Move_command, p)
    pause(0.02)
end



%% Plotting
samples = 200;
t = 1:samples;
figure(11);
plot(t,Es_vec')
% hold on; plot(t,phi(3,:))
grid on; hold off
title('Features Error')
xlabel("samples")
ylabel("error")
legend("E_x_t_i_p", "E_y_t_i_p", "E_\theta", "E_l","\phi")

figure(12);
plot(t,delta_p_vec')
grid on
title('\Delta p')
xlabel("samples")
ylabel("step values")
legend("\Delta x", "\Delta y", "\Delta \phi", "\Delta \theta")

% figure(13);
% plot(t,R2_Pos_vec)
% grid on
% title('\Delta p')
% xlabel("samples")
% ylabel("step values")
% legend("\Delta x", "\Delta y", "\Delta \phi", "\Delta \theta")
%% files setup
datetime1 = string(datetime('now','Format','d_MMM_HH_mm'));
filename1 = sprintf('Aug23_lung_1_cont_%s.mat',datetime1);

save(filename1)

%% US stop
% Run this section to disconnect US
US_stop

