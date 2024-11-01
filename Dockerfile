FROM debian:bookworm

LABEL authors="zen"

# 设置非交互模式
ENV DEBIAN_FRONTEND=noninteractive

# 更换完整源
COPY debian.sources /etc/apt/sources.list.d/debian.sources

# 设置仓颉sdk
COPY Cangjie.tar.gz /root
RUN tar xvf /root/Cangjie.tar.gz
RUN echo 'source /cangjie/envsetup.sh' >> /root/.zshrc

# 更新软件包并安装依赖
RUN apt update && \
    apt install -y --no-install-recommends \
    build-essential openssh-server zsh && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# 中文支持
RUN apt update && \
    apt install -y --no-install-recommends locales && \
    echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8

# 设置环境变量
ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8

# 设置 root 密码
RUN echo "root:123456" | chpasswd

# 设置默认shell
RUN chsh -s /usr/bin/zsh

# 允许 root 登录 SSH
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

# 天朝特色：更换源
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources

# 启动 SSH 服务
WORKDIR /root
ENTRYPOINT ["service", "ssh", "start", "-D"]

# docker --debug build --no-cache  -t zhangyiming748/cangjie:latest -f Dockerfile .
# docker run --restart no -d --name cangjie -p 8022:22 zhangyiming748/fastcangjie:latest
# docker exec -it cangjie zsh