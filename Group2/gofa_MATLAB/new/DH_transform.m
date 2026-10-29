% link length in meter
% link_twist in deg (to avoid the infinitesimal output of trigonometry
% operation)
% link offset in m
% joint value in deg

function T = DH_transform(link_length,link_twist,link_offset,joint_value)
a= link_length;
alpha = link_twist;
d= link_offset;
theta = joint_value;

T = sym(zeros(4,4));

T(1,1) = cosd(theta);
T(1,2) = -sind(theta);
T(1,3) = 0;
T(1,4) = a;

T(2,1) = sind(theta)*cosd(alpha);
T(2,2) = cosd(theta)*cosd(alpha);
T(2,3) = -sind(alpha);
T(2,4) = -sind(alpha)*d;

T(3,1) = sind(theta)*sind(alpha);
T(3,2) = cosd(theta)*sind(alpha);
T(3,3) = cosd(alpha);
T(3,4) = cosd(alpha)*d;

T(4,1) = 0;
T(4,2) = 0;
T(4,3) = 0;
T(4,4) = 1;