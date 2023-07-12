REPORT y_get_image .


TYPES:
  tab_content TYPE STANDARD TABLE OF bapiconten,

  BEGIN OF ty_graphic_table,
    line TYPE x LENGTH 255,
  END OF ty_graphic_table,
  tab_graphic_table TYPE TABLE OF ty_graphic_table,

  tab_graphic_names TYPE TABLE OF stxbitmaps-tdname.

DATA:
  bytecount     TYPE i,
  tdbtype       TYPE stxbitmaps-tdbtype,
  content       TYPE tab_content,

  graphic_size  TYPE i,
  graphic_names TYPE tab_graphic_names,

  path          TYPE rlgrap-filename VALUE 'C:\Users\EdmilsonNascimentoJe\OneDrive - GFI\Images\',
  btype         TYPE tdbtype VALUE 'BMON', " Colorida: 'BCOL'
  graphic_table TYPE tab_graphic_names.


graphic_names = VALUE #(
  ( 'ARROW1' )
  ( 'REVENUE QUEBEC' )
).

LOOP AT graphic_names INTO DATA(graphic_name) .

  CLEAR:
    bytecount, content, graphic_size, graphic_table[] .

  CALL FUNCTION 'SAPSCRIPT_GET_GRAPHIC_BDS'
    EXPORTING
      i_object       = 'GRAPHICS'
      i_name         = graphic_name
      i_id           = 'BMAP'
*     i_btype        = 'BCOL'
      i_btype        = btype
    IMPORTING
      e_bytecount    = bytecount
    TABLES
      content        = content
    EXCEPTIONS
      not_found      = 1
      bds_get_failed = 2
      bds_no_content = 3
      OTHERS         = 4.

  CALL FUNCTION 'SAPSCRIPT_CONVERT_BITMAP'
    EXPORTING
      old_format               = 'BDS'
      new_format               = 'BMP'
      bitmap_file_bytecount_in = bytecount
    IMPORTING
      bitmap_file_bytecount    = graphic_size
    TABLES
      bds_bitmap_file          = content
      bitmap_file              = graphic_table
    EXCEPTIONS
      OTHERS                   = 1.

  DATA(field_name) = CONV rlgrap-filename( |{ path }{ graphic_name }.bmp| ) .

  CALL FUNCTION 'WS_DOWNLOAD'
    EXPORTING
      bin_filesize            = graphic_size
      filename                = field_name
      filetype                = 'BIN'
    TABLES
      data_tab                = graphic_table
    EXCEPTIONS
      invalid_filesize        = 1
      invalid_table_width     = 2
      invalid_type            = 3
      no_batch                = 4
      unknown_error           = 5
      gui_refuse_filetransfer = 6.

  IF ( sy-subrc NE 0 ) .
    CONTINUE .
  ENDIF .

  WRITE:/ 'file ', field_name .

ENDLOOP .