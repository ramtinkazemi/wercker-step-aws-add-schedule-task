#!/bin/bash
set +e
set -o noglob

#
# Headers and Logging
#

error() { printf "✖ %s\n" "$@"
}
warn() { printf "➜ %s\n" "$@"
}

type_exists() {
  if [ $(type -P $1) ]; then
    return 0
  fi
  return 1
}

STEP_PREFIX="WERCKER_AWS_ECS_SCHEDULED_TASK"
step_var() {
  echo $(tmp=${STEP_PREFIX}_$1 && echo ${!tmp}) 
}


# Check python is installed
if ! type_exists 'python3'; then
  error "Please install python 3.x"
  exit 1
fi

# Check pip is installed
if ! type_exists 'pip'; then
  error "Please install pip"
  exit 1
fi

# Check env file
# https://github.com/builtinnya/dotenv-shell-loader
# source $WERCKER_STEP_ROOT/src/dotenv-shell-loader.sh
# dotenv

# Check variables
if [ -z "$(step_var 'KEY')" ]; then
  error "Please set the 'key' variable"
  exit 1
fi

if [ -z "$(step_var 'SECRET')" ]; then
  error "Please set the 'secret' variable"
  exit 1
fi

if [ -z "$(step_var 'REGION')" ]; then
  error "Please set the 'region' variable"
  exit 1
fi

if [ -z "$(step_var 'SCHEDULE_RULE_NAME')" ]; then
  error "Please set the 'schedule-rule-name' variable"
  exit 1
fi

if [ -z "$(step_var 'SCHEDULE_EXPRESSION')" ]; then
  error "Please set the 'schedule-expression' variable"
  exit 1
fi

if [ -z "$(step_var 'SCHEDULE_STATE')" ]; then
  error "Please set the 'schedule-state' variable"
  exit 1
fi

if [ -z "$(step_var 'CLUSTER_NAME')" ]; then
  error "Please set the 'cluster-name' variable"
  exit 1
fi

if [ -z "$(step_var 'TASK_DEFINITION_NAME')" ]; then
  error "Please set the 'task-definition-name' variable"
  exit 1
fi

if [ -z "$(step_var 'TARGET_TEMPLATE')" ]; then
  error "Please set the 'target-template' variable"  
fi

# INPUT Variables for main.sh

#FOR AWS CONFIGURE
STEP_AWS_ACCESS_KEY_ID=$(step_var 'KEY')
STEP_AWS_SECRET_ACCESS_KEY=$(step_var 'SECRET')
STEP_AWS_DEFAULT_REGION=$(step_var 'REGION')

#FOR AWS EVENT RULE
STEP_SCHEDULE_RULE_NAME=$(step_var 'SCHEDULE_RULE_NAME')
STEP_SCHEDULE_EXPRESSION=$(step_var 'SCHEDULE_EXPRESSION')
STEP_SCHEDULE_STATE=$(step_var 'SCHEDULE_STATE')
STEP_SCHEDULE_DESCRIPTION=$(step_var 'SCHEDULE_DESCRIPTION')

#FOR AWS EVENT TARGET
STEP_CLUSTER=$(step_var 'CLUSTER_NAME')
STEP_TASK_COUNT=$(step_var 'TASK_COUNT')
STEP_TASK_DEFINITION=$(step_var 'TASK_DEFINITION_NAME')
STEP_TARGET_ID=$(step_var 'TARGET_ID')
STEP_TARGET_TEMPLATE=$(step_var 'TARGET_TEMPLATE')

STEP_DIR=$WERCKER_STEP_ROOT

source $STEP_DIR/src/main.sh




