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
* NSS Wrapper (to handle Openshift's dynamic UIDs)

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
      image: mchudgins/jumpbox:latest
      command: [ "/bin/sh", "-c", "while /bin/true; do sleep 60; done" ]
      env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: "metadata.namespace"
      imagePullPolicy: Always
  restartPolicy: Never
```

## Connecting to the the jumpbox
After logging in via the Openshift `cli`, you can run `oc exec` to connect to the jumpbox pod. 
However, for some reason I haven't taken the time to fully grok, the PS1 prompt complains "I have no name".  To correct this
launch a second Bash child process.  Since `oc` doesn't [currently](https://github.com/openshift/origin/issues/2284)
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
oc exec -i -t $1 -- env COLUMNS=$COLUMNS LINES=$LINES TERM=$TERM bash -il -c "bash"
```


Call this new shell script `kshell` and connect to your jumpbox pod using `kshell <pod name>`.

Happy hunting.

