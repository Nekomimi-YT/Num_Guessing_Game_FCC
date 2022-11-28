#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#User is prompted to enter username
echo "Enter your username:"
read USERNAME

# Check database for username
USERNAME_CHECK=$($PSQL "SELECT username FROM game_info WHERE username= '$USERNAME'")
# If no username, add username to the database
if [[ -z $USERNAME_CHECK ]]
  then
    ADD_USERNAME=$($PSQL "INSERT INTO game_info(username) VALUES('$USERNAME')")
    # Format $USERNAME to remove spaces
    USERNAME=$(echo $USERNAME | sed -E 's/^ *| *$//')
    # Greet new user 
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    # Else query GAMES_PLAYED and BEST GAME
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM game_info WHERE username='$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM game_info WHERE username='$USERNAME'")
    # Format the variables to remove spaces
    USERNAME=$(echo $USERNAME_CHECK | sed -E 's/^ *| *$//')
    GAMES_PLAYED=$(echo $GAMES_PLAYED | sed -E 's/^ *| *$//')
    BEST_GAME=$(echo $BEST_GAME | sed -E 's/^ *| *$//')
    # greet user with current game status data
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#GAMEPLAY
# Assign a random number between 1-1000 to RANDOM_NUMBER
RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 )) 
# Prompt the user for a guess
echo $RANDOM_NUMBER
echo "Guess the secret number between 1 and 1000:"
read GUESS

declare -i COUNTER=0
while [[ ! $GUESS == $RANDOM_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
    # Add the guess to a guessing count
    COUNTER=$(($COUNTER+1)) 
    # Response and wait for next GUESS
    echo "That is not an integer, guess again:"
    read GUESS
  elif (( $GUESS > $RANDOM_NUMBER ))
    then
    # Add the guess to a guessing count
    COUNTER=$(($COUNTER+1)) 
    # Response and wait for next GUESS
    echo "It's lower than that, guess again:"
    read GUESS
  elif (( $GUESS < $RANDOM_NUMBER ))
    then
    # Add the guess to a guessing count
    COUNTER=$(($COUNTER+1)) 
    # Response and wait for next GUESS
    echo "It's higher than that, guess again:"
    read GUESS
  fi
done

# Add correct guess to the guessing count
COUNTER=$(($COUNTER+1))
# Format game variables for final output 
NUMBER_OF_GUESSES=$(echo $COUNTER | sed -E 's/^ *| *$//')
SECRET_NUMBER=$(echo $RANDOM_NUMBER | sed -E 's/^ *| *$//')
# Output same stats
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

# Input any new values into the game_info database
GAMES_PLAYED_CHECK=$($PSQL "SELECT games_played FROM game_info WHERE username='$USERNAME'")
if [[ -z $GAMES_PLAYED_CHECK ]]
  then
  #insert into DB 1 for games_played
  GAMES_PLAYED_RESULT=$($PSQL "UPDATE game_info SET games_played=1 WHERE username='$USERNAME'")
  #insert into $COUNTER for best_game
  BEST_GAME_RESULT=$($PSQL "UPDATE game_info SET best_game=$COUNTER WHERE username='$USERNAME'")
else
  # add games_played + 1
  UPDATE_GAMES_PLAYED=$(($GAMES_PLAYED_CHECK+1))
  GAMES_PLAYED_RESULT=$($PSQL "UPDATE game_info SET games_played=$UPDATE_GAMES_PLAYED WHERE username='$USERNAME'")
  # compare counter to DB best game and replace if less
  if (( $COUNTER < $BEST_GAME ))
    then
    UPDATE_BEST_GAME=$($PSQL "UPDATE game_info SET best_game=$COUNTER WHERE username='$USERNAME'") 
  fi
fi
