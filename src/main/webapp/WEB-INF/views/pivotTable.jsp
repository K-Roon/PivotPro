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

    excelDataJS = [
        <c:forEach var="row" items="${excelData}">
        ["<c:forEach var="cell" items="${row}">${cell}<c:if test="${!status.last}">", "</c:if></c:forEach>"],
        </c:forEach>
    ];
    headerDataJS = excelDataJS[0];

    function renderTable() {
        const tableBody = document.getElementById('pivotTableBody');
        const headerRow = document.getElementById('headerRow');
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

        tableBody.innerHTML = '';
        for (let i = 1; i < excelDataJS.length; i++) {
            const row = document.createElement('tr');
            excelDataJS[i].forEach((cell, index) => {
                const td = document.createElement('td');
                td.innerHTML = cell;
                row.appendChild(td);
            });
            tableBody.appendChild(row);
        }
    }

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

    function shiftColumns(fromIndex, toIndex) {
        const element = headerDataJS.splice(fromIndex, 1)[0];
        headerDataJS.splice(toIndex, 0, element);

        for (let i = 0; i < excelDataJS.length; i++) {
            const rowElement = excelDataJS[i].splice(fromIndex, 1)[0];
            excelDataJS[i].splice(toIndex, 0, rowElement);
        }
        renderTable();
    }

    function showContextMenu(event) {
        event.preventDefault();
        clickedColumnIndex = event.target.cellIndex;
        const contextMenu = document.getElementById('contextMenu');
        contextMenu.style.display = 'block';
        contextMenu.style.left = `${event.pageX}px`;
        contextMenu.style.top = `${event.pageY}px`;
    }

    document.addEventListener('click', function(event) {
        const contextMenu = document.getElementById('contextMenu');
        if (!contextMenu.contains(event.target)) {
            contextMenu.style.display = 'none';
        }
    });

    function duplicateColumn() {
        headerDataJS.splice(clickedColumnIndex, 0, headerDataJS[clickedColumnIndex]);
        for (let i = 0; i < excelDataJS.length; i++) {
            excelDataJS[i].splice(clickedColumnIndex, 0, excelDataJS[i][clickedColumnIndex]);
        }
        renderTable();
    }

    function deleteColumn() {
        headerDataJS.splice(clickedColumnIndex, 1);
        for (let i = 0; i < excelDataJS.length; i++) {
            excelDataJS[i].splice(clickedColumnIndex, 1);
        }
        renderTable();
    }

    renderTable();
</script>
</body>
</html>
