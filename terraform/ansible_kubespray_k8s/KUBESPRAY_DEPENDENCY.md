# Kubespray Dependency

This repository currently vendors Kubespray `2.31.0` from:

`https://github.com/kubernetes-sigs/kubespray`

The version is recorded in `kubespray/galaxy.yml`. Treat the vendored directory
as upstream code: do not mix local roles or project-specific changes into it.

For the next Kubespray upgrade, replace the directory from a verified release
tag or convert it to a Git submodule pinned to an exact commit. Test cluster
creation, an idempotent second run, and a supported upgrade before merging.
