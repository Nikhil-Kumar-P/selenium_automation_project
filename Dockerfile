# Use the maven image as the build stage
FROM maven:3.9.7-eclipse-temurin-21 AS build
WORKDIR /automation.project

# Set the JAVA_HOME environment variable
ENV JAVA_HOME /Library/Java/JavaVirtualMachines/temurin-21.jdk/Contents/Home

# Copy the project files
COPY pom.xml .
COPY src ./src
COPY src/main/java/TestSuite/TestCase.xlsx ./src/main/java/TestSuite/TestCase.xlsx

# Install Firefox
RUN apt-get update && apt-get install -y firefox

# Install Maven
RUN apt-get update && apt-get install -y maven

# Package the application
RUN mvn clean package -DskipTests

# Use the eclipse-temurin image as the runtime stage
FROM eclipse-temurin:21-jre-jammy
WORKDIR /automation.project

# Copy the built application from the build stage
COPY --from=build /automation.project/target /automation.project/target

# Install Firefox in the runtime stage as well
RUN apt-get update && apt-get install -y firefox

# Install Maven in the runtime stage as well
RUN apt-get update && apt-get install -y maven

# Set the path to the properties file as an environment variable
ENV PROPERTIES_FILE=src/main/java/ObjectRepository/objectrepository.properties

# Run the application
CMD ["java", "-jar", "/automation.project/target/automation.project-0.0.1-SNAPSHOT.jar"]
