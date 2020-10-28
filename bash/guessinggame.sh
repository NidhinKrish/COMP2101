#!/bin/bash -x
#
# This script implements a guessing game
# it will pick a secret number from 1 to 10
# it will then repeatedly ask the user to guess the number
#    until the user gets it right

# Give the user instructions for the game
cat <<EOF
Let's play a game.
I will pick a secret number from 1 to 10 and you have to guess it.
If you get it right, you get a virtual prize.
Here we go!
EOF

# Pick the secret number and save it
secretnumber=$(($RANDOM % 10 +1)) # save our secret number to compare later
echo "$secretnumber"
# This loop repeatedly asks the user to guess and tells them if they got the right answer
# TASK 1: Test the user input to make sure it is not blank
# TASK 2: Test the user input to make sure it is a number from 1 to 10 inclusive
# TASK 3: Tell the user if their guess is too low, or too high after each incorrect guess

read -p "Enter a number from 1 to 10: " userguess # ask for a guess
if [ "$userguess" =  "$secretnumber" ]; then
  echo "You got it! Have a milkdud"
fi
while [[ -z $userguess ]]; do #task1
  echo " There is no value entered"
  read -p "Please enter a number from 1 to 10: " userguess
  if [ "$userguess" =  "$secretnumber" ]; then
    echo "You got it! Have a milkdud"
  fi
done
while [ $userguess != $secretnumber ]; do # ask repeatedly until they get it right
  if [[ $userguess -gt $secretnumber ]]; then
    echo "The guessed number is too high"
    break
  else
    echo "The guessed number is too low"
    break
  fi
echo "You got it! Have a milkdud."
done
exit
