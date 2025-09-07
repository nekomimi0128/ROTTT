# Ubuntu 22.04 LTS をベースイメージとして使用
FROM ubuntu:22.04

# 日本語環境に必要なパッケージをインストール
# ロケール設定、日本語フォント、入力メソッド (Mozc) を追加
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tightvncserver \
    sudo \
    supervisor \
    language-pack-ja \
    fonts-ipaexfont-gothic \
    ibus-mozc \
    && apt-get clean

# ロケールをja_JP.UTF-8に設定
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8
RUN locale-gen ja_JP.UTF-8

# VNCサーバーの設定
RUN echo '#!/bin/bash' > /root/.vnc/xstartup \
    && echo 'unset SESSION_MANAGER' >> /root/.vnc/xstartup \
    && echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /root/.vnc/xstartup \
    && echo 'startxfce4 &' >> /root/.vnc/xstartup \
    && chmod +x /root/.vnc/xstartup \
    && tightvncserver :1

# VNCサーバーを自動起動するためのSupervisor設定
RUN mkdir -p /etc/supervisor/conf.d \
    && echo '[supervisord]' > /etc/supervisor/conf.d/supervisord.conf \
    && echo 'nodaemon=true' >> /etc/supervisor/conf.conf \
    && echo '[program:vncserver]' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'command=su -c "vncserver :1"' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'user=root' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'autostart=true' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'autorestart=true' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'stdout_logfile=/var/log/supervisor/vncserver.log' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'stderr_logfile=/var/log/supervisor/vncserver_err.log' >> /etc/supervisor/conf.d/supervisord.conf

# コンテナ起動時にSupervisorを起動
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# VNCポートを公開
EXPOSE 5901
