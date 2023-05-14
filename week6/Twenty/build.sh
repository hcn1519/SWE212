javac *.java
jar cfm framework.jar manifest.mf *.class

javac -cp framework.jar $1/*.java
jar cf deploy/app2.jar $1/*.class