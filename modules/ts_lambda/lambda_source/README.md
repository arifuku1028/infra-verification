# ts_lambda module

TypeScript で Lambda 関数を開発してデプロイするためのモジュール

## Lambda 開発用ディレクトリ（サンプル）

### ディレクトリ構成

```text
lambda_source/
└── example/ （適宜リネームする）
    ├── src/
    │   └── (Lambda 関数のソースコード)
    ├── package.json
    ├── tsconfig.json
    ├── .eslintrc.yml
    └── .prettierrc.mjs
```

### 使用方法

- `lambda_source/` 配下をコピーして Lambda 関数コードを作成
- 本モジュールを呼び出し、開発コードのディレクトリパス（例: `lambda_source/example` ）を `ts_source_path` として入力
- `terraform apply` を実行し、TypeScript で記述した Lambda 関数をビルド・デプロイ
