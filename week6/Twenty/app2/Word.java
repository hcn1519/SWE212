
import java.util.*;

public class Word implements IWord {

  public ArrayList<String> words(String filePath) {

    try {
      App app = new App(filePath);
      return app.words();
    } catch (Exception e) {
      e.printStackTrace();
      return new ArrayList<String>();  
    }
  }
}