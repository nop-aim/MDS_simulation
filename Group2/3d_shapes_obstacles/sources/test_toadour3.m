%% Script Test Hệ Tọa Độ UR3
clear all; close all; clc;

% 1. Khởi tạo Robot (Đảm bảo folder 'ur3-model' nằm trong thư mục hiện tại)
try
    % Load robot trực tiếp từ file URDF
    robot = importrobot(fullfile('ur3-model', 'ur3.urdf'));
    robot.DataFormat = 'column';
    fprintf('✅ Đã load mô hình UR3 thành công.\n');
catch
    error('❌ Không tìm thấy file URDF. Kiểm tra lại đường dẫn "ur3-model/ur3.urdf".');
end

% 2. Kiểm tra Link 'tool0' và 'ee_link'
targetLink = 'tool0'; % Chúng ta ưu tiên tool0 cho dòng UR
try
    T = getTransform(robot, robot.homeConfiguration, targetLink);
    
    fprintf('\n--- KẾT QUẢ KIỂM TRA FRAME: %s ---\n', targetLink);
    disp('Ma trận xoay (Orientation Matrix):');
    disp(T(1:3, 1:3));
    
    disp('Vị trí (Position Vector):');
    disp(T(1:3, 4));
catch
    warning('Link "%s" không tồn tại. Đang thử với "ee_link"...', targetLink);
    targetLink = 'ee_link';
    T = getTransform(robot, robot.homeConfiguration, targetLink);
    disp(T(1:3, 1:3));
end

% 3. Hiển thị Robot và Trục tọa độ để đối chiếu mắt
figure('Name', 'Kiểm tra hướng Robot UR3', 'Color', 'w');
show(robot, robot.homeConfiguration, 'Frames', 'on', 'Visuals', 'on');
hold on;

% Vẽ trục tọa độ chuẩn của môi trường (World Frame) để so sánh
scale = 0.3;
quiver3(0,0,0, scale,0,0, 'r', 'LineWidth', 3, 'MaxHeadSize', 0.5); % X - Đỏ
quiver3(0,0,0, 0,scale,0, 'g', 'LineWidth', 3, 'MaxHeadSize', 0.5); % Y - Xanh lá
quiver3(0,0,0, 0,0,scale, 'b', 'LineWidth', 3, 'MaxHeadSize', 0.5); % Z - Xanh dương
text(scale, 0, 0, ' X World', 'Color', 'r', 'FontWeight', 'bold');
text(0, scale, 0, ' Y World', 'Color', 'g', 'FontWeight', 'bold');
text(0, 0, scale, ' Z World', 'Color', 'b', 'FontWeight', 'bold');

grid on; axis equal; view(3);
title(['Hướng của ' targetLink ' so với World Frame']);