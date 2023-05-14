
import java.util.*;

public class Word implements IWord {

  public ArrayList<String> words(String filePath) {

    try {
     WordFrequencyController wfc = new WordFrequencyController(filePath);
      return wfc.run();
    } catch (Exception e) {
      e.printStackTrace();
      return new ArrayList<String>();  
    }
  }
}