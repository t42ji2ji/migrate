#!/usr/bin/env sh
# 當發生錯誤時終止腳本運行
set -e
# 打包
flutter build web --base-href /migrate/
# 移動至到打包後的dist目錄
cd build/web
git init
git add -A
git commit -m 'deploy'
git checkout -b gh-pages
# 部署到 https://github.com/chou0728/eric-project.git 分支為 gh-pages
git push -f https://github.com/t42ji2ji/migrate.git gh-pages
cd -
echo "https://t42ji2ji.github.io/migrate/"
