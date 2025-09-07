# Ubuntu 22.04 LTS をベースイメージとして使用
FROM ubuntu:22.04

# 日本語環境に必要なパッケージをインストール
# ロケール設定、日本語フォント、入力メソッド (Mozc) を追加
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tightvncserver \
    sudo \
    websockify \
    language-pack-ja \
    fonts-ipaexfont-gothic \
    ibus-mozc \
    && apt-get clean

# ロケールをja_JP.UTF-8に設定
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8
RUN locale-gen ja_JP.UTF-8

# VNCサーバーのxstartup設定
RUN echo '#!/bin/bash' > /root/.vnc/xstartup \
    && echo 'unset SESSION_MANAGER' >> /root/.vnc/xstartup \
    && echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /root/.vnc/xstartup \
    && echo 'startxfce4 &' >> /root/.vnc/xstartup \
    && chmod +x /root/.vnc/xstartup

# VNCサーバーとnoVNCを起動するスクリプトを作成
RUN echo '#!/bin/bash' > /usr/local/bin/start-vnc.sh \
    && echo 'tightvncserver :1 -geometry 1280x800' >> /usr/local/bin/start-vnc.sh \
    && echo 'websockify --web /usr/share/novnc 6080 localhost:5901' >> /usr/local/bin/start-vnc.sh \
    && echo 'sleep infinity' >> /usr/local/bin/start-vnc.sh \
    && chmod +x /usr/local/bin/start-vnc.sh

# コンテナ起動時にスクリプトを実行
CMD ["/usr/local/bin/start-vnc.sh"]

# noVNCのポートを公開
EXPOSE 6080
