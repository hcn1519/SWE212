import sys, string
import numpy as np

characters = np.array([' ']+list(open(sys.argv[1]).read())+[' '])

# Normalize
characters[~np.char.isalpha(characters)] = ' '
characters = np.char.upper(characters)

# Apply Leet code
translation_mapping = str.maketrans('ABCDEFGHIJKLMNOPQRSTUVWXYZ', '∆8<D£ƒ[#1√K|мИ0р9®57UVW%¥5')
characters = np.char.translate(characters, translation_mapping)

### Split the words by finding the indices of spaces
sp = np.where(characters == ' ')
sp2 = np.repeat(sp, 2)

w_ranges = np.reshape(sp2[1:-1], (-1, 2))
w_ranges = w_ranges[np.where(w_ranges[:, 1] - w_ranges[:, 0] > 2)]
w_ranges2 = np.repeat(w_ranges, 2, axis=0)
gram2 = np.reshape(w_ranges2[1:-1], ((len(w_ranges2) - 2) // 2, 2, 2))

# str_ranges: [[1, 9],[10, 24]]
def merge_str(str_ranges):  
  lhs = str_ranges[0] # [1, 9]
  rhs = str_ranges[1] # [10, 24]

  l = ''.join(characters[lhs[0]:lhs[1]]).strip()
  r = ''.join(characters[rhs[0]:rhs[1]]).strip()

  return l + " " + r
  
words = list(map(merge_str, gram2))

### Finally, count the word occurrences
uniq, counts = np.unique(words, axis=0, return_counts=True)
wf_sorted = sorted(zip(uniq, counts), key=lambda t: t[1], reverse=True)

for w, c in wf_sorted[:5]:
    print(w, '-', c)
