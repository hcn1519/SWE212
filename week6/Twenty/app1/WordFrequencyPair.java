import java.io.*;
import java.util.*;

public class WordFrequencyPair implements Comparable<WordFrequencyPair> {
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