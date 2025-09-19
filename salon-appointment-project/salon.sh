#!/bin/bash
echo -e "\n~~~~ Salon Appointment Scheduler ~~~~\n"
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "Welcome to Lex Luthor's Salon!\nPlease select a service:\n"
  SERVICES=$($PSQL "SELECT * FROM services;") 
  echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1) SCHEDULE_APPOINTMENT ;;
    2) SCHEDULE_APPOINTMENT ;;
    3) SCHEDULE_APPOINTMENT ;;
    4) SCHEDULE_APPOINTMENT ;;
    5) SCHEDULE_APPOINTMENT ;;
    *) MAIN_MENU "Invalid service. Please enter a valid option."
  esac
}

SCHEDULE_APPOINTMENT(){
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  echo -e "\nPlease enter your phone number: "
  read CUSTOMER_PHONE
  NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
  CUSTOMER_NAME=$(echo $NAME | sed -r 's/^ *| *$//g')
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nNo record available for that phone number. Please enter your name."
    read CUSTOMER_NAME
    INSERT_USER_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    echo -e "What time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $CUSTOMER_NAME?"
    read SERVICE_TIME
    SERVICE_AVAILABILITY=$($PSQL "SELECT appointment_id FROM appointments WHERE time = '$SERVICE_TIME';")
    if [[ -z $SERVICE_AVAILABILITY ]]
    then
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE' AND name='$CUSTOMER_NAME';")
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
      echo -e "I have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $CUSTOMER_NAME."
    else 
      echo -e "\nSorry, that time has already been scheduled. Please try again."
      SCHEDULE_APPOINTMENT 
    fi
  else
    echo -e "What time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $CUSTOMER_NAME?"
    read SERVICE_TIME
    SERVICE_AVAILABILITY=$($PSQL "SELECT appointment_id FROM appointments WHERE time = '$SERVICE_TIME';")
    if [[ -z $SERVICE_AVAILABILITY ]]
    then
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE' AND name='$CUSTOMER_NAME';")
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
      echo -e "I have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $CUSTOMER_NAME."
    else 
      echo -e "\nSorry, that time has already been scheduled. Please try again."
      SCHEDULE_APPOINTMENT 
    fi
  fi
}

MAIN_MENU