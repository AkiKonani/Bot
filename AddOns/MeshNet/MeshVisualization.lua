local addOnName, AddOn, exports, imports = ...
local Modules = imports and imports.Modules or _G.Modules
local MeshNet = Modules.determineExportsVariable(addOnName, exports)
local Core, HWT, Array, Draw, Conditionals = Modules.determineImportVariables('Core', 'HWT', 'Array', 'Draw', 'Conditionals', imports)

local _ = {}

local RANGE = 5

local function convertVertexToScreenPoint(vertex)
  return Core.convertWorldPositionToScreenPosition(Core.createPosition(vertex[1], vertex[2], vertex[3]))
end

local function visualizePolygons()
  local position = Core.retrieveCharacterPosition()
  local closestPolygon = Core.retrieveClosestMeshPolygon(position, RANGE, RANGE, RANGE)

  if closestPolygon then
    local polygons = HWT.GetMeshPolygons(position.continentID, closestPolygon, position.x, position.y, position.z, RANGE)

    if polygons then
      do
        local options = {
          color = { 0, 1, 0, 1 },
          fillColor = { 0, 1, 0, 0.2 }
        }
        Array.forEach(polygons, function(polygon)
          if polygon ~= closestPolygon and polygon ~= AddOn.firstOffMeshConnectionPolygon and polygon ~= AddOn.secondOffMeshConnectionPolygon then
            MeshNet.visualizePolygon(polygon, options)
          end
        end)
      end
      do
        if closestPolygon ~= AddOn.firstOffMeshConnectionPolygon and closestPolygon ~= AddOn.secondOffMeshConnectionPolygon then
          local options = {
            color = { 139 / 255, 195 / 255, 74 / 255, 1 },
            fillColor = { 139 / 255, 195 / 255, 74 / 255, 0.2 }
          }
          MeshNet.visualizePolygon(closestPolygon, options)
        end
      end
    end
  end
end

function MeshNet.visualizePolygon(polygon, options)
  options = options or {}

  local continentID = Core.retrieveCurrentContinentID()
  local vertices = HWT.GetMeshPolygonVertices(continentID, polygon)
  if vertices then
    local points = Array.map(vertices, convertVertexToScreenPoint)
    Draw.drawPolygon(points, options.fillColor)

    Draw.SetColorRaw(unpack(options.color))
    local previousPoint = vertices[1]
    for index = 2, #vertices do
      local point = vertices[index]
      Draw.Line(
        previousPoint[1],
        previousPoint[2],
        previousPoint[3],
        point[1],
        point[2],
        point[3]
      )
      previousPoint = point
    end
    Draw.Line(
      previousPoint[1],
      previousPoint[2],
      previousPoint[3],
      vertices[1][1],
      vertices[1][2],
      vertices[1][3]
    )
  end
end

local function setDrawColor(red, green, blue)
  Draw.SetColorRaw(red / 255, green / 255, blue / 255, 1)
end

local function visualizeOffMeshConnections()
  local continentID = select(8, GetInstanceInfo())
  local connections = HWT.GetOffmeshConnections(continentID)

  if connections and Array.hasElements(connections) then
    local radius = 0.5

    local function drawConnection(connection)
      local x1, y1, z1, x2, y2, z2 = select(4, HWT.GetOffmeshConnectionDetails(connection))
      local isPoint1InRange = Core.calculateDistanceFromCharacterToPosition(Core.createPosition(x1, y1, z1)) <= RANGE
      local isPoint2InRange = Core.calculateDistanceFromCharacterToPosition(Core.createPosition(x2, y2, z2)) <= RANGE
      if isPoint1InRange or isPoint2InRange then
        Draw.Line(x1, y1, z1, x2, y2, z2)
        if isPoint1InRange then
          Draw.Circle(x1, y1, z1, radius)
        end
        if isPoint2InRange then
          Draw.Circle(x2, y2, z2, radius)
        end
      end
    end

    local closestConnection = AddOn.findClosestOffMeshConnection()

    Draw.SetColorRaw(0, 0, 1, 1)
    Array.forEach(connections, function(connection)
      if connection ~= closestConnection then
        drawConnection(connection)
      end
    end)

    if closestConnection then
      setDrawColor(156, 156, 255)
      drawConnection(closestConnection)
    end
  end
end

local isMeshVisualizationEnabled = false

Draw.Sync(function()
  if isMeshVisualizationEnabled then
    visualizePolygons()
    visualizeOffMeshConnections()
  end
end)

function MeshNet.toggleMeshVisualization()
  local isEnablingMeshVisualization = not isMeshVisualizationEnabled

  if isEnablingMeshVisualization then
    local continentID = Core.retrieveCurrentContinentID()
    if not HWT.IsMapLoaded(continentID) then
      HWT.LoadMap(continentID)
      Conditionals.doOnceWhen(
        function()
          return HWT.IsMapLoaded(continentID)
        end,
        function ()
          _.toggleMeshVisualization2()
        end
      )
    else
      _.toggleMeshVisualization2()
    end
  else
    _.toggleMeshVisualization2()
  end
end

function _.toggleMeshVisualization2()
  isMeshVisualizationEnabled = not isMeshVisualizationEnabled
end