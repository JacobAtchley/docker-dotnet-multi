docker buildx build -f ./docker-multi-test/Dockerfile -t docker-multi-test-all --platform linux/amd64,linux/arm64,linux/arm .
#docker inspect docker-multi-test-all -f "{{.Os}}/{{.Architecture}}"