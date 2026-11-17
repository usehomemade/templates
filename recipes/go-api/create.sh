go mod init app
# air rebuilds and restarts the server on every save (dev mode with live reload).
go get -tool github.com/air-verse/air@latest
printf '/tmp/\n/app\n' >.gitignore
