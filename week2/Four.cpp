#include <algorithm>
#include <fstream>
#include <iostream>
#include <sstream>
#include <string>
#include <vector>

int main(int argc, char **argv) {

  std::vector<std::string> stopWords = {};
  std::ifstream inf{"../stop_words.txt"};

  while (inf) {
    std::string strInput;
    inf >> strInput;
    std::stringstream ss(strInput);
    std::string str;
    while (std::getline(ss, str, ',')) {

      std::transform(str.begin(), str.end(), str.begin(),
                     [](unsigned char c) { return std::tolower(c); });

      stopWords.push_back(str);
    }
  }

  for (int n = 97; n < 123; n++) {
    char cn = n;
    std::string s(1, cn);
    stopWords.push_back(s);
  }

  std::vector<std::string> wordStrs = {};
  std::vector<int> wordFreqs = {};

  std::ifstream file{argv[1]};
  std::string line;
  while (std::getline(file, line)) {
    int startIdx = -1;
    int i = 0;
    line.push_back('\n');

    for (auto c : line) {

      if (startIdx == -1) {
        if (isalnum(c)) {
          startIdx = i;
        }
      } else {
        if (!isalnum(c)) {

          std::string word = line.substr(startIdx, i - startIdx);

          std::transform(word.begin(), word.end(), word.begin(),
                         [](unsigned char x) { return std::tolower(x); });

          bool isInStopWord = false;
          for (auto stopWord : stopWords) {
            if (word == stopWord) {
              isInStopWord = true;
              break;
            }
          }

          if (!isInStopWord) {
            bool found = false;
            int pairIdx = 0;
            for (; pairIdx < wordStrs.size(); pairIdx++) {
              if (wordStrs[pairIdx] == word) {
                wordFreqs[pairIdx] += 1;
                found = true;
                break;
              }
            }

            if (!found) {
              wordStrs.push_back(word);
              wordFreqs.push_back(1);
            } else if (wordStrs.size() > 1) {

              for (int n = pairIdx; n >= 0; n--) {
                if (wordFreqs[pairIdx] > wordFreqs[n]) {
                  std::string tmp1 = wordStrs[pairIdx];
                  wordStrs[pairIdx] = wordStrs[n];
                  wordStrs[n] = tmp1;

                  int tmp2 = wordFreqs[pairIdx];
                  wordFreqs[pairIdx] = wordFreqs[n];
                  wordFreqs[n] = tmp2;
                  pairIdx = n;
                }
              }
            }
          }

          startIdx = -1;
        }
      }

      i += 1;
    }
  }

  for (int i = 0; i < 25; i++) {
    std::cout << wordStrs[i] << "  -  " << wordFreqs[i] << std::endl;
  }
}