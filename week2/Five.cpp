#include <algorithm>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

// helper function
std::vector<std::string> split_str(const std::string &s, char delim) {
  std::stringstream ss(s);
  std::string item;
  std::vector<std::string> elems;
  while (std::getline(ss, item, delim)) {
    elems.push_back(item);
  }
  return elems;
}

// procedures
void read_file(const char *filename, std::vector<char> &data) {
  std::ifstream inf{filename};
  
  char c;
  if(inf.is_open()) {
    while(inf.good()) {
      inf.get(c);
      data.push_back(c);
    }
  }
  inf.close();
}

void filter_chars_and_normalize(std::vector<char> &data) {
  for(int i = 0; i < data.size(); i++) {
    if (isalnum(data[i])) {
      data[i] = std::tolower(data[i]); 
    } else {
      data[i] = ' ';
    }
  }
}

void scan(std::vector<char> &data, std::vector<std::string> &words) {
  std::string data_str(data.begin(), data.end());
  std::vector<std::string> splited = split_str(data_str, ' ');
  words.insert(words.end(), splited.begin(), splited.end());
}

void remove_stop_words(std::vector<std::string> &words) {
  std::ifstream inf{"../stop_words.txt"};
  std::vector<std::string> stop_words{};

  while (inf) {
    std::string strInput;
    inf >> strInput;
    std::vector<std::string> splited = split_str(strInput, ',');
    stop_words.insert(stop_words.end(), splited.begin(), splited.end());
  }

  for (int n = 97; n < 123; n++) {
    char cn = n;
    std::string s(1, cn);
    stop_words.push_back(s);
  }
  
  std::vector<int> indexes {};
  for(int i = 0; i < words.size(); i++) {
    if (words[i] == "") {
      indexes.push_back(i);
    } else if (std::find(stop_words.begin(), stop_words.end(), words[i]) != stop_words.end()) {
      indexes.push_back(i);
    }
  }

  for(int i = indexes.size() - 1; i >= 0; i--) {
    words.erase(words.begin() + indexes[i]);
  }
}

void map_and_sort_frequencies(std::vector<std::string> &word_strs, std::vector<int> &word_freqs, std::vector<std::string> &words) {

  for(auto w : words) {

    auto itr = std::find(word_strs.begin(), word_strs.end(), w);

    if (itr != word_strs.cend()) {
      auto idx = std::distance(word_strs.begin(), itr);
      word_freqs[idx] += 1;

      for (int n = idx; n >= 0; n--) {
        if (word_freqs[idx] > word_freqs[n]) {
          std::string tmp1 = word_strs[idx];
          word_strs[idx] = word_strs[n];
          word_strs[n] = tmp1;
  
          int tmp2 = word_freqs[idx];
          word_freqs[idx] = word_freqs[n];
          word_freqs[n] = tmp2;
          idx = n;
        }
      }
    } else {
      word_strs.push_back(w);
      word_freqs.push_back(1);
    }
  }
}

int main(int argc, char **argv) {
  std::vector<char> data {};
  std::vector<std::string> words {};
  std::vector<std::string> word_strs {};
  std::vector<int> word_freqs {};
  
  read_file(argv[1], data);
  filter_chars_and_normalize(data);
  scan(data, words);
  remove_stop_words(words);
  map_and_sort_frequencies(word_strs, word_freqs, words);
  
  for (int i = 0; i < 25; i++) {
    std::cout << word_strs[i] << "  -  " << word_freqs[i] << std::endl;
  }
}