# Ubuntu 22.04 LTS をベースイメージとして使用
FROM ubuntu:22.04

# 環境変数などを設定
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8

# リポジトリのミラーを変更し、日本語環境と必要なパッケージをインストール
RUN sed -i 's/http:\/\/archive.ubuntu.com/http:\/\/jp.archive.ubuntu.com/g' /etc/apt/sources.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    language-pack-ja \
    font-noto-cjk \
    ibus-mozc \
    sudo \
    tightvncserver \
    xfce4 \
    xfce4-goodies \
    novnc \
    websockify

# VNCサーバーとnoVNCを起動するスクリプトを作成
RUN echo '#!/bin/bash' > /usr/local/bin/start-vnc.sh \
    && echo 'tightvncserver :1 -geometry 1280x800' >> /usr/local/bin/start-vnc.sh \
    && echo 'websockify --web /usr/share/novnc 6080 localhost:5901' >> /usr/local/bin/start-vnc.sh \
    && echo 'sleep infinity' >> /usr/local/bin/start-vnc.sh \
    && chmod +x /usr/local/bin/start-vnc.sh

# コンテナ起動時にスクリプトを自動実行
CMD ["/usr/local/bin/start-vnc.sh"]

# noVNCポートを公開
EXPOSE 6080
