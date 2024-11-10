<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>피벗 테이블</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        #contextMenu {
            display: none; /* 기본적으로 숨김 */
            position: absolute;
            z-index: 1000;
            background-color: white;
            border: 1px solid #ccc;
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.2);
            padding: 10px;
            border-radius: 5px;
        }
    </style>
</head>
<body>

<a href="javascript:history.back()" class="back-button">뒤로가기</a>

<div class="container">
    <h1>엑셀 데이터</h1>

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

<div id="contextMenu">
    <ul>
        <li onclick="duplicateColumn()">열 복제</li>
        <li onclick="deleteColumn()">열 삭제</li>
    </ul>
</div>

<script>
    let draggedColumnIndex;
    let clickedColumnIndex;
    let excelDataJS = [];
    let headerDataJS = [];

    // 엑셀 데이터를 자바스크립트 배열로 변환
    excelDataJS = [
        <c:forEach var="row" items="${excelData}">
        ["<c:forEach var="cell" items="${row}">${cell}<c:if test="${!status.last}">", "</c:if></c:forEach>"],
        </c:forEach>
    ];
    // 헤더 데이터도 자바스크립트 배열로 변환
    headerDataJS = excelDataJS[0];

    function renderTable() {
        const tableBody = document.getElementById('pivotTableBody');
        const headerRow = document.getElementById('headerRow');

        // 헤더 재렌더링
        headerRow.innerHTML = '';
        headerDataJS.forEach((header, index) => {
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
            excelDataJS[i].forEach((cell, index) => {
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
        event.preventDefault();
        const targetColumnIndex = event.target.cellIndex;
        if (draggedColumnIndex !== targetColumnIndex) {
            shiftColumns(draggedColumnIndex, targetColumnIndex);
        }
    }

    // 열 교체 함수 - 데이터 배열과 헤더 배열 모두 교체한 후 테이블을 재렌더링
    function shiftColumns(fromIndex, toIndex) {
        const element = headerDataJS.splice(fromIndex, 1)[0];
        headerDataJS.splice(toIndex, 0, element);
        for (let i = 0; i < excelDataJS.length; i++) {
            const rowElement = excelDataJS[i].splice(fromIndex, 1)[0];
            excelDataJS[i].splice(toIndex, 0, rowElement);
        }
        renderTable();
    }

    // 우클릭 컨텍스트 메뉴 표시
    function showContextMenu(event) {
        event.preventDefault();
        clickedColumnIndex = event.target.cellIndex;
        const contextMenu = document.getElementById('contextMenu');
        contextMenu.style.display = 'block';
        contextMenu.style.left = `${event.clientX}px`; // 정확한 위치
        contextMenu.style.top = `${event.clientY}px`;
    }

    // 컨텍스트 메뉴 숨기기
    document.addEventListener('click', function(event) {
        const contextMenu = document.getElementById('contextMenu');
        if (!contextMenu.contains(event.target)) {
            contextMenu.style.display = 'none';
        }
    });

    // 열 복제
    function duplicateColumn() {
        headerDataJS.splice(clickedColumnIndex, 0, headerDataJS[clickedColumnIndex]);
        for (let i = 0; i < excelDataJS.length; i++) {
            excelDataJS[i].splice(clickedColumnIndex, 0, excelDataJS[i][clickedColumnIndex]);
        }
        renderTable();
    }

    // 열 삭제
    function deleteColumn() {
        headerDataJS.splice(clickedColumnIndex, 1);
        for (let i = 0; i < excelDataJS.length; i++) {
            excelDataJS[i].splice(clickedColumnIndex, 1);
        }
        renderTable();
    }

    // 테이블 초기 렌더링
    renderTable();
</script>
</body>
</html>
