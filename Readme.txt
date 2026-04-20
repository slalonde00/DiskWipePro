DiskWipePro

DiskWipePro is a fast, portable, and secure disk erasure tool written in Bash for Linux systems.
It is designed to provide enterprise-level data sanitization comparable to industry tools such as Blancco, while remaining lightweight and easy to deploy from a USB environment.

---

Features

- Secure disk wiping with multiple overwrite passes
- Supports HDD, SSD, and NVMe drives
- Designed to meet DoD 5220.22-M data sanitization standards
- Faster execution compared to traditional wiping tools
- Portable – can run from a USB key without installation
- Automatic disk detection
- Interactive disk selection menu
- Progress tracking during erase operations
- Minimal dependencies

---

Supported Erasure Standards

DiskWipePro supports secure overwrite methods inspired by recognized standards:

- DoD 5220.22-M (3-pass and 7-pass variants)
- Zero-fill (single pass)
- Random data overwrite

These methods aim to make data recovery extremely difficult or practically impossible when applied correctly.

---

Requirements

- Linux-based OS (Ubuntu, Linux Mint, etc.)
- Root privileges
- Bash shell

Optional (auto-installed if missing):

- coreutils
- util-linux
- lsblk
- dd

---

Installation

Clone the repository:

git clone https://github.com/slalonde00/DiskWipePro.git
cd DiskWipePro

Make the script executable:

chmod +x diskwipepro.sh

---

Usage

Run the script as root:

sudo ./diskwipepro.sh

Steps:

1. Launch the script
2. Select the disk you want to erase
3. Choose the wiping method
4. Confirm the operation
5. Monitor progress until completion

---

⚠ WARNING ⚠

This tool will PERMANENTLY DELETE all data on the selected disk.

- There is NO recovery possible after execution
- Double-check the selected disk before confirming
- Use with caution in production environments

---

How It Works

DiskWipePro overwrites the entire disk with controlled data patterns (zeros, random data, or multi-pass sequences).
This process ensures that previously stored data cannot be reconstructed using conventional recovery techniques.

---

Use Cases

- IT asset disposal and recycling
- Preparing disks for resale
- Secure data destruction
- Lab environments and testing
- System redeployment

---

Future Improvements

- GUI version (planned)
- Logging and certification reports
- Parallel multi-disk wiping
- Advanced SSD/NVMe secure erase integration

---

License

This project is open-source.
Feel free to use, modify, and distribute.

---

Author

Sébastien Lalonde
GitHub: https://github.com/slalonde00

---

Disclaimer

The author is not responsible for any data loss, hardware damage, or misuse of this software.
Use at your own risk.
