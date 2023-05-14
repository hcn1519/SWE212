import java.io.*;
import java.util.*;
import java.util.jar.*;
import java.net.URL;
import java.net.URLClassLoader;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

public class Twenty {

    public static void main(String[] args) throws IOException {
        Properties prop = new Properties();
        String fileName = args[0];
        try (FileInputStream fis = new FileInputStream(fileName)) {
            prop.load(fis);
        } catch (Exception e) {
          e.printStackTrace();
          return;
        }

      try {
        File jarPath = new File(prop.getProperty("app"));
        String pkgName = prop.getProperty("pkgname");
        
        URL[] urls = { new URL("jar:file:" + jarPath + "!/" + pkgName + "/") };
        
        URLClassLoader classLoader = new URLClassLoader(urls);
        
        String className1 = "Word";
        Class<?> cls1 = classLoader.loadClass(className1);
        IWord word = (IWord) cls1.newInstance();

        String className2 = "Freq";
        Class<?> cls2 = classLoader.loadClass(className2);
        IFreq freq = (IFreq) cls2.newInstance();

        ArrayList<String> extractedWords = word.words(args[1]);
        List<String> res = freq.top25(extractedWords);
        
        for (String s : res) {
          System.out.println(s);
        }
      } catch(Exception e) {
        e.printStackTrace();
        return;
      }

  }
}