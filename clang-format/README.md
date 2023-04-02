# clang-format
## Purpose
Provide a clang-format docker image.
## How to use?
Build the docker image:
```bash
# First cd the repo root.

# Then change to the sub folder of each individual image to be built.
cd ./clang-format

docker build --tag clang_format:latest --tag clang_format:14.0.0-ubuntu --rm .
```

Run the image
```bash
# Linux bash
docker run --rm --volume "$(pwd)":/repo_to_check --user $(id -u):$(id -g) clang_format:latest

# Windows Powershell
docker run --rm --volume ${PWD}:/repo_to_check clang_format:latest
```

**Reference**:
* Regarding the permission of a written file under Linux, read [link](https://unix.stackexchange.com/questions/627027/files-created-by-docker-container-are-owned-by-root).<br>
  Solved by `--user $(id -u):$(id -g)`.
