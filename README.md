# learngitbranching-lzcapp

[learnGitBranching](https://github.com/pcottle/learnGitBranching) 的 LazyCat LPK 打包 —— 交互式 Git 可视化闯关学习应用（纯静态站点，无后端服务）。

## 结构

- `package.yml` — LPK v2 包元数据（`community.lazycat.app.learngitbranching`）
- `lzc-manifest.yml` — 运行结构：静态文件直出（`file:///lzcapp/pkg/content/`）
- `lzc-build.yml` — 构建配置（`build.sh` + `contentdir: ./dist`）
- `build.sh` — 拉取上游 main 源码 → yarn 1.x 安装构建 → 拷贝 `build/` 到 `dist/`
- `package.json` / `yarn.lock` — 上游清单副本，供 setup-node yarn 缓存使用
- `.github/lazycat-action.yml` — ca-x/lazycat-github-action 配置（git 版本源，node 工具链，仅私有商店）
- `.github/workflows/lazycat.yml` — 每日自动构建 + 发布喵喵商店

## 发布

推送到 `lazycat-contrib/learngitbranching-lzcapp` 后，GitHub Action 自动：

1. 计算下一个 patch 版本
2. 构建上游 main 最新 commit（yarn install + yarn build）
3. 产出 `community.lazycat.app.learngitbranching-v<version>.lpk` Release 资产
4. 发布到喵喵商店（`APPSTORE_URL` / `APPSTORE_TOKEN`，可选 `APP_ID`、`PRIVATE_STORE_GROUP_CODES`）

需在仓库/组织配置 Secrets：`APPSTORE_URL`、`APPSTORE_TOKEN`。

## 本地验证

```bash
UPSTREAM_SOURCE_DIR=../lgb lzc-cli project release -o learngitbranching.lpk
```
