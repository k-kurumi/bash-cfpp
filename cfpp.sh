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
  local next_url=/v2/apps?inline-relations-depth=2

  # 全ての情報を取得する
  while [ x${next_url} != xnull ]
  do
    ((page_index++))
    local json=${buffer_dir}/apps.${page_index}.json
    cf curl ${next_url} > ${json}
    next_url=`cat $json | jq -r '.next_url'`
  done

  # 表示
  cat ${buffer_dir}/apps.*.json | jq -c '.resources[]| {
                                                        "app_name": .entity.name,
                                                        "app_guid": .metadata.guid,
                                                        "state": .entity.state,
                                                        "space_name": .entity.space.entity.name,
                                                        "org_name": .entity.space.entity.organization.entity.name
                                                      }'
}

function show_services() {
  local page_index=0
  local next_url=/v2/service_instances?inline-relations-depth=2

  # 全ての情報を取得する
  while [ x${next_url} != xnull ]
  do
    ((page_index++))
    local json=${buffer_dir}/service_instances.${page_index}.json
    cf curl ${next_url} > ${json}
    next_url=`cat $json | jq -r '.next_url'`
  done

  # 表示
  cat ${buffer_dir}/service_instances.*.json | jq -c '.resources[]| {
                                                                      "si_name": .entity.name,
                                                                      "si_guid": .metadata.guid,
                                                                      "space_name": .entity.space.entity.name,
                                                                      "org_name": .entity.space.entity.organization.entity.name
                                                                    }'
}


function usage_exit() {
  echo "Usage: $0 [-a|-s|-r]"
  exit 1
}

##########

if [ $# -eq 0 ]; then
  # 引数なしはusageを書き出して終了
  usage_exit
fi

# コマンドライン引数の処理
while getopts asr:h opt
do
  case ${opt} in
    a)
      show_apps
      ;;
    r)
      show_routes # FIXME 作る
      ;;
    s)
      show_services
      ;;
    *)
      usage_exit
      ;;
  esac
done
