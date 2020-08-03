build:
	go build \
		-o goors-sync 
deps: 
	go get -v
build-linux:
	CGO_ENABLED=0 \
	GOOS=linux \
	GOARCH=amd64
	go build \
		-o goors-sync-linux-amd64 
build-windows:
	CGO_ENABLED=0 \
	GOOS=windows\
	GOARCH=amd64
	go build \
		-o goors-sync-windows-amd64.exe 
tar:
	tar \
		--gzip \
		--create \
		--file goors-sql.tar.gz \
		sqlQueries 
