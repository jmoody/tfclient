FROM ubuntu:20.04
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN apt-get install -y sqlite3
RUN apt-get install -y git
RUN apt-get install -y openssl
RUN apt-get install -y sed

RUN pip3 install bcrypt
ENV PYTHONUNBUFFERED 1

EXPOSE 10000
RUN git clone -b feature/unset-client-mode https://github.com/jmoody/textflight.git textflight
WORKDIR /textflight
RUN cp textflight.conf.example textflight.conf
RUN mkdir -p certs
RUN openssl \
      req -x509 \
      -newkey rsa:4096 \
      -keyout certs/key.pem \
      -out certs/cert.pem \
      -days 365 \
      -nodes \
      -subj "/C=DE/ST=BW/L=Konstanz/O=nibiru/OU=Org/CN=localhost"
RUN sed -i -e "s/SSL = false/SSL = true/" textflight.conf
RUN sed -i -e "s/SSLCert =/SSLCert = certs\/cert.pem/" textflight.conf
RUN sed -i -e "s/SSLKey =/SSLKey = certs\/key.pem/" textflight.conf
ADD "https://www.random.org/cgi-bin/randbyte?nbytes=10&format=h" skipcache
RUN cat textflight.conf

CMD ["src/main.py"]
