#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt for username
echo "Enter your username:"
read USERNAME

# Check if the user exists
USERNAME_AVAIL=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM users INNER JOIN games USING (user_id) WHERE username='$USERNAME'")
BEST_GAME=$($PSQL "SELECT MIN(number_guesses) FROM users INNER JOIN games USING(user_id) WHERE username='$USERNAME'")

# If username is not available, insert new user
if [[ -z $USERNAME_AVAIL ]]; then
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate a random number and initialize guess counter
RANDOM_NUM=$((1 + RANDOM % 1000))
GUESS=1
echo "Guess the secret number between 1 and 1000:"

# Loop for guessing game
while read NUM; do
  if ! [[ $NUM =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  else
    if [[ $NUM -eq $RANDOM_NUM ]]; then
      break
    elif [[ $NUM -gt $RANDOM_NUM ]]; then
      echo -n "It's lower than that, guess again: "
    else
      echo -n "It's higher than that, guess again: "
    fi
    GUESS=$((GUESS + 1))
  fi
done

# Display results
echo "You guessed it in $GUESS tries. The secret number was $RANDOM_NUM. Nice job!"

# Insert game results
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
INSERT_GAME=$($PSQL "INSERT INTO games(number_guesses, user_id) VALUES($GUESS, $USER_ID)")