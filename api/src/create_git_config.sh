#!/bin/bash
mkdir -p /opt/render/project/src/.git
cat <<EOF > /opt/render/project/src/.git/config
[core]
    repositoryformatversion = 0
    filemode = true
    bare = false
    logallrefupdates = true
[remote "origin"]
    url = https://github.com/imputnet/cobalt.git
    fetch = +refs/heads/*:refs/remotes/origin/*
[branch "main"]
    remote = origin
    merge = refs/heads/main
EOF
