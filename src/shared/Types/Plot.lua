local PlotTypes = {};

export type Plot = Model & {
    Tiles: Folder,
    Structures: Folder,
    Debris: Folder,
};

export type Tile = BasePart;

return PlotTypes;
