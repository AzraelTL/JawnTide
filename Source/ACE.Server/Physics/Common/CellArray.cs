using System.Collections.Generic;

namespace ACE.Server.Physics.Common
{
    public class CellArray
    {
        public bool AddedOutside;
        public bool LoadCells;
        public Dictionary<uint, ObjCell> Cells;
        public int NumCells;

        /// <summary>
        /// JawnTide instancing: which copy of the landblock the cells are being looked up in
        /// </summary>
        public int? VariationId;

        public CellArray()
        {
            Cells = new Dictionary<uint, ObjCell>();
        }

        public void SetStatic()
        {
            AddedOutside = false;
            LoadCells = false;
            NumCells = 0;
        }

        public void SetDynamic()
        {
            AddedOutside = false;
            LoadCells = true;
            NumCells = 0;
        }

        public void add_cell(uint cellID, ObjCell cell)
        {
            if (!Cells.ContainsKey(cellID))
            {
                Cells.Add(cellID, cell);
                NumCells++;
            }
        }

        public void remove_cell(ObjCell cell)
        {
            if (Cells.ContainsKey(cell.ID))
            {
                Cells.Remove(cell.ID);
                NumCells--;
            }
        }
    }
}
