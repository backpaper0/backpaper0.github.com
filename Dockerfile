FROM python:2

ADD requirements.txt requirements.txt

RUN pip install -r requirements.txt

WORKDIR /opt/blog

ENTRYPOINT ["tinker", "-b"]
