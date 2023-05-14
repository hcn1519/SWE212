
import java.util.*;

public class Freq implements IFreq {

  public List<String> top25(ArrayList<String>words) {
    List<String> top25 = words.subList(0, Math.min(words.size(), 25));
    
    return top25;
  }
}