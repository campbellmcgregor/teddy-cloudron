FROM cloudron/base:3.0.0@sha256:455c70428723e3a823198c57472785437eb6eab082e79b3ff04ea584faf46e92

EXPOSE 8080

RUN mkdir -p /app/data /app/code

RUN apt-get update && \
    apt-get -y -q install openjdk-11-jdk && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk-amd64/
ENV JAVA_OPTS -Duser.timezone=Europe/London -Dfile.encoding=UTF-8 -Xmx1024m

 #Download and install Jetty
ENV JETTY_VERSION 9.4.12.v20180830
RUN wget -nv -O /tmp/jetty.tar.gz \
    "https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/${JETTY_VERSION}/jetty-distribution-${JETTY_VERSION}.tar.gz" \
    && tar xzf /tmp/jetty.tar.gz -C /app/code \
    && mv /app/code/jetty* /app/code/jetty \
    && useradd jetty -U -s /bin/false \
    && chown -R jetty:jetty /app/code/jetty
WORKDIR /app/code/jetty
RUN chmod +x bin/jetty.sh

# Init configuration
COPY opt /app/code
ENV JETTY_HOME /app/code/jetty
ENV JAVA_OPTIONS -Xmx512m


###teddy docker

RUN apt-get update && apt-get -y -q install ffmpeg mediainfo tesseract-ocr tesseract-ocr-fra tesseract-ocr-ita tesseract-ocr-kor tesseract-ocr-rus tesseract-ocr-ukr tesseract-ocr-spa tesseract-ocr-ara tesseract-ocr-hin tesseract-ocr-deu tesseract-ocr-pol tesseract-ocr-jpn tesseract-ocr-por tesseract-ocr-tha tesseract-ocr-jpn tesseract-ocr-chi-sim tesseract-ocr-chi-tra tesseract-ocr-nld tesseract-ocr-tur tesseract-ocr-heb tesseract-ocr-hun tesseract-ocr-fin tesseract-ocr-swe tesseract-ocr-lav tesseract-ocr-dan tesseract-ocr-nor && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Remove the embedded javax.mail jar from Jetty
RUN rm -f /app/code/jetty/lib/mail/javax.mail.glassfish-*.jar

ADD docs.xml /app/code/jetty/webapps/docs.xml
ADD docs-web/target/docs-web-*.war /app/code/jetty/webapps/docs.war


ENV JAVA_OPTIONS -Xmx1g
COPY start.sh /app/code
RUN chmod +x /app/code/start.sh && chown cloudron:cloudron /app/code/start.sh
# Set the default command to run when starting the container
CMD [ "/app/code/start.sh" ]