#!/bin/bash
#
# This script produces a dynamic welcome message
# it should look like
#   Welcome to planet hostname, title name!

# Task 1: Use the variable $USER instead of the myname variable to get your name
# Task 2: Dynamically generate the value for your hostname variable using the hostname command - e.g. $(hostname)
# Task 3: Add the time and day of the week to the welcome message using the format shown below
#   Use a format like this:
#   It is weekday at HH:MM AM.
# Task 4: Set the title using the day of the week
#   e.g. On Monday it might be Optimist, Tuesday might be Realist, Wednesday might be Pessimist, etc.
#   You will need multiple tests to set a title
#   Invent your own titles, do not use the ones from this example

###############
# Variables   #
###############
myname=$USER
hostname=$(hostname)
today=$(date +%A)
time=$(date +"%I:%M %p")

test $today == "MONDAY" && title=red
test $today == "TUESDAY" && title=green
test $today == "WEDNESDAY" && title=blue
test $today == "THURSDAY" && title=yellow
test $today == "FRIDAY" && title=violet
test $today == "SATURDAY" && title=maganta
test $today == "SUNDAY" && title=orange

###############
# Main        #
###############

output="It is $today at $time.\
  Welcome to planet $hostname, \"$title $myname!\""
cowsay "$output"
