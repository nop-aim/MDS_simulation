figure; hold on; grid on;

% Đường DS chuẩn (đỏ)
plot3(x_sim(1,:), x_sim(2,:), x_sim(3,:), 'r', 'LineWidth', 2);

% Quỹ đạo robot – 3 giai đoạn
plot3(pos_log(1,idx1), pos_log(2,idx1), pos_log(3,idx1), ...
      'b', 'LineWidth', 2);   % đầu

plot3(pos_log(1,idx2), pos_log(2,idx2), pos_log(3,idx2), ...
      'g', 'LineWidth', 2);   % giữa

plot3(pos_log(1,idx3), pos_log(2,idx3), pos_log(3,idx3), ...
      'k', 'LineWidth', 2);   % cuối

plot3(attractor(1), attractor(2), attractor(3), 'mo', ...
      'MarkerSize', 12, 'LineWidth', 2);

legend('DS reference','Robot (early)','Robot (middle)','Robot (late)','Attractor');
xlabel('X'); ylabel('Y'); zlabel('Z');
view(3);
axis equal;
