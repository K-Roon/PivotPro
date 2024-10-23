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
            cursor: pointer;
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
        .draggable-column {
            cursor: move;
        }
        /* 컨텍스트 메뉴 스타일 */
        #contextMenu {
            display: none;
            position: absolute;
            z-index: 1000;
            background-color: white;
            border: 1px solid #ccc;
            box-shadow: 2px 2px 5px rgba(0,0,0,0.2);
            padding: 10px;
            border-radius: 5px;
        }
        #contextMenu ul {
            list-style-type: none;
            padding: 0;
            margin: 0;
        }
        #contextMenu ul li {
            padding: 5px 10px;
            cursor: pointer;
        }
        #contextMenu ul li:hover {
            background-color: #f0f0f0;
        }
    </style>
</head>
<body>

<!-- 좌측 상단에 뒤로가기 버튼 -->
<a href="javascript:history.back()" class="back-button">뒤로가기</a>

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
        <tr id="headerRow">
            <c:forEach var="cell" items="${excelData[0]}">
                <th class="draggable-column" ondragstart="drag(event)" draggable="true" ondrop="drop(event)" ondragover="allowDrop(event)" oncontextmenu="showContextMenu(event)">${cell}</th>
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

<!-- 우클릭 메뉴 -->
<div id="contextMenu">
    <ul>
        <li onclick="duplicateColumn()">열 복제</li>
        <li onclick="deleteColumn()">열 삭제</li>
    </ul>
</div>

<script>
    let draggedColumnIndex; // 드래그할 열의 인덱스
    let clickedColumnIndex; // 우클릭한 열의 인덱스
    let excelDataJS = []; // 엑셀 데이터를 자바스크립트 배열로 변환할 공간
    let headerDataJS = []; // 헤더 데이터를 자바스크립트 배열로 변환

    // 엑셀 데이터를 자바스크립트 배열로 변환
    excelDataJS = [
        <c:forEach var="row" items="${excelData}">
        ["<c:forEach var="cell" items="${row}">${cell}<c:if test="${!status.last}">", "</c:if></c:forEach>"],
        </c:forEach>
    ];

    // 헤더 데이터도 자바스크립트 배열로 변환
    headerDataJS = excelDataJS[0];

    // 테이블 재렌더링 함수
    function renderTable() {
        const tableBody = document.getElementById('pivotTableBody');
        const headerRow = document.getElementById('headerRow');

        // 헤더 재렌더링
        headerRow.innerHTML = '';
        headerDataJS.forEach(header => {
            const th = document.createElement('th');
            th.classList.add('draggable-column');
            th.setAttribute('draggable', 'true');
            th.setAttribute('ondragstart', 'drag(event)');
            th.setAttribute('ondrop', 'drop(event)');
            th.setAttribute('ondragover', 'allowDrop(event)');
            th.setAttribute('oncontextmenu', 'showContextMenu(event)');
            th.innerHTML = header;
            headerRow.appendChild(th);
        });

        // 본문 데이터 재렌더링
        tableBody.innerHTML = ''; // 기존 데이터 삭제

        for (let i = 1; i < excelDataJS.length; i++) { // 첫 번째 행은 헤더이므로 제외
            const row = document.createElement('tr');
            excelDataJS[i].forEach(cell => {
                const td = document.createElement('td');
                td.innerHTML = cell;
                row.appendChild(td);
            });
            tableBody.appendChild(row);
        }
    }

    // 열 드래그 앤 드롭 기능
    function allowDrop(event) {
        event.preventDefault();
    }

    function drag(event) {
        draggedColumnIndex = event.target.cellIndex;
    }

    function drop(event) {
        const targetColumnIndex = event.target.cellIndex;
        if (draggedColumnIndex !== targetColumnIndex) {
            swapColumns(draggedColumnIndex, targetColumnIndex);
        }
    }

    // 열 교체 함수 - 데이터 배열 자체를 교체한 후 테이블을 재렌더링
    function swapColumns(fromIndex, toIndex) {
        // 열 타이틀 교체
        const tempHeader = headerDataJS[fromIndex];
        headerDataJS[fromIndex] = headerDataJS[toIndex];
        headerDataJS[toIndex] = tempHeader;

        // 열 데이터 교체
        for (let i = 0; i < excelDataJS.length; i++) {
            const temp = excelDataJS[i][fromIndex];
            excelDataJS[i][fromIndex] = excelDataJS[i][toIndex];
            excelDataJS[i][toIndex] = temp;
        }
        renderTable(); // 데이터 변경 후 테이블 재렌더링
    }

    // 테이블 정렬 기능
    let sortDirection = true; // true = ascending, false = descending
    function sortTable(event) {
        const columnIndex = event.target.cellIndex;

        excelDataJS = [excelDataJS[0]].concat(
            excelDataJS.slice(1).sort((rowA, rowB) => {
                const cellA = rowA[columnIndex];
                const cellB = rowB[columnIndex];

                const isNumeric = !isNaN(cellA) && !isNaN(cellB);
                const a = isNumeric ? parseFloat(cellA) : cellA.toLowerCase();
                const b = isNumeric ? parseFloat(cellB) : cellB.toLowerCase();

                if (a < b) return sortDirection ? -1 : 1;
                if (a > b) return sortDirection ? 1 : -1;
                return 0;
            })
        );

        sortDirection = !sortDirection;
        renderTable(); // 정렬 후 테이블 재렌더링
    }

    // 우클릭 컨텍스트 메뉴 표시
    function showContextMenu(event) {
        event.preventDefault();
        clickedColumnIndex = event.target.cellIndex;

        const contextMenu = document.getElementById('contextMenu');
        contextMenu.style.display = 'block';
        contextMenu.style.left = `${event.pageX}px`; // 클릭 위치에 맞게 좌표 설정
        contextMenu.style.top = `${event.pageY}px`;
    }

    // 컨텍스트 메뉴 숨기기
    document.addEventListener('click', function() {
        document.getElementById('contextMenu').style.display = 'none';
    });

    // 열 복제
    function duplicateColumn() {
        // 열 타이틀 복제
        headerDataJS.splice(clickedColumnIndex, 0, headerDataJS[clickedColumnIndex]);

        // 데이터 복제
        for (let i = 0; i < excelDataJS.length; i++) {
            excelDataJS[i].splice(clickedColumnIndex, 0, excelDataJS[i][clickedColumnIndex]);
        }
        renderTable(); // 복제 후 테이블 재렌더링
    }

    // 열 삭제
    function deleteColumn() {
        // 열 타이틀 삭제
        headerDataJS.splice(clickedColumnIndex, 1);

        // 데이터 삭제
        for (let i = 0; i < excelDataJS.length; i++) {
            excelDataJS[i].splice(clickedColumnIndex, 1);
        }
        renderTable(); // 삭제 후 테이블 재렌더링
    }

    // 테이블 초기 렌더링
    renderTable();
</script>
</body>
</html>
