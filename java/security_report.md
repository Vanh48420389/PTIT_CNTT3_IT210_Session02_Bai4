# Báo cáo bảo mật: Tường lửa dữ liệu View Layer

## 1. Phân tích lỗ hổng XSS và vai trò của `<c:out>`
**XSS (Cross-Site Scripting)** là kỹ thuật tấn công mà hacker chèn các đoạn mã thực thi độc hại (thường là JavaScript) vào các trường nhập liệu của ứng dụng web. Nếu View Layer in thẳng dữ liệu này ra mà không mã hóa, trình duyệt của nạn nhân sẽ tưởng đó là code của hệ thống và chạy nó, dẫn đến việc bị trộm cookie, chiếm quyền phiên làm việc (session hijacking) hoặc chuyển hướng trang web.

**Trường hợp `keyword = <script>alert('xss')</script>`:**
* **Nếu dùng EL thuần (`${keyword}`):** Hệ thống sẽ in nguyên văn chuỗi này vào mã HTML. Trình duyệt sẽ thấy thẻ `<script>`, thực thi nó và hiện lên bảng thông báo (hoặc chạy mã độc ngầm).
* **Vì sao `<c:out value="${keyword}"/>` an toàn:** Thẻ `<c:out>` mặc định có thuộc tính `escapeXml="true"`. Nó tự động mã hóa (escape) các ký tự đặc biệt của HTML (`<`, `>`, `&`, `'`, `"`).
* **Kết quả sinh ra (Output HTML):** Mã độc sẽ bị biến thành `&lt;script&gt;alert('xss')&lt;/script&gt;`. Trình duyệt sẽ chỉ hiểu đây là văn bản (text) thông thường và in ra dòng chữ `<script>alert('xss')</script>` lên màn hình, hoàn toàn vô hại.

## 2. Lựa chọn cấu trúc điều khiển: `<c:if>` vs `<c:choose>`
* **Sự khác biệt:**
    * `<c:if>`: Tương đương với lệnh `if` trong Java, dùng cho các điều kiện đơn lẻ. Nó không hỗ trợ thẻ `else`.
    * `<c:choose> / <c:when> / <c:otherwise>`: Tương đương cấu trúc `if - else if - else` hoặc `switch-case`. Chỉ có MỘT nhánh duy nhất thỏa mãn điều kiện đầu tiên được thực thi.
* **Áp dụng cho "Giá vé" và "Vé còn lại":** Bắt buộc phải dùng **`<c:choose>`**. Lý do là vì các trạng thái này **loại trừ lẫn nhau (mutually exclusive)**.
    * Giá vé: Hoặc là MIỄN PHÍ (khi = 0), hoặc là HIỂN THỊ TIỀN (khi > 0).
    * Vé còn lại: HẾT VÉ (= 0), hoặc SẮP HẾT (< 10), hoặc CÒN NHIỀU (>= 10).
    * Nếu cố chấp dùng `<c:if>`, ta sẽ phải viết các điều kiện phức tạp (VD: `<c:if test="${remaining > 0 && remaining < 10}">`) làm code JSP rối rắm, dài dòng và dễ sai sót logic.

## 3. Tự động hóa định tuyến với `<c:url>`
* **Vấn đề của Hardcode (`href="/events/1/book"`):** Dấu `/` ở đầu đại diện cho thư mục gốc của Server (VD: `http://localhost:8080/`).
* **Hậu quả khi Deploy:** Nếu ứng dụng của công ty không triển khai ở thư mục gốc, mà được đặt trong một Context Path riêng biệt (ví dụ cấu hình Tomcat trỏ vào `/ticketing`), thì link hardcode sẽ dẫn đến `http://localhost:8080/events/1/book` (gây lỗi 404). Đường dẫn đúng phải là `http://localhost:8080/ticketing/events/1/book`.
* **Giải pháp `<c:url>`:** Thẻ này tự động dò tìm Context Path của ứng dụng ở thời điểm chạy (runtime) và gắn nó vào phía trước đường dẫn của bạn. Nhờ vậy, source code mang tính "di động" (portable) cao, deploy lên môi trường nào (dev, test, prod) có context path ra sao thì link vẫn tự động sinh ra chính xác 100%.