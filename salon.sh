#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
SERVICES=$($PSQL "SELECT * FROM services")
LIST_SERVICES () {
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do 
    echo "$SERVICE_ID) $NAME"
  done
}
echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e 'Welcome to My Salon, how can I help you?\n'
LIST_SERVICES
read SERVICE_ID_SELECTED
SERVICE_CHOICE_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
# if service not found
if [[ -z $SERVICE_CHOICE_RESULT ]]
then 
  echo -e "\nI could not find that service. What would you like today?"
  LIST_SERVICES
else
  #get phone number
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  #get name and ID
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  #if not exists
  if [[ -z $CUSTOMER_ID ]]
  then 
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
    read SERVICE_TIME
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
fi