FROM ghcr.io/typst/typst:latest

LABEL author="MRegirouard"
LABEL maintainer="MRegirouard"
LABEL description="A simple container to do a git pull and compile a Typst document."

# Install git and check version
RUN apk add --no-cache git
RUN git --version

RUN mkdir /app
RUN chown 1000:1000 /app

WORKDIR /app
USER 1000:1000

# Set defaults
ENV GIT_TAG=main
ENV GIT_CLONE_PATH=/app/Repo
ENV TYPST_OUTPUT_PATH=/out.pdf

# Copy script, and set permissions to be executed/read by anyone
COPY --chmod=555 PullAndRender.sh /

CMD [ "/PullAndRender.sh" ]
