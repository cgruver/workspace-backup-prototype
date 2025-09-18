#!/usr/bin/env bash

set -x

set -e

current_time=$(date +%s)
for namespace in $(oc get namespaces -l app.kubernetes.io/component=workspaces-namespace  -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' )
do
  for workspace in $(oc get devworkspaces -n ${namespace} -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
  do
    workspace_status=$(oc get devworkspace ${workspace} -n ${namespace} -o go-template='{{.status.phase}}')
    if [[ "${workspace_status}" == "Stopped" ]]
    then
      stop_time=$(date -d$(oc get devworkspace ${workspace} -n ${namespace} -o go-template='{{range .status.conditions}}{{if eq .type "Started"}}{{.lastTransitionTime}}{{end}}{{end}}') +%s)
      stop_span=$(( ${current_time} - ${stop_time} ))
      if [[ ${stop_span} -lt  ${SCAN_PERIOD} ]]
      then
        echo "Backing Up Workspace: ${workspace} in ${namespace}"
        workspace_pvc="storage-$(oc get devworkspace ${workspace} -n ${namespace} -o go-template='{{.status.devworkspaceId}}')"  
        oc process workspace-backup -p DEVWORKSPACE_NAME=${workspace} -p DEVWORKSPACE_NAMESPACE=${namespace} -p DEVWORKSPACE_PVC=${workspace_pvc} -p DEVWORKSPACE_BACKUP_REGISTRY=${DEVWORKSPACE_BACKUP_REGISTRY} | oc apply -n ${namespace} -f -
      fi
    fi
  done
done

