#!/bin/bash

k8s_version=v1.0.6
pause_version=0.8.0
podmaster_version=1.1
flannel_version=0.5.3
registry_version=2

pullAndSave() {
    # first arg is image, second filename
	echo "pulling and saving $1"
	docker pull "$1"
	docker save -o "$2" "$1"
}

# get absolute path of this script
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# build inaetics images
for NAME in celix-agent felix-agent node-provisioning; do
	echo "building and saving $NAME image"
	IMAGE="172.17.8.20:5000/inaetics/$NAME:latest"
	docker build -t "$IMAGE" "$DIR/../inaetics-demo/$NAME/"
	docker save -o "$DIR/../images/controller/$NAME.tar" "$IMAGE"
done

echo "downloading kubernetes binaries"
wget -O - "https://storage.googleapis.com/kubernetes-release/release/$k8s_version/kubernetes-server-linux-amd64.tar.gz" | tar -xz -C "$DIR/../opt/bin" --strip=3
rm "$DIR"/../opt/bin/*.docker_tag
rm "$DIR"/../opt/bin/*.tar

# pull and save 3rd party images
pullAndSave "gcr.io/google_containers/pause:$pause_version", "$DIR/../images/all/pause.tar"
#pullAndSave "gcr.io/google_containers/hyperkube:$k8s_version", "$DIR/../images/all/pause.tar"
#pullAndSave "gcr.io/google_containers/podmaster:$pause_version", "$DIR/../images/controller/pause.tar"
pullAndSave "quay.io/coreos/flannel:$flannel_version" "$DIR/../images/all/flannel.tar" 
pullAndSave "registry:$registry_version" "$DIR/../images/controller/registry.tar" 
