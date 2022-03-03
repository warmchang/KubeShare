CONTAINER_PREFIX?=riyazhu
CONTAINER_NAME?=kubeshare-scheduler
CONTAINER_VERSION?=testv1
CONTAINER_IMAGE=$(CONTAINER_PREFIX)/$(CONTAINER_NAME):$(CONTAINER_VERSION)


TARGET=kubeshare-scheduler kubeshare-device-manager kubeshare-config-client
GO=go
GO_MODULE=GO111MODULE=on
BIN_DIR=bin/
ALPINE_COMPILE_FLAGS=CGO_ENABLED=0 GOOS=linux GOARCH=amd64
NVML_COMPILE_FLAGS=CGO_LDFLAGS_ALLOW='-Wl,--unresolved-symbols=ignore-in-object-files' GOOS=linux GOARCH=amd64
PACKAGE_PREFIX=KubeShare/cmd/

.PHONY: all clean $(TARGET)

all: $(TARGET)

kubeshare-device-manager:
	$(GO_MODULE) $(ALPINE_COMPILE_FLAGS) $(GO) build -o $(BIN_DIR)$@ $(PACKAGE_PREFIX)$@

kubeshare-scheduler:
	$(GO_MODULE) $(ALPINE_COMPILE_FLAGS) $(GO) build -o $(BIN_DIR)$@ $(PACKAGE_PREFIX)$@

kubeshare-config-client:
	$(GO_MODULE) $(NVML_COMPILE_FLAGS) $(GO) build -o $(BIN_DIR)$@ $(PACKAGE_PREFIX)$@


build-image:
	docker build -t $(CONTAINER_IMAGE) -f ./docker/$(CONTAINER_NAME)/Dockerfile . --no-cache

push-image:
	docker push  $(CONTAINER_IMAGE) 

deploy-component:
	kubectl apply -f build/
	
delete-component:
	kubectl delete -f build/

save-image:
	docker save -o $(CONTAINER_NAME)_$(CONTAINER_VERSION).tar $(CONTAINER_IMAGE)

load-image:
	docker load -i $(CONTAINER_NAME)_$(CONTAINER_VERSION).tar

clean:
	rm $(BIN_DIR)* 2>/dev/null; exit 0
