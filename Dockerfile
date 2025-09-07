# Ubuntu 22.04 LTSをベースイメージとして使用
FROM ubuntu:22.04

# 環境変数などを設定
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8

# パッケージリストを更新し、日本語パッケージを優先してインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    language-pack-ja \
    locales

# 日本語ロケールの設定を反映
RUN locale-gen ja_JP.UTF-8

# その他の必要なパッケージをインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    font-noto-cjk \
    ibus-mozc \
    sudo \
    tightvncserver \
    xfce4 \
    xfce4-goodies \
    novnc \
    websockify \
    supervisor \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# VNCサーバーとnoVNCを起動する設定ファイルを作成
RUN echo '[supervisord]' > /etc/supervisor/conf.d/supervisord.conf \
    && echo 'nodaemon=true' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo '[program:vnc]' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'command=tightvncserver :1 -geometry 1280x800' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'autostart=true' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'autorestart=true' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo '[program:novnc]' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'command=websockify --web /usr/share/novnc 6080 localhost:5901' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'autostart=true' >> /etc/supervisor/conf.d/supervisord.conf \
    && echo 'autorestart=true' >> /etc/supervisor/conf.conf.d/supervisord.conf

# コンテナ起動時にsupervisorを自動実行
CMD ["/usr/bin/supervisord"]

# noVNCポートを公開
EXPOSE 6080
