# Phân quyền Task theo vai trò (Admin / Thành viên)
## các acc có sẵn:
 c@gmail.com - mật khẩu:Duy123!
 d@gmail.com - mật khẩu như trên
 e@gmail.com - mật khẩu như trên
## Mục tiêu
- **Admin (nhóm trưởng)**: được thêm / sửa / xóa task trên màn hình Task.
- **Thành viên thường**: chỉ được đổi trạng thái task **được giao cho mình** trên Kanban. Không được chạm vào task của người khác.

## Cách xác định Admin

Đã có sẵn trong data:
- `Group.createdBy` = Firebase Auth UID của người tạo nhóm.
- `TeamMember.role` = `'Admin'` cho người tạo nhóm.

→ Chỉ cần so sánh `FirebaseAuth.instance.currentUser!.uid == group.createdBy` là biết user hiện tại có phải admin không.

## Cách xác định "task của tôi"

- Mỗi task có trường `assignee` lưu **initials** (VD: `"AN"`).
- Lấy initials của user hiện tại (đã có sẵn logic `_currentUserInitials` trong `tasks_screen.dart`).
- So sánh `task.assignee == currentUserInitials` → task của tôi.

---

## Proposed Changes

### Màn hình Task — [tasks_screen.dart](file:///e:/DAIHOC/ltdd/lib/screens/tasks_screen.dart)

#### Thay đổi 1: Ẩn nút "＋ Thêm task" nếu không phải admin
- Kiểm tra `currentUser.uid == widget.selectedGroup.createdBy`.
- Nếu **không phải admin** → `AppTopBar` không truyền `actionLabel` / `onAction` → nút biến mất.

#### Thay đổi 2: Ẩn nút sửa/xóa trên mỗi task item nếu không phải admin
- Truyền thêm `bool isAdmin` vào `_TaskItem`.
- Nếu `isAdmin == false` → ẩn cột icon edit/delete.

> [!NOTE]
> Thành viên thường vẫn **nhìn thấy** danh sách task nhưng không có nút thao tác (không thêm, sửa, xóa). Nút toggle (check ✓) cũng sẽ bị ẩn với thành viên thường để đảm bảo chỉ admin mới thay đổi task.

---

### Màn hình Kanban — [kanban_screen.dart](file:///e:/DAIHOC/ltdd/lib/screens/kanban_screen.dart) & [kanban_widgets.dart](file:///e:/DAIHOC/ltdd/lib/widgets/kanban_widgets.dart)

#### Thay đổi 3: Chỉ cho đổi trạng thái task được giao cho mình
- Trong `KanbanScreen`: tính `currentUserInitials` giống logic trong `tasks_screen.dart`.
- Truyền `currentUserInitials` xuống `KanbanColumn` → `KanbanCard`.
- Trong `KanbanCard`: nếu `task.assignee != currentUserInitials` → ẩn `PopupMenuButton` (nút swap trạng thái).

> [!IMPORTANT]
> Admin **cũng** chỉ được đổi trạng thái task của mình trong Kanban (theo yêu cầu: "các thành viên chỉ được tác động đến công việc mà mình được giao"). Nếu bạn muốn admin được đổi tất cả task trong Kanban, hãy cho tôi biết.

---

## Tóm tắt file cần sửa

| File | Thay đổi |
|---|---|
| [tasks_screen.dart](file:///e:/DAIHOC/ltdd/lib/screens/tasks_screen.dart) | Ẩn nút thêm/sửa/xóa/toggle nếu không phải admin |
| [kanban_screen.dart](file:///e:/DAIHOC/ltdd/lib/screens/kanban_screen.dart) | Tính `currentUserInitials`, truyền xuống widget |
| [kanban_widgets.dart](file:///e:/DAIHOC/ltdd/lib/widgets/kanban_widgets.dart) | Ẩn nút đổi trạng thái nếu task không phải của user |

**Không cần thay đổi model, service, hay cấu trúc Firestore.** Tất cả đều là thay đổi UI thuần.

---

## Verification Plan

### Automated Tests
- Chạy `flutter build apk --debug` để verify build thành công.

### Manual Verification
- Đăng nhập bằng tài khoản **admin** (người tạo nhóm) → thấy đủ nút thêm/sửa/xóa task.
- Đăng nhập bằng tài khoản **thành viên** → không thấy nút thêm/sửa/xóa.
- Trong Kanban, mỗi user chỉ thấy nút đổi trạng thái trên task được giao cho mình.
