% doan chuong trinh nay thuc hien mo phong hanh dong pick and place su dung
% robot YUMI cua ABB. Canh tay phai thuc hien hanh dong pick and place.
% Thuc hien ngay 1/8/2025

clc
clear all
close all

%% Buoc 1: Nhap URDF va tao RigidBodyTree
urdfPath = 'D:\PhdRMIT\ds_robotarm\robot_tree\urdf_files_dataset\urdf_files_dataset\urdf_files\matlab\yumi_description\urdf\abbYuMi.urdf';

% Hien thi robot tu URDF (de xac dinh dung URDF)
smimport(urdfPath); 

% Tao RigidBodyTree
yumiRBT = importrobot(urdfPath);
yumiRBT.DataFormat = 'row';   % tra ve vector double

%% Buoc 2: Tao IK solver
ik = robotics.InverseKinematics('RigidBodyTree', yumiRBT); % goi IK solver de cho matlab 2018a robotics.InverseKinematics
weights = [0.25 0.25 0.25 1 1 1]; % [x y z roll pitch yaw] % trong so cho IK

% Lay home configuration
initialGuessStruct = homeConfiguration(yumiRBT); % cau hinh home cho robot duoi dang mang struct

% Xu ly tuong thich: struct -> double
if isstruct(initialGuessStruct)
    initialGuess = [initialGuessStruct.JointPosition];
else
    initialGuess = initialGuessStruct;
end

% Tao pose dich
%homogeneous transform 4x4 (SE3) cho end-effector
%axang2tform - Convert axis-angle rotation to homogeneous transformation
%trvec2tform - ma tran dich chuyen vi tri
%nhan hai ma tran ta duoc : Pose c?a end-effector trong không gian 3D
targetPose = trvec2tform([0.3, -0.2, 0.4]) * axang2tform([0 1 0 pi]); 
endEffector = 'gripper_r_base';

[configSol, solInfo] = ik(endEffector, targetPose, weights, initialGuess);

%% Buoc 3: Giai IK cho Pick va Place
pickPose = trvec2tform([0.3, -0.2, 0.3]) * axang2tform([0 1 0 pi]);
placePose = trvec2tform([0.4,  0.2, 0.35]) * axang2tform([0 1 0 pi/2]);

[configPick, solPick] = ik(endEffector, pickPose, weights, initialGuess);
[configPlace, solPlace] = ik(endEffector, placePose, weights, configPick);

disp('Pick configuration (rad):');
disp(configPick')
disp('Place configuration (rad):');
disp(configPlace')

% Hien thi robot o Pick
figure;
show(yumiRBT, configPick, 'PreservePlot', false);
title('Pick Pose'); 
axis equal; 
view(135,20);

% Hien thi robot o Place
figure;
show(yumiRBT, configPlace, 'PreservePlot', false);
title('Place Pose'); 
axis equal;
view(135,20);

%% Buoc 4: quy dao chuyen dong cho pick and place
numPoints = 50;
qPick = configPick(:);    
qPlace = configPlace(:);  

t = linspace(0,1,numPoints);
qTraj = (1 - t) .* qPick + t .* qPlace;

% Mo phong chuyen dong robot
figure;
for i = 1:numPoints
    show(yumiRBT, qTraj(:,i)', 'PreservePlot', false);
    title(sprintf('Frame %d / %d', i, numPoints));
    axis([-0.5 1 -0.5 1 -0.1 1]); % gioi han khung hinh 
    view(135,20);
    drawnow;
end

