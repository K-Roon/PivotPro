<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>피벗 테이블 컨트롤</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
        }
        div {
            margin-bottom: 20px;
        }
        label {
            margin-right: 10px;
        }
        select, button {
            margin-right: 10px;
        }
    </style>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        $(document).ready(function () {
            // 필드 목록 로드
            $.ajax({
                url: "/api/getFields",
                method: "GET",
                success: function (fields) {
                    fields.forEach(function (field) {
                        $("#rowField").append(new Option(field, field));
                        $("#colField").append(new Option(field, field));
                    });
                },
                error: function () {
                    alert("필드 목록을 가져오는 중 오류가 발생했습니다.");
                }
            });
        });

        function updatePivotTable() {
            const rowField = encodeURIComponent($("#rowField").val());
            const colField = encodeURIComponent($("#colField").val());
            const aggregator = encodeURIComponent($("#aggregator").val());

            if (!rowField || !colField) {
                alert("행 필드와 열 필드를 선택해 주세요.");
                return;
            }

            // iframe의 src를 업데이트하여 generatedTable.jsp에 매개변수를 전달
            $("#pivotIframe").attr("src", `/generatedTable?rowField=${rowField}&colField=${colField}&aggregator=${aggregator}`);
        }
    </script>
</head>
<body>
<h1>피벗 테이블 컨트롤</h1>
<div>
    <label>행 필드:</label>
    <select id="rowField">
        <option value="" disabled selected>선택하세요</option>
    </select>
    <label>열 필드:</label>
    <select id="colField">
        <option value="" disabled selected>선택하세요</option>
    </select>
    <label>집계 방식:</label>
    <select id="aggregator">
        <option value="Sum">합계</option>
        <option value="Count">개수</option>
        <option value="Average">평균</option>
    </select>
    <button onclick="updatePivotTable()">테이블 업데이트</button>
</div>

<h2>피벗 테이블</h2>
<iframe id="pivotIframe" src="<c:url value='/generatedTable'/>" width="100%" height="500" frameborder="0"></iframe>
</body>
</html>
