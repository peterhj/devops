This is a collection of strongly coupled scripts,
initscripts, and design principles for implementing
high-availability service architectures on Linux
systems running OpenRC.

The design principles are as follows:

1.  Twinned services via parity ports
2.  Graceful failover via SIGHUP
3.  Auto-deploy via inotify and rsync

Below, we explain design principles in futher detail.

## Twinned services via parity ports

Each service should be implemented as a
**pair of twin initscripts**.
We refer to the twin initscripts (or simply twins) by
their parity index, 0 or 1.

To initialize the twin initscripts, simply drop
the initscript template `service.example` into
`/etc/init.d`, and then create two symlinks, like
the following (as root):

    cp -p service.example /etc/init.d/
    cd /etc/init.d
    ln -s service.example my-service-name.0
    ln -s service.example my-service-name.1

where `my-service-name` should be the binary executable
name of your service.

Service twinning enables the following system invariant:
**at least one twin (0 or 1) is in a started state**.
This is how high availability can be achieved when you
have an old version of your service currently running on
the system, and you would like to upgrade to a new
version with minimal (i.e. zero) downtime.

To actually take advantage of the above invariant, you
must follow a certain discipline when starting and
stopping a twinned service.
In the following example, we assume that twin 0 is the
old version and twin 1 is the new version, but in a real
setting the two may be swapped:

1.  First, start the new service version:

        rc-service my-service-name.1 zap start

    The new service will enter a started state but may
    not yet be accepting connections.
2.  Next, hang-up or "hup" the old service version:

        rc-service my-service-name.0 hup

    This sends SIGHUP to the old version.
    (In the next section, we explain what a twinned
    service should do upon receiving SIGHUP.)
3.  Finally, after possibly waiting for 1-2 seconds,
    it is safe to stop the old service version:

        rc-service my-service-name.0 stop

## Graceful failover via SIGHUP

When one twin of a service twin pair receives SIGHUP,
the following sequence of events should occur:

1.  The service should no longer accept new
    connections on its port, but should finish
    serving existing connections.
2.  After having served all existing connections,
    the service should stop listening on its port.
3.  After having unbound its port, the service
    should sleep until receiving SIGINT or SIGTERM,
    upon which the service process should cleanup
    and exit.

(todo)

## Auto-deploy via inotify and rsync

(todo)
