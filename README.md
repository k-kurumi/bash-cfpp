# bash-cfpp

権限を有するスペースからアプリ情報などをまとめて取得して表示する(json)

### usage

```
### require: cf(loggedin) and jq command

## swho help
$ bash cfpp.sh

## show apps
$ bash cfpp.sh -a

## show service instances
$ bash cfpp.sh -s

## show spaces
$ bash cfpp.sh -sp
```

### todo

- [x] apps
- [x] service instances
- [x] spaces
- [ ] user provided service instances
