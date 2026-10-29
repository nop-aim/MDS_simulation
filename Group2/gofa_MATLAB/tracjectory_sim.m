load('trajectory_data.mat');
x=lem_trajectory(:,2);
z=lem_trajectory(:,4)+1.2;
y=lem_trajectory(:,3);
t=lem_trajectory(:,1);

traj = [t x y z];
traj_offet=[x y z ];
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
