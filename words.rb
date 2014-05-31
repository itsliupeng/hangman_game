
## This is the words list database
WORD_FILE = "./words1"

## find all words that have some length
def words_of_length(len)
  word_array = []

  File.open(WORD_FILE) do |f|
    while line = f.gets
      word = line.strip
      if word.length == len
        word_array << word
      end
    end
  end
  word_array
end


## the argument nodeep is to prevent infinite recursive
def freq_of_pat(words, black_list, pat, nodeep=false)
  word_array = []
  ## document frequencies of letters
  freq_hash = Hash.new(0)
  ## use word_hash to tell me how many letters left a word need to guess out
  word_hash = Hash.new(0)

  list = ""
  black_list.each do |c|
    list += c
  end

  if list == ""
    list_regex = '(\w)'
  else
    list_regex = "([^#{list}])"
  end

  regex = %r{#{pat.gsub('*', list_regex)}}

  puts regex.to_s if DEBUG

  words.each do |word|
    if m = word.match(regex)
      word_array << word

      c_set = m[1, m.length-1].uniq
      word_hash[word] = c_set.length

      c_set.each do |c|
        freq_hash[c] += 1
      end

    end

  end

  freq_hash =  (freq_hash.sort_by {|k, v| v}).reverse.to_h
  word_hash = (word_hash.sort_by {|k, v| v}).to_h

  g = freq_hash.keys[0]

  # varient small, freq_hash large,  guess_count less, 10%
  if nodeep == false && word_hash.length > 0


    l = freq_hash.keys[-1]

    if freq_hash[g] == freq_hash[l] 
     if  100 - 10 * black_list.length - 1 * freq_hash.length < 0
      g = "GIVEUP1"
     else
       key = rand(freq_hash.length)
       g = freq_hash.keys[key]
     end
    end

    # test if have enough times to guess the word

    if word_hash.values[0] + black_list.length == 10
      words_temp = []
      word_hash.keys.each do |k|
        if word_hash[k] == word_hash.values[0]
          words_temp << k
        end
      end
      ## use nodeep=true to prevent infinite recursive
      g = freq_of_pat(words_temp, black_list, pat, nodeep=true)[0]

    end

    if word_hash.values[0] + black_list.length > 10
      g = "GIVEUP2"
    end
  end

  puts freq_hash.to_s if DEBUG
  puts word_hash.to_a[0].to_s if DEBUG
  puts "words count: #{word_array.length}" if DEBUG

  [g, word_array]
end

