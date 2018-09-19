FROM java:8-jre-alpine
COPY spring-cloud-consul-school-0.0.1-SNAPSHOT.jar /app.jar
EXPOSE 8898
CMD ["/usr/bin/java", "-jar", "/app.jar"]