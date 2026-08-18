FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    qemu-system-x86 \
    qemu-utils \
    genisoimage \
    iproute2 \
    curl \
    novnc \
    websockify \
    python3-numpy \
    && rm -rf /var/lib/apt/lists/*

# Установка go-template-cli
RUN curl -Lo /usr/local/bin/go-template https://github.com/bluebrown/go-template-cli/releases/download/v0.3.2/tpl-linux-amd64-static \
    && chmod +x /usr/local/bin/go-template

WORKDIR /app

COPY vm.yaml /app/vm.yaml
COPY qemu-run.sh.tmpl /app/qemu-run.sh.tmpl

EXPOSE 6080 5900

CMD ["sh", "-c", "cat /app/vm.yaml | go-template -d yaml --file /app/qemu-run.sh.tmpl > /app/run.sh && chmod +x /app/run.sh && /app/run.sh"]
