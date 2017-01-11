#!/bin/bash -l
#
# cf curl経由で取得したjsonを整形表示する
#

export LANG=en_US.UTF-8

# 一時ファイルの書き出し場所
buffer_dir=/tmp/cfpp/`uuidgen`
mkdir -p ${buffer_dir}

function show_apps() {
  local page_index=0
  local next_url=/v2/apps

  # 全ての情報を取得する
  while [ x${next_url} != xnull ]
  do
    ((page_index++))
    local json=${buffer_dir}/apps.${page_index}.json
    cf curl ${next_url}?inline-relations-depth=2 > ${json}
    next_url=`cat $json | jq '.next_url'`
  done

  # 表示
  cat ${buffer_dir}/apps.*.json | jq -c '.resources[]| {"app_name": .entity.name, "app_guid": .metadata.guid, "state": .entity.state, "space_name": .entity.space.entity.name, "org_name": .entity.space.entity.organization.entity.name}'
}

show_apps
