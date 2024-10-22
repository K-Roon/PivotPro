<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>피벗 테이블</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            background-color: #f5f5f7;
            margin: 0;
            padding: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 2rem;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        h1 {
            text-align: center;
            font-size: 2rem;
            color: #333;
            margin-bottom: 1.5rem;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin: 1.5rem 0;
        }

        th, td {
            border: 1px solid #ddd;
            padding: 12px;
            text-align: center;
            vertical-align: middle;
        }

        th {
            background-color: #f2f2f2;
            cursor: pointer;
        }

        tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        tr:hover {
            background-color: #f1f1f1;
        }

        /* 컨텍스트 메뉴 스타일 */
        #contextMenu {
            display: none;
            position: absolute;
            z-index: 1000;
            background-color: white;
            border: 1px solid #ccc;
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.2);
            padding: 10px;
            border-radius: 5px;
        }

        #contextMenu ul {
            list-style: none;
            margin: 0;
            padding: 0;
        }

        #contextMenu ul li {
            padding: 8px 12px;
            cursor: pointer;
        }

        #contextMenu ul li:hover {
            background-color: #f0f0f0;
        }

        .back-button {
            position: absolute;
            top: 10px;
            left: 10px;
            padding: 10px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
    </style>
</head>
<body>

<!-- 좌측 상단에 뒤로가기 버튼 -->
<a href="javascript:history.back()" class="back-button">뒤로가기</a>

<div class="container">
    <h1>엑셀 데이터</h1>

    <!-- 피벗 테이블 -->
    <table id="pivotTable">
        <thead>
        <tr id="headerRow">
            <c:forEach var="cell" items="${excelData[0]}">
                <th class="draggable-column" draggable="true" ondragstart="drag(event)" ondragover="allowDrop(event)" ondrop="drop(event)" oncontextmenu="showContextMenu(event)">
                        ${cell}
                </th>
            </c:forEach>
        </tr>
        </thead>
        <tbody id="pivotTableBody">
        <c:forEach var="row" items="${excelData}" varStatus="status">
            <tr>
                <c:if test="${!status.first}">
                    <c:forEach var="cell" items="${row}">
                        <td>${cell}</td>
                    </c:forEach>
                </c:if>
            </tr>
        </c:forEach>
        </tbody>
    </table>
</div>

<!-- 우클릭 컨텍스트 메뉴 -->
<div id="contextMenu">
    <ul>
        <li onclick="duplicateColumn()">열 복제</li>
        <li onclick="deleteColumn()">열 삭제</li>
    </ul>
</div>

<script>
    let draggedColumnIndex; // 드래그할 열의 인덱스
    let clickedColumnIndex; // 우클릭한 열의 인덱스
    let originalOrder = []; // 원래의 열 순서를 저장

    // 테이블 상태 추출
    function getTableState() {
        const table = document.getElementById('pivotTable');
        const headers = Array.from(table.rows[0].cells).map(cell => cell.innerHTML);
        const data = Array.from(table.rows).slice(1).map(row => Array.from(row.cells).map(cell => cell.innerHTML));
        return { headers, data };
    }

    // 테이블 상태 업데이트
    function updateTable(headers, data) {
        const table = document.getElementById('pivotTable');
        const headerRow = table.rows[0];
        const bodyRows = Array.from(table.rows).slice(1);

        // 헤더 업데이트
        headers.forEach((header, index) => {
            headerRow.cells[index].innerHTML = header;
        });

        // 본문 업데이트
        data.forEach((row, rowIndex) => {
            row.forEach((cell, cellIndex) => {
                bodyRows[rowIndex].cells[cellIndex].innerHTML = cell;
            });
        });
    }

    // 열 드래그 앤 드롭 (열을 옆으로 밀기)
    function allowDrop(event) {
        event.preventDefault();
    }

    function drag(event) {
        draggedColumnIndex = event.target.cellIndex;
        originalOrder = getTableState(); // 열 이동 전 원래 상태 저장
    }

    function drop(event) {
        event.preventDefault();
        const targetColumnIndex = event.target.cellIndex;
        if (draggedColumnIndex !== targetColumnIndex) {
            const { headers, data } = originalOrder;

            // 드래그한 열을 원래 위치에서 제거하고, 새로운 위치에 삽입
            const draggedHeader = headers.splice(draggedColumnIndex, 1)[0];
            headers.splice(targetColumnIndex, 0, draggedHeader);

            data.forEach(row => {
                const draggedData = row.splice(draggedColumnIndex, 1)[0];
                row.splice(targetColumnIndex, 0, draggedData);
            });

            updateTable(headers, data);
        }
    }

    // 컨텍스트 메뉴 표시
    function showContextMenu(event) {
        event.preventDefault();
        clickedColumnIndex = event.target.cellIndex;

        const contextMenu = document.getElementById('contextMenu');
        contextMenu.style.display = 'block';
        contextMenu.style.left = `${event.pageX}px`;
        contextMenu.style.top = `${event.pageY}px`;

        return false; // 컨텍스트 메뉴 표시 후 기본 동작 막기
    }

    // 컨텍스트 메뉴 숨기기
    document.addEventListener('click', function () {
        document.getElementById('contextMenu').style.display = 'none';
    });

    // 열 복제
    function duplicateColumn() {
        const { headers, data } = getTableState();
        headers.splice(clickedColumnIndex, 0, headers[clickedColumnIndex]);
        data.forEach(row => row.splice(clickedColumnIndex, 0, row[clickedColumnIndex]));
        updateTable(headers, data);
    }

    // 열 삭제
    function deleteColumn() {
        const { headers, data } = getTableState();
        headers.splice(clickedColumnIndex, 1);
        data.forEach(row => row.splice(clickedColumnIndex, 1));
        updateTable(headers, data);
    }
</script>
</body>
</html>
