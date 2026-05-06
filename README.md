# 🎮 NTE Viet Hoa Auto Updater

Tool PowerShell giúp **tự động cập nhật bản Việt hoá mới nhất** cho game *Neverness To Everness* từ GitHub Releases.

---

## 🚀 Tính năng

* 🔄 Tự động kiểm tra version mới nhất
* ⬇️ Tự động download đúng file cần thiết
* 📂 Tự tìm đường dẫn game (không cần config)
* 🧠 Tự detect đúng folder `Win64`
* 🛡️ Không ghi đè sai folder (có validate)
* ⚡ Chỉ update khi có version mới
* 💾 Lưu version ngay trong folder game

---

## 📦 Yêu cầu

* Windows
* PowerShell (có sẵn trên Windows 10/11)
* Kết nối Internet

---

## ▶️ Cách sử dụng

⚡ Cập nhật nhanh (1 dòng lệnh)

Bạn có thể chạy tool mà không cần tải file bằng cách mở PowerShell và chạy:
```powershell
irm https://raw.githubusercontent.com/SeiSilver/NTE-Viet-Hoa-Auto-Update-Windows/main/NTE%20Update.ps1 | iex
```

### Done

Script sẽ tự động:

1. Tìm game trong máy
2. Tìm đúng folder:

   ```
   Client\WindowsNoEditor\HT\Binaries\Win64
   ```
3. Kiểm tra version
4. Nếu có bản mới → tự update

---

## 🧠 Lần đầu chạy

Nếu script không tìm được game:

```
❌ Không tìm thấy app
```

👉 Bạn chỉ cần nhập đường dẫn game:

Ví dụ:
```
C:\Games\Neverness To Everness
```

---

## 📂 File được cài

Sau khi update, folder `Win64` sẽ có:

```
netbios.dll
game_vi.dat
viet_font.ttf
.latest_version
```

---

## 🔄 Cách hoạt động

* Tool sẽ gọi GitHub API để lấy bản mới nhất
* So sánh với file `.latest_version` trong game
* Nếu khác → update
* Nếu giống → skip

---

## ⚠️ Lưu ý

### ❗ Quyền admin

Nếu game nằm trong:

```
C:\Program Files\
```

👉 cần chạy PowerShell **Run as Administrator**

---

### ❗ Lần đầu chưa có mod

Tool vẫn hoạt động bình thường và sẽ tự cài

---

### ❗ Antivirus

Một số antivirus có thể cảnh báo file `.dll` → đây là bình thường

---

## 🛠 Troubleshooting

### Không tìm thấy game

👉 Nhập tay đường dẫn game

---

### Sai folder

👉 Đảm bảo path chứa:

```
Win64
```

---

### Không update

👉 Kiểm tra:

* Internet
* GitHub có release mới chưa

---

## 📌 Ghi chú

* Tool chỉ hoạt động với bản game PC
* Không hỗ trợ mobile
* Không chỉnh sửa file ngoài danh sách mod

---

## ❤️ Credits

* Mod: https://github.com/CallMeDangDev/NTE-Viet-Hoa

---