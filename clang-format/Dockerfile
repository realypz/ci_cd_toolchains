# Use Debian 11 as the base image
FROM ubuntu:jammy-20220428

# Set the maintainer label
LABEL maintainer="Your Name <your@email.com>"

# Install clang_format and curl
RUN apt-get update && apt-get install -y clang-format curl

# Copy the .clang-format file from the current directory
COPY clang-format.sh .

# Set the entrypoint to clang_format
ENTRYPOINT ["/bin/bash", "/clang-format.sh"]
