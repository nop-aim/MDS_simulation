import pybullet as p
import pybullet_data
import numpy as np
import gymnasium as gym
from gymnasium import spaces

# --- HẰNG SỐ VÀ CẤU HÌNH ---
GOFA_MODEL_PATH = "gofa.urdf" 
K_DS = 0.5 

class GofaDSResidualEnv(gym.Env):
    def __init__(self, use_gui=True):
        super(GofaDSResidualEnv, self).__init__()
        
        # 1. Khởi tạo PyBullet
        if use_gui:
            self.client = p.connect(p.GUI)
        else:
            self.client = p.connect(p.DIRECT)
            
        p.setAdditionalSearchPath(pybullet_data.getDataPath(), physicsClientId=self.client)
        p.setGravity(0, 0, -9.81, physicsClientId=self.client)

        # 2. Định nghĩa Không gian Hành động và Quan sát
        self.action_space = spaces.Box(low=-0.1, high=0.1, shape=(3,), dtype=np.float32)
        self.observation_space = spaces.Box(low=-np.inf, high=np.inf, shape=(6,), dtype=np.float32) 
        
        # 3. Thuộc tính của Môi trường
        self.k_ds = K_DS
        self.gofa_id = None
        self.obstacle_id = None # Thêm ID cho vật cản
        self.end_effector_link_index = 6
        self.active_joints = [1, 2, 3, 4, 5, 6]
        self.target_pos = np.array([0.5, 0.5, 0.5])
        self.initial_pos = np.array([0.0, 0.0, 0.0])
        
        self.reset()

    def reset(self, seed=None, options=None):
        """Đặt lại môi trường về trạng thái ban đầu."""
        super().reset(seed=seed)
        p.resetSimulation(physicsClientId=self.client)
        p.setGravity(0, 0, -9.81, physicsClientId=self.client)
        
        # Tải nền (plane) và robot
        p.loadURDF("plane.urdf", physicsClientId=self.client)
        # Thay đổi tên biến từ 'ur3_id' sang 'gofa_id' (đã sửa trong code gốc)
        self.gofa_id = p.loadURDF(GOFA_MODEL_PATH, basePosition=[0, 0, 0], useFixedBase=True, physicsClientId=self.client)

        # Thiết lập vị trí khớp ban đầu
        initial_joint_positions = [0.0] * 6
        for i, joint_index in enumerate(self.active_joints):
            p.resetJointState(self.gofa_id, joint_index, initial_joint_positions[i], physicsClientId=self.client)
        
        # Tính vị trí TCP khởi tạo
        ls = p.getLinkState(self.gofa_id, self.end_effector_link_index, physicsClientId=self.client)
        self.initial_pos = np.array(ls[0])
        
        # Tải thế giới, các điểm gỡ lỗi và VẬT CẢN
        self._load_world()
        
        observation = self._get_observation()
        info = {}
        return observation, info

    def _load_world(self):
        """Thiết lập thế giới, vật thể, điểm gỡ lỗi VÀ VẬT CẢN."""
        p.removeAllUserDebugItems(physicsClientId=self.client)
        
        # Vị trí Mục tiêu (Target Position)
        self.target_pos = np.array([0.5, 0.1, 0.2])

        # --- Thêm Vật cản (Obstacle) ---
        # 1. Tạo hình dạng va chạm (Collision Shape) và hình ảnh (Visual Shape)
        box_half_extents = [0.1, 0.1, 0.1] # Kích thước nửa hộp: 20cm x 20cm x 20cm
        
        col_id = p.createCollisionShape(
            p.GEOM_BOX, 
            halfExtents=box_half_extents, 
            physicsClientId=self.client
        )
        vis_id = p.createVisualShape(
            p.GEOM_BOX, 
            halfExtents=box_half_extents, 
            rgbaColor=[0.8, 0.2, 0.2, 1], # Màu đỏ
            physicsClientId=self.client
        )
        
        # 2. Vị trí vật cản (Đặt vật cản giữa vị trí khởi tạo và mục tiêu)
        obstacle_pos = [0.3, 0.05, 0.1] # Vị trí X, Y, Z
        
        # 3. Tạo vật thể đa năng (MultiBody)
        self.obstacle_id = p.createMultiBody(
            baseMass=0, # Mass = 0: Vật cản cố định (Static)
            baseCollisionShapeIndex=col_id,
            baseVisualShapeIndex=vis_id,
            basePosition=obstacle_pos,
            physicsClientId=self.client
        )
        print(f"Đã thêm Vật cản Box tại vị trí: {obstacle_pos}")

        # --- Vẽ Debug Points (Không thay đổi) ---
        p.addUserDebugPoints([self.initial_pos], [[1, 0, 0]], 10.0, physicsClientId=self.client) # red
        p.addUserDebugPoints([self.target_pos], [[0, 1, 0]], 10.0, physicsClientId=self.client) # green

    # 97
    def ds_velocity(self, x, x_goal):
        """
        DS tuyến tính: x_dot = -k(x - x_goal).
        Tính vận tốc Cartesian mong muốn dựa trên Hệ thống Động (DS).
        """
        return -self.k_ds * (x - x_goal)

    # 102
    def cartesian_to_joint_vel(self, v_des):
        """
        Map v_des (TCP) -> qdot bằng Jacobian, chỉ dùng active_joints.
        Chuyển đổi vận tốc Cartesian mong muốn thành vận tốc khớp.
        """
        # (Giữ nguyên logic tính Jacobian và Pseudo-Inverse)
        ls = p.getLinkState(self.gofa_id, self.end_effector_link_index, physicsClientId=self.client)
        tcp_pos = ls[0]
        
        js = p.getJointStates(self.gofa_id, self.active_joints, physicsClientId=self.client)
        joint_positions = [state[0] for state in js]
        
        zero_vec = [0.0] * len(joint_positions)
        jac_t, jac_r = p.calculateJacobian(
            self.gofa_id, 
            self.end_effector_link_index, 
            tcp_pos, 
            joint_positions, 
            zero_vec, 
            zero_vec,
            physicsClientId=self.client
        )
        J = np.array(jac_t)[:, :len(self.active_joints)] 
        
        J_pinv = np.linalg.pinv(J)
        q_dot = J_pinv @ v_des
        
        return q_dot

    def _get_observation(self):
        """Lấy trạng thái quan sát hiện tại."""
        # Bạn có thể cân nhắc thêm thông tin về vật cản (vị trí, khoảng cách) vào observation 
        # để bộ điều khiển residual có thể học cách tránh nó.
        ls = p.getLinkState(self.gofa_id, self.end_effector_link_index, physicsClientId=self.client)
        tcp_pos = np.array(ls[0])
        observation = np.concatenate([tcp_pos, self.target_pos])
        return observation

    def step(self, action):
        """Thực hiện một bước hành động (action) trong môi trường."""
        
        # 1. Lấy vị trí TCP hiện tại (x)
        ls = p.getLinkState(self.gofa_id, self.end_effector_link_index, physicsClientId=self.client)
        x_current = np.array(ls[0])
        
        # 2. Vận tốc DS nền
        v_ds_base = self.ds_velocity(x_current, self.target_pos)
        
        # 3. Vận tốc Residual (Action)
        v_residual = action
        
        # 4. Vận tốc mong muốn tổng cộng
        v_des_total = v_ds_base + v_residual
        
        # 5. Chuyển đổi sang Vận tốc khớp
        q_dot_des = self.cartesian_to_joint_vel(v_des_total)
        
        # 6. Áp dụng điều khiển vận tốc khớp
        p.setJointMotorControlArray(
            self.gofa_id,
            self.active_joints,
            p.VELOCITY_CONTROL,
            targetVelocities=q_dot_des,
            forces=[500] * len(self.active_joints),
            physicsClientId=self.client
        )
        
        # 7. Bước tiến mô phỏng
        p.stepSimulation(physicsClientId=self.client)
        
        # 8. Tính thưởng và Điều kiện Kết thúc
        distance = np.linalg.norm(x_current - self.target_pos)
        reward = -distance 
        
        # Thêm hình phạt nếu robot va chạm với vật cản
        contact_points = p.getContactPoints(self.gofa_id, self.obstacle_id, physicsClientId=self.client)
        if contact_points:
            reward -= 5.0 # Hình phạt lớn cho va chạm
            # Bạn có thể thêm: terminated = True để kết thúc episode ngay khi va chạm
        
        terminated = distance < 0.01 
        truncated = False
        
        # 9. Trả về
        observation = self._get_observation()
        info = {"distance": distance, "collided": bool(contact_points)}
        return observation, reward, terminated, truncated, info

    def render(self):
        pass

    def close(self):
        p.disconnect(physicsClientId=self.client)

# --- Ví dụ về cách sử dụng ---
if __name__ == '__main__':
    env = GofaDSResidualEnv(use_gui=True)
    
    print("Môi trường GofaDSResidualEnv (có Vật cản) đã khởi tạo.")
    
    episodes = 5
    max_steps = 200
    
    for episode in range(episodes):
        obs, info = env.reset()
        terminated = False
        truncated = False
        episode_reward = 0
        
        print(f"\n--- Episode {episode + 1} ---")
        
        for step in range(max_steps):
            # Giả định action = 0.0 để chỉ chạy bộ điều khiển DS nền:
            # Lưu ý: Với vật cản, DS nền (không tránh cản) CÓ THỂ ĐÂM VÀO vật cản
            action = np.zeros(env.action_space.shape) 
            
            obs, reward, terminated, truncated, info = env.step(action)
            episode_reward += reward
            
            # Kiểm tra va chạm để in thông báo
            if info.get("collided"):
                 print(f"!!! VA CHẠM tại bước {step+1}. Thưởng: {reward:.2f}")

            if terminated or truncated:
                print(f"Kết thúc tại bước {step+1}. Khoảng cách cuối: {info['distance']:.4f}")
                break
            
        print(f"Tổng thưởng Episode: {episode_reward:.2f}")

    env.close()
    print("Mô phỏng kết thúc.")