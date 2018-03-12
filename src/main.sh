#!/bin/sh

###################################
# INPUT
#
# echo $STEP_AWS_PROFILE
# echo $STEP_AWS_ACCESS_KEY_ID
# echo $STEP_AWS_SECRET_ACCESS_KEY
# echo $STEP_AWS_DEFAULT_REGION
# 
# echo $STEP_SCHEDULE_RULE_NAME
# echo $STEP_SCHEDULE_EXPRESSION
# echo $STEP_SCHEDULE_STATE
# echo $STEP_SCHEDULE_DESCRIPTION
# 
# echo $STEP_CLUSTER
# echo $STEP_TASK_COUNT
# echo $STEP_TASK_DEFINITION
# echo $STEP_TARGET_ID

STEP_AWS_PROFILE=wercker-step-aws-ecs

aws configure set aws_access_key_id ${STEP_AWS_ACCESS_KEY_ID} --profile ${STEP_AWS_PROFILE}
aws configure set aws_secret_access_key ${STEP_AWS_SECRET_ACCESS_KEY} --profile ${STEP_AWS_PROFILE}
if [ -n "${STEP_AWS_DEFAULT_REGION}" ]; then
  aws configure set region ${STEP_AWS_DEFAULT_REGION} --profile ${STEP_AWS_PROFILE}
fi

warn "Collection Input Data for Target template"
TASK_DEFINITION_ARN=$(aws ecs describe-task-definition --profile ${STEP_AWS_PROFILE} --task-definition ${STEP_TASK_DEFINITION} --query taskDefinition.taskDefinitionArn --output text)
_AWS_ACCOUNT=$(aws sts get-caller-identity --profile ${STEP_AWS_PROFILE} --output text --query 'Account')
ROLE_ARN=arn:aws:iam::${_AWS_ACCOUNT}:role/ecsEventsRole
CLUSTER_ARN=$(aws ecs describe-clusters --profile ${STEP_AWS_PROFILE} --clusters ${STEP_CLUSTER} --query clusters[0].clusterArn --output text)

#########
#
# FROM https://github.com/wercker/step-bash-template
#
#
TARGET_FILE=$(dirname $STEP_TARGET_TEMPLATE)/ecs_task_target.json

warn "Templating $STEP_TARGET_TEMPLATE -> $TARGET_FILE"

if [ -e /dev/urandom ]; then
    RANDO=$(LANG=C tr -cd 0-9 </dev/urandom | head -c 12)
else
    RANDO=2344263247
fi

source "$STEP_DIR/src/template.sh" "$STEP_TARGET_TEMPLATE" > "$TARGET_FILE" 2>$RANDO

if [ ! -z "$STEP_BASH_TEMPLATE_ERROR_ON_EMPTY" ]; then
  if [ -s $RANDO ]; then
    cat $RANDO
    rm -f $RANDO
    exit 1
  fi
fi
rm -f $RANDO

cat $TARGET_FILE

warn "Put rule : $STEP_SCHEDULE_RULE_NAME"
aws events put-rule \
    --profile ${STEP_AWS_PROFILE} \
    --name ${STEP_SCHEDULE_RULE_NAME} \
    --schedule-expression "${STEP_SCHEDULE_EXPRESSION}" \
    --state ${STEP_SCHEDULE_STATE} \
    --description  "${STEP_SCHEDULE_DESCRIPTION}"

warn "Put Target: $TARGET_FILE"
aws events put-targets \
    --profile ${STEP_AWS_PROFILE} \
    --cli-input-json file://$TARGET_FILE



