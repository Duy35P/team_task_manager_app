# 📋 Hướng Dẫn Chạy Project TeamTask

> **TeamTask** — Ứng dụng quản lý công việc nhóm với tính năng cộng tác real-time, được xây dựng bằng Flutter + Firebase.

---

## 📑 Mục lục

1. [Yêu cầu hệ thống](#-1-yêu-cầu-hệ-thống)
2. [Cài đặt môi trường](#-2-cài-đặt-môi-trường)
3. [Clone và cài đặt project](#-3-clone-và-cài-đặt-project)
4. [Cấu hình Firebase](#-4-cấu-hình-firebase)
5. [Chạy ứng dụng](#-5-chạy-ứng-dụng)
6. [Tạo tài khoản và đăng nhập](#-6-tạo-tài-khoản-và-đăng-nhập)
7. [Test cộng tác Real-time](#-7-test-cộng-tác-real-time)
8. [Cấu trúc Project](#-8-cấu-trúc-project)
9. [Xử lý lỗi thường gặp](#-9-xử-lý-lỗi-thường-gặp)

---

## 🖥 1. Yêu cầu hệ thống

| Yêu cầu | Phiên bản tối thiểu |
|---|---|
| **Flutter SDK** | 3.38.x (stable) |
| **Dart SDK** | 3.10.x |
| **Android Studio** | Hedgehog (2023.1) trở lên |
| **Java JDK** | 17 |
| **Git** | 2.x |
| **Trình duyệt** | Chrome hoặc Edge (để chạy web) |

### Thiết bị chạy app (chọn ít nhất 1):
- ✅ **Chrome / Edge** — chạy web (nhanh nhất, không cần thiết bị vật lý)
- ✅ **Android** — điện thoại thật (cắm USB, bật USB Debugging) hoặc Android Emulator
- ✅ **iOS** — cần máy macOS + Xcode (nếu có)

---

## 🔧 2. Cài đặt môi trường

### Bước 2.1: Cài Flutter SDK

1. Tải Flutter SDK tại: https://docs.flutter.dev/get-started/install
2. Giải nén vào thư mục mong muốn (ví dụ: `C:\flutter`)
3. Thêm `C:\flutter\bin` vào biến môi trường **PATH**
4. Mở terminal mới và kiểm tra:

```bash
flutter --version
```

Kết quả mong đợi:
```
Flutter 3.38.x • channel stable
Dart 3.10.x
```

### Bước 2.2: Cài Android Studio (nếu chạy trên Android)

1. Tải tại: https://developer.android.com/studio
2. Cài đặt và mở Android Studio
3. Vào **Settings > Plugins** → cài plugin **Flutter** (tự kéo thêm Dart)
4. Vào **Settings > SDK Manager** → đảm bảo đã cài **Android SDK 35** (hoặc mới hơn)
5. Chấp nhận licenses:

```bash
flutter doctor --android-licenses
```

### Bước 2.3: Kiểm tra môi trường

```bash
flutter doctor
```

Đảm bảo các mục sau đều ✅ (tick xanh):
```
[✓] Flutter
[✓] Android toolchain
[✓] Chrome - develop for the web
```

> 💡 **Tip**: Nếu chỉ muốn chạy trên web (Chrome), bạn **không cần** cài Android Studio.

---

## 📦 3. Clone và cài đặt project

### Bước 3.1: Clone repository

```bash
git clone <URL_REPOSITORY>
cd <TEN_THU_MUC_PROJECT>
```

### Bước 3.2: Cài đặt dependencies

```bash
flutter pub get
```

Lệnh này sẽ tải về tất cả packages cần thiết:
- `firebase_core` — kết nối Firebase
- `firebase_auth` — xác thực người dùng
- `cloud_firestore` — cơ sở dữ liệu real-time

### Bước 3.3: Kiểm tra thiết bị khả dụng

```bash
flutter devices
```

Kết quả ví dụ:
```
Found 3 connected devices:
  Chrome (web)       • chrome   • web-javascript
  Edge (web)         • edge     • web-javascript
  Windows (desktop)  • windows  • windows-x64
```

---

## 🔥 4. Cấu hình Firebase

### 4.1. Thông tin Firebase Project

Project đã được kết nối với Firebase project sau:

| Thông tin | Giá trị |
|---|---|
| **Project ID** | `teammanager-1e970` |
| **Project Name** | TeamManager |
| **Console URL** | https://console.firebase.google.com/project/teammanager-1e970 |
| **Dịch vụ sử dụng** | Firebase Auth, Cloud Firestore |

### 4.2. Những gì đã có sẵn trong repo

Khi bạn clone project về, toàn bộ cấu hình Firebase **đã được bao gồm sẵn**, bạn **KHÔNG cần** tạo project Firebase mới:

| File | Vị trí | Mục đích |
|---|---|---|
| `firebase_options.dart` | `lib/firebase_options.dart` | Chứa API keys cho Web, Android, iOS |
| `google-services.json` | `android/app/google-services.json` | Cấu hình Firebase cho Android |
| `firebase.json` | Thư mục gốc | Metadata project Firebase |
| `build.gradle.kts` | `android/app/build.gradle.kts` | Đã tích hợp plugin `google-services` |

> ✅ **Kết luận**: Chỉ cần `flutter pub get` → `flutter run` là chạy được, không cần cấu hình Firebase thêm.

### 4.3. Các dịch vụ Firebase được sử dụng

#### 🔐 Firebase Authentication (Xác thực người dùng)

- **Phương thức**: Email / Mật khẩu
- **Chức năng**: Đăng ký, đăng nhập, đăng xuất, quên mật khẩu
- **Tự động**: Mỗi user đăng ký sẽ được tạo document trong collection `users` trên Firestore

#### 🗄 Cloud Firestore (Cơ sở dữ liệu real-time)

Firestore là NoSQL database trên cloud, cho phép **đồng bộ dữ liệu tức thì** giữa các thiết bị.

**Cấu trúc dữ liệu trên Firestore:**

```
firestore/
├── users/                          # Collection người dùng
│   └── {userId}/                   # Document cho mỗi user
│       ├── name: "Minh Hoàng"
│       ├── email: "mh@test.com"
│       ├── initials: "MH"
│       ├── avatarColorIndex: 0
│       └── createdAt: Timestamp
│
├── groups/                         # Collection nhóm
│   └── {groupId}/                  # Document cho mỗi nhóm
│       ├── name: "Team Flutter Dev"
│       ├── description: "Nhóm phát triển app..."
│       ├── isActive: true
│       ├── createdBy: "{userId}"
│       ├── channels: ["chung", "dev", "design"]
│       ├── createdAt: Timestamp
│       │
│       ├── members/                # Subcollection thành viên
│       │   └── {memberId}/
│       │       ├── name: "Minh Hoàng"
│       │       ├── initials: "MH"
│       │       ├── role: "Admin"
│       │       ├── taskCount: 8
│       │       └── avatarColorIndex: 0
│       │
│       ├── tasks/                  # Subcollection công việc
│       │   └── {taskId}/
│       │       ├── title: "Thiết kế màn hình Login"
│       │       ├── status: "done"     # todo | doing | done
│       │       ├── assignee: "MH"
│       │       ├── deadline: "20/04"
│       │       ├── type: "task"        # task | kanban
│       │       └── createdAt: Timestamp
│       │
│       ├── messages/               # Subcollection tin nhắn
│       │   └── {messageId}/
│       │       ├── sender: "Minh Hoàng"
│       │       ├── text: "Hello team!"
│       │       ├── userId: "{userId}"
│       │       ├── channel: "chung"
│       │       └── createdAt: Timestamp
│       │
│       └── activities/             # Subcollection hoạt động
│           └── {activityId}/
│               ├── actor: "An Nhiên"
│               ├── action: "hoàn thành task"
│               ├── detail: "Viết API xác thực"
│               ├── time: "10 phút"
│               ├── colorIndex: 1
│               └── createdAt: Timestamp
```

### 4.4. Cơ chế Real-time hoạt động như thế nào?

App sử dụng **Firestore Snapshots** — một cơ chế listener real-time:

```
┌──────────────┐         ┌──────────────────┐         ┌──────────────┐
│   User A     │         │  Cloud Firestore │         │   User B     │
│  (Chrome)    │         │  (Firebase Cloud)│         │  (Android)   │
├──────────────┤         ├──────────────────┤         ├──────────────┤
│              │         │                  │         │              │
│ Gửi tin nhắn ├────────►│ Lưu message doc  │         │              │
│              │         │        │         │         │              │
│              │         │        ▼         │         │              │
│              │         │ Push snapshot    ├────────►│ StreamBuilder │
│              │         │ tới ALL listeners│         │ nhận data mới│
│              │         │                  │         │ → UI rebuild │
│              │         │        │         │         │ → Hiện tin   │
│              │         │        ▼         │         │   nhắn mới!  │
│ StreamBuilder│◄────────┤ Push snapshot    │         │              │
│ cũng nhận   │         │ tới chính User A │         │              │
│ → Confirm ✓ │         │                  │         │              │
└──────────────┘         └──────────────────┘         └──────────────┘
```

Code thực hiện trong `lib/services/firestore_service.dart`:

```dart
// Ví dụ: Lắng nghe tin nhắn real-time
Stream<List<Message>> watchMessages(String groupId, String channel) {
  return _db.collection('groups').doc(groupId)
      .collection('messages')
      .where('channel', isEqualTo: channel)
      .snapshots()  // ← Đây là key: listener real-time!
      .map((snap) => snap.docs.map((doc) => Message.fromMap(doc.id, doc.data())).toList());
}
```

Trên UI, sử dụng `StreamBuilder` để tự động cập nhật:

```dart
StreamBuilder<List<Message>>(
  stream: firestoreService.watchMessages(groupId, channel),
  builder: (context, snapshot) {
    final msgs = snapshot.data ?? [];
    // UI tự rebuild mỗi khi có message mới!
    return ListView.builder(...);
  },
)
```

### 4.5. Firestore Security Rules

Hiện tại Firestore rules được cấu hình ở chế độ **test mode** (cho phép đọc/ghi tự do) để thuận tiện phát triển. Rules được quản lý trên Firebase Console:

1. Vào https://console.firebase.google.com/project/teammanager-1e970
2. Chọn **Firestore Database** → tab **Rules**
3. Rules hiện tại:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

> ⚠️ **Lưu ý**: Rules trên chỉ dùng cho môi trường **phát triển/test**. Trong production, cần siết chặt rules theo authentication.

### 4.6. (Tùy chọn) Tạo Firebase Project riêng

Nếu bạn muốn dùng Firebase project **của riêng mình** thay vì project chung, làm theo các bước sau:

#### Bước 1: Tạo project trên Firebase Console

1. Vào https://console.firebase.google.com
2. Nhấn **"Add project"** → đặt tên → tạo project

#### Bước 2: Bật Authentication

1. Trong Firebase Console → chọn **Authentication** → **Get Started**
2. Tab **Sign-in method** → bật **Email/Password**

#### Bước 3: Tạo Firestore Database

1. Trong Firebase Console → chọn **Firestore Database** → **Create database**
2. Chọn location (ví dụ: `asia-southeast1` cho Việt Nam)
3. Chọn **Start in test mode** → Create

#### Bước 4: Cài FlutterFire CLI và cấu hình lại

```bash
# Cài Firebase CLI (cần Node.js)
npm install -g firebase-tools

# Đăng nhập Firebase
firebase login

# Cài FlutterFire CLI
dart pub global activate flutterfire_cli

# Cấu hình lại (chạy trong thư mục project)
flutterfire configure --project=<YOUR_PROJECT_ID>
```

Lệnh `flutterfire configure` sẽ tự động:
- Tạo lại `lib/firebase_options.dart` với keys mới
- Tạo lại `android/app/google-services.json`
- Cấu hình cho các platform bạn chọn (Web, Android, iOS)

#### Bước 5: Chạy lại app

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

> 💡 Dữ liệu mẫu sẽ tự động được seed vào database mới khi user đầu tiên đăng ký (do `SeedService` trong app).

---

## 🚀 5. Chạy ứng dụng

### 🌐 Chạy trên Web (Chrome) — Khuyến nghị cho test nhanh

```bash
flutter run -d chrome
```

### 🌐 Chạy trên Web (Edge)

```bash
flutter run -d edge
```

### 📱 Chạy trên điện thoại Android

1. **Bật USB Debugging** trên điện thoại:
   - Vào **Cài đặt > Giới thiệu > Nhấn 7 lần vào "Số bản dựng"** để bật Developer Options
   - Vào **Cài đặt > Tùy chọn nhà phát triển > Bật "Gỡ lỗi USB"**
2. Cắm USB vào máy tính
3. Cho phép kết nối khi điện thoại hiện popup
4. Chạy lệnh:

```bash
flutter run
```

(Flutter sẽ tự chọn thiết bị Android nếu có)

Hoặc chỉ định thiết bị cụ thể:

```bash
flutter run -d <DEVICE_ID>
```

### 🖥 Chạy trên Windows Desktop

```bash
flutter run -d windows
```

> ⚠️ **Lưu ý**: Chạy trên Windows desktop chưa được cấu hình Firebase. Khuyến nghị dùng **Chrome/Edge** hoặc **Android**.

### Chạy chế độ Release (nhanh hơn, không debug)

```bash
flutter run --release -d chrome
```

---

## 👤 6. Tạo tài khoản và đăng nhập

Khi chạy app lần đầu, bạn sẽ thấy **màn hình đăng nhập**.

### Tạo tài khoản mới:

1. Nhấn **"Đăng ký"** ở dưới form đăng nhập
2. Điền thông tin:
   - **Họ và tên**: Tên hiển thị trong nhóm (ví dụ: `Nguyễn Văn A`)
   - **Email**: Email bất kỳ (ví dụ: `a@test.com`)
   - **Mật khẩu**: Tối thiểu 6 ký tự
3. Nhấn **"Đăng ký"**
4. App sẽ tự động đăng nhập và tải dữ liệu mẫu

### Đăng nhập (nếu đã có tài khoản):

1. Nhập **Email** và **Mật khẩu**
2. Nhấn **"Đăng nhập"**

### Tài khoản test có sẵn (nếu đã seed):

> Mỗi tài khoản mới đăng ký sẽ tự động được seed dữ liệu mẫu (3 nhóm, tasks, chat, kanban...) nếu database chưa có dữ liệu.

---

## 🔄 7. Test cộng tác Real-time

Đây là tính năng chính của app — **nhiều người dùng cùng thấy dữ liệu cập nhật tức thì** mà không cần refresh.

### Cách test: Mở 2 trình duyệt cùng lúc

Mở **2 terminal/command prompt** riêng biệt, cùng trỏ đến thư mục project:

**Terminal 1:**
```bash
flutter run -d chrome
```

**Terminal 2:**
```bash
flutter run -d edge
```

> 💡 Cả hai sẽ mở 2 cửa sổ trình duyệt khác nhau chạy cùng app.

### Các bước test:

| Bước | Người A (Chrome) | Người B (Edge) | Kết quả |
|------|---|---|---|
| 1 | Đăng nhập tài khoản A | Đăng nhập tài khoản B | Cả 2 vào app |
| 2 | Vào tab **Chat** → gửi tin nhắn | Quan sát tab **Chat** | 💬 Tin nhắn xuất hiện tức thì |
| 3 | Vào tab **Công việc** → thêm task mới | Quan sát tab **Công việc** | ✅ Task mới hiện ngay |
| 4 | Vào tab **Kanban** → đổi trạng thái card | Quan sát tab **Kanban** | 📋 Card tự chuyển cột |
| 5 | Vào tab **Nhóm** → tạo nhóm mới | Quan sát tab **Dashboard** | 📊 Nhóm mới xuất hiện |

### Cách test giữa 2 máy tính khác nhau:

Vì app sử dụng **Firebase Cloud** (không phải local), hai người ở **hai máy tính khác nhau** hoàn toàn có thể test real-time:

1. **Máy A**: Clone repo → `flutter pub get` → `flutter run -d chrome` → Đăng nhập
2. **Máy B**: Clone repo → `flutter pub get` → `flutter run -d chrome` → Đăng nhập
3. Cả hai thao tác trên cùng nhóm → dữ liệu đồng bộ real-time! 🎉

### Cách test với điện thoại + máy tính:

**Terminal 1** (trên máy tính):
```bash
flutter run -d chrome
```

**Terminal 2** (trên điện thoại Android cắm USB):
```bash
flutter run -d <DEVICE_ID_DIEN_THOAI>
```

---

## 📁 8. Cấu trúc Project

```
lib/
├── main.dart                    # Entry point — khởi tạo Firebase, chạy app
├── firebase_options.dart        # Cấu hình Firebase (tự sinh bởi FlutterFire CLI)
├── models.dart                  # Data models: Task, Message, Group, TeamMember, ...
├── theme.dart                   # Màu sắc, style chung cho toàn app
├── responsive.dart              # Helper xác định mobile/desktop
│
├── services/
│   ├── auth_service.dart        # Đăng nhập, đăng ký, đăng xuất (Firebase Auth)
│   ├── firestore_service.dart   # CRUD real-time với Firestore (watchTasks, watchMessages, ...)
│   └── seed_service.dart        # Import dữ liệu mẫu vào Firestore (chạy 1 lần)
│
├── screens/
│   ├── home_screen.dart         # Màn hình chính — auth gate + navigation
│   ├── dashboard_screen.dart    # Tổng quan: thống kê tasks, tiến độ, nhóm
│   ├── tasks_screen.dart        # Danh sách công việc (dạng bảng)
│   ├── kanban_screen.dart       # Kanban board (Chờ làm → Đang làm → Hoàn thành)
│   ├── groups_screen.dart       # Quản lý nhóm, thành viên, hoạt động
│   ├── timeline_screen.dart     # Timeline hoạt động theo thời gian
│   ├── chat_screen.dart         # Chat nhóm real-time (nhiều kênh)
│   └── account_screen.dart      # Đăng nhập / Trang cá nhân
│
└── widgets/
    ├── sidebar.dart             # Thanh điều hướng bên trái (desktop)
    ├── app_top_bar.dart         # AppBar chung
    ├── dashboard_widgets.dart   # Widgets cho Dashboard
    ├── task_widgets.dart        # Widgets cho Tasks
    ├── kanban_widgets.dart      # Widgets cho Kanban
    ├── chat_widgets.dart        # Widgets cho Chat
    ├── group_widgets.dart       # Widgets cho Groups
    └── timeline_widgets.dart    # Widgets cho Timeline
```

### Cơ chế Real-time:

```
Người dùng thao tác (thêm task, gửi tin nhắn, ...)
    ↓
FirestoreService ghi dữ liệu lên Cloud Firestore
    ↓
Firestore tự động push snapshot tới tất cả listeners
    ↓
StreamBuilder trên UI của MỌI người dùng nhận data mới
    ↓
UI tự rebuild → hiển thị dữ liệu mới nhất (không cần refresh)
```

### Các tính năng chính:

| Tính năng | Mô tả |
|---|---|
| 🔐 **Xác thực** | Đăng nhập / Đăng ký / Quên mật khẩu (Firebase Auth) |
| 📊 **Dashboard** | Thống kê tasks, tiến độ nhóm, tổng quan |
| ✅ **Quản lý Tasks** | Thêm, xem, đánh dấu hoàn thành (real-time) |
| 📋 **Kanban Board** | Kéo thả tasks giữa các cột trạng thái |
| 👥 **Quản lý Nhóm** | Tạo nhóm, thêm thành viên, xem hoạt động |
| 💬 **Chat Real-time** | Nhắn tin nhóm, tạo kênh, đa kênh |
| 📅 **Timeline** | Xem hoạt động theo dòng thời gian |
| 📱 **Responsive** | Giao diện tự điều chỉnh mobile / desktop |

---

## ❗ 9. Xử lý lỗi thường gặp

### Lỗi: `flutter pub get` thất bại

```bash
# Xóa cache và thử lại
flutter clean
flutter pub get
```

### Lỗi: Không tìm thấy thiết bị

```bash
# Kiểm tra danh sách thiết bị
flutter devices

# Nếu không thấy Chrome, đảm bảo đã cài Chrome
# Nếu không thấy Android, kiểm tra USB Debugging đã bật
```

### Lỗi: `Gradle build failed` (Android)

```bash
# Đảm bảo Java 17
java -version

# Nếu sai version, cài JDK 17 và set JAVA_HOME
```

### Lỗi: `PlatformException` khi chạy trên Windows Desktop

> App chưa cấu hình Firebase cho Windows. Hãy chạy trên **Chrome** hoặc **Android** thay thế.

### Lỗi: Không kết nối được Firebase / Timeout

- Kiểm tra kết nối internet
- Firebase project đã được cấu hình sẵn, không cần thêm API key
- Nếu dùng mạng trường/công ty, đảm bảo không bị firewall chặn `*.firebaseio.com` và `*.googleapis.com`

### Lỗi: Dữ liệu trống khi vào app lần đầu

- Đợi vài giây để seed service import dữ liệu mẫu
- Nếu vẫn trống, nhấn nút **"Tải lại"** trên màn hình

### Lỗi: Hot Reload không hoạt động

```bash
# Trong terminal đang chạy flutter run, nhấn:
r    # Hot reload
R    # Hot restart (restart toàn bộ app)
q    # Thoát app
```

---

## 📝 Tóm tắt lệnh cần nhớ

| Lệnh | Mô tả |
|---|---|
| `flutter pub get` | Cài đặt dependencies |
| `flutter devices` | Xem danh sách thiết bị |
| `flutter run -d chrome` | Chạy trên Chrome |
| `flutter run -d edge` | Chạy trên Edge |
| `flutter run` | Chạy trên thiết bị mặc định |
| `flutter clean` | Xóa build cache |
| `flutter doctor` | Kiểm tra môi trường |

---

## 🛠 Tech Stack

| Công nghệ | Phiên bản | Vai trò |
|---|---|---|
| Flutter | 3.38.x | Framework UI đa nền tảng |
| Dart | 3.10.x | Ngôn ngữ lập trình |
| Firebase Auth | 6.4.0 | Xác thực người dùng |
| Cloud Firestore | 6.3.0 | Database real-time |
| Firebase Core | 4.7.0 | Kết nối Firebase |

---

> 📬 Nếu gặp vấn đề, liên hệ nhóm phát triển để được hỗ trợ.
