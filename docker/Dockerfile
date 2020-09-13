FROM python:3

RUN pip install --upgrade pip && \
    pip install Tinkerer sphinxjp.themes.tinkerbelizehole

WORKDIR /workspace

ENTRYPOINT ["tinker", "-b"]
