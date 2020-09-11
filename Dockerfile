FROM golang:1.8

WORKDIR /go/src/netsetup
RUN mkdir client
RUN mkdir server
RUN printf "package main\nfunc main(){\nfor{}\n}" > empty.go
RUN apt update -y
RUN apt install -y net-tools

COPY router_setup.sh .

RUN go build empty.go
RUN rm empty.go
CMD ["./empty"]
