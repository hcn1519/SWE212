import java.io.*;
import java.util.*;

public class DataStorageManager extends TFExercise {
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
