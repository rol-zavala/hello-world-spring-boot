#build
FROM maven:3.8.5-openjdk-17 AS build
ENV HOME=/home/app
WORKDIR ${HOME}
COPY . ${HOME}
RUN mvn -f ${HOME}/pom.xml clean package -DskipTests

#launch
FROM openjdk:17
ENV HOME=/home/app
VOLUME /tmp
RUN mkdir -p /qr
EXPOSE 80
COPY --from=build ${HOME}/target/*.jar app.jar
ENTRYPOINT ["sh", "-c", "java -jar /app.jar"]