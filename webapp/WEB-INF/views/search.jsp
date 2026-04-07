<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- Khai báo URI chuẩn cho Tomcat 10+ (Jakarta EE) --%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html>
<head>
    <title>Tìm kiếm sự kiện</title>
    <style>
        .text-red { color: red; font-weight: bold; }
        .text-orange { color: orange; font-weight: bold; }
        .text-green { color: green; font-weight: bold; }
        .badge-free { background-color: #28a745; color: white; padding: 2px 6px; border-radius: 4px; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>

<%-- 1. HEADER TÌM KIẾM --%>
<%-- BẮT BUỘC dùng c:out cho keyword do người dùng nhập vào để chống XSS --%>
<h2>Kết quả tìm kiếm cho: <c:out value="${keyword}" default=""/></h2>

<c:choose>
    <%-- BẪY SỐ 3: Xử lý danh sách rỗng --%>
    <c:when test="${empty events}">
        <p>Không tìm thấy sự kiện nào phù hợp.</p>
    </c:when>

    <%-- 2. HIỂN THỊ DANH SÁCH (Khi có dữ liệu) --%>
    <c:otherwise>
        <p>Tìm thấy <strong>${fn:length(events)}</strong> sự kiện.</p>

        <table>
            <thead>
            <tr>
                <th>STT</th>
                <th>Tên sự kiện</th>
                <th>Ngày tổ chức</th>
                <th>Giá vé</th>
                <th>Vé còn lại</th>
                <th>Thao tác</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach items="${events}" var="event" varStatus="loop">
                <tr>
                        <%-- STT tự động --%>
                    <td>${loop.count}</td>

                        <%-- Tên sự kiện: BẪY SỐ 2 - Phải dùng c:out đề phòng XSS từ Database --%>
                    <td><c:out value="${event.name}" /></td>

                        <%-- Ngày tổ chức: In trực tiếp vì Controller đã để dạng String --%>
                    <td>${event.date}</td>

                        <%-- Giá vé: Xử lý 2 nhánh --%>
                    <td>
                        <c:choose>
                            <c:when test="${event.price == 0}">
                                <span class="badge-free">MIỄN PHÍ</span>
                            </c:when>
                            <c:otherwise>
                                <fmt:formatNumber value="${event.price}" type="number" groupingUsed="true"/> VNĐ
                            </c:otherwise>
                        </c:choose>
                    </td>

                        <%-- Vé còn lại: Xử lý 3 nhánh --%>
                    <td>
                        <c:choose>
                            <c:when test="${event.remainingTickets == 0}">
                                <span class="text-red">HẾT VÉ</span>
                            </c:when>
                            <c:when test="${event.remainingTickets < 10}">
                                <span class="text-orange">Sắp hết (còn ${event.remainingTickets} vé)</span>
                            </c:when>
                            <c:otherwise>
                                <span class="text-green">${event.remainingTickets}</span>
                            </c:otherwise>
                        </c:choose>
                    </td>

                        <%-- Thao tác: BẪY SỐ 4 - Ẩn/Hiện nút đặt vé dựa trên số lượng --%>
                    <td>
                        <c:choose>
                            <c:when test="${event.remainingTickets == 0}">
                                <button disabled>Đặt vé</button>
                            </c:when>
                            <c:otherwise>
                                <%-- Dùng c:url để tự động xử lý Context Path --%>
                                <a href="<c:url value='/events/${event.id}/book'/>">
                                    <button>Đặt vé</button>
                                </a>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </c:otherwise>
</c:choose>

<hr>
<%-- 3. FOOTER --%>
<%-- BẪY SỐ 6: Guard điều kiện trước khi gọi fn:toUpperCase để tránh NullPointerException khi list rỗng --%>
<c:if test="${not empty events}">
    <p>Sự kiện nổi bật nhất: <strong><c:out value="${fn:toUpperCase(events[0].name)}"/></strong></p>
</c:if>

<p>Số ký tự của từ khóa tìm kiếm: <strong>${fn:length(keyword)}</strong> ký tự.</p>

</body>
</html>