 %Thời gian mô phỏng
T = 10;                % tổng thời gian (s)
dt = 0.001;             % bước thời gian
t = 0:dt:T;            % vector thời gian
% 
% % Tham số quỹ đạo: đường tròn trong mặt phẳng XY
% R = 0.1425;               % bán kính (m)
% f = 0.1;               % tần số quay (Hz)  -> 0.1 Hz = 1 vòng trong 10 giây
% omega = 2*pi*f;        % tốc độ góc (rad/s)
% Tham số quỹ đạo: đường tròn trong mặt phẳng XY
R = -0.453;               % bán kính (m)
f = 0.1;               % tần số quay (Hz)  -> 0.1 Hz = 1 vòng trong 10 giây
omega = 2*pi*f;        % tốc độ góc (rad/s)
% Tọa độ theo thời gian
x = R*cos(omega*t);
y = R*sin(omega*t);
z = 0.815*ones(size(t));   % giữ z cố định
% Ma trận quỹ đạo (time + position)

traj = [t' x' y' z'];
traj_offet=[x' y' z' ];
%thêm quỹ đạo cho mô phỏng
% reduce the resolution for trajectory display
theshold_filter_m =0.001;
traj_offset_display(1,1) =traj_offet(1,1);
traj_offset_display(1,2) =traj_offet(1,2);
traj_offset_display(1,3) =traj_offet(1,3);
idx =1;
for i=2:1:length(traj_offet)
    if ((abs(traj(i,2)-traj_offset_display(idx,1)) > theshold_filter_m) || ...
        (abs(traj(i,3)-traj_offset_display(idx,2)) > theshold_filter_m) || ...
        (abs(traj(i,4)-traj_offset_display(idx,3)) > theshold_filter_m))

        idx =idx +1;
        traj_offset_display(idx,1) =traj_offet(i,1);
        traj_offset_display(idx,2) =traj_offet(i,2);
        traj_offset_display(idx,3) =traj_offet(i,3);
    end

end
% Vẽ quỹ đạo 3D
figure;
plot3(x, y, z, 'b', 'LineWidth', 2); hold on;
plot3(x(1), y(1), z(1), 'ro', 'MarkerFaceColor','r'); % điểm bắt đầu
plot3(x(end), y(end), z(end), 'go', 'MarkerFaceColor','g'); % điểm kết thúc
grid on; axis equal;
xlabel('X'); ylabel('Y'); zlabel('Z');
title('Quỹ đạo tròn theo thời gian');

% Vẽ thêm biểu diễn theo thời gian
figure;
subplot(3,1,1); plot(t,x); xlabel('t (s)'); ylabel('x(t)');
subplot(3,1,2); plot(t,y); xlabel('t (s)'); ylabel('y(t)');
subplot(3,1,3); plot(t,z); xlabel('t (s)'); ylabel('z(t)');
