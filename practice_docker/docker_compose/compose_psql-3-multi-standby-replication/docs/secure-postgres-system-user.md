
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
################################################################################
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
=POSTGRES :: security assessment :: system user account

## Why secure the postgres system user account?

 The `postgres` system user account is the default administrative user for PostgreSQL databases.
 Securing this account is critical because it has elevated privileges to manage the database server,
 access sensitive data, and perform administrative tasks. If compromised, an attacker could gain
 full control over the PostgreSQL instance, leading to data breaches, data loss, or unauthorized
 modifications.

 Key reasons to secure the `postgres` user account include:

 1. **Prevent Unauthorized Access**: Ensuring that only authorized personnel can access the `postgres`
    account helps prevent unauthorized database access.

 2. **Limit Attack Surface**: By restricting shell access and using strong authentication methods,
    you reduce the potential attack vectors that could be exploited by malicious actors.

 3. **Protect Sensitive Data**: The `postgres` user has access to all databases and tables within
    PostgreSQL. Securing this account helps protect sensitive information stored in the databases.

 4. **Maintain System Integrity**: A compromised `postgres` account can lead to unauthorized changes
    in database configurations, potentially affecting system stability and performance.

 5. **Compliance Requirements**: Many regulatory standards require strict access controls and
    auditing for database systems. Securing the `postgres` user helps meet these compliance obligations.

Overall, securing the `postgres` system user account is a fundamental step in safeguarding your
PostgreSQL environment against potential threats and ensuring the integrity and confidentiality of
your data.

## Potgres :: system user account review

Let's look at a typical postgres user account on an Ubuntu Linux system:
```
-> grep postgres /etc/passwd
postgres:x:513:513:PostgreSQL administrator,,,:/var/lib/postgresql:/bin/bash

-> grep postgres /etc/group
ssl-cert:x:120:postgres
postgres:x:513:devuser

=> sudo grep postgres /etc/shadow
postgres:*:19794:0:99999:7:::
```

::::::::::::::

### Postgres System User Account Security Assessment

Security Posture: ⚠️ MIXED - Some Concerns

   ✅ SECURE Elements:

   Feature                      Status           Details
   ─────────────────────────────────────────────────────────────────────────────────────────────
   Password Locked              ✅ Good           * in shadow = no password login possible
   System UID                   ✅ Good           UID 513 (< 1000) = system account
   Dedicated Account            ✅ Good           Separate postgres user for DB processes
   SSL Certificate Access       ✅ Good           Member of ssl-cert group for TLS certs

   ⚠️ SECURITY CONCERNS:


   🔴 Issue #1: Shell Access Enabled

   Shell: /bin/bash

   Risk: The postgres account has a full interactive shell, which is NOT recommended
    for production.
   Best Practice: Should be /bin/false or /usr/sbin/nologin
   Why it matters:
     • If someone compromises the postgres process, they could potentially get shell access
     • Violates principle of least privilege
     • Standard hardening guides recommend no-shell for service accounts

   🟡 Issue #2: User 'devuser' in postgres Group

   postgres:x:513:devuser

   Risk: Your user account devuser has direct postgres group membership.
   Implications:
     • devuser can read/write files owned by postgres group
     • Can access PostgreSQL data directory directly
     • Can modify configuration files
   Questions:
     • Is this intentional for administrative purposes?
     • Do you need direct file system access, or should you use sudo -u postgres?

### 🔒 Hardening Recommendations:

  Priority 1: Remove Shell Access

   bash
   # Safer approach - disable shell
   sudo usermod -s /usr/sbin/nologin postgres
   # Or even more restrictive
   sudo usermod -s /bin/false postgres

   ⚠️ Note: This will prevent direct su - postgres logins. You'll need to use:

   bash
   sudo -u postgres psql
   sudo -u postgres bash -c "command"

   Priority 2: Review User Group Membership

   Option A: Remove devuser from postgres group (more secure)

   bash
   sudo gpasswd -d devuser postgres

   Option B: Keep it if needed for admin tasks, but document why
   Questions for you:
     1. Do you regularly need direct file system access to PostgreSQL data?
     2. Do you manage config files manually or through configuration management?
     3. Can you perform admin tasks via sudo -u postgres instead?

###   📊 Comparison: Your Setup vs Best Practices

   Security Control    Your Server             Best Practice                       Status
   ─────────────────────────────────────────────────────────────────────────────────────────────
   Password locked     ✅ * (locked)            ✅ Locked                            PASS
   Shell access        ❌ /bin/bash             ✅ /bin/false or /usr/sbin/nologin   FAIL
   System UID          ✅ 513                   ✅ < 1000                            PASS
   Home directory      ✅ /var/lib/postgresql   ✅ Standard location                 PASS
   SSL cert access     ✅ ssl-cert group        ✅ For TLS                           PASS
   Admin user access   ⚠️devuser in group       ❓ Depends on policy                 REVIEW

###   🎯 Bottom Line:

Current State: This is a standard Debian/Ubuntu PostgreSQL installation with typical defaults, but not hardened for production.

Risk Level:
  • Low-Medium if only trusted admins have access to the server
  • Medium-High if following strict security compliance (PCI-DSS, SOC2, etc.)

Recommended Actions:
  4. ✅ Disable shell for postgres account
  5. ⚠️Review devuser's postgres group membership
  6. 📋 Audit file permissions on PostgreSQL directories
  7. 🔍 Check if postgres has sudo privileges (shouldn't)

Would you like me to help you:
  • Check PostgreSQL data directory permissions?
  • Review pg_hba.conf and postgresql.conf security settings?
  • Verify no sudo access for postgres account?
  • Generate a hardening script for this system?

A: If you give the postgres user /usr/sbin/nologin, will this affect replication or other automated tasks?
A: No, changing the postgres user's shell to /usr/sbin/nologin will not affect replication or 
other automated PostgreSQL tasks. Here's why:
1. PostgreSQL Daemon: The PostgreSQL server (postgres process) runs as the postgres user,
   but it does not require an interactive shell to function. It operates as a background service.
2. Replication Processes: Replication tasks (like streaming replication) are handled by
   PostgreSQL's internal processes, not by invoking shell commands under the postgres user.
3. Automated Tasks: Any automated scripts or cron jobs that need to run as the postgres user
   should be executed using sudo -u postgres or similar methods that do not require an interactive shell.
4. Best Practice: Setting the shell to /usr/sbin/nologin is a common security best practice
   for service accounts, reducing the attack surface without impacting functionality.
In summary, changing the shell to /usr/sbin/nologin enhances security without disrupting PostgreSQL operations, including replication.

::::::::::::::

If setting `/usr/sbin/nologin` as the shell for the postgres user  can affect replication 
and automated tasks, depending on how they're configured. Here's what you need to know:

How `/usr/sbin/nologin` Works

When a user has `/usr/sbin/nologin` as their shell:
  • Interactive login is blocked - SSH, `su`, `su -` will be denied
  • Non-interactive commands may still work - Commands executed via `su -c`
, systemd services, or cron jobs typically still function

Impact on PostgreSQL Operations

✅ What Usually STILL Works:
  1. PostgreSQL service itself - The database server runs fine because:  • systemd (or init) starts the service without needing shell access  • The postgres process doesn't require an interactive shell
  2. Replication - Usually continues working because:  • Streaming replication uses PostgreSQL protocol connections, not shell commands  • The replication process is spawned by the already-running postgres daemon
  3. Automated maintenance - Tasks like autovacuum work because they run within the PostgreSQL server process

⚠️ What MIGHT Break:
  1. Scripts using `su - postgres` - Won't work  • Solution: Use `su -s /bin/bash postgres` or `sudo -u postgres`
  2. Cron jobs - May fail if configured to require a shell  • Solution: Use systemd timers or specify shell explicitly in cron
  3. Backup scripts - Tools like `pg_dump`, `pg_basebackup` if invoked via `su -`  • Solution: Use `sudo -u postgres pg_dump` or `su -s /bin/bash postgres -c "pg_dump..."`
  4. SSH-based replication (rare) - If using SSH for WAL shipping  • Solution: Keep `/bin/bash` or use key-based authentication with forced commands

Best Practice Recommendation

For hardened PostgreSQL servers, you typically want:

bash
# Set nologin but allow service and non-interactive commands
usermod -s /usr/sbin/nologin postgres
# Ensure scripts use this pattern:
sudo -u postgres psql -c "COMMAND"
# OR
su -s /bin/bash postgres -c "COMMAND"

Alternative approach (more restrictive):


bash
# Keep bash but disable password and lock account
usermod -s /bin/bash postgres
passwd -l postgres
# Then use sudo with NOPASSWD for specific commands in sudoers

Testing Replication After Change

If you're considering this change, test it:


bash
# Check replication status
sudo -u postgres psql -c "SELECT * FROM pg_stat_replication;"
# Verify streaming replication
sudo -u postgres psql -c "SELECT pg_current_wal_lsn();"
# Test backup
sudo -u postgres pg_basebackup -D /tmp/test_backup -F tar

The short answer: For most modern PostgreSQL setups using systemd and streaming replication,
`/usr/sbin/nologin` is fine and won't break replication. Just ensure your maintenance scripts use
`sudo -u postgres` instead of `su - postgres`.
Would you like me to help you check your specific PostgreSQL configuration or replication setup to
determine if this change would cause issues?

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
################################################################################
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

## Practical Demo Commands

Change the postgres user shell to nologin and test access:
```    
-> sudo usermod -s /usr/sbin/nologin postgres

-> grep postgres /etc/passwd
postgres:x:151:151:PostgreSQL administrator,,,:/var/lib/postgresql:/usr/sbin/nologin
```
Test login attempts and command execution:
```
-> sudo su - postgres
This account is currently not available.
```

Run a command as postgres:
```
-> sudo -u postgres head /var/log/postgres/postgresql.log

-> sudo -u postgres psql -c "SELECT * FROM pg_stat_replication;"

-> sudo -u postgres /postgres/bin/mybashscript.sh
```
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
################################################################################
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

## How to handle 'cd' command not found error after changing shell to nologin

After changing the shell i get this

```
-> sudo -u postgres cd /postgres/bin
sudo: cd: command not found
sudo: "cd" is a shell built-in command, it cannot be run directly.
sudo: the -s option may be used to run a privileged shell.
sudo: the -D option may be used to run a command in a specific directory.
```

-> sudo -u postgres bash -c "cd /postgres/bin && ./mybashscript.sh"

The error occurs because `cd` is a shell built-in command, not an executable that `sudo`
can run directly. When you switch users with `sudo -u`, you need to either:
1. Use the `-s` option to start a shell as that user, then navigate:
```
sudo -u postgres -s
cd /postgres/bin
```

2. Use the `-D` option to run a command in a specific directory:

```
sudo -u postgres -D /postgres/bin <command>
```
Bb
3. Run the shell explicitly and pass the cd command:

```
sudo -u postgres bash -c "cd /postgres/bin && pwd"I'
```

For your PostgreSQL initialization, the best approach is:
```
sudo -u postgres bash -c "cd /postgres/bin && ./initdb -D /postgres/data"
```

Or use the `-D` flag with sudo:
```
sudo -u postgres -D /postgres/bin ./initdb -D /postgres/data
```

## Why set nologin if -s gets you a shell?

This indicates the postgres user does not have a shell
```
 -> sudo su - postgres
 This account is currently not available.
```

But this allows me to get a shell as the postgres user
what is the point of setting nologin if using -s gets you a shell? isn't the security
point moot?

This is a common source of confusion about Unix/Linux security. 
Let me clarify the distinction:

The Security Model

`nologin` shell prevents:
  • ❌ Direct SSH logins as postgres
  • ❌ `su - postgres` (requires the user's shell to be valid)
  • ❌ Console/TTY logins
  • ❌ Password-based authentication for that user
`nologin` does NOT prevent:
  • ✅ `sudo -u postgres -s` (root/sudoers can override)
  • ✅ `sudo -u postgres bash`
  • ✅ Running commands as that user via `sudo -u postgres <command>`

Why This Makes Sense

The security model is actually intentional and layered:
  1. External attacks: An attacker who compromises SSH or gets network access cannot  directly log in as `postgres` because:
  • No valid shell for login
  • No password typically set
  • SSH denies the login

  2. Privilege escalation boundary: To become `postgres`, you must:
  • First be root (or have sudo privileges)
  • This creates an audit trail in sudo logs
  • Actions are logged with who invoked them

  3. Service accounts don't need interactive logins: The `postgres` user is meant to:
  • Run the PostgreSQL daemon
  • Have files owned by it
  • NOT be used for human interactive sessions


The Real Security Value

   Attacker's path WITHOUT nologin:
   Internet → SSH as postgres → Direct access
   Attacker's path WITH nologin:
   Internet → SSH as postgres → BLOCKED ❌
   Internet → Exploit another service → Get user shell → Need sudo privileges →
   BLOCKED ❌

With `sudo -u postgres -s`:

   You (authorized admin) → sudo (with your credentials) → Logged in sudo → Act as   postgres ✅

Audit Trail Example

● bash $ echo "Example of what gets logged:"; cat << 'EOF'
# In /var/log/auth.log or /var/log/secure:
Nov 26 00:11:05 hostname sudo: devuser : TTY=pts/0 ; PWD=/home/devuser ; USER=postgres ;COMMAND=/bin/bash -s
Nov 26 00:11:05 hostname sudo: pam_unix(sudo:session): session opened for user postgres by
Nov 26 00:11:05 hostname sudo: pam_unix(sudo:session): session opened for user postgres by  devuser(uid=1000)

Summary

The point of `nologin` is:
  • Defense in depth against external attacks
  • Prevents unauthorized direct access
  • Forces all access through sudo (which requires authorization + creates audit logs)
  • Makes it clear this is a service account, not a user account
`sudo -u postgres -s` working is intentional:
  • You're already authorized (you have sudo rights)
  • Your actions are logged
  • It's a controlled, auditable way to perform admin tasks
Think of it like: `nologin`
 locks the front door, but authorized admins (with sudo) have a master key that's logged
every time it's used. The security isn't moot—it's just protecting against
unauthorized access while allowing authorized access with accountability.

=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
################################################################################
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

