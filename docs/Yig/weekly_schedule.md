# Weekly Schedule

## Daily Operations

### 00:00-01:00 UTC - reserved

### 01:00-24:00 UTC - node-triggered kopia and k0s backup

- 01:00 UTC yig16 kopia_snapshot
- 01:15 UTC yig32 kopia_snapshot
- 01:30 UTC yig64 kopia_snapshot
- 01:45 UTC yig32 k0s backup
- 01:55 UTC yig16/yig64 k0s backup:
  - Mon/Wed/Fri/Sun yig16
  - Tue/Thu/Sat yig64

### 02:00-02:30 UTC - reserved

### 02:30-04:30 UTC - Longhorn backups

- 02:30 UTC Longhorn schedule `timeseries-backup` - selected volumes with timeseries DBs with limited retention
- 03:30 UTC Longhorn schedule `daily-backup` - rest of production volumes with longer retention

### 04:30-05:00 UTC - reserved

### 05:00-07:00 UTC - Velero backups

- 05:00 UTC:
  - Mon-Sat - `daily-quick-backup` - snapshots on non-timeseries volumes; reserve 1h
  - Sun - `weekly-full-backup` - Kopia backups on all production volumes; reserve 2h

### 07:00-23:00 UTC - day-time

### 23:00-24:00 UTC - Synology backups / reserved
