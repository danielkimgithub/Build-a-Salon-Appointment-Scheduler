#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

#header
echo -e "\n~~~~~ Kim's Salon Scheduler ~~~~~\n"

#greeting
echo -e "\nWelcome to Kim's Salon, how can I help you?"
# obtain service requested
echo -e "\nPlease select desired service:"

# create function that will loop steps necessary to schedule appointment and update db
MAIN_MENU(){

  # error message if no argument input
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # get services available from db
  SERVICES_AVAILABLE=$($PSQL "select service_id, name from services order by service_id;")
  # output services available
  echo "$SERVICES_AVAILABLE" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "\n$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  # return to menu if service selected is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "Please selected number associated with the listed services."
  else
    # query name of service selected
    SERVICE_NAME_SELECTED=$($PSQL "select name from services where service_id = $SERVICE_ID_SELECTED;")
    if [[ -z $SERVICE_NAME_SELECTED ]]
    then
      MAIN_MENU "I'm sorry we don't offer that service yet. Please select from listed service."
    else
      echo -e "\nYou have requested a$SERVICE_NAME_SELECTED."

      echo -e "\nPlease provide your phone number to schedule an appointment." 
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "select name from customers where phone = '$CUSTOMER_PHONE';")

      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nWe could not find your name in the database. Please provide your first and last name:"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_NAME=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
        echo -e "\nThank you. Your information has been added to our database."
      fi

      echo -e "\nPlease provide a time for your$SERVICE_NAME_SELECTED service, $CUSTOMER_NAME."
      read SERVICE_TIME

      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE';")

      APPOINTMENT_INSERTED=$($PSQL "insert into appointments(time, customer_id, service_id) values('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED);")
      echo -e "\nI have put you down for a$SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
      echo -e "\nThank you for using our virtual appointment scheduler. Hope to see you soon!"

    fi
  fi

}

MAIN_MENU