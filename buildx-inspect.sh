docker buildx build -f ./docker-multi-test/Dockerfile -t docker-multi-test-all --platform linux/amd64,linux/arm64,linux/arm .