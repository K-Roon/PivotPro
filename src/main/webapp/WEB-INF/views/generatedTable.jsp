<!DOCTYPE html>
<html>
<head>
    <title>Generated Pivot Table</title>
</head>
<body>
<h1>Generated Pivot Table</h1>
<%
    // 매개변수 가져오기
    String rowField = request.getParameter("rowField");
    String colField = request.getParameter("colField");
    String aggregator = request.getParameter("aggregator");

    // 피벗 테이블 생성 로직
    if (rowField != null && colField != null && aggregator != null) {
        out.println("<table border='1'>");
        out.println("<thead><tr><th>" + rowField + "</th><th>" + colField + "</th><th>" + aggregator + "</th></tr></thead>");
        out.println("<tbody>");

        // 실제 데이터 로직은 백엔드에서 처리
        for (int i = 0; i < 5; i++) {
            out.println("<tr><td>Row" + i + "</td><td>Col" + i + "</td><td>" + (i * 10) + "</td></tr>");
        }

        out.println("</tbody>");
        out.println("</table>");
    } else {
        out.println("<p>컨트롤을 사용하여 피벗 테이블을 구성해 주세요.</p>");
    }
%>
</body>
</html>
