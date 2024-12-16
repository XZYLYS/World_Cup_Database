#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Clear the tables 
echo $($PSQL "TRUNCATE teams,games")
cat games.csv | while IFS="," read YEAR ROUND WN ON WG OG
do
  # initial check for row heads
  if [[ $YEAR != "year" ]]
  then
    # ```````````````````````` POPULATING TEAMS TABLE ````````````````````````
    #populate teams using winning team
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WN'")
    if [[ -z $WINNER_ID ]]
    then
      # inserts winning team to the teams table
      WINNER_INSERT=$($PSQL "INSERT INTO teams(name) VALUES('$WN')")
      if [[ $WINNER_INSERT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WN using winner
      fi
      # fetched the team id of the winning team
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WN'")
    fi
    #populate teams using opponent teams
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$ON'")
    if [[ -z $OPPONENT_ID ]]
    then
      # inserts opponents team to the teams table
      OPPONENT_INSERT=$($PSQL "INSERT INTO teams(name) VALUES('$ON')")
      if [[ $OPPONENT_INSERT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $ON using opponent
      fi
      # fetched the team id of the opponent
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$ON'")
    fi
    # ```````````````````````````````````````````````````````````````````````` 
    # ```````````````````````` POPULATING GAMES TABLE ````````````````````````
    GAME_INSERT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES($YEAR,'$ROUND',$WINNER_ID,$OPPONENT_ID,$WG,$OG)")
      if [[ $OPPONENT_INSERT == "INSERT 0 1" ]]
      GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year=$YEAR AND round='$ROUND' AND winner_id=$WINNER_ID AND opponent_id=$OPPONENT_ID")
      then
        echo Inserted into games $GAME_ID
      fi
  fi
done