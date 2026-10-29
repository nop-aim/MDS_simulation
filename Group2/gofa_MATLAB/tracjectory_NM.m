t  = e.time;                 % thời gian
ex = e.signals.values(:,1);  % sai số x
ey = e.signals.values(:,2);  % sai số y
ez = e.signals.values(:,3);  % sai số z

figure;
plot(t, ex, 'r', 'LineWidth', 1.5); hold on;
plot(t, ey, 'g', 'LineWidth', 1.5);
plot(t, ez, 'b', 'LineWidth', 1.5);
grid on;

xlabel('Thời gian (s)');
ylabel('Sai số vị trí (m)');
legend('e_x','e_y','e_z');
title('Sai số vị trí đầu công tác theo thời gian');
e_norm = sqrt(ex.^2 + ey.^2 + ez.^2);

figure;
plot(t, e_norm, 'k', 'LineWidth', 1.5);
grid on;
xlabel('Thời gian (s)');
ylabel('||e|| (m)');
title('Chuẩn sai số vị trí');
