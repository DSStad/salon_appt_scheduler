#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n ~~~ D's Salon ~~~\n"

SERVICE_MENU() {
  # get services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  echo -e "\nWeclome to D's Salon. These are the services we offer:"
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  # which service is selected
  echo -e "\nWhat can we do for you?"
  read SERVICE_ID_SELECTED

  # get service name
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # if not a service selected
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_MENU "Please pick a valid service."
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    # get customer name
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    
    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # if customer not found
    if [[ -z $CUSTOMER_NAME ]]
    then
      # GET CUSTOMERS NAME
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME
      # INSERT NEW CUSTOMER
      INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

      # get new customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      # GET SERVICE TIME FOR NEW CUSTOMER
      echo -e "\nWhat time would you like to schedule your service?"
      read SERVICE_TIME

      # INSERT INTO APPTS
      INSERT_NEW_CUSTOMER_APPT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."

    else
      # GET SERVICE TIME FOR RETURN CUSTOMER
      echo -e "\nWhat time would you like to schedule your service?"
      read SERVICE_TIME

      INSERT_APPT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."

    fi
  fi
}

SERVICE_MENU