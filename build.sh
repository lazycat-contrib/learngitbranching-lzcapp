#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
upstream_dir="$(mktemp -d)"
source_dir="${UPSTREAM_SOURCE_DIR:-}"

cleanup() {
  rm -rf "${upstream_dir}"
}
trap cleanup EXIT

if [[ -z "${source_dir}" ]]; then
  upstream_sha="$(
    git ls-remote https://github.com/pcottle/learnGitBranching.git \
      refs/heads/main | awk '{print $1}'
  )"
  test -n "${upstream_sha}"

  source_dir="${upstream_dir}/source"
  mkdir -p "${source_dir}"
  curl --fail --location --retry 3 --retry-all-errors \
    "https://codeload.github.com/pcottle/learnGitBranching/tar.gz/${upstream_sha}" \
    | tar -xz --strip-components=1 -C "${source_dir}"
else
  source_dir="$(cd "${source_dir}" && pwd)"
  upstream_sha="$(git -C "${source_dir}" rev-parse HEAD)"
fi

test -f "${source_dir}/yarn.lock"
cd "${source_dir}"

# Upstream enforces yarn via scripts/check-package-manager.js (npm_execpath),
# so make sure a real yarn 1.x binary is on PATH.
if ! command -v yarn >/dev/null 2>&1; then
  corepack enable 2>/dev/null || true
fi
if ! command -v yarn >/dev/null 2>&1; then
  npm install --prefix "${HOME}/.local/opt/yarn" yarn@1.22.22
  export PATH="${HOME}/.local/opt/yarn/node_modules/.bin:${PATH}"
fi
yarn --version

printf 'Building upstream commit %s\n' "${upstream_sha}"
yarn install --frozen-lockfile
# upstream build = prebuild(i18n generate) + jasmine tests + vite build + postbuild(assets)
yarn build

rm -rf "${project_root}/dist"
cp -a build "${project_root}/dist"
