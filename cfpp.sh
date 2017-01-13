#!/bin/bash -l
#
# cf curl経由で取得したjsonを整形表示する
#

export LANG=en_US.UTF-8

# 一時ファイルの書き出し場所
buffer_dir=/tmp/cfpp/`date +%s`
mkdir -p ${buffer_dir}

# cf curl経由で該当データを取得し、整形して出力する
function print_category {
  local category=${1:-"apps"}
  local page_index=0
  local next_url=/v2/${category}?inline-relations-depth=2

  # 1ページ50件の全てのページを取得する
  while [ x${next_url} != xnull ]
  do
    ((page_index++))
    local json=${buffer_dir}/${category}.${page_index}.json
    cf curl ${next_url} > ${json}
    next_url=`cat $json | jq -r '.next_url'`
  done

  jq_filter='.'
  case "${category}" in
    "apps")
      jq_filter='.resources[]| {
        "app_name": .entity.name,
        "app_guid": .metadata.guid,
        "state": .entity.state,
        "space_name": .entity.space.entity.name,
        "org_name": .entity.space.entity.organization.entity.name
      }'
      ;;
    "service_instances")
      jq_filter='.resources[]| {
        "si_name": .entity.name,
        "si_guid": .metadata.guid,
        "label": .entity.service_plan.entity.service.entity.label,
        "space_name": .entity.space.entity.name,
        "org_name": .entity.space.entity.organization.entity.name
      }'
      ;;
  esac

  cat ${buffer_dir}/${category}.*.json | jq -c "${jq_filter}"
}

function usage_exit() {
  echo "Usage: $0 [-a|-s]"
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
      print_category "apps"
      ;;
    s)
      print_category "service_instances"
      ;;
    *)
      usage_exit
      ;;
  esac
done
