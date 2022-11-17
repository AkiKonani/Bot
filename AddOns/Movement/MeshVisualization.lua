local RANGE = 50

local function visualizePolygons()
  if not GMR.IsMeshLoaded() then
    GMR.LoadMeshFiles()
  end

  local continentID = select(8, GetInstanceInfo())
  local position = Movement.retrievePlayerPosition()
  local polygon = HWT.GetClosestMeshPolygon(continentID, position.x, position.y, position.z, 1000, 1000, 1000)

  GMR.LibDraw.SetColorRaw(0, 1, 0, 1)
  local continentID = select(8, GetInstanceInfo())
  local position = Movement.retrievePlayerPosition()
  local polygon = HWT.GetClosestMeshPolygon(continentID, position.x, position.y, position.z, 1000, 1000, 1000)

  local polygons = HWT.GetMeshPolygons(continentID, polygon, position.x, position.y, position.z, RANGE)

  Array.forEach(polygons, function(polygon)
    local vertices = HWT.GetMeshPolygonVertices(continentID, polygon)
    local previousPoint = vertices[1]
    for index = 2, #vertices do
      local point = vertices[index]
      GMR.LibDraw.Line(
        previousPoint[1],
        previousPoint[2],
        previousPoint[3],
        point[1],
        point[2],
        point[3]
      )
      previousPoint = point
    end
    GMR.LibDraw.Line(
      previousPoint[1],
      previousPoint[2],
      previousPoint[3],
      vertices[1][1],
      vertices[1][2],
      vertices[1][3]
    )
  end)
end

local function visualizeOffMeshConnections()
  local continentID = select(8, GetInstanceInfo())
  local connections = HWT.GetOffmeshConnections(continentID)
  GMR.LibDraw.SetColorRaw(0, 0, 1, 1)
  local radius = 0.5
  Array.forEach(connections, function(connection)
    local x1, y1, z1, x2, y2, z2 = select(4, HWT.GetOffmeshConnectionDetails(connection))
    local isPoint1InRange = GMR.GetDistanceToPosition(x1, y1, z1) <= RANGE
    local isPoint2InRange = GMR.GetDistanceToPosition(x2, y2, z2) <= RANGE
    if isPoint1InRange or isPoint2InRange then
      GMR.LibDraw.Line(x1, y1, z1, x2, y2, z2)
      if isPoint1InRange then
        GMR.LibDraw.Circle(x1, y1, z1, radius)
      end
      if isPoint2InRange then
        GMR.LibDraw.Circle(x2, y2, z2, radius)
      end
    end
  end)
end

local isMeshVisualizationEnabled = false

doWhenGMRIsFullyLoaded(function()
  hooksecurefunc(GMR.LibDraw, 'clearCanvas', function()
    if isMeshVisualizationEnabled then
      visualizePolygons()
      visualizeOffMeshConnections()
    end
  end)
end)

function toggleMeshVisualization()
  isMeshVisualizationEnabled = not isMeshVisualizationEnabled
end