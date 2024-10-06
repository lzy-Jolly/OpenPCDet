# 基于指定的基础镜像
FROM pytorch/pytorch:1.7.0-cuda11.0-cudnn8-devel

# 更改apt源为清华镜像源
RUN sed -i 's|http://archive.ubuntu.com/ubuntu/|https://mirrors.tuna.tsinghua.edu.cn/ubuntu/|g' /etc/apt/sources.list && \
    sed -i 's|http://security.ubuntu.com/ubuntu/|https://mirrors.tuna.tsinghua.edu.cn/ubuntu/|g' /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
    git zip unzip libssl-dev libcairo2-dev lsb-release libgoogle-glog-dev libgflags-dev libatlas-base-dev libeigen3-dev software-properties-common \
    build-essential cmake pkg-config libapr1-dev autoconf automake libtool curl libc6 libboost-all-dev debconf libomp5 libstdc++6 \
    libqt5core5a libqt5xml5 libqt5gui5 libqt5widgets5 libqt5concurrent5 libqt5opengl5 libcap2 libusb-1.0-0 libatk-adaptor neovim \
    python3-pip python3-tornado python3-dev python3-numpy python3-virtualenv libpcl-dev libgoogle-glog-dev libgflags-dev libatlas-base-dev \
    libsuitesparse-dev python3-pcl pcl-tools libgtk2.0-dev libavcodec-dev libavformat-dev libswscale-dev libtbb2 libtbb-dev libjpeg-dev \
    libpng-dev libtiff-dev libdc1394-22-dev xfce4-terminal tmux tree rsync &&\
    rm -rf /var/lib/apt/lists/*


# For CUDA 11.3
RUN pip install torch==1.12.1+cu113 torchvision==0.13.1+cu113 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu113
ENV TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6+PTX"

# OpenPCDet
RUN pip install numpy==1.23.0 llvmlite numba tensorboardX easydict pyyaml scikit-image tqdm SharedArray open3d mayavi av2 kornia==0.6.5 pyquaternion -i https://pypi.tuna.tsinghua.edu.cn/simple
RUN pip install spconv-cu113 nuscenes-devkit==1.0.5 -i https://pypi.tuna.tsinghua.edu.cn/simple



# 安装额外的系统工具和监控工具
RUN apt-get update && apt-get install -y \
    tmux \
    tree \
    rsync \
    nvtop \
    htop && \
    rm -rf /var/lib/apt/lists/*

# 克隆 OpenPCDet 仓库到 /root 目录下，并安装其依赖
WORKDIR /root
RUN git clone https://github.com/open-mmlab/OpenPCDet.git && \
    cd OpenPCDet && \
    pip install -r requirements.txt && \
    python3 setup.py develop && \
 

# 克隆 pc-corrector 仓库到 /root 目录下，并安装其依赖
WORKDIR /root
RUN git clone https://github.com/quan-dao/pc-corrector.git && \
    cd pc-corrector && \
    pip install -r requirements.txt && \
    pip install python-git-info einops torch_scatter torchmetrics==0.9 && \
    python3 setup.py develop --user && \
    pip cache purge  # 清理 pip 缓存

# 设置工作目录为根目录
WORKDIR /

# 配置环境变量
ENV NVIDIA_VISIBLE_DEVICES="all" \
    OpenCV_DIR=/usr/share/OpenCV \
    NVIDIA_DRIVER_CAPABILITIES="video,compute,utility,graphics" \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib:/usr/lib:/usr/local/lib \
    QT_GRAPHICSSYSTEM="native"
