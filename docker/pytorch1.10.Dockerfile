# 基于指定的基础镜像
FROM djiajun1206/pcdet:python3.8_pytorch1.10

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
    pip3 install -r requirements.txt && \
    python3 setup.py develop && \
    python3 setup.py

# 克隆 pc-corrector 仓库到 /root 目录下，并安装其依赖
WORKDIR /root
RUN git clone https://github.com/quan-dao/pc-corrector.git && \
    cd pc-corrector && \
    pip3 install -r requirements.txt && \
    pip3 install python-git-info einops torch_scatter torchmetrics==0.9 && \
    python3 setup.py develop --user && \
    pip3 cache purge  # 清理 pip 缓存

# 设置工作目录为根目录
WORKDIR /

# 配置环境变量
ENV NVIDIA_VISIBLE_DEVICES="all" \
    OpenCV_DIR=/usr/share/OpenCV \
    NVIDIA_DRIVER_CAPABILITIES="video,compute,utility,graphics" \
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/lib:/usr/lib:/usr/local/lib \
    QT_GRAPHICSSYSTEM="native"
