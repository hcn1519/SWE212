import java.io.*;
import java.util.*;
import java.util.jar.*;
import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.Method;

abstract class TFExercise {
    public String getInfo() {
        return this.getClass().getName();
    }
}

public class WordFrequencyController extends TFExercise {
    private DataStorageManager storageManager;
    private StopWordManager stopWordManager;
    private WordFrequencyManager wordFreqManager;
    
    public WordFrequencyController(String pathToFile) throws IOException {
        this.storageManager = new DataStorageManager(pathToFile);
        this.stopWordManager = new StopWordManager();
        this.wordFreqManager = new WordFrequencyManager();
    }
    
    public ArrayList<String> run() {
      
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

        ArrayList<String> res = new ArrayList<String>();        
        for (WordFrequencyPair pair : this.wordFreqManager.sorted()) {
          res.add(pair.getWord() + " - " + pair.getFrequency());
        }
        return res;
        
      } catch(Exception e) {
        e.printStackTrace();
      }
      return new ArrayList<String>();
    }
}
