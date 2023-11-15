# D-Bus Translator

For D-Bus there are several command-line tools that differ in usability
and availability.

- `dbus-send`, the original tool from libdbus
- `busctl` from systemd
- `gdbus` from GLib

`dbus-translate` can be put in front of such a call to translate between these tools.

Example (spaces added to aid comparison):

```console
$ dbus-translate dbus-send --print-reply --dest=a.service /object an.interface.Method string:an_arg
dbus-send --session --print-reply --dest\=a.service               /object          an.interface.Method string:an_arg
busctl    --user             call         a.service               /object          an.interface Method      s an_arg
gdbus     call --session           --dest a.service --object-path /object --method an.interface.Method      \"an_arg\"
```
