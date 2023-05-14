import java.io.*;
import java.util.*;

public class StopWordManager extends TFExercise {
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