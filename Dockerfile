# Use the official Tomcat 9 image with JDK 11
FROM tomcat:9.0-jdk11

# Copy the PetClinic WAR file to the Tomcat webapps directory
COPY target/petclinic.war /usr/local/tomcat/webapps/

# Expose the default Tomcat port
EXPOSE 8080

# Start the Tomcat server
CMD ["catalina.sh", "run"]
