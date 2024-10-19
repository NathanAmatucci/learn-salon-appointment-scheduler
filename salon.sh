#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Welcome to my salon"
  echo "Select a service:"
  echo "1) Cut"
  echo "2) Wash"
  echo "3) Style" 

  # Prompt the user to select a service
  echo -e "\nPlease enter the service number you'd like:"
  read SERVICE_ID_SELECTED

  # Check if the service exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  
  if [[ -z $SERVICE_NAME ]]
  then
    # If the service does not exist, show the menu again
    MAIN_MENU "Invalid service number. Please choose a valid service number."
  else
    APPOINTMENT_MENU
  fi
}

APPOINTMENT_MENU() {

  # Prompt for phone number
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE

  # Check if the phone number exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # If customer does not exist, prompt for their name and add them to the customers table
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nIt looks like you're a new customer. Please enter your name:"
    read CUSTOMER_NAME

    # Insert the new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  # Get the customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # Prompt for appointment time
  echo -e "\nWhat time would you like your appointment?"
  read SERVICE_TIME

  # Insert the appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Confirm the appointment
  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ *//;s/ *$//') # Format service name by trimming spaces
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    echo "Sorry, there was an error scheduling your appointment."
  fi
}

MAIN_MENU
