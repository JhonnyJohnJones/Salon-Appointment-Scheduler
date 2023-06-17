#!/bin/bash

PSQL="psql --tuples-only --username=freecodecamp --dbname=salon -c"


MAIN_MENU () {
  echo $1
  echo -e "\n- Serviços -\n"
  echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")" | while IFS=" |" read SERVICE_ID SERVICE_NAME
  do
    if [[ $SERVICE_ID =~ ^[0-9]+$ ]]
    then
      echo "$SERVICE_ID) $SERVICE_NAME"
    fi
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "COLOQUE o NÚMERO do SERVIÇO"
  else
    SERVICE_NAME=($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
    if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU "ID do SERVIÇO não encontrado"
    else
      APPOINT_MENU "$SERVICE_ID_SELECTED"
    fi
  fi
}

APPOINT_MENU () {
  SERVICE_ID_SELECTED=$1
  echo "Coloque seu número de telefone:"
  read CUSTOMER_PHONE
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_NAME ]]
  then
    echo "Seu telefone não está registrado no nosso sistema. Coloque seu nome:"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
    if [[ $INSERT_CUSTOMER_RESULT = "INSERT 0 1" ]]
    then
      echo "Usuário adicionado com sucesso"
    else
      echo "Usuário não pode ser adicionado devido a um erro inesperado"
    fi
  fi
  echo "Coloque o horário desejado:"
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
  if [[ $INSERT_APPOINTMENT_RESULT = "INSERT 0 1" ]]
  then
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU