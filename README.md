# contained-vlan

Attach VLAN into containers

## The principle

The Docker has unfortunate obssession with managing the networks for you. Fortunately there is way to say NO to that habit by `--network none`. Which creates poor little container with just `lo`. Then you can benefit from your skills to push the necessary parts inside the container using the great `ip` command.

__Note:__ The default config passed the docker packets through firewall rules which has to be avoided for simplicity. Thus use the `60-docker-l2-fix.conf` and put it into `/etc/sysctl.d` for persistency. And also load it imediately with `sysctl -p /etc/sysctl.d/60-docker-l2-fix.conf`.
