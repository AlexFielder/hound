CMDS := $(GOPATH)/bin/houndd $(GOPATH)/bin/hound

SRCS := $(shell find . -type f -name '*.go')

WEBPACK_ARGS := -p
ifdef DEBUG
	WEBPACK_ARGS := -d
endif

ALL: $(CMDS)

ui: ui/bindata.go

node_modules:
	npm install

$(GOPATH)/bin/houndd: ui/bindata.go $(SRCS)
	go install github.com/hound-search/hound/cmds/houndd

$(GOPATH)/bin/hound: ui/bindata.go $(SRCS)
	go install github.com/hound-search/hound/cmds/hound

.build/bin/go-bindata:
	$(GOPATH)/bin/go-bindata.exe
	#GOPATH=`pwd`/.build go get github.com/jteeuwen/go-bindata/...

ui/bindata.go: $(GOPATH)/bin/go-bindata.exe node_modules $(wildcard ui/assets/**/*)
	mkdir .build\ui
	rsync -r ui/assets/* .build/ui
	npx webpack $(WEBPACK_ARGS)
	$< -o $@ -pkg ui -prefix .build/ui -nomemcopy .build/ui/...

dev: ALL
	npm install

test:
	go test github.com/hound-search/hound/...
	npm test

lint:
	export GO111MODULE=on
	go get github.com/golangci/golangci-lint/cmd/golangci-lint
	export GOPATH=/tmp/gopath
	export PATH=$GOPATH/bin:$PATH
	golangci-lint run ./...

clean:
	rmdir /s /q .build node_modules
