# modules/asg

App tier: Auto Scaling Group over a launch template (Amazon Linux 2023, IMDSv2 required, encrypted gp3 root, SSM instance profile, no key pair, no port 22) running the Dockerized app, with CPU target tracking and rolling instance refresh.

User data (`user_data.sh.tftpl`) installs Docker, reads the DB credentials from Secrets Manager with the instance role, and starts the container.

The app-to-DB egress rule lives in the root module.

## Inputs / outputs

See [variables.tf](variables.tf) and [outputs.tf](outputs.tf).
