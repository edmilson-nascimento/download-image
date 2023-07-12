REPORT /yga/nascimento.


DATA:
  l_bytecount   TYPE i,
  l_tdbtype     LIKE stxbitmaps-tdbtype,
  l_content     TYPE STANDARD TABLE OF bapiconten INITIAL SIZE 0,

  graphic_size  TYPE i,
  graphic_names TYPE TABLE OF stxbitmaps-tdname,

  path          TYPE rlgrap-filename VALUE 'C:\Users\EdmilsonNascimentoJe\OneDrive - GFI\Images\',
  l_btype       TYPE  tdbtype VALUE 'BMON'.

DATA:
  BEGIN OF graphic_table OCCURS 0,
    line TYPE x LENGTH 255,
  END OF graphic_table .


graphic_names = VALUE #(
  ( 'EREDES_DORI_DA_PAULOPEREIRA' )
  ( 'EREDES_DSAT_NUNOCARDOSO' )
  ( 'EREDES_DSAN_AAP_PEDROTRINDADE' )
  ( 'EREDES_DSAN_AAD_ANTONIOMIGUEL' )
  ( 'EREDES_DSAN_AAM_EDITESILVA' )
  ( 'EREDES_DSAS_AAL_NUNOFERREIRA' )
  ( 'EREDES_DSAS_AAT_ANTONIOVAZ' )
  ( 'EREDES_DSAS_AAA_LUISSILVA' )
  ( 'EREDES_DGV_RICARDOMESSIAS' )
  ( 'EREDES_DPD_TAS_SERGIOPINTO' )
).

LOOP AT graphic_names INTO DATA(graphic_name) .

  CLEAR:
    l_bytecount, l_content, graphic_size, graphic_table[] .

  CALL FUNCTION 'SAPSCRIPT_GET_GRAPHIC_BDS'
    EXPORTING
      i_object       = 'GRAPHICS'
*     i_name         = 'RNATU_EREDES'
      i_name         = graphic_name
      i_id           = 'BMAP'
*     i_btype        = 'BCOL'
      i_btype        = l_btype
    IMPORTING
      e_bytecount    = l_bytecount
    TABLES
      content        = l_content
    EXCEPTIONS
      not_found      = 1
      bds_get_failed = 2
      bds_no_content = 3
      OTHERS         = 4.

  CALL FUNCTION 'SAPSCRIPT_CONVERT_BITMAP'
    EXPORTING
      old_format               = 'BDS'
      new_format               = 'BMP'
      bitmap_file_bytecount_in = l_bytecount
    IMPORTING
      bitmap_file_bytecount    = graphic_size
    TABLES
      bds_bitmap_file          = l_content
      bitmap_file              = graphic_table
    EXCEPTIONS
      OTHERS                   = 1.

  DATA(field_name) = CONV rlgrap-filename( |{ path }{ graphic_name }.bmp| ) .

  CALL FUNCTION 'WS_DOWNLOAD'
    EXPORTING
      bin_filesize            = graphic_size
      filename                = field_name
*     filename                = 'C:\FirmaAsociado.bmp'
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

ENDLOOP .