<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Pivot Table Control</title>
    <script>
        function updatePivotTable() {
            const rowField = document.getElementById("rowField").value;
            const colField = document.getElementById("colField").value;
            const aggregator = document.getElementById("aggregator").value;

            // iframe의 src를 업데이트하여 generatedTable.jsp에 매개변수를 전달
            const iframe = document.getElementById("pivotIframe");
            iframe.src = `/generatedTable?rowField=${rowField}&colField=${colField}&aggregator=${aggregator}`;
        }
    </script>
</head>
<body>
<h1>Pivot Table Control</h1>
<div>
    <label>Row Field:</label>
    <input type="text" id="rowField" placeholder="Enter row field name">
    <label>Column Field:</label>
    <input type="text" id="colField" placeholder="Enter column field name">
    <label>Aggregator:</label>
    <select id="aggregator">
        <option value="Sum">Sum</option>
        <option value="Count">Count</option>
        <option value="Average">Average</option>
    </select>
    <button onclick="updatePivotTable()">Update Table</button>
</div>

<h2>Pivot Table</h2>
<iframe id="pivotIframe" src="<c:url value="/generatedTable"/>" width="100%" height="500" frameborder="0"></iframe>
</body>
</html>
