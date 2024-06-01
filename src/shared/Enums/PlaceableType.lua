--[[

    For now, there are 4 types of Placeables:
    - Factory
    - Residence
    - Commercial
    - Road

    Each type of Placeable has a different set of properties, such as:
    - Factory: Production rate, production capacity, production cost, production time
    - Residence: Population, population capacity, population growth rate, population growth time
    - Commercial: Revenue, revenue capacity, revenue growth rate, revenue growth time
    - Road: Cost, speed, capacity

--]]

return {
    EMPTY = { 
        name = "Empty",
        isBuilding = false,
        properties = {}
    },

    RESIDENTIAL = {
        name = "Residential",
        isBuilding = true,
        properties = {
            population = 0,
            populationCapacity = 0,
            populationGrowthRate = 0,
            populationGrowthTime = 0
        }
    },

    COMMERCIAL = {
        name = "Commercial",
        isBuilding = true,
        properties = {
            revenue = 0,
            revenueCapacity = 0,
            revenueGrowthRate = 0,
            revenueGrowthTime = 0
        }
    },

    INDUSTRIAL = {
        name = "Industrial",
        isBuilding = true,
        properties = {
            production = 0,
            productionCapacity = 0,
            productionCost = 0,
            productionTime = 0
        }
    },

    ROAD = {
        name = "Road",
        isBuilding = false,
        properties = {
            cost = 0,
            speed = 0,
            capacity = 0
        }
    }
}