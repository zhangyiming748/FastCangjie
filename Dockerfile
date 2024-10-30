FROM debian:bookworm

LABEL authors="zen"

# 设置非交互模式
ENV DEBIAN_FRONTEND=noninteractive

# 更换完整源
COPY debian.sources /etc/apt/sources.list.d/debian.sources

# 设置仓颉sdk
COPY Cangjie.tar.gz /root
RUN tar xvf /root/Cangjie.tar.gz
RUN source  /root/cangjie/envsetup.sh
RUN cjc -v

# 更新软件包并安装依赖
RUN apt update && \
    apt install -y --no-install-recommends \
    build-essential && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# 中文支持
RUN apt update && \
    apt install -y --no-install-recommends locales && \
    echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen zh_CN.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8

# 天朝特色：更换源
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list.d/debian.sources

# 设置环境变量
ENV LANG=zh_CN.UTF-8 \
    LANGUAGE=zh_CN:zh \
    LC_ALL=zh_CN.UTF-8

# 设置 root 密码
RUN echo "root:123456" | chpasswd

WORKDIR /
ENTRYPOINT ["bash"]
