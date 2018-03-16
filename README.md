# step-aws-ecs-scheduled-task
Wercker Step to register task definition in aws ecs, the schedule task name will be "$STEP_APP_NAME-$STEP_SCHEDULE_RULE_NAME"


# Example

## target-template 
ecs_task_target.json.template
```
{
  "Rule": "${STEP_APP_NAME}-${STEP_SCHEDULE_RULE_NAME}",
  "Targets": [
    {
      "Id": "${STEP_TARGET_ID}",
      "Arn": "${CLUSTER_ARN}",
      "RoleArn": "${ROLE_ARN}",
      "EcsParameters": {
        "TaskDefinitionArn": "${TASK_DEFINITION_ARN}",
        "TaskCount": ${STEP_TASK_COUNT}
  }
  }
  ]
}

```


## wecker.yml

```
deploy:
    steps:
    - ramtinkazemi/aws-ecs-add-scheduled-task@0.0.x:
        name: sample scheduled task
        key: $STEP_AWS_ACCESS_KEY_ID
        secret: $STEP_AWS_SECRET_ACCESS_KEY
        region: $STEP_AWS_DEFAULT_REGION
        schedule-rule-name: my-schedule-rule
        schedule-expression: cron(0 20 * * ? *)
        cluster-name: my-cluster
        task-count: 1
        task-definition-name: my-task-definition
        target-id: my-target-id
        target-template: ecs_task_target.json.template

```


