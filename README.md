JOGridView
==========

This is a grid view based on the concepts that UITableView set forth to provide.

- A cell is one portion of a grid
- Cells are bare now, need more features to pack it.
- Cells are re-usable
- The grid is defined by rows and columns
- Rows have individually settable heights
- Column widths are limited to the equal distribution amongst all columns in a row
- There is no selection at this moment.
- It automatically purges reusable cells when there is a memory constrain

TODO:
- clean up first before laying out to conserve on memory
- consistent delegate/datasource method signatures
- cellforrowatindexpath in JOGridView (wtf is it really for?)
- reflow cells?
- heightforrowatindexpath doesn't work before cache values are not done right when heightforrow is set dynamically (should cache using assoc storage)