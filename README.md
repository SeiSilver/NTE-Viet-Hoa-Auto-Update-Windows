# 🎮 NTE Viet Hoa Auto Updater

Tool PowerShell giúp **tự động cập nhật bản Việt hoá mới nhất** cho *Neverness To Everness*.

---

## 🚀 Tính năng

* 🔄 Tự check version mới
* ⬇️ Tự download & update
* 📂 Tự tìm đường dẫn game
* 🧠 Auto detect folder `Win64`
* 🛡️ Tránh ghi đè sai folder
* 💾 Lưu version trong game

---

## ▶️ Cách dùng (nhanh nhất)

Mở PowerShell và chạy:

```powershell
(irm https://raw.githubusercontent.com/SeiSilver/NTE-Viet-Hoa-Auto-Update-Windows/main/NTE-Update.ps1).ToString() | iex
```

---

## ⚙️ Script sẽ làm gì?

1. Tìm game trong máy
2. Tìm đúng folder:

   ```
   Client\WindowsNoEditor\HT\Binaries\Win64
   ```
3. So sánh version
4. Có bản mới → tự update

---

## 🧠 Lần đầu chạy

Nếu không tìm thấy game:

```
❌ Không tìm thấy app
```

👉 Nhập đường dẫn, ví dụ:

```
C:\Games\Neverness To Everness
```

---

## 📂 File được cài

```
netbios.dll
game_vi.dat
viet_font.ttf
.latest_version
```

---

## ⚠️ Lưu ý

* Nếu game nằm trong `C:\Program Files\` → chạy **Run as Administrator**
* Lần đầu chưa có mod → tool vẫn tự cài
* Antivirus cảnh báo `.dll` là bình thường

---

## 🛠 Lỗi thường gặp

* **Không tìm thấy game** → nhập tay path
* **Sai folder** → đảm bảo có `Win64`
* **Không update** → kiểm tra internet / release mới

---

## ⚡ Tạo shortcut (1 click)

1. Chuột phải Desktop → **New → Shortcut**
2. Dán:

```
powershell -NoProfile -Command "(irm https://raw.githubusercontent.com/SeiSilver/NTE-Viet-Hoa-Auto-Update-Windows/main/NTE-Update.ps1).ToString() | iex"
```

3. Đặt tên → Finish

👉 Sau đó chỉ cần **double click để update**

---

## ❤️ Credits

* Mod: https://github.com/CallMeDangDev/NTE-Viet-Hoa
