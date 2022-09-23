# !/bin/bash
for i in $(multipass list --format csv | grep "^k3s[A-z0-9-]*" -o); do
    echo "killing $i"
    multipass delete -p $i
done
exit 0