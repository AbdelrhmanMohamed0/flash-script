## 📦 Auto Flash Script for Raspberry Pi 

This script automates the process of unzipping and flashing a `.wic` or `.wic.bz2` image (generated via **Yocto Project**) to an SD card for Raspberry Pi  using `dd`.

---

### 🛠️ Requirements

- Linux system with:
  - `bash`
  - `lsblk`
  - `bunzip2`
  - `dd`
- `.wic` or `.wic.bz2` image generated from Yocto:
  - Just set `IMAGE_FSTYPES = "wic"` in your `.bb` image recipe.
  - If `bzip2` compression is enabled (by default in most cases), Yocto will automatically generate a `.wic.bz2` file.


---

### 🔧 Configuration

Before running the script, **update the image path variables** inside the script:

```bash
BASE_PATH="/media/abdelrhman/linux/build_rspi/tmp"
IMAGE_DIRECTORY="${BASE_PATH}/deploy/images/raspberrypi4-64"
```

Also, these variables/paths might need editing depending on your setup:

- `TEMP_COPY` (temporary location for `.bz2` extraction)
- `TEMP_EXTRACTED_IMAGE` (temporary `.wic` after unzip)

---

### 🚀 Usage

1. Open terminal and `cd` into the folder containing the script.
2. Give execute permission:

```bash
chmod +x auto-flash.sh
```

3. Run the script:

```bash
./auto-flash.sh
```

4. The script will:
   - Detect if a `.wic` or `.wic.bz2` image exists in the configured folder.
   - If `.wic.bz2` is found, it will be extracted automatically.
   - List connected devices using `lsblk`.
   - Ask you to choose a target device (e.g., `/dev/sdb`).
   - Ask if you want to `erase` or `flash` the selected device.

---

### ✨ Options

#### Erase
- Unmounts all partitions of the selected device.
- Overwrites the device with `/dev/zero` to erase all data.

#### Flash
- Writes the `.wic` image directly to the selected device using `dd`.

---

### ⚠️ Warning

- Always double-check the selected device name (e.g., `/dev/sdb`) to avoid data loss.
- The script shows `lsblk` output to help you identify the correct device.

---

### ✅ Example Output

```bash
./auto-flash.sh
# Detects image
# Prompts device selection (/dev/sdb)
# Prompts: erase or flash
# Executes accordingly
```

---

### 👨‍💻 Author

- **Name:** Abdelrhman Mohamed Ellawendi  
- **Email:** eng.abdelrhmanmohamed95@gmail.com  
- **Date:** April 29, 2025  

---