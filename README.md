This is a hangman game client written in ruby

## instructions
[https://github.com/joycehan/strikingly-interview-test-instructions](https://github.com/joycehan/strikingly-interview-test-instructions)

## Requirements
- Ruby 2.1
- rest_client

## How to run it

- in irb/pry, just require './hangman.rb'
- if you want to submit your answer, type submit_test_results

## program result
- all guessed words are stored in array WORDS, "#" means this word is not in my words_dict, the prefix "&" means that cann't guess it out by 10 times

## Algorithms
1. use regular expression to get matched words, caculute the frequency of each letter, and choose the letter with highest value, then loop as this to the end

2. 对于备选字母频率都一样的话，随机选1个。统计发现计分规则是 20 * numberOfCorrectWords - numberOfWrongGuesses， 猜对1个单词跟猜错字母20次是
零博弈的。我比较保守（因为总共只猜80次），设为在前10个以内备选字母频率一样的话，随机猜1个

3. 对于减少猜错次数的做法： 
    - 如果发现备选单词组中猜对一个单词所需的最少次数大于剩余的可猜次数时， 直接放弃本轮，开始下一轮
    - 如果相等， 选取所需字母数最少的所有单词组成单词组，再到步骤1
    
## 问题
- 我的 words_dict 主要采用linux下/usr/share/dict/american-english, 外加网络上下载的350,000个单词中的长度大于8的部分，因为我发现长度小的单词数据库大了后，反而难猜。我想如果测试时已知server端的words_dict，结果会好一点。还有有些单词不在我的words_dict
- server端的post action 非幂等， 我的client端retry request 直接 nextWord/nextGuess， 导致有些轮直接跳过，所以我的结果实际猜词数小于80， 视retry次数而定
- server端返回的numberOfGuessAllowedForThisWord不正确，尤其在网络差时，所以我在cilent端自己设定每个单词最多只做10次猜测

{"message"=>
  "Thank You! Please paste this JSON and send to joyce[at]strikingly.com",
 "userId"=>"dp90219@gmail.com",
 "secret"=>"6BPIJR6AUES9VN295RTOITIZREO8NC",
 "status"=>200,
 "data"=>
  {"userId"=>"dp90219@gmail.com",
   "secret"=>"6BPIJR6AUES9VN295RTOITIZREO8NC",
   "numberOfWordsTried"=>80,
   "numberOfCorrectWords"=>57,
   "numberOfWrongGuesses"=>189,
   "totalScore"=>951,
   "dateTime"=>"Fri May 30 2014 14:52:43 GMT+0000 (UTC)"}}
由于网络retry， 实际猜了74个单词

 
