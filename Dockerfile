FROM alpine:3.22

RUN apk add --no-cache \
    bash \
    coreutils \
    qemu-system-x86_64 \
    qemu-img \
    cdrkit \
    iproute2 \
    curl \
    novnc \
    websockify \
    py3-numpy

RUN curl -Lo /usr/local/bin/go-template https://github.com/bluebrown/go-template-cli/releases/download/v0.3.2/tpl-linux-amd64-static \
    && chmod +x /usr/local/bin/go-template

WORKDIR /app

COPY vm.yaml /app/vm.yaml
COPY qemu-run.sh.tmpl /app/qemu-run.sh.tmpl
COPY lib /app/lib
COPY templates /app/templates

EXPOSE 6080 5900

CMD ["sh", "-c", "cat /app/vm.yaml | go-template -d yaml -f /app/qemu-run.sh.tmpl -f /app/templates/* -n qemu-run.sh.tmpl > /app/run.sh && chmod +x /app/run.sh && /app/run.sh"]
