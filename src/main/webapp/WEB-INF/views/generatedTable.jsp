<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>피벗 테이블 결과</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: center;
        }
        th {
            background-color: #f4f4f4;
            font-weight: bold;
        }
        caption {
            font-size: 1.5em;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
<h1>피벗 테이블 결과</h1>
<p><strong>행 필드:</strong> ${rowField}</p>
<p><strong>열 필드:</strong> ${colField}</p>
<p><strong>집계 방식:</strong> ${aggregator}</p>

<c:choose>
    <c:when test="${not empty pivotSummary}">
        <table>
            <caption>요약된 데이터</caption>
            <thead>
            <tr>
                <th>${rowField}</th>
                <th>${colField}</th>
                <th>값</th>
            </tr>
            </thead>
            <tbody>
            <c:forEach var="entry" items="${pivotSummary}">
                <tr>
                    <td>${entry.key}</td>
                    <td>
                        <c:forEach var="colEntry" items="${entry.value}">
                            ${colEntry.key}: ${colEntry.value}<br>
                        </c:forEach>
                    </td>
                    <td>${entry.value}</td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
    </c:when>
    <c:otherwise>
        <p>데이터가 없습니다. 요청을 확인하세요.</p>
    </c:otherwise>
</c:choose>
</body>
</html>
