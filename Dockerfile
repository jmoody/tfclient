FROM ubuntu:20.04
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y sqlite3
RUN apt-get install -y git

RUN pip3 install bcrypt
ENV PYTHONUNBUFFERED 1

EXPOSE 10000
RUN git clone https://leagueh.xyz/git/textflight/.git/ textflight
WORKDIR /textflight
CMD ["src/main.py"]
