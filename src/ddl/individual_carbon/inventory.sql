use ${TPCDS_DBNAME};
drop table if exists inventory_text;
create table inventory_text
(
    inv_date_sk               int,
    inv_item_sk               int,
    inv_warehouse_sk          int,
    inv_quantity_on_hand      bigint
)
USING csv
OPTIONS(header "false", delimiter "|", path "${TPCDS_GENDATA_DIR}/inventory.dat")
;
drop table if exists inventory;
create table inventory 
using carbondata
as (select * from inventory_text)
;
drop table if exists inventory_text;
