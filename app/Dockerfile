# ---------- Build Stage ----------
FROM golang:1.19 AS build

WORKDIR /go/src/tasky
COPY . .
RUN go mod download
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /go/src/tasky/tasky

# ---------- Release Stage ----------
FROM alpine:3.17.0 as release

WORKDIR /app

# Binary + static assets
COPY --from=build /go/src/tasky/tasky .
COPY --from=build /go/src/tasky/assets ./assets

# Wiz Lab requirement: include identity file
COPY --from=build /go/src/tasky/wizexercise.txt ./wizexercise.txt

EXPOSE 8080
ENTRYPOINT ["/app/tasky"]










# the below was here from Jeff Thorne's tasky 
# Building the binary of the App
# FROM golang:1.19 AS build

# WORKDIR /go/src/tasky
# COPY . .
# RUN go mod download
# RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /go/src/tasky/tasky

# # Wiz Lab requirement: include wizexercise.txt in the container
# COPY --from=build /go/src/tasky/wizexercise.txt ./wizexercise.txt


# FROM alpine:3.17.0 as release

# WORKDIR /app
# COPY --from=build  /go/src/tasky/tasky .
# COPY --from=build  /go/src/tasky/assets ./assets
# EXPOSE 8080
# ENTRYPOINT ["/app/tasky"]


