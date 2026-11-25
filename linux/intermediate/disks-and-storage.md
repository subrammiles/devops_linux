# Disks, Filesystems, and Mounting

`lsblk`, `df`, `du`, `mount`, `/etc/fstab`, `mkfs`, swap

## Key ideas

- A **disk** is a device such as `/dev/sda` or `/dev/nvme0n1`.
- A disk is split into **partitions**: `/dev/sda1`, `/dev/nvme0n1p1`.
- A partition is formatted with a **filesystem** (ext4, xfs).
- A filesystem is **mounted** on a directory (a *mount point*). After that, its files appear under that directory.

## Looking at disks

```bash
lsblk                   # Disks, partitions and mount points as a tree
lsblk -f                # Also show filesystem type and UUID
sudo fdisk -l           # Partition tables in detail
sudo blkid              # UUIDs and filesystem types
```

Example `lsblk` output:

```text
NAME        SIZE TYPE MOUNTPOINTS
nvme0n1     476G disk
├─nvme0n1p1   1G part /boot/efi
└─nvme0n1p2 475G part /
sdb          50G disk
```

Here `sdb` is a new, unused disk.

## Disk space

```bash
df -h                   # Free space on each mounted filesystem
df -h /var              # The filesystem that holds /var
df -i                   # Inodes: a disk can be "full" of small files while bytes remain
du -sh /var/log         # Total size of a directory
du -h --max-depth=1 /var | sort -rh | head   # Biggest subdirectories
sudo ncdu /             # Interactive browser (sudo apt install ncdu)
```

### When the disk is full

Common culprits, roughly in order:

```bash
sudo du -h --max-depth=1 /var | sort -rh | head
sudo journalctl --disk-usage
sudo journalctl --vacuum-size=200M          # Shrink the systemd journal
sudo apt clean                              # Downloaded package cache
docker system df                            # Docker images, containers, volumes
docker system prune                         # Remove unused Docker data (read the prompt first)
```

If `df` says the disk is full but `du` can't find the files, a process may still hold a deleted file open:

```bash
sudo lsof +L1           # Open files that have been deleted
```

Restarting that process frees the space.

## Adding a new disk

> ⚠️ `mkfs` erases everything on the device. Check the device name with `lsblk` first. Formatting the wrong disk destroys its data.

The example below uses a new, empty disk `/dev/sdb`.

```bash
# 1. Create one partition that uses the whole disk
sudo parted /dev/sdb --script mklabel gpt mkpart primary ext4 0% 100%

# 2. Create a filesystem on it
sudo mkfs.ext4 /dev/sdb1

# 3. Create a mount point and mount it
sudo mkdir -p /data
sudo mount /dev/sdb1 /data
df -h /data
```

A mount made this way disappears after a reboot. To make it permanent, use `/etc/fstab`.

## `/etc/fstab`: mounts at boot

Get the partition's UUID. UUIDs don't change when disks are reordered, unlike `/dev/sdX` names.

```bash
sudo blkid /dev/sdb1
```

Add a line to `/etc/fstab`:

```text
# <device>                                 <mount point> <type> <options>        <dump> <pass>
UUID=3f2a1b7c-0000-4d2e-9a1f-123456789abc  /data         ext4   defaults,nofail  0      2
```

- `nofail` lets the system keep booting if this disk is missing.
- `pass` is the order for filesystem checks at boot: `1` for `/`, `2` for others, `0` to skip.

Test before rebooting. A broken `fstab` can stop a server from booting:

```bash
sudo umount /data
sudo mount -a           # Mount everything in fstab; errors show here
sudo findmnt --verify   # Check fstab for mistakes
```

## Mounting and unmounting

```bash
mount | grep /data          # Is it mounted?
findmnt /data               # Clearer view
sudo umount /data           # Unmount (note the spelling: umount)
sudo lsof +D /data          # If "target is busy", see what's using it
```

## Swap

Swap is disk space used when RAM runs out. It's slow, but it can prevent out-of-memory crashes on small servers.

```bash
swapon --show
free -h

# Create a 2 GB swap file
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

## LVM in brief

LVM (Logical Volume Manager) lets you grow volumes and combine disks. Cloud images and RHEL often use it.

```bash
sudo pvs; sudo vgs; sudo lvs        # Physical volumes, volume groups, logical volumes

# Grow a logical volume by 10 GB and resize its filesystem in one step
sudo lvextend -r -L +10G /dev/vg0/data
```

## Practice

1. Run `lsblk -f` and identify your root filesystem and its type.
2. Find the five largest directories under `/var`: `sudo du -h --max-depth=1 /var | sort -rh | head -5`
3. Run `df -i` and compare inode use with `df -h`.
4. Run `findmnt --verify` to check your current `/etc/fstab`.

Previous: [archives-and-compression.md](archives-and-compression.md) · Next: [systemd-services.md](systemd-services.md)
