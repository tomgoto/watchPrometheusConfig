# watchPrometheusConfig サービス

S3バケットに保存されたPrometheus設定ファイルのパーツを定期的に確認し、変更を見つけた場合はPrometheus設定ファイルを更新します。



## 配置

- /opt/watchPrometheus/merge_prometheusConfigs.sh
- /etc/default/watchPrometheusConfig
- /etc/systemd/system/watchPrometheusConfig.service
- /opt/watchPrometheus/watchPrometheusConfig.sh

## How to install 
```shell
bash install.sh
```

## サンプル
S3バケットに、`configSample`内のファイルをコピーしておくと、自動的にprometheusに更新します
