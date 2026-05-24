# **Commits as pixels**

~Following that one social media post about a recruiter hiring someone sollely based on their Github activity... and coders reacting by saying they would implement a crontab to daily commit to GitHub
I have a blank activity page because most of my work on github is under my work account (my employer ask specifically for our team to get a specific Github work account)
That blank activity page gave me an idea : the activity table is showing one square per day, seven days per collumn and 52 weeks a year... and closely resembling a 7X52 led matrix. So why not use it to display a message?

## Project Rules

First we need some ROE to set the stage. Here are the rules I tried to follow :

## Readability
Readability counts ... but also speed. The git hub profile contibutions matrix is a 7days X 52 weeks so for every vertical line we would need a full week of daily commits and a simple "Hello world" would take 55 weeks to be printed.  

With only 7 pixels days a week, a 3x4 easily readable font would need 5 weeks per sign. If we go instead for a 3x3 font, then we can stack two lines of text separated by an empty line... no commits on Thursdays! 
So we will work with a 3x3 pixels font on two lines (still requires 20 **weeks** for a 5 letter word) There is a good font example here https://www.dafont.com/3x3-font-for-nerds.charmap Letters are readable but numbers are barely (an '8' in 3x3 pixels does not look like anything :( ). So we will stick to short text only messages, no numbers. 

## Language
Let's use bash

Because : why not? I don't play much with strings in bash, I will also use tables... that's a good workout!

## Mantra
Let's keep it simple
Let's go full K.I.S.S. on that one : we only need the present README and a parametrized bash script

Speaking of simple, a crontab on a remote server runs once a day to trigger the commits is simple enough. The not so simple part will be that the script will need to determine by itself if a commit is needed to display a pixel or not. 

Let's not mess this up
~it is out there for anyone to see :)

## Breakdown 
1. script is launched by crontab once a day from a remote machine
2. script reads README for input text
3. script commits to github
4. ???
5. profit

## Challenges:
~The space is limited in height and width comes with a time downsize. 
Readability of 3x3 font
Write on 2 lines means scope each word, determine it's size, 
Script has to self determine if it is a commit day or not each day depending on if a pixel is needed or not. This is the real challenge as we need to go from text to pixels to commits
eg one letter like H has to be split between 4 weeks (3 columns of pixel, one of space) then we need to programmaticaly determine 

### Coding rules:
Stick to 3x3 pixels font
One letter spans on 4 weeks (One 3 pixels letter and one blank pixel for spacing)
First word is written on first line. Second word igoes to second line. 
n case of odd word in a phrase, it creates and odd line, when if only even words in phrase, the line keeps even. 
If one word is bigger than the other, then we add spaces to the shorter one so two words forms a column (readability focus)
If we need to use brighter pixel (readbility) which means that we need multiple commits. This will help readability as other projects hosted in the same repo and commiting changes to these would add unwated pixels to the display

## Breakdown
Week of the year (WOY) is determined using `date +%-V`
Day of wee (DOW) is determined using `date +%u`
```WOY=	$(date +%-V)
DOW=$(date +%u)
```


Letters of each words are entered in table word1 and word2
Max lengh of word[*] determines the number of weeks needed (+1 to add a space and start again)

## Font
3x3 font by
https://www.dafont.com/3x3-font-for-nerds.charmap


## Future
Maybe one day I'll play with the green gradiants based on number of commits per day GH offers

## Note for the world
I know other commits on my other works will inevitably create noise. Thatsaid I have another github account for my work, and a little entropy is never too much :D

# Below we set the message that will be printed
message="Hello World"

# To reset the timelime
``` sed -i '/^start_date=/d' README.md
git commit -am "reset timeline"```

start_date="2026-05-24"
