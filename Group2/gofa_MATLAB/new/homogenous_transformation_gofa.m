clc
clear all
close all

%% homogenous_transform_GOFA
syms theta1 theta2 theta3 theta4 theta5 theta6 % in deg
T01 = DH_transform(0.265, 180-theta1, 0, 0);
T12 = DH_transform(0, theta2 + 90, 0, 90);
T23 = DH_transform(0, theta3, 0.444, 0);
T34 = DH_transform(0.47, theta4, 0.11, -90);
T45 = DH_transform(0, theta5, 0, -90);
T56 = DH_transform(0, theta6, 0.08, -90);
T6_EF = DH_transform(0.101, 0, 0, 0);

T0_EF = simplify(T01*T12*T23*T34*T45*T56*T6_EF)

% test dong hoc thuan robot gofa
p_ef_x = T0_EF(1,4);
p_ef_y = T0_EF(2,4);
p_ef_z = T0_EF(3,4);

syms t1 t2 t3 t4 t5 t6
p_ef_x_short = subs(p_ef_x,[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi])
p_ef_y_short = subs(p_ef_y,[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi])
p_ef_z_short = subs(p_ef_z,[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi])

R_0_EF_11_short = subs( T0_EF(1,1),[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi])
R_0_EF_12_short = subs( T0_EF(1,2),[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi])
R_0_EF_13_short = subs( T0_EF(1,3),[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi])

R_0_EF_21_short = subs( T0_EF(2,1),[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi])
R_0_EF_22_short = subs( T0_EF(2,2),[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi])
R_0_EF_23_short = subs( T0_EF(2,3),[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi])

R_0_EF_31_short = subs( T0_EF(3,1),[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi])
R_0_EF_32_short = subs( T0_EF(3,2),[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi])
R_0_EF_33_short = subs( T0_EF(3,3),[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi])


% validation
x1_test = double(subs(p_ef_x_short,[t1 t2 t3 t4 t5 t6 ],[0 -pi/2 0 0 pi/2 0 ]))

y1_test = double(subs(p_ef_y_short,[t1 t2 t3 t4 t5 t6 ],[0 -pi/2 0 0 pi/2 0  ]))

z1_test = double(subs(p_ef_z_short,[t1 t2 t3 t4 t5 t6 ],[0 -pi/2 0 0 pi/2 0  ]))


x1_test = double(subs(p_ef_x_short,[t1 t2 t3 t4 t5 t6 ],[0 -pi/3 pi/4 0 pi/12 0 ]))

y1_test = double(subs(p_ef_y_short,[t1 t2 t3 t4 t5 t6 ],[0 -pi/3 pi/4 0 pi/12 0  ]))

z1_test = double(subs(p_ef_z_short,[t1 t2 t3 t4 t5 t6 ],[0 -pi/3 pi/4 0 pi/12 0  ]))


%% Linear_Jacobian_GOFA

J11 = simplify(diff(p_ef_x_short,t1))
J12 = simplify(diff(p_ef_x_short,t2))
J13 = simplify(diff(p_ef_x_short,t3))
J14 = simplify(diff(p_ef_x_short,t4))
J15 = simplify(diff(p_ef_x_short,t5))
J16 = simplify(diff(p_ef_x_short,t6))

J21 = simplify(diff(p_ef_y_short,t1))
J22 = simplify(diff(p_ef_y_short,t2))
J23 = simplify(diff(p_ef_y_short,t3))
J24 = simplify(diff(p_ef_y_short,t4))
J25 = simplify(diff(p_ef_y_short,t5))
J26 = simplify(diff(p_ef_y_short,t6))

J31 = simplify(diff(p_ef_z_short,t1))
J32 = simplify(diff(p_ef_z_short,t2))
J33 = simplify(diff(p_ef_z_short,t3))
J34 = simplify(diff(p_ef_z_short,t4))
J35 = simplify(diff(p_ef_z_short,t5))
J36 = simplify(diff(p_ef_z_short,t6))


% Angular Jacobian
T01_short = subs(T01,[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi]);
J41 = T01_short(1,3)
J51 = T01_short(2,3)
J61 = T01_short(3,3)

T02 = T01*T12;
T02_short = subs(T02,[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi]);
J42 = simplify(T02_short(1,3))
J52 = simplify(T02_short(2,3))
J62 = simplify(T02_short(3,3))

T03 = T02*T23;
T03_short = subs(T03,[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi]);
J43 = simplify(T03_short(1,3))
J53 = simplify(T03_short(2,3))
J63 = simplify(T03_short(3,3))

T04 = T03*T34;
T04_short = subs(T04,[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi]);
J44 = simplify(T04_short(1,3))
J54 = simplify(T04_short(2,3))
J64 = simplify(T04_short(3,3))

T05 = T04*T45;
T05_short = subs(T05,[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi]);
J45 = simplify(T05_short(1,3))
J55 = simplify(T05_short(2,3))
J65 = simplify(T05_short(3,3))

T06 = T05*T56;
T06_short = subs(T06,[theta1 theta2 theta3 theta4 theta5 theta6], [t1*180/pi t2*180/pi t3*180/pi t4*180/pi t5*180/pi t6*180/pi]);
J46 = simplify(T06_short(1,3))
J56 = simplify(T06_short(2,3))
J66 = simplify(T06_short(3,3))