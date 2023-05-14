import java.io.*;
import java.util.*;
import java.util.jar.*;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

public class Seventeen {
    
    public static void main(String[] args) throws IOException {

      try {
        new WordFrequencyController(args[0]).run();
      } catch (Exception e) {
        e.printStackTrace();
        return;
      }
      
      JarFile jarFile = new JarFile("Seventeen.jar");
      ArrayList<String> availableClassNames = new ArrayList<String>();
      
      Enumeration allEntries = jarFile.entries();
      while (allEntries.hasMoreElements()) {
        JarEntry entry = (JarEntry) allEntries.nextElement();
        String name = entry.getName();
        if (name.endsWith(".class")) {
          String[] parts = name.split("\\.");
          availableClassNames.add(parts[0]);
        }
      }

      System.out.println("Enter class name to use");
      System.out.println("Available class names:");
      for (String s : availableClassNames) {
        System.out.println(s);
      }
      Scanner in = new Scanner(System.in);
      String className = in.nextLine();
      in.close();
      
      try {
        Class<?> cls = Class.forName(className);
        ClassDescripter desc = new ClassDescripter(cls);
        ClassDescripter.ClassComponent[] components = ClassDescripter.ClassComponent.values();

        for (ClassDescripter.ClassComponent c : components) {
          String field = desc.description(c);
          System.out.println(field);
        }
    } catch (ClassNotFoundException e) {
        e.printStackTrace();
    }
  }
}

class ClassDescripter {
  public enum ClassComponent {
    FIELD,
    METHOD,
    SUPERCLASS,
    INTERFACE
  }

  private Class<?> cls;
  
  public ClassDescripter(Class<?> cls) throws IOException {
    this.cls = cls;
  }
  
  public String description(ClassComponent component) {
    String res = "------------------";
    
    switch (component) {
    case FIELD:
        Field[] fields = this.cls.getDeclaredFields();
        res = res.concat("\nFields:");
        for (Field field : fields) {
            res = res.concat("\n" + field.getName() + ": " + field.getType().getName());
        }
        break;
    case METHOD:
        Method[] methods = this.cls.getDeclaredMethods();
        res = res.concat("\nMethods:\n");
        for (Method method : methods) {
            res = res.concat(method.getName());
        }
        break;
    case SUPERCLASS:
        Class<?> superClass = this.cls.getSuperclass();
        res = res.concat("\nSuperclass:\n").concat(superClass.getName());
        break;
    default:
        // interface
        Class<?>[] interfaces = this.cls.getInterfaces();
        res = res.concat("\nInterfaces:\n");
        for (Class<?> i : interfaces) {
          res = res.concat(i.getName());
        }
        break;
    }

    return res;
  }
}

abstract class TFExercise {
    public String getInfo() {
        return this.getClass().getName();
    }
}

class WordFrequencyController extends TFExercise {
    private DataStorageManager storageManager;
    private StopWordManager stopWordManager;
    private WordFrequencyManager wordFreqManager;
    
    public WordFrequencyController(String pathToFile) throws IOException {
        this.storageManager = new DataStorageManager(pathToFile);
        this.stopWordManager = new StopWordManager();
        this.wordFreqManager = new WordFrequencyManager();
    }
    
    public void run() {
      
      Class<?> dsm = DataStorageManager.class;
      Class<?> wfm = WordFrequencyManager.class;
      Class<?> wfp = WordFrequencyPair.class;
      Class<?> swm = StopWordManager.class;

      try {
        Method getWordsMethod = dsm.getMethod("getWords");
        Method isStopWordMethod = swm.getMethod("isStopWord", String.class);
        Method incrementCountMethod = wfm.getMethod("incrementCount", String.class);
        Method sortedMethod = wfm.getMethod("sorted");
        Method getWordMethod = wfp.getMethod("getWord");
        Method getFrequencyMethod = wfp.getMethod("getFrequency");
  
        ArrayList<String> words = (ArrayList<String>) getWordsMethod.invoke(this.storageManager);
        for (String word : words) {
            if (!(boolean) isStopWordMethod.invoke(this.stopWordManager, word)) {
              incrementCountMethod.invoke(this.wordFreqManager, word);
            }
        }

        ArrayList<WordFrequencyPair> pairs = (ArrayList<WordFrequencyPair>) sortedMethod.invoke(this.wordFreqManager);

        int numWordsPrinted = 0;
        for (WordFrequencyPair pair : pairs) {
          String w = (String) getWordMethod.invoke(pair);
          int freq = (int) getFrequencyMethod.invoke(pair);
          System.out.println(w + " - " + freq);
          numWordsPrinted++;
          if (numWordsPrinted >= 25) {
                break;
            }
        }
      } catch(Exception e) {
        e.printStackTrace();
      }
    }
}

/** Models the contents of the file. */
class DataStorageManager extends TFExercise {
    private List<String> words;
    
    public DataStorageManager(String pathToFile) throws IOException {
        this.words = new ArrayList<String>();
        
        Scanner f = new Scanner(new File(pathToFile), "UTF-8");
        try {
            f.useDelimiter("[\\W_]+");
            while (f.hasNext()) {
                this.words.add(f.next().toLowerCase());
            }
        } finally {
            f.close();
        }
    }
    
    public List<String> getWords() {
        return this.words;
    }
    
    public String getInfo() {
        return super.getInfo() + ": My major data structure is a " + this.words.getClass().getName();
    }
}

/** Models the stop word filter. */
class StopWordManager extends TFExercise {
    private Set<String> stopWords;
    
    public StopWordManager() throws IOException {
        this.stopWords = new HashSet<String>();
        
        Scanner f = new Scanner(new File("../../stop_words.txt"), "UTF-8");
        try {
            f.useDelimiter(",");
            while (f.hasNext()) {
                this.stopWords.add(f.next());
            }
        } finally {
            f.close();
        }
        
        // Add single-letter words
        for (char c = 'a'; c <= 'z'; c++) {
            this.stopWords.add("" + c);
        }
    }
    
    public boolean isStopWord(String word) {
        return this.stopWords.contains(word);
    }
    
    public String getInfo() {
        return super.getInfo() + ": My major data structure is a " + this.stopWords.getClass().getName();
    }
}

/** Keeps the word frequency data. */
class WordFrequencyManager extends TFExercise {
    private Map<String, MutableInteger> wordFreqs;
    
    public WordFrequencyManager() {
        this.wordFreqs = new HashMap<String, MutableInteger>();
    }
    
    public void incrementCount(String word) {
        MutableInteger count = this.wordFreqs.get(word);
        if (count == null) {
            this.wordFreqs.put(word, new MutableInteger(1));
        } else {
            count.setValue(count.getValue() + 1);
        }
    }
    
    public List<WordFrequencyPair> sorted() {
        List<WordFrequencyPair> pairs = new ArrayList<WordFrequencyPair>();
        for (Map.Entry<String, MutableInteger> entry : wordFreqs.entrySet()) {
            pairs.add(new WordFrequencyPair(entry.getKey(), entry.getValue().getValue()));
        }
        Collections.sort(pairs);
        Collections.reverse(pairs);
        return pairs;
    }
    
    public String getInfo() {
        return super.getInfo() + ": My major data structure is a " + this.wordFreqs.getClass().getName();
    }
}

class MutableInteger {
    private int value;
    
    public MutableInteger(int value) {
        this.value = value;
    }
    
    public int getValue() {
        return value;
    }
    
    public void setValue(int value) {
        this.value = value;
    }
}

class WordFrequencyPair implements Comparable<WordFrequencyPair> {
    private String word;
    private int frequency;
    
    public WordFrequencyPair(String word, int frequency) {
        this.word = word;
        this.frequency = frequency;
    }
    
    public String getWord() {
        return word;
    }
    
    public int getFrequency() {
        return frequency;
    }
    
    public int compareTo(WordFrequencyPair other) {
        return this.frequency - other.frequency;
    }
}