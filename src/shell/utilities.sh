#!/usr/bin/env bash

###############################################################################
# Author: M. Oranje
# Licence: MIT
###############################################################################

function args() {
  if test -s /dev/stdin
  then
    echo "$(</dev/stdin)"
  else
    echo "$1"
  fi
}

function json_create () {
  string="$1"
  # Regex that matches the last item and the closing bracket of the root object
  regex="({\".+)(}$)"
  if [[ $string =~ $regex ]]
  then
    echo "${BASH_REMATCH[1]}, \"$2\": \"$3\"${BASH_REMATCH[2]}"
  else
    echo "{\"$2\": \"$3\"}"
  fi
}

function json_find () {
  string="$1"
  regex="\"$2\": *\"*([^\",]*)\"*"
  if [[ $string =~ $regex ]]
  then
    echo "${BASH_REMATCH[1]}"
  else
    echo "FALSE"
  fi
}

function json_update () {
  string="$1"
  regex="(.+)\"$2\": *\"*[^\",]*\"*(,?.+)"
  if [[ $string =~ $regex ]]
  then
    echo "${BASH_REMATCH[1]}\"$2\": \"$3\"${BASH_REMATCH[2]}"
  else
    echo "Error: Key ($2) not present in JSON, use create() to add new keys"
  fi
}

function strip_string() {
  string="$2"
  regex="(^.*)$1(.*$)"
  if [[ $string =~ $regex ]]
  then
    echo "${BASH_REMATCH[1]}${BASH_REMATCH[2]}"
  else
    echo "$string"
  fi
}

function splice_string() {
  string="$2"
  regex="$1"
  if [[ $string =~ $regex ]]
  then
    echo "${BASH_REMATCH[1]}"
  else
    echo ""
  fi
}

split_string() {
  delimiter="$1"
  index="$2"
  string="$3"

  IFS="$delimiter" read -r -a item <<< "$string"

  # The pipe to xargs is meant to remove trailing and leading whitespace
  echo -e "${item[$index]}" | xargs
}

strip_all() {
  # Skip first argument
  string="$1"

  for pattern in "${@:2}"
  do
    string=$(echo "$string" | sed "s/$pattern//g")
  done

  # Remove leading, trailing and extra whitespace
  echo "$string" | tr -s " " | xargs
  # echo "$string"
}

if_set() {
  if [ -n "$1" ]
  then
    echo "$2$3"
  else
    echo "$2"
  fi
}

if_unset() {
  if [ -z "$1" ]
  then
    echo "$2"
  else
    echo "$1"
  fi
}

return_text() {
 echo -n "$1"
}

menu() {
  menu="$(cat "menu/$1.json")"
  return_text "${menu//\"autocomplete\":\"/\"autocomplete\":\"$2}"
  exit 0
}

character_trigger() {
  query="$1"
  match="$2"
  menu_name="$3"

  if [[ $query =~ $match ]]
  then
    menu "$menu_name" "$query"
  fi
}