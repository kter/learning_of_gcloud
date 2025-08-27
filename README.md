# 推奨ファイルレイアウト

## トップレベル

* stage ... ステージング用
* prod ... 本番用
* mgmt ... DevOpsツール用（踏み台サーバー、CIサーバなど）
* global ... 全環境を跨いで使用するリソースを入れる環境（S3, IAMなど）

## セカンドレベル

* vpc ... ネットワークトポロジ
* services ... アプリケーションやマイクロサービス
* data-storage ... MySQLやRedisなどのデータストア

## フォースレベル

* 各コンポーネントの名前 (mysql, webなど)

## ファイルレベル

* variables.tf ... 入力変数
* outputs.tf ... 出力変数
* main.tf ... リソースとデータソース (大きくなってきたらmain-xxx.tfと分けると良い)
