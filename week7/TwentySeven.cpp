#include <algorithm>
#include <fstream>
#include <functional>
#include <iostream>
#include <set>
#include <sstream>
#include <string>
#include <vector>

std::vector<std::string> split_str(const std::string &s, char delim) {
  std::stringstream ss(s);
  std::string item;
  std::vector<std::string> elems;
  while (std::getline(ss, item, delim)) {
    elems.push_back(item);
  }
  return elems;
}

std::vector<char> read_file(const char *filename) {
  std::vector<char> data{};
  std::ifstream inf{filename};

  char c;
  if (inf.is_open()) {
    while (inf.good()) {
      inf.get(c);
      data.push_back(c);
    }
  }
  inf.close();
  return data;
}

void filter_chars_and_normalize(std::vector<char> &data) {
  for (int i = 0; i < data.size(); i++) {
    if (isalnum(data[i])) {
      data[i] = std::tolower(data[i]);
    } else {
      data[i] = ' ';
    }
  }
}

std::vector<std::string> scan(std::vector<char> &data) {
  std::vector<std::string> words = {};
  std::string data_str(data.begin(), data.end());
  std::vector<std::string> splited = split_str(data_str, ' ');
  words.insert(words.end(), splited.begin(), splited.end());
  return words;
}

std::vector<std::string> all_words(const char *filename) {
  auto data = read_file(filename);
  filter_chars_and_normalize(data);
  return scan(data);
}

std::vector<std::string> stop_words() {
  std::vector<std::string> words{};
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
  return stop_words;
}

// - Column reprsents the column in spreadsheet
template <typename U, typename T> class Column {
public:
  U values;
  T function;

  Column() : function(nullptr) {}

  Column(const U &columnValues, const T &columnFunction)
      : values(columnValues), function(columnFunction) {}

  void setValues(U &columnValues) { values = columnValues; }
};

int main(int argc, char **argv) {

  auto f1 = [](std::vector<std::string> allwords,
               std::vector<std::string> stopwords) -> std::vector<std::string> {
    std::vector<std::string> res = {};

    for (auto w : allwords) {
      auto is_non_stopword =
          (std::find(stopwords.begin(), stopwords.end(), w) != stopwords.end());
      if (is_non_stopword) {
        res.push_back("");
      } else {
        res.push_back(w);
      }
    }
    return res;
  };

  auto f2 =
      [](std::vector<std::string> non_stopwords) -> std::vector<std::string> {
    std::set<std::string> unique(non_stopwords.begin(), non_stopwords.end());
    std::vector<std::string> filtered(unique.begin(), unique.end());
    return filtered;
  };

  auto f3 = [](std::vector<std::string> non_stopwords,
               std::vector<std::string> unique_words) -> std::vector<int> {
    std::vector<int> counts;

    for (const auto &unique_word : unique_words) {

      int count = 0;
      for (const auto &non_stopword : non_stopwords) {
        if (non_stopword == unique_word) {
          count += 1;
        }
      }
      counts.push_back(count);
    }
    return counts;
  };

  auto f4 =
      [](std::vector<std::string> unique_words,
         std::vector<int> counts) -> std::vector<std::pair<std::string, int>> {
    std::vector<std::pair<std::string, int>> combinedData;
    for (size_t i = 0; i < unique_words.size(); i++) {
      combinedData.push_back(std::make_pair(unique_words[i], counts[i]));
    }

    std::sort(combinedData.begin(), combinedData.end(),
              [](const std::pair<std::string, int> &a,
                 const std::pair<std::string, int> &b) {
                return a.second > b.second;
              });

    return combinedData;
  };

  Column allwords = Column(all_words(argv[1]), []() {});
  Column stopwords = Column(stop_words(), []() {});
  Column non_stopwords = Column<std::vector<std::string>, decltype(f1)>({}, f1);
  Column unique_words = Column<std::vector<std::string>, decltype(f2)>({}, f2);
  Column counts = Column<std::vector<int>, decltype(f3)>({}, f3);
  Column sortedCol =
      Column<std::vector<std::pair<std::string, int>>, decltype(f4)>({}, f4);

  auto n = non_stopwords.function(allwords.values, stopwords.values);
  non_stopwords.setValues(n);

  auto u = unique_words.function(non_stopwords.values);
  unique_words.setValues(u);

  auto c = counts.function(non_stopwords.values, unique_words.values);
  counts.setValues(c);

  auto sc = sortedCol.function(unique_words.values, counts.values);
  sortedCol.setValues(sc);

  for (size_t i = 1; sortedCol.values.size(); i++) {
    auto s = sortedCol.values[i];

    if (i <= 25) {
      std::cout << s.first << " - " << s.second << std::endl;
    } else {
      break;
    }
  }
}