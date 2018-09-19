FROM java:8-jre-alpine
COPY spring-cloud-consul-student-0.0.1-SNAPSHOT.jar /app.jar
EXPOSE 8899
CMD ["/usr/bin/java", "-jar", "/app.jar"]