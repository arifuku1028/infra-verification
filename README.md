# infra-verification

インフラ検証用の Terraform コードです

## 準備

Windows 環境では Git for Windows をインストールします（他のシェルでは Lambda のビルドが失敗します）

- https://gitforwindows.org/

Terraform をインストールします

- https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform
- Windows 環境は path 追加も必要です
  - https://stackoverflow.com/questions/1618280/where-can-i-set-path-to-make-exe-on-windows

Volta をインストールします（Lambda のビルドに Node.js を使用するため）

- https://docs.volta.sh/guide/getting-started

## Terraform 実行

対象のディレクトリに移動して Terraform の初期化コマンドを実行します

```
cd vpc/
terraform init
```

必要に応じてドライランコマンドを実行します

```
terraform plan
```

apply コマンドを実行してコード内容を適用します（確認が求められるので `yes` と入力して Enter

```
terraform apply
```
