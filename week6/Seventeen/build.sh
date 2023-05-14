echo "Remove cached files - *.class and *.jar"
rm *.class *.jar

echo "Compile Seventeen.java"
javac Seventeen.java

echo "Create jar - Seventeen.jar"
jar cfm Seventeen.jar manifest.mf *.class