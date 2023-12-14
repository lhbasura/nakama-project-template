FROM registry.heroiclabs.com/heroiclabs/nakama-pluginbuilder:3.16.0  AS builder

ENV GO111MODULE on
ENV CGO_ENABLED 1
ENV GOPRIVATE "github.com/heroiclabs/nakama-project-template"

WORKDIR /backend

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y --no-install-recommends gcc libc6-dev

RUN go install github.com/go-delve/delve/cmd/dlv@latest
COPY . .

# RUN go build --trimpath --mod=vendor --buildmode=plugin -o ./backend.so

RUN go build --trimpath --gcflags "all=-N -l" --mod=vendor --buildmode=plugin -o ./backend.so


FROM registry.heroiclabs.com/heroiclabs/nakama-dsym:3.16.0

COPY --from=builder /go/bin/dlv /nakama
COPY --from=builder /backend/backend.so /nakama/data/modules
COPY --from=builder /backend/*.lua /nakama/data/modules/
COPY --from=builder /backend/build/*.js /nakama/data/modules/build/
COPY --from=builder /backend/local.yml /nakama/data/
