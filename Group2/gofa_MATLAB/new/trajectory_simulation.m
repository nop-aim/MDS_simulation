%% load_lem_trajectory.m

close all; clc;

%% load file 
TRAJ_FILE = 'trajectory_data.mat'; 
LEM_VAR   = 'lem_trajectory';      
doPlot3D  = true;
theshold_filter_m = 1e-3;          

%% import
S = load(TRAJ_FILE);
assert(isfield(S, LEM_VAR), 'Không tìm thấy biến %s trong %s!', LEM_VAR, TRAJ_FILE);
raw = S.(LEM_VAR);
assert(size(raw,2) >= 4, 'Biến %s phải có tối thiểu 4 cột [t x y z].', LEM_VAR);

time = raw(:,1);
traj = raw(:,2:4);     % [x y z]


[time, iu] = unique(time,'stable'); 
traj = traj(iu,:);

% dt
if numel(time) >= 2
    dt_all = diff(time);
    dt = median(dt_all);
else
    dt = 0.01;
end

%% plot
if doPlot3D
    figure('Name','Raw trajectory (from file)');
    plot3(traj(:,1), traj(:,2), traj(:,3), '.-r'); grid on; axis equal;
    xlabel('X [m]'); ylabel('Y [m]'); zlabel('Z [m]');
    title('Raw trajectory');
    
    
    hold on;
    dq = [diff(traj,1,1); [0 0 0]];
    quiver3(traj(1:end-1,1), traj(1:end-1,2), traj(1:end-1,3), dq(1:end-1,1), dq(1:end-1,2), dq(1:end-1,3));
end

%% OFFSET

X_offset = traj(1,1);
Y_offset = traj(1,2);
Z_offset = traj(1,3);

traj_offset = traj;                 
traj_offset(:,1) = traj_offset(:,1) - X_offset;
traj_offset(:,2) = traj_offset(:,2) - Y_offset;
traj_offset(:,3) = traj_offset(:,3) - Z_offset;

% matrix [time traj_offset]
trajectory_time = [time, traj_offset];

%% plot 2D
filtered_2D_point = [];
idx = 1;
filtered_2D_point(idx,:) = traj_offset(1,1:2);
for i = 2:size(traj_offset,1)
    if any(abs(traj_offset(i,1:2) - filtered_2D_point(idx,:)) > theshold_filter_m) ...
       || abs(traj_offset(i,3)) > theshold_filter_m
        idx = idx + 1;
        filtered_2D_point(idx,:) = traj_offset(i,1:2);
    end
end

% plot 2D 
figure('Name','Filtered 2D');
plot(filtered_2D_point(:,1), filtered_2D_point(:,2), '.-r'); grid on; axis equal;
xlabel('X [m]'); ylabel('Y [m]'); title('Filtered 2D ');

%% WORKSPACE
%  - time           : vector thời gian
%  - traj           : [x y z] (gốc theo file)
%  - traj_offset    : [x y z] (dịch để điểm đầu ở (0,0,0))
%  - trajectory_time: [time x y z] (dạng tiện cho From Workspace)
%  - dt             : bước thời gian danh nghĩa
assignin('base','time',time);
assignin('base','traj',traj);
assignin('base','traj_offset',traj_offset);
assignin('base','trajectory_time',trajectory_time);
assignin('base','dt',dt);
