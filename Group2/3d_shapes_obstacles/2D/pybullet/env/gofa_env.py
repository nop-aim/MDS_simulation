import gymnasium as gym
from gymnasium import spaces

import numpy as np
import pybullet as p
import pybullet_data
import os, time, math
from typing import Optional, Tuple, List

# ================== EPFL LASA – Ellipse Modulation ==================
def modulation_matrix_ellipse()