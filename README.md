# jumpbox

Provides a "jumpbox" image for Openshift containing:

* bash
* curl
* source code control: git
* dns utilities: nslookup and dig
* text editors: nano and vi
* scripting: python
* aws cli
* mysql
* Openshift cli

The jumpbox is a docker container which runs a simple, one line `bash` shell script to loop indefinitely on a `sleep` statement.

## Deploying a jumpbox on Openshift
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: jumpbox
spec:
  containers:
    - name: jumpbox
      image: 172.30.250.243:5000/openshift/jumpbox:latest
      command: [ "/bin/sh", "-c", "while /bin/true; do sleep 60; done" ]
      env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: "metadata.namespace"
        - name: PUBLIC_URL
          value: "http://gitserver.$(POD_NAMESPACE):$(SERVICE_PORT)"
      imagePullPolicy: Always
  restartPolicy: Never
```

You will need to adapt the IP Address of the Openshift provided registry to your actual IP Address.

## Connecting to the the jumpbox
After logging in via the Openshift `cli`, you can run `oc exec` to connect to the jumpbox pod.  Since `oc` doesn't [currently](https://github.com/openshift/origin/issues/2284)
set up the Linux terminal to match the command line terminal on your computer, create the following `bash` shell script
to provide for a more optimal user experience:
```bash
#!/bin/sh
if [ "$1" = "" ]; then
  echo "Usage: kshell <pod>"
  exit 1
fi
COLUMNS=`tput cols`
LINES=`tput lines`
TERM=xterm
oc exec -i -t $1 -- env COLUMNS=$COLUMNS LINES=$LINES TERM=$TERM bash -il
```

Call this new shell script `kshell` and connect to your jumpbox pod using `kshell <pod name>`.

Happy hunting.

