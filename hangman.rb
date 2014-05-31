require 'rest_client'
require 'json'
require './words.rb'

## verbose of print
V = false
DEBUG = false

USER_ID = "dp90219@gmail.com"
URL = "http://strikingly-interview-test.herokuapp.com/guess/process"
SITE = RestClient::Resource.new(URL, timeout: 10, open_timeout: 10)
WORDS = []


def get_response(action, secret=nil, guess=nil)
  retries = 0
  begin
    response = JSON.parse(SITE.post action: action, userId: USER_ID, secret: secret, guess: guess, content_type: "application/json")

  rescue
    return if (retries +=1) > 5
    puts "get response timeout, retrying..."
    retry
  end
  response
end

def initiate_game
  response = get_response("initiateGame")
  [response["secret"], response["data"]["numberOfWordsToGuess"], response["data"]["numberOfGuessAllowedForEachWord"]]
end

SECRECT, NUM_WORDS, NUM_GUESSES = initiate_game()

def next_word
  get_response("nextWord", SECRECT)["word"].downcase
end

def guess_word(guess)
  guess = guess.upcase
  response = get_response("guessWord", SECRECT, guess)
  puts "word_to_guess: #{response["word"].downcase}, \
    numberOfWordsTried: #{response["data"]["numberOfWordsTried"]}, \
    numberOfGuessAllowedForThisWord: #{response["data"]["numberOfGuessAllowedForThisWord"]}"  if DEBUG
  return response

end

def get_test_results
  get_response("getTestResults", SECRECT)
end

def submit_test_results
  get_response("submitTestResults", SECRECT)
end

## guess one word is named onew round
def round
  response = nil
  black_list = []
  pat = next_word.downcase

  words_dict = words_of_length pat.length
  while true
    g, words_dict = freq_of_pat words_dict, black_list, pat
    if g == nil
      puts "Word Not KNOWN"
      WORDS << "#"
      break

    elsif g == "GIVEUP1"
      puts "GIVE UP"
      WORDS << "&1"
      break

    elsif g == "GIVEUP2"
      puts "GIVE UP"
      WORDS << "&2"
      break
    end

    black_list << g

    puts "The #{black_list.length}th guess letter is #{g.upcase}"
    puts "black_list is #{black_list.to_s}, length: #{black_list.length}"if V

    response = guess_word g
    pat = response["word"].downcase
    puts "#{pat}"

    unless pat.include? '*'
      WORDS << pat
      puts "GOT IT"
      break
    end
    ## the numberOfGuessAllowedForThisWord received from server is not correct!!
    if response["data"]["numberOfGuessAllowedForThisWord"] == 0
      WORDS << pat
      break
    end

    if black_list.length == NUM_GUESSES
      WORDS << pat
      puts "WRONG, NEXT ROUND"
      break
    end
  end

  num_of_round = response["data"]["numberOfWordsTried"]
  num_of_round
end


def start
  num_of_round = 1
  while num_of_round <= NUM_WORDS
    puts "Round #{num_of_round}:"
    num_of_round = round + 1
    puts "All you have guessed: #{WORDS.to_s}" if V
  end
  puts "guess over!!!"
  puts "#{WORDS.length} words you've guessed: #{WORDS}"

  puts get_test_results

end

## because requests often need retrying, so I ues this to count the number of word guessed actually
def word_count(words)
  num = 0
  words.each do |word|
     unless word.include?('*') || word.include?('#')
       num += 1
     end
  end
  num
end



## start to guess

start
