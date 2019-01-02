[Unit]
Description=${DISK} volume to ${MOUNT_PATH}
Before=docker.service

[Mount]
What=${DISK}
Where=${MOUNT_PATH}

[Install]
WantedBy=docker.service
