#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games RESTART IDENTITY")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WGOALS OPGOALS
do
  if [[ $YEAR != 'year' ]]
  then
    #check for winner in team_id
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    #if not found
    if [[ -z $TEAM_ID ]]
    then
      #insert winner in teams
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      #get winner_id
      WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    else
      WIN_ID=$TEAM_ID
    fi
    #check for opponent team_id
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    #if not found
    if [[ -z $TEAM_ID ]]
    then
      #insert opponent in teams
      INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      #get opponent_id
      OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    else
      OPP_ID=$TEAM_ID
    fi
    #insert all game data into games
    GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WIN_ID, $OPP_ID, $WGOALS, $OPGOALS)")
  fi
done

