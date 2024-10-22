<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>피벗 테이블</title>
    <link rel="stylesheet" href="style/styles.css">
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid black;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        .drag-handle {
            cursor: move;
        }
    </style>
</head>
<body>
<div class="container">
    <h1>엑셀 데이터</h1>

    <!-- 피벗 테이블 옵션 -->
    <div>
        <label for="rowField">행 필드 선택:</label>
        <select id="rowField">
            <c:forEach var="cell" items="${excelData[0]}">
                <option value="${cell}">${cell}</option>
            </c:forEach>
        </select>

        <label for="columnField">열 필드 선택:</label>
        <select id="columnField">
            <c:forEach var="cell" items="${excelData[0]}">
                <option value="${cell}">${cell}</option>
            </c:forEach>
        </select>

        <label for="summaryFunction">집계 함수:</label>
        <select id="summaryFunction">
            <option value="sum">합계</option>
            <option value="avg">평균</option>
            <option value="count">개수</option>
        </select>

        <button onclick="generatePivotTable()">피벗 테이블 생성</button>
    </div>

    <!-- 피벗 테이블 출력 -->
    <table id="pivotTable">
        <thead>
        <tr>
            <c:forEach var="cell" items="${excelData[0]}"> <!-- 첫 번째 행을 헤더로 사용 -->
                <th>${cell}</th>
            </c:forEach>
        </tr>
        </thead>
        <tbody id="pivotTableBody">
        <c:forEach var="row" items="${excelData}" varStatus="status">
            <tr>
                <c:if test="${!status.first}"> <!-- 첫 번째 행을 제외하고 본문 출력 -->
                    <c:forEach var="cell" items="${row}">
                        <td>${cell}</td>
                    </c:forEach>
                </c:if>
            </tr>
        </c:forEach>
        </tbody>
    </table>

    <a href="/" class="btn">홈으로 돌아가기</a>
</div>

<script>
    // 엑셀 데이터를 자바스크립트 배열로 변환
    const excelData = [
        <c:forEach var="row" items="${excelData}">
        ["<c:forEach var="cell" items="${row}">${cell}<c:if test="${!status.last}">", "</c:if></c:forEach>"],
        </c:forEach>
    ];

    // 최대 셀 개수 구하기 (행마다 셀 개수가 다를 수 있으므로)
    const maxCellCount = Math.max(...excelData.map(row => row.length));

    // 피벗 테이블 생성 함수
    function generatePivotTable() {
        const rowField = document.getElementById("rowField").value;
        const columnField = document.getElementById("columnField").value;
        const summaryFunction = document.getElementById("summaryFunction").value;

        const rowFieldIndex = excelData[0].indexOf(rowField);
        const columnFieldIndex = excelData[0].indexOf(columnField);

        const pivotData = {};

        // 데이터를 그룹화하고 집계 계산
        for (let i = 1; i < excelData.length; i++) {
            const rowValue = excelData[i][rowFieldIndex];
            const columnValue = excelData[i][columnFieldIndex];
            const value = parseFloat(excelData[i][2]); // 요약할 값이 포함된 열 (필요에 맞게 조정)

            if (!pivotData[rowValue]) {
                pivotData[rowValue] = {};
            }

            if (!pivotData[rowValue][columnValue]) {
                pivotData[rowValue][columnValue] = [];
            }

            pivotData[rowValue][columnValue].push(value);
        }

        let pivotTableBody = '';
        for (const row in pivotData) {
            pivotTableBody += '<tr><td>' + row + '</td>';
            for (let i = 0; i < maxCellCount; i++) {  // 모든 행에 최대 셀 개수만큼 출력
                let summaryValue = '';
                if (pivotData[row][i]) {
                    const values = pivotData[row][i];
                    if (summaryFunction === 'sum') {
                        summaryValue = values.reduce((a, b) => a + b, 0);
                    } else if (summaryFunction === 'avg') {
                        summaryValue = values.reduce((a, b) => a + b, 0) / values.length;
                    } else if (summaryFunction === 'count') {
                        summaryValue = values.length;
                    }
                }
                pivotTableBody += '<td>' + (summaryValue || '') + '</td>';
            }
            pivotTableBody += '</tr>';
        }

        document.getElementById('pivotTableBody').innerHTML = pivotTableBody;
    }

    // 테이블 행 드래그 앤 드롭 (추가 가능)
    const table = document.getElementById("pivotTable");
    let dragged;

    table.addEventListener('dragstart', (event) => {
        dragged = event.target;
        event.target.style.opacity = .5;
    });

    table.addEventListener('dragend', (event) => {
        event.target.style.opacity = "";
    });

    table.addEventListener('dragover', (event) => {
        event.preventDefault();
    });

    table.addEventListener('drop', (event) => {
        event.preventDefault();
        if (event.target.tagName === 'TD' || event.target.tagName === 'TH') {
            dragged.parentNode.insertBefore(dragged, event.target.parentNode);
        }
    });
</script>
</body>
</html>
