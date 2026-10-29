import gymnasium as gym
from stable_baselines3 import SAC
from stable_baselines3.common.env_util import make_vec_env
import os

# 1. Import Môi trường Tùy chỉnh
# Đảm bảo class GoFaDSResidualEnv được import hoặc đăng ký (như dòng comment cuối cùng trong file .env)
# Ví dụ: from gofa_ds_residual_env import GoFaDSResidualEnv 

# --- Cấu hình ---
# Đổi tên cho dễ chạy, nếu môi trường chưa được đăng ký
ENV_CLASS_NAME = 'GoFaDSResidualEnv' 
LOG_DIR = "./logs/"
MODEL_DIR = "./models/"
TOTAL_TIMESTEPS = 500_000 # Tổng số bước mô phỏng để huấn luyện

# Tạo thư mục nếu chưa tồn tại
os.makedirs(LOG_DIR, exist_ok=True)
os.makedirs(MODEL_DIR, exist_ok=True)

def create_gofa_env():
    """Hàm tạo môi trường (Dùng cho make_vec_env)"""
    # Thay thế bằng hàm tạo thực tế của môi trường GoFa của bạn
    # Ví dụ: return GoFaDSResidualEnv()
    
    # Dùng môi trường Dummy nếu GoFaDSResidualEnv chưa hoạt động
    from gofa_env import GoFaDSResidualEnv 
    return GoFaDSResidualEnv()


# 2. Tạo môi trường Vector hóa
# Tăng số lượng môi trường (n_envs) có thể tăng tốc độ thu thập dữ liệu
vec_env = make_vec_env(create_gofa_env, n_envs=1) 

# 3. Khởi tạo Mô hình SAC
# MlpPolicy (Multi-Layer Perceptron) là policy mặc định cho môi trường liên tục
model = SAC(
    "MlpPolicy",
    vec_env,
    verbose=1,
    buffer_size=100000,
    learning_rate=3e-4,
    gamma=0.99,
    tensorboard_log=LOG_DIR
)

print(f"Bắt đầu huấn luyện SAC trên {ENV_CLASS_NAME} với {TOTAL_TIMESTEPS} bước...")
print("-" * 50)

# 4. Huấn luyện Mô hình
# Bạn có thể thêm Callback để lưu checkpoint định kỳ
model.learn(
    total_timesteps=TOTAL_TIMESTEPS,
    log_interval=10,
    reset_num_timesteps=True
)

# 5. Lưu Mô hình cuối cùng
MODEL_FILE = os.path.join(MODEL_DIR, "sac_gofa_final.zip")
model.save(MODEL_FILE)
print(f"\n Hoàn thành huấn luyện. Mô hình đã được lưu tại: {MODEL_FILE}")

# Đóng môi trường
vec_env.close()