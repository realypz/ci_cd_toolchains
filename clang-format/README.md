# clang-format
## Purpose
Provide a clang-format docker image.
## How to use?
Build the docker image:
```bash
# First cd the repo root.

# Then change to the sub folder of each individual image to be built.
cd ./clang-format

docker build --tag clang_format --rm .
```

Run the image
```bash
# Linux bash
docker run --rm --volume "$(pwd)":/repo_to_check --user $(id -u):$(id -g) clang_format

# Windows Powershell
docker run --rm --volume ${PWD}:/repo_to_check clang_format
```

**Reference**:
* Regarding the permission of a written file under Linux, read [link](https://unix.stackexchange.com/questions/627027/files-created-by-docker-container-are-owned-by-root).<br>
  Solved by `--user $(id -u):$(id -g)`.
