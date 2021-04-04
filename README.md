This is the webservice layer of phase 3.
Before attempting to build, be sure you have the following
installed:

Postgres - latest version
https://www.postgresql.org/download/

The datasource configuration can be found in resources/application.properties

The application assumes postgres is running at localhost:5432
and has the user postgres with password root.

Java 11

To build:

From the root directory via the commandline:

On windows:

``./gradlew.bat build ``

On *nix:

``./gradlew build``

To run via commandline execute from the project root directory : 

On windows:

``./gradlew.bat bootRun ``

On *nix

``./gradlew bootRun``

You can also build via an editor of your choice by importing 
as a gradle project. (I like Intellij)
https://www.jetbrains.com/idea/download/#section=windows


To verify that the application is running navigate to http://localhost:8080 in your browser.

The database schema located in resources/schema.sql. 

The application will dynamically create the schema everytime it starts. 

