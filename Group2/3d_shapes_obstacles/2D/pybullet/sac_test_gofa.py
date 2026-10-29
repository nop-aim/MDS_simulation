import gymnasium as gym
from stable_baselines3 import SAC
import numpy as np
import os
import time

# 1. Import Môi trường Tùy chỉnh (Đảm bảo đường dẫn đúng)
from gofa__env import GoFaDSResidualEnv 
# Nếu môi trường có tên đăng ký, dùng: env_id = "GoFaDSResidual-v0"

# --- Cấu hình ---
MODEL_PATH = "./models/sac_gofa_final.zip"
NUM_EPISODES = 5 # Số episode muốn test
RENDER_MODE = 'human' # 'human' để xem mô phỏng (cần PyBullet GUI)

# 2. Khởi tạo Môi trường Test
# Môi trường test thường không cần vector hóa
try:
    env = GoFaDSResidualEnv(render_mode=RENDER_MODE)
except TypeError:
    env = GoFaDSResidualEnv()
    print("Môi trường không hỗ trợ render_mode, chạy ở chế độ mặc định.")


# 3. Tải Mô hình đã huấn luyện
if not os.path.exists(MODEL_PATH):
    print(f"❌ Lỗi: Không tìm thấy file mô hình tại '{MODEL_PATH}'. Vui lòng huấn luyện trước.")
    env.close()
    exit()

try:
    # Load mô hình, đảm bảo môi trường được truyền vào
    model = SAC.load(MODEL_PATH, env=env)
    print(f"✅ Đã tải mô hình thành công từ '{MODEL_PATH}'")

    # 4. Thực hiện chạy thử (Test Loop)
    print(f"\nBắt đầu Test với {NUM_EPISODES} episodes...")
    for episode in range(NUM_EPISODES):
        print(f"\n===== EPISODE {episode + 1} =====")
        
        obs, info = env.reset()
        done = False
        total_reward = 0
        step_count = 0
        
        while not done:
            # Chọn hành động (action) từ mô hình (deterministic=True cho test)
            action, _ = model.predict(obs, deterministic=True)
            
            # Thực hiện hành động
            obs, reward, terminated, truncated, info = env.step(action)
            
            total_reward += reward
            step_count += 1
            done = terminated or truncated
            
            # Có thể thêm độ trễ nếu cần xem rõ chuyển động
            # time.sleep(1/240.0) 

        print(f"Episode {episode + 1} kết thúc sau {step_count} bước. Tổng Reward: {total_reward:.2f}")

    env.close()
    print("\nHoàn thành Test.")

except Exception as e:
    print(f"❌ Đã xảy ra lỗi khi tải hoặc chạy mô hình: {e}")
    if 'env' in locals():
        env.close()